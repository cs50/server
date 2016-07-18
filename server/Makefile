default: run

build:
	docker build -t cs50/server .

rebuild:
	docker build --no-cache -t cs50/server .

run:
	docker run -i --name server50 -p 80:80 --rm -v "$(PWD)"/:/root -t cs50/server
	#docker run -i --name server50 --rm -v "$(PWD)"/:/root -t cs50/server

shell:
	#docker run -i --name server50 -p 80:80 --rm -v "$(PWD)"/:/home/ubuntu/workspace -t cs50/server
	docker exec -it server50 bash
