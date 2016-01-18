default: build

pull:
	docker login
	docker pull cs50/php:apache

build:
	docker build -t cs50/php:apache .

rebuild:
	docker build --no-cache -t cs50/php:apache .

run: build
	docker run -i -p 80:80 -t cs50/php:apache

bash: build
	docker run -i -p 80:80 -t cs50/php:apache bash
