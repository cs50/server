default: build

pull:
	docker login
	docker pull cs50/php

build:
	docker build -t cs50/php .
