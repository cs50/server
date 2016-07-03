default: run

build:
	docker build --pull -t cs50/python:django .

rebuild:
	docker build --no-cache -t cs50/python:django .

run: build
	docker run -i --name python_django -p 80:80 --rm -t cs50/python:django

shell:
	docker exec -it python_django bash
