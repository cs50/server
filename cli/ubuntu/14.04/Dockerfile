FROM ubuntu:14.04

# packages
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        clang \
        curl \
        gdb \
        git \
        man \
        openjdk-7-jdk \
        openjdk-7-jre-headless \
        perl \
        php5-cli \
        php5-curl \
        php5-gmp \
        php5-intl \
        php5-mcrypt \
        python \
        python3 \
        python-dev \
        python-pip \
        ruby \
        ruby-dev \
        vim \
        wget

# composer
RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
ONBUILD RUN composer self-update

# environment
COPY ./etc/profile.d/cs50.sh /etc/profile.d/
COPY ./etc/vim/vimrc.local /etc/vim/

# TEMPORARY FOR asciidoc50 UNTIL MOVED INTO DEB
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
