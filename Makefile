.PHONY: default
default: run

build:
	docker build --build-arg VCS_REF="$(shell git rev-parse HEAD)" --tag cs50/server .
	$(MAKE) squash

depends:
	pip3 install docker-squash

rebuild:
	docker build --build-arg VCS_REF="$(shell git rev-parse HEAD)" --no-cache --tag cs50/server .
	$(MAKE) squash

run:
	docker run --interactive --publush-all --rm --security-opt seccomp=unconfined --tty --volume "$(PWD)"/examples:/var/www --tag cs50/server bash --login

squash: depends
	docker images cs50/server
	docker-squash --tag cs50/server cs50/server
	docker images cs50/server
