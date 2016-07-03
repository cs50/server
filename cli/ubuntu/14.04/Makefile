default: build run

build:
	docker build --pull -t cs50/cli:latest .
	docker build --pull -t cs50/cli:ubuntu .

rebuild:
	docker build --no-cache --pull -t cs50/cli:ubuntu .

run:
	docker run -i --rm -v `pwd`/:/root -t cs50/cli:ubuntu
