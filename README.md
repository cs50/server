# TODO

* Tidy `/opt/cs50/server50/etc/nginx/mime.types`.
* Tidy `/opt/cs50/server50/etc/nginx/fastcgi_params`.
* Combine `/etc/opt/cs50/server50/nginx.conf` and /var/opt/cs50/server50/default` and store in `/var/opt/cs50/server50/nginx.conf` (to parallel `/var/opt/cs50/server50/gunicorn.conf`).
* Add `pip install requirements.txt`.
* Ensure `composer install` works.
* Finish support for `gunicorn` and Python:
    * http://flask.pocoo.org/docs/0.11/deploying/wsgi-standalone/#gunicorn
    * http://stackoverflow.com/questions/16857955/running-django-with-gunicorn-best-practice
    * http://docs.gunicorn.org/en/stable/run.html
    * https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu-14-04
    * https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-gunicorn-and-nginx-on-ubuntu-14-04
