# Usage

|File|Inferred application type
|----|-------------------------
|`app.js`|Node.js or Meteor JS in bundled/packaged mode
|`config.ru`|Ruby, Ruby on Rails
|`.meteor`|Meteor JS in non-bundled/packaged mode
|`passenger_wsgi.py`|Python
|`*`|HTML, PHP

# Configuration

Any [Passenger Standalone option](https://www.phusionpassenger.com/library/config/standalone/reference/) can be set as
an environment variable named `PASSENGER_<OPTION>`, e.g. `PASSENGER_MAX_POOL_SIZE=12`. Open-source Passenger serves
Python and Ruby apps one request per process, so `max_pool_size` (default 6) is the number of requests an instance
handles at once; raise it as far as the instance's memory allows.

## Requests that never finish

Open-source Passenger has no request time limit, so a request stuck in an outbound call (a GitHub outage, say) holds
its process until the server is restarted; once every process is stuck, Passenger answers "This website is under heavy
load (queue full)" even after the remote service has recovered. The image defends against that in three layers:

|Variable|Default|Effect
|--------|-------|------
|`CS50_CONNECT_TIMEOUT`|`5`|Seconds Python's `requests` (and so Authlib, lib50), `http.client` (`urllib`) and `smtplib` (Flask-Mail) wait for a TCP connection when the app passed no timeout. An explicit timeout in app code, including `timeout=None`, is left alone.
|`CS50_READ_TIMEOUT`|`30`|Seconds the same libraries wait for a response. `CS50_DEFAULT_TIMEOUT=0` disables both defaults.
|`CS50_MAX_REQUEST_TIME`|`120`|Seconds one request may run before `passenger-watchdog` kills its process (SIGABRT, which makes Passenger's Python loader log every thread's stack first; SIGKILL 10s later if needed). Passenger spawns a replacement and the stuck request gets a 502. Only processes that serve one request at a time are considered, so a Node.js app holding a WebSocket is unaffected. Set it above the slowest request the app legitimately serves, or `0` to disable.

`ssh` as a client (git over `ssh://`) gets `ConnectTimeout`, `ServerAlive*` and `ChannelTimeout` from
`/etc/ssh/ssh_config.d/cs50-timeouts.conf`. Calls these layers do not reach, `subprocess` and Kubernetes clients among
them, still need a timeout in the app.

# References

* Nginx
  * [Alphabetical index of directives](http://nginx.org/en/docs/dirindex.html)
* Passenger
  * [Configuration reference](https://www.phusionpassenger.com/library/config/standalone/reference/)
