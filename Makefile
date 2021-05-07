
image_version := $(shell bash compute_version.sh)


image_name := odahub/frontend:$(shell git describe --always)

build:
	docker build -t $(image_name) .

update:
	# because no to submodules
	git clone git@gitlab.astro.unige.ch:cdci/frontend/drupal7-for-astrooda.git || true
	(cd drupal7-for-astrooda; git pull origin staging-1.3)
	git clone git@gitlab.astro.unige.ch:cdci/frontend/bootstrap_astrooda.git drupal7-for-astrooda/sites/all/themes/bootstrap_astrooda || true
	(cd drupal7-for-astrooda/sites/all/themes/bootstrap_astrooda; git pull origin staging-1.3)
	git clone git@gitlab.astro.unige.ch:cdci/frontend/astrooda.git drupal7-for-astrooda/sites/all/modules/astrooda || true
	(cd drupal7-for-astrooda/sites/all/modules/astrooda; git pull staging-1.3)
#	git clone git@gitlab.astro.unige.ch:cdci/frontend/drupal7-db-for-astrooda.git drupal7-db-for-astrooda || true
#	(cd drupal7-db-for-astrooda; git pull)


push: build
	docker push $(image_name)  


pull:
	git submodule foreach  --recursive git pull origin staging-1.2

run: build
	docker run -p 8000:80 $(image_name)
