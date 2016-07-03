FROM ubuntu:14.04

# working directory
RUN rm -rf /usr/src/app/*
WORKDIR /usr/src/app

# port
EXPOSE 80

# dev
RUN apt-get update && \
    apt-get install -y mysql-client telnet vim
COPY ./etc/vimrc /etc/vimrc
COPY ./etc/profile.d/cs50.sh /etc/profile.d/

# python
RUN apt-get update && \
    apt-get install -y python-setuptools

# supervisor
RUN apt-get update && \
    apt-get install -y supervisor
COPY ./etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# app
ONBUILD COPY . /usr/src/app/
ONBUILD RUN pip install

# start container
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
