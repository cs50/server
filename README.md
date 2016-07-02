# CS50 Docker Images

* `cs50/cli`, `cs50/cli:ubuntu` ([_Dockerfile_](https://github.com/cs50/docker/blob/master/cli/ubuntu/14.04/Dockerfile))
* `cs50/php:apache` ([_Dockerfile_](https://github.com/cs50/docker/blob/master/php/apache/Dockerfile))
* `cs50/php:nginx` ([_Dockerfile_](https://github.com/cs50/docker/blob/master/php/nginx/Dockerfile))

# Building

Be sure [Docker Engine](https://docs.docker.com/engine/installation/) is installed.

    cd cli/ubuntu/14.04
    make build

    cd php/apache
    make build

    cd php/nginx
    make build
