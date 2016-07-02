default: run

build:
	docker build --pull -t cs50/php:apache .

rebuild:
	docker build --no-cache -t cs50/php:apache .

run: build
	docker run -i --name php_apache -p 80:80 --rm -t cs50/php:apache

shell:
	docker exec -it php_apache bash
