"""
Default timeouts for outbound network calls made by Python apps on cs50/server.

Passenger (open source) serves a Python app one request per process and has no request time
limit (max_request_time is Enterprise only), so an outbound call that never returns pins a
process for good. Once every process is pinned, Passenger serves "This website is under heavy
load (queue full)" until it is restarted, even after the remote service has recovered, because
a half-open TCP connection never receives a FIN or RST. Libraries apps commonly rely on
(Authlib, lib50, Flask-Mail, urllib) issue their calls with no timeout, so give those calls one
here, once, for every app built on this image.

Python imports this module at interpreter start-up (it lives in site-packages). It patches
nothing until the client library in question is imported, so plain `python3` and `pip` are
unaffected, and an app that never imports `requests` never pays for loading it.

What is bounded, and how:
  - requests (and so Authlib, lib50, and anything else built on it): requests.adapters
    .HTTPAdapter.send receives timeout=(connect, read) whenever the caller passed none.
    requests turns a missing timeout into an explicit None on the socket, so
    socket.setdefaulttimeout() would not work here; the adapter is the one place every call
    passes through, and a timeout the caller does set is left alone.
  - http.client (and so urllib.request): HTTPConnection gets a connect-and-read timeout when
    the caller passed none.
  - smtplib (and so Flask-Mail): SMTP and SMTP_SSL get the same.

What is deliberately NOT done: socket.setdefaulttimeout(). Passenger's own wsgi-loader
accepts each request inside the app process over a Unix socket; a process-wide default would
put that socket into timeout mode and abort any request whose client drains the response
slowly. Only outbound client libraries are touched.

Configuration (environment variables, read when each library is first imported):
  CS50_CONNECT_TIMEOUT   seconds to wait for a TCP connection (default 5). A healthy service
                         connects well under a second; a connect still pending after a few
                         seconds is an outage, and waiting longer only holds the process.
  CS50_READ_TIMEOUT      seconds to wait for a response, or between bytes of one (default 30)
  CS50_DEFAULT_TIMEOUT   set to 0 to disable every default here (explicit timeouts in app
                         code are unaffected either way)
"""

import importlib.abc
import importlib.machinery
import os
import socket
import sys

_PATCHES = {}


def _timeouts():
    """(connect, read) in seconds from the environment, or None when disabled."""
    if os.environ.get("CS50_DEFAULT_TIMEOUT", "").strip() == "0":
        return None
    try:
        connect = float(os.environ.get("CS50_CONNECT_TIMEOUT", 5))
        read = float(os.environ.get("CS50_READ_TIMEOUT", 30))
    except ValueError:
        connect, read = 5.0, 30.0
    return connect, read


def _patch_requests(module):
    adapters = module  # requests.adapters
    original = adapters.HTTPAdapter.send
    if getattr(original, "_cs50_default_timeout", False):
        return

    def send(self, request, timeout=None, **kwargs):
        if timeout is None:
            timeout = _timeouts()
        return original(self, request, timeout=timeout, **kwargs)

    send._cs50_default_timeout = True
    send.__wrapped__ = original
    send.__doc__ = original.__doc__
    adapters.HTTPAdapter.send = send


def _patch_init_timeout(cls, position):
    """
    Wrap cls.__init__ so an unset `timeout` becomes the configured one. These stdlib classes
    take a single timeout that covers both connecting and each read, so pass the read value.

    "Unset" means absent, or the socket._GLOBAL_DEFAULT_TIMEOUT sentinel: subclasses pass the
    sentinel positionally to the parent (HTTPSConnection -> HTTPConnection, SMTP_SSL -> SMTP)
    and urllib.request passes it by keyword. An explicit timeout=None (block forever) is a
    deliberate choice and is left alone. `position` is the 0-based index of `timeout` among
    the positional parameters after self.
    """
    original = cls.__init__
    if getattr(original, "_cs50_default_timeout", False):
        return

    def __init__(self, *args, **kwargs):
        timeouts = _timeouts()
        if timeouts is not None:
            unset = socket._GLOBAL_DEFAULT_TIMEOUT
            if len(args) > position:
                if args[position] is unset:
                    args = (*args[:position], timeouts[1], *args[position + 1:])
            elif kwargs.get("timeout", unset) is unset:
                kwargs["timeout"] = timeouts[1]
        original(self, *args, **kwargs)

    __init__._cs50_default_timeout = True
    __init__.__wrapped__ = original
    __init__.__doc__ = original.__doc__
    cls.__init__ = __init__


def _patch_http_client(module):
    # HTTPConnection(host, port=None, timeout=..., ...); HTTPSConnection.__init__ chains to it
    _patch_init_timeout(module.HTTPConnection, 2)


def _patch_smtplib(module):
    # SMTP(host='', port=0, local_hostname=None, timeout=..., ...); SMTP_SSL.__init__ chains to it
    _patch_init_timeout(module.SMTP, 3)


_PATCHES["requests.adapters"] = _patch_requests
_PATCHES["http.client"] = _patch_http_client
_PATCHES["smtplib"] = _patch_smtplib


class _PatchOnImport(importlib.abc.MetaPathFinder, importlib.abc.Loader):
    """Runs the matching patch right after one of the modules above finishes importing."""

    def find_spec(self, fullname, path, target=None):
        if fullname not in _PATCHES:
            return None
        # Let the ordinary finders locate the module, then take over only its exec step
        for finder in sys.meta_path:
            if finder is self or not hasattr(finder, "find_spec"):
                continue
            spec = finder.find_spec(fullname, path, target)
            if spec is not None:
                spec.loader = _Loader(spec.loader)
                return spec
        return None


class _Loader(importlib.abc.Loader):
    def __init__(self, loader):
        self._loader = loader

    def create_module(self, spec):
        return self._loader.create_module(spec)

    def exec_module(self, module):
        self._loader.exec_module(module)
        try:
            _PATCHES[module.__name__](module)
        except Exception as e:  # never let a hardening step break the import itself
            sys.stderr.write(f"cs50/server sitecustomize: could not set default timeout for {module.__name__}: {e}\n")


def _install():
    if _timeouts() is None:
        return
    sys.meta_path.insert(0, _PatchOnImport())
    # A module imported before this hook was installed gets patched directly
    for name, patch in _PATCHES.items():
        if name in sys.modules:
            patch(sys.modules[name])


_install()
