FROM cs50/cli

# port
EXPOSE 8080

# override CS50 CLI's MOTD
COPY ./motd /etc/

# TEMP until in repo
# install server50
COPY ./server50_1.0.0_amd64.deb /tmp
RUN apt-get update && (dpkg -i /tmp/server50_1.0.0_amd64.deb || true) && apt-get install -f -y
RUN rm -f /tmp/server50_1.0.0_amd64.deb

#COPY . /home/ubuntu/workspace
#COPY . /root

#RUN chown -R www-data:www-data /srv/www
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
#CMD ["/usr/local/bin/server50"]
