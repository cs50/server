default: run

build:
	docker build -t cs50/server:ubuntu .

rebuild:
	docker build --no-cache -t cs50/server:ubuntu .

run:
	docker run -i --name server -p 8080:8080 --rm -v "$(PWD)"/examples:/var/www -t cs50/server:ubuntu bash -l

shell:
	docker exec -it server bash -l
