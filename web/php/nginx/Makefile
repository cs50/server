default: run

build:
	docker build --pull -t cs50/php:nginx .

rebuild:
	docker build --no-cache -t cs50/php:nginx .

run: build
	docker run -i --name php_nginx -p 80:80 --rm -t cs50/php:nginx

shell:
	docker exec -it php_nginx bash
