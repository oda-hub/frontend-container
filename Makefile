run: build
	docker run -p 8083:80 --link mysql:mysql --name frontend frontend


build:
	docker build -t frontend .

db:
	mysql --protocol TCP -h 127.0.0.1 -P 3307  -u root --password=`cat mysql-password | xargs` < astrooda.sql
	mysql --protocol TCP -h 127.0.0.1 -P 3307  -u root --password=`cat mysql-password | xargs` < astrooda-user.sql
