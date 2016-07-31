default: run

build:
	cp -f ../server50/server50_1.0.0_amd64.deb .
	docker build -t cs50/server .

rebuild:
	docker build --no-cache -t cs50/server .

run:
	docker run -i --name server50 -p 8080:8080 --rm -v "$(PWD)"/apps:/root -t cs50/server

shell:
	docker exec -it server50 bash -l
