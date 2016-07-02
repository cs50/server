# CS50 Docker Images

* `cs50/cli`, `cs50/cli:ubuntu` ([_Dockerfile_](https://github.com/cs50/docker/blob/master/cli/ubuntu/14.04/Dockerfile))
* `cs50/php:apache`, Ubuntu + PHP-FPM + Apache
* `cs50/php:nginx`, Ubuntu + PHP-FPM + nginx

# Building

1. Install [Docker Toolbox](https://www.docker.com/products/docker-toolbox).
1. Launch **Docker QuickStart Terminal**.
1. Execute `cd /path/to/docker`.
1. TODO

# Troubleshooting

## Error checking TLS connection: Error checking and/or regenerating the certs

    docker-machine regenerate-certs default

If something still seems awry with Docker, odds are the below will help. **The below will delete and recreate the virtual machine used by Docker.**

    docker-machine stop default
    docker-machine rm default
    docker-machine create --driver virtualbox default
    eval $(docker-machine env default)
