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

# TEMPORARY FOR asciidoc50 UNTIL MOVED INTO DEB
# apt-get
RUN apt-get update && \
    apt-get install \
        curl \
        wget
# gem
RUN gem install \
    asciidoctor \
    coderay \
    thread_safe \
    tilt
COPY ./asciidoc50 /opt/asciidoc50
RUN chmod a+x /opt/asciidoc50/bin/asciidoc50
ENV PATH "$PATH:/opt/asciidoc50/bin"

# working directory
WORKDIR /root

# entrypoint
ENTRYPOINT ["bash", "-l"]
