run:
	docker run -it -P --rm -v "$(PWD)"/examples:/var/www -t cs50/server:focal bash -l

build:
	docker build -t cs50/server:focal .

rebuild:
	docker build --no-cache -t cs50/server:focal .
