default: run

build:
	docker build -t cs50/server .

rebuild:
	docker build --no-cache -t cs50/server .

run:
	#docker run -i --name server50 --rm -v "$(PWD)"/bin:/opt/server50/bin -v "$(PWD)"/etc:/etc/server50 -t cs50/server
	docker run -i --name server50 -p 80:80 --rm -v "$(PWD)"/opt/server50:/opt/server50 -t cs50/server

shell:
	#docker run -i --name server50 -p 80:80 --rm -t cs50/server
	docker exec -it server50 bash
