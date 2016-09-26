FROM cs50/cli

# working directory
WORKDIR /srv/www

# default port (to match Cloud9)
EXPOSE 8080

# TEMP until in repo
# install server50
COPY ./server50_1.0.0_amd64.deb /tmp
RUN apt-get update && (dpkg -i /tmp/server50_1.0.0_amd64.deb || true) && apt-get install -f -y
RUN rm -f /tmp/server50_1.0.0_amd64.deb

# override MOTD
RUN echo "This is CS50 Server." > /etc/motd

# install app in working directory
ONBUILD COPY . /srv/www

#RUN chown -R www-data:www-data /srv/www
CMD ["passenger", "start"]
