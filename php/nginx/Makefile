default: build

pull:
	docker login
	docker pull cs50/php:nginx

build:
	docker build -t cs50/php:nginx .

rebuild:
	docker build --no-cache -t cs50/php:nginx .

run: build
	docker run -i -p 80:80 -t cs50/php:nginx

bash: build
	docker run -i -p 80:80 -t cs50/php:nginx bash
