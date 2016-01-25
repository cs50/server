default: run

pull:
	docker login
	docker pull cs50/php:nginx

build:
	docker build -t cs50/php:nginx .

rebuild:
	docker build --no-cache -t cs50/php:nginx .

run: build
	docker run -i --name php_nginx -p 80:80 --rm -t cs50/php:nginx

bash:
	docker exec -it php_nginx bash
