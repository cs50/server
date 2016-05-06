FROM ubuntu:14.04.2

# packages
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        clang-3.6 \
        gdb \
        git \
        man \
        openjdk-7-jdk \
        openjdk-7-jre-headless \
        php5-cli \
        php5-curl \
        php5-gmp \
        php5-intl \
        php5-mcrypt \
        ruby-dev \
        vim

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# https://bugs.launchpad.net/ubuntu/+source/llvm-toolchain-3.6/+bug/1566240
RUN ln -s /usr/bin/clang-3.6 /usr/bin/clang
RUN ln -s /usr/bin/clang-3.6 /usr/bin/clang++

# environment
COPY ./etc/profile.d/cs50.sh /etc/profile.d/
COPY ./etc/vimrc /etc/vimrc

# working directory
WORKDIR /root

# entrypoint
ENTRYPOINT ["bash", "-l"]
