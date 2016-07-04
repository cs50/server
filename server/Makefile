default: run

build:
	docker build --pull -t cs50/server .

rebuild:
	docker build --no-cache -t cs50/server .

run: build
	docker run -i --name server50 -p 80:80 --rm -t cs50/server

shell:
	docker exec -it server50 bash
