"""Validate cs50_rds_guard against two real MySQL servers.

Run inside cs50/server with the module installed (see tests/rds_guard.sh). Expects:
  MYSQL_BLUE  hostname of the server that will be made read-only (the old primary)
  MYSQL_GREEN hostname of the writer (the new primary)
Both share the same root password (MYSQL_PASSWORD) and have a database "t".
"""

import os
import sys

import sqlalchemy
from sqlalchemy import create_engine, event, text

PASSWORD = os.environ["MYSQL_PASSWORD"]
BLUE = os.environ["MYSQL_BLUE"]
GREEN = os.environ["MYSQL_GREEN"]
failures = []


def check(name, condition, detail=""):
    print(("PASS  " if condition else "FAIL  ") + name + (f"  ({detail})" if detail else ""))
    if not condition:
        failures.append(name)


def url(host, **query):
    return sqlalchemy.engine.URL.create("mysql", "root", PASSWORD, host, 3306, "t", query=query or None)


def set_read_only(host, value):
    with create_engine(url(host), execution_options={"allow_read_only": True}).connect() as c:
        c.execute(text(f"SET GLOBAL read_only = {int(value)}"))
        c.execute(text(f"SET GLOBAL super_read_only = {int(value)}"))


class FlippingResolver:
    """Simulate the RDS CNAME flip: every *new* connection goes to whatever `target` is now,
    while connections already in the pool stay where they were opened (as in production,
    where DNS is only consulted when the pool opens a connection)."""

    def __init__(self):
        self.target = BLUE

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        pass

    def engine(self, **kwargs):
        import MySQLdb

        def creator():
            return MySQLdb.connect(host=self.target, user="root", passwd=PASSWORD, db="t")

        return create_engine("mysql://", creator=creator, **kwargs)


def connected_server_of(conn):
    return conn.execute(text("SELECT @@hostname")).scalar()


# 0. The guard registered itself purely because sqlalchemy was imported (via .pth + import hook)
import cs50_rds_guard  # noqa: E402

check("guard auto-registered on import of sqlalchemy", cs50_rds_guard._registered)
check("import hook removed itself after firing", not any(type(f).__name__ == "_SQLAlchemyImportHook" for f in sys.meta_path))

set_read_only(BLUE, False)
set_read_only(GREEN, False)
blue_hostname = create_engine(url(BLUE), execution_options={"allow_read_only": True}).connect().execute(text("SELECT @@hostname")).scalar()
green_hostname = create_engine(url(GREEN), execution_options={"allow_read_only": True}).connect().execute(text("SELECT @@hostname")).scalar()
check("test servers are distinct", blue_hostname != green_hostname, f"{blue_hostname} vs {green_hostname}")

with FlippingResolver() as dns:
    # 1. The incident: the app has a pooled connection to blue; blue becomes read-only; DNS now says green.
    engine = dns.engine(pool_size=2, max_overflow=0)
    with engine.connect() as conn:
        check("before switchover: pooled connection is on blue", connected_server_of(conn) == blue_hostname)
        conn.execute(text("CREATE TABLE IF NOT EXISTS t.probe (id INT)"))
        conn.commit()
    set_read_only(BLUE, True)
    dns.target = GREEN

    with engine.connect() as conn:
        server = connected_server_of(conn)
        check("after switchover: checkout transparently moved to the writer", server == green_hostname, f"on {server}")
        conn.execute(text("CREATE TABLE IF NOT EXISTS t.probe (id INT)"))
        conn.execute(text("INSERT INTO t.probe VALUES (1)"))
        conn.commit()
        check("after switchover: writes succeed with no error surfaced to the app", True)

    # 2. The guard also acts as a pre-ping: a server-side killed connection is replaced silently
    with engine.connect() as conn:
        conn_id = conn.execute(text("SELECT CONNECTION_ID()")).scalar()
    with create_engine(url(GREEN), execution_options={"allow_read_only": True}).connect() as killer:
        killer.execute(text(f"KILL {conn_id}"))
    with engine.connect() as conn:
        check("dead pooled connection replaced silently (pre-ping behaviour)", conn.execute(text("SELECT 1")).scalar() == 1)
    engine.dispose()

    # 3. handle_error path: a 1290 that slips past the checkout (server flips read-only mid-request)
    set_read_only(BLUE, False)
    dns.target = BLUE
    engine = dns.engine(pool_size=1, max_overflow=0)
    with engine.connect() as conn:
        connected_server_of(conn)  # passes the checkout guard while writable
        set_read_only(BLUE, True)
        try:
            conn.execute(text("INSERT INTO t.probe VALUES (2)"))
            check("1290 mid-request raises", False)
        except sqlalchemy.exc.OperationalError as e:
            check("1290 mid-request raises", e.orig.args[0] == 1290)
            check("1290 is treated as a disconnect (connection_invalidated)", e.connection_invalidated)
    dns.target = GREEN
    with engine.connect() as conn:
        check("next checkout after 1290 lands on the writer", connected_server_of(conn) == green_hostname)
    engine.dispose()

    # 4. Overrides
    set_read_only(BLUE, True)
    dns.target = BLUE
    strict = dns.engine(pool_size=1, max_overflow=0)
    try:
        strict.connect()
        check("strict engine refuses a permanently read-only server", False)
    except sqlalchemy.exc.InvalidRequestError as e:
        check("strict engine refuses a permanently read-only server", "read-only after 3 attempts" in str(e))
    strict.dispose()

    relaxed = dns.engine(execution_options={"allow_read_only": True})
    with relaxed.connect() as conn:
        check("per-engine override: execution_options allow_read_only lets it connect", connected_server_of(conn) == blue_hostname)
    relaxed.dispose()

    # 5. Non-MySQL dialects are untouched
    sqlite = create_engine("sqlite://")
    with sqlite.connect() as conn:
        check("sqlite engine unaffected", conn.execute(text("SELECT 1")).scalar() == 1)

    set_read_only(BLUE, False)

print()
print("ALL PASSED" if not failures else f"{len(failures)} FAILED: {failures}")
sys.exit(1 if failures else 0)
