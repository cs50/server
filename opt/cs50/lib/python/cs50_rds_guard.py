"""Make every SQLAlchemy engine in this image resilient to RDS blue/green switchovers.

After a switchover, the old primary stays up but read-only. A connection opened during DNS
propagation can point at it indefinitely, failing every write with MySQL error 1290 ("The MySQL
server is running with the --read-only option"), because the connection is alive and so the pool
never replaces it. This module treats a read-only MySQL server as an unexpected condition:

* engine_connect: before handing a connection to the application, check @@global.read_only. If
  the server is read-only (or the connection is dead), discard the connection and retry with a
  fresh one, so the application never sees the error.
* handle_error: if error 1290 is raised anyway, treat it as a disconnect, which makes SQLAlchemy
  invalidate that connection and every other connection in the pool opened before it.

Applied to all engines whose dialect is "mysql" (mysqlclient, PyMySQL, mysql-connector); other
dialects (e.g., SQLite in tests) are untouched.

To opt out for an engine that intentionally talks to a read-only database (e.g., a read replica):

    create_engine(url, execution_options={"allow_read_only": True})
    # or, with Flask-SQLAlchemy:
    SQLALCHEMY_ENGINE_OPTIONS = {"execution_options": {"allow_read_only": True}}

To opt out for an entire process, set the environment variable CS50_ALLOW_READ_ONLY_DB=1.

Installed via a .pth file so that it applies to every Python process in the image, but it only
imports SQLAlchemy (and registers its listeners) once the process itself imports SQLAlchemy.
"""

import importlib.abc
import os
import sys

__all__ = ["ALLOW_READ_ONLY_OPTION", "ENV_VAR", "install", "register"]

ALLOW_READ_ONLY_OPTION = "allow_read_only"
ENV_VAR = "CS50_ALLOW_READ_ONLY_DB"
ER_OPTION_PREVENTS_STATEMENT = 1290  # MySQL: server is running with --read-only
MAX_ATTEMPTS = 3

_registered = False


def _process_opted_out():
    return os.environ.get(ENV_VAR, "").strip().lower() in ("1", "true", "yes")


def _engine_opted_out(engine):
    return engine.dialect.name != "mysql" or bool(
        engine.get_execution_options().get(ALLOW_READ_ONLY_OPTION)
    )


def register():
    """Register the listeners on sqlalchemy.engine.Engine (idempotent)."""
    global _registered
    if _registered or _process_opted_out():
        return
    _registered = True

    import logging

    from sqlalchemy import event, exc
    from sqlalchemy.engine import Engine

    logger = logging.getLogger(__name__)

    @event.listens_for(Engine, "engine_connect")
    def ensure_writable(conn):
        if _engine_opted_out(conn.engine):
            return
        for attempt in range(1, MAX_ATTEMPTS + 1):
            dbapi_connection = conn.connection.dbapi_connection  # reconnects if invalidated
            try:
                cursor = dbapi_connection.cursor()
                try:
                    cursor.execute("SELECT @@global.read_only")
                    (read_only,) = cursor.fetchone()
                finally:
                    cursor.close()
            except Exception as e:  # dead connection; replace it too
                logger.warning("discarding dead MySQL connection (attempt %d/%d): %s", attempt, MAX_ATTEMPTS, e)
                conn.invalidate(e)
                continue
            if not read_only:
                return
            logger.warning(
                "discarding connection to read-only MySQL server %s (attempt %d/%d); "
                "expected the writer. Was there a failover or blue/green switchover?",
                conn.engine.url.render_as_string(hide_password=True), attempt, MAX_ATTEMPTS,
            )
            conn.invalidate()
        raise exc.InvalidRequestError(
            f"cs50_rds_guard: MySQL server {conn.engine.url.render_as_string(hide_password=True)} is "
            f"read-only after {MAX_ATTEMPTS} attempts; expected the writer. If this engine should talk to a "
            f"read-only database, set execution_options={{{ALLOW_READ_ONLY_OPTION!r}: True}} or {ENV_VAR}=1."
        )

    @event.listens_for(Engine, "handle_error")
    def read_only_is_disconnect(ctx):
        if ctx.engine is None or _engine_opted_out(ctx.engine):
            return
        if ctx.execution_context is not None and ctx.execution_context.execution_options.get(ALLOW_READ_ONLY_OPTION):
            return
        args = getattr(ctx.original_exception, "args", ())
        if args and args[0] == ER_OPTION_PREVENTS_STATEMENT:
            logger.warning(
                "MySQL error 1290 (read-only) from %s; invalidating pooled connections so the next request "
                "reconnects to the writer", ctx.engine.url.render_as_string(hide_password=True),
            )
            ctx.is_disconnect = True
            ctx.invalidate_pool_on_disconnect = True


class _SQLAlchemyImportHook(importlib.abc.MetaPathFinder):
    """One-shot finder that calls register() right after the sqlalchemy package is imported."""

    def find_spec(self, fullname, path, target=None):
        if fullname != "sqlalchemy":
            return None
        for finder in sys.meta_path:
            if finder is self or not hasattr(finder, "find_spec"):
                continue
            spec = finder.find_spec(fullname, path, target)
            if spec is not None:
                break
        else:
            return None
        loader, hook = spec.loader, self

        class Loader(importlib.abc.Loader):
            def create_module(self, spec):
                return loader.create_module(spec)

            def exec_module(self, module):
                loader.exec_module(module)
                if hook in sys.meta_path:
                    sys.meta_path.remove(hook)
                register()

        spec.loader = Loader()
        return spec


def install():
    """Entry point used by the .pth file: register now if SQLAlchemy is already imported, else lazily."""
    if _process_opted_out():
        return
    if "sqlalchemy" in sys.modules:
        register()
    elif not any(isinstance(f, _SQLAlchemyImportHook) for f in sys.meta_path):
        sys.meta_path.insert(0, _SQLAlchemyImportHook())


install()
