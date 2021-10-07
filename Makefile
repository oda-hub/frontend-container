
image_version := $(shell bash make.sh compute-version)


image_name := odahub/frontend:$(shell bash make.sh compute-version)

push: build
	docker push $(image_name)  

build: 
	docker build -t $(image_name) .

update:
	# because no to submodules
	bash make.sh clone_all $(VERSION)


#		--net host 
run: build
	docker rm -f oda-frontend || true
	docker run \
		-v $(shell realpath private/drupal7_sites_default_settings.php):/var/www/astrooda/sites/default/settings.php \
		-p 8090:80 \
		-p 8093:443 \
		--name oda-frontend \
		--net oda-net \
		-d \
		--rm \
			$(image_name)

local-mysql:
	docker rm -f oda-mysql || true
	docker run --net oda-net --rm -d --name oda-mysql -e MYSQL_ROOT_PASSWORD=$(ODA_DB_ROOT_PASSWORD) mysql:5

local-net:
	docker network create oda-net

local-db:
	cat ../drupal7-db-for-astrooda/drupal7-db-for-astrooda.sql | docker exec -i oda-mysql mysql astrooda --password=$(ODA_DB_ROOT_PASSWORD)

local-db-user:
	cat ../private/astrooda-user.sql | docker exec -i oda-mysql mysql astrooda --password=$(ODA_DB_ROOT_PASSWORD)

local-drupal-admin:
	docker exec oda-frontend bash -c 'cd /var/www/astrooda; ~/.composer/vendor/bin/drush upwd --password="'$(cat private/drupal-admin)'" sitamin'

local-drush-cc:
	docker exec oda-frontend bash -c 'cd /var/www/astrooda; ~/.composer/vendor/bin/drush cc all'
