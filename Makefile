default: run

build:
	docker build -t cs50/server .

rebuild:
	docker build --no-cache -t cs50/server .

run:
	#docker run -i --name server50 --rm -v "$(PWD)"/bin:/opt/cs50/server50/bin -v "$(PWD)"/etc:/etc/server50 -t cs50/server
	docker run -i --name server50 -p 8080:8080 --rm -v "$(PWD)"/opt/cs50/server50:/opt/cs50/server50 -v "$(PWD)"/apps:/srv/www -t cs50/server

shell:
	#docker run -i --name server50 -p 8080:8080 --rm -t cs50/server
	docker exec -it server50 bash
