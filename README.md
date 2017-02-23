# Usage

|File|Inferred application type
|----|-------------------------
|`app.js`|Node.js or Meteor JS in bundled/packaged mode
|`config.ru`|Ruby, Ruby on Rails
|`.meteor`|Meteor JS in non-bundled/packaged mode
|`passenger_wsgi.py`|Python
|`*`|HTML, PHP

# Customization

* `http.conf`
* `server.conf`

# References

* Nginx
  * [Alphabetical index of directives](http://nginx.org/en/docs/dirindex.html)
* Passenger
  * [Configuration reference](https://www.phusionpassenger.com/library/config/standalone/reference/)

# To Document

* `http.conf`, `server.conf`
* https://www.phusionpassenger.com/library/config/standalone/reference/#--startup-file-startup_file
* PHP
* APPLICATION_ENV
* `tmp/always_restart.txt` in `app_dir`
* add sample app
* `public`, `--static-files-dir`, https://www.phusionpassenger.com/library/config/standalone/reference/#--static-files-dir-static_files_dir
* HTTPS behind load-balancer
* `docker-compose.override.yml`
