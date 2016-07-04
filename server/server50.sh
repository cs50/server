#!/bin/bash

docker run -i --name server50 -p 80:80 --rm -v "$(PWD)"/:/home/ubuntu/workspace -t cs50/server
