default: build run

pull:
	docker login
	docker pull cs50/cli:ubuntu

build:
	docker build -t cs50/cli:ubuntu .

rebuild:
	docker build --no-cache -t cs50/cli .

run:
	docker run -i --rm -v `pwd`/:/root -t cs50/cli:ubuntu
