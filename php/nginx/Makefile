default: run

build:
	docker build --pull -t cs50/php:nginx .

rebuild:
	docker build --no-cache -t cs50/php:nginx .

up: build
	docker-compose up &

shell:
	docker exec -it php_nginx bash
