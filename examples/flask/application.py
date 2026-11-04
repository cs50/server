import time

from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "hello, world"

@app.route("/hang")
def hang():
    """Never returns, like a request stuck in an outbound call; tests/smoke.sh uses it to exercise passenger-watchdog."""
    time.sleep(10**6)
    return "unreachable"
