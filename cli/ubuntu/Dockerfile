FROM ubuntu:16.04

# packages
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        clang \
        composer \
        gdb \
        git \
        man \
        openjdk-8-jdk \
        openjdk-8-jre-headless \
        php-cli \
        php-curl \
        php-gmp \
        php-intl \
        php-mcrypt \
        ruby-dev \
        vim

# environment
COPY ./etc/profile.d/cs50.sh /etc/profile.d/
COPY ./etc/vim/vimrc.local /etc/vim/

# working directory
WORKDIR /root

# entrypoint
ENTRYPOINT ["bash", "-l"]
