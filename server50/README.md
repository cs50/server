# TODO

* Determine if handling `gunicorn`'s PID properly.
* Decide how to handle `static` dir for Python.
* Decide how to handle other `*.conf` files.
* Decide how to handle other PHP `index.php` usage.
* Determine how to specify path to python app (hardcoded in `/usr/local/bin/gunicorn` at the moment).
* Decide whether to foreground `supervisord` (for dev and prod and C9).
* Move `cli` and `server` to own repos.
* Add to `.ebextensions`, a la `render50-server`:
```
    # TODO: migrate to .ebextensions, a la https://github.com/cs50/render50-server/blob/master/.ebextensions/nginx.config
    #set_by_lua $application_env 'return os.getenv("APPLICATION_ENV")';
    #if ($application_env != 'dev') {
    #    set $test '1';
    #}
    #if ($http_x_forwarded_proto != 'https') {
    #    set $test '${test}1';
    #}
    #if ($http_user_agent !~ '^ELB-HealthChecker/') {
    #    set $test '${test}1';
    #}
    #if ($test = '111') {
    #    rewrite ^ https://$host$request_uri? permanent;
    #}
```

# References

* https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-gunicorn-and-nginx-on-ubuntu-14-04
* https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu-14-04
* https://w3techs.com/technologies/cross/web_server/ranking
