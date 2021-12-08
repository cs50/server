default: run

build:
	docker build --build-arg VCS_REF="$(shell git rev-parse HEAD)" -t cs50/server .

run:
	docker run -it -P --rm --security-opt seccomp=unconfined -v "$(PWD)"/examples:/var/www -t cs50/server bash -l
