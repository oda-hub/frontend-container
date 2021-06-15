
image_version := $(shell bash make.sh compute-version)


image_name := odahub/frontend:$(shell bash make.sh compute-version)

push: build
	docker push $(image_name)  

build: 
	docker build -t $(image_name) .

update:
	# because no to submodules
	bash make.sh clone_all_latest


run: build
	docker run \
		--net host \
		-v $(shell realpath ../private/drupal7_sites_default_settings.php):/var/www/astrooda/sites/default/settings.php \
		-p 8020:80 \
			$(image_name)
