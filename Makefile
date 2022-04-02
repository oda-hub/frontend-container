
push: build
	docker push odahub/frontend:$(shell bash make.sh compute-version)

build: #update 
	
	docker build -t odahub/frontend:$(shell bash make.sh compute-version) .

update:
	# because no to submodules
	bash make.sh clone_all_latest


#		--net host 
run: build
	docker rm -f oda-frontend || true
	docker run \
		-v $(shell realpath private/drupal7_sites_default_settings.php):/var/www/mmoda/sites/default/settings.php \
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
	cat ../mmoda-frontend-db/mmoda.sql | docker exec -i oda-mysql mysql mmoda --password=$(ODA_DB_ROOT_PASSWORD)

local-db-user:
	cat ../private/mmoda-user.sql | docker exec -i oda-mysql mysql mmoda --password=$(ODA_DB_ROOT_PASSWORD)

local-drupal-admin:
	docker exec oda-frontend bash -c 'cd /var/www/mmoda; ~/.composer/vendor/bin/drush upwd --password="'$(shell cat private/drupal-admin)'" admin'

local-drush-cc:
	docker exec oda-frontend bash -c 'cd /var/www/mmoda; ~/.composer/vendor/bin/drush cc all'
