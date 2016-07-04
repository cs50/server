default: run

build:
	docker build --pull -t cs50/server .

rebuild:
	docker build --no-cache -t cs50/server .

run:
	docker run -i --name server50 -p 80:80 --rm -v "$(PWD)"/:/home/ubuntu/workspace -t cs50/server
