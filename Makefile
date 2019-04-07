image_version := $(shell git branch | awk '{print $$2}')-at-$(shell git describe --abbrev=8 --always --tags)

image_name := admin.reproducible.online/frontend:$(strip $(image_version))

update:
	git clone git@gitlab.astro.unige.ch:cdci/frontend/drupal7-for-astrooda.git || true
	(cd drupal7-for-astrooda; git pull)
	git clone git@gitlab.astro.unige.ch:cdci/frontend/bootstrap_astrooda.git drupal7-for-astrooda/sites/all/themes/bootstrap_astrooda || true
	(cd drupal7-for-astrooda/sites/all/themes/bootstrap_astrooda; git pull)
	git clone git@gitlab.astro.unige.ch:cdci/frontend/astrooda.git drupal7-for-astrooda/sites/all/modules/astrooda || true
	(cd sites/all/modules/astrooda; git pull)
#	git clone git@gitlab.astro.unige.ch:cdci/frontend/drupal7-db-for-astrooda.git drupal7-db-for-astrooda || true
#	(cd drupal7-db-for-astrooda; git pull)

build:
	docker build -t $(image_name) .

push: build
	docker push $(image_name)  


pull:
	git submodule foreach  --recursive git pull origin staging-1.2
