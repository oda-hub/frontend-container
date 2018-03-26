run: build
	docker run -p 8083:80 --link mysql:mysql --name frontend frontend


build:
	docker build -t frontend .

db:
	mysql -h 127.0.0.1 -P 3306  -u root --password=`cat mysql-password | xargs` < astrooda_drupal7_db_20180323.sql
