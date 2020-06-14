FROM cs50/server
EXPOSE 8080

COPY ./requirements.txt /tmp
RUN pip3 install -r /tmp/requirements.txt && rm -f /tmp/requirements.txt
