default: build

pull:
	docker login
	docker pull cs50/php

build:
	docker build -t cs50/php .

run: build
	docker run -i -p 80:80 -t cs50/php

bash: build
	docker run -i -p 80:80 -t cs50/php bash
