#!/bin/bash

docker run -i --name server50 --rm -v "$(PWD)"/:/root -t cs50/server
