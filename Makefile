default: run

build:
	docker build -t cs50/server .

rebuild:
	docker build --no-cache -t cs50/server .

run:
	docker run -i --name server50 -p 8080:8080 --rm -v "$(PWD)"/examples:/srv/www -t cs50/server bash -l

shell:
	docker exec -it server bash -l
