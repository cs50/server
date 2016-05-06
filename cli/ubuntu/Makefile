default: build run

build:
	docker build -t cs50/cli:ubuntu .

rebuild:
	docker build --no-cache -t cs50/cli:ubuntu .

run:
	docker run -i --rm -v `pwd`/:/root -t cs50/cli:ubuntu
