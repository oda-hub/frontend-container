build:
	docker build -t frontend .

run: build
	docker run -p 8083:80 --link mysql:mysql --name frontend frontend

