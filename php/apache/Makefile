default: run

pull:
	docker login
	docker pull cs50/php:apache

build:
	docker build -t cs50/php:apache .

rebuild:
	docker build --no-cache -t cs50/php:apache .

run: build
	docker run -i --name php_apache -p 80:80 --rm -t cs50/php:apache

bash:
	docker exec -it php_apache bash
