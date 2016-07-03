# Troubleshooting

## Elastic Beanstalk

### No EXPOSE directive found in Dockerfile, abort deployment

Because `/opt/elasticbeanstalk/hooks/appdeploy/enact/00run.sh` on the EC2 host used by EB has

    # verify Dockerfile
    # currently we require Dockerfile to expose exactly one port

    EB_CONFIG_DOCKER_PORT=`cat $EB_CONFIG_APP_CURRENT/Dockerfile | grep -i ^EXPOSE | awk '{print $2}' | sed $'s/\r//'`

    if [ -z "$EB_CONFIG_DOCKER_PORT" ]; then
            error_exit "No EXPOSE directive found in Dockerfile, abort deployment" 1
    fi

    if [ `echo $EB_CONFIG_DOCKER_PORT | wc -w` -gt 1 ]; then
            EB_CONFIG_DOCKER_PORT=`echo $EB_CONFIG_DOCKER_PORT | awk '{print $1}'`
            warn "Only one EXPOSE directive is allowed, using the first one: $EB_CONFIG_DOCKER_PORT"
    fi

any Dockerfile that inherits from `cs50/php` must explicitly expose a port, as via

    EXPOSE 80

even though `cs50/php` already exposes as much.
