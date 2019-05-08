
image_version := $(shell sh compute_version.sh)


image_name := admin.reproducible.online/frontend:$(strip $(astrooda_version))

update:
	# because no to submodules
	git clone git@gitlab.astro.unige.ch:cdci/frontend/drupal7-for-astrooda.git || true
	(cd drupal7-for-astrooda; git pull)
	git clone git@gitlab.astro.unige.ch:cdci/frontend/bootstrap_astrooda.git drupal7-for-astrooda/sites/all/themes/bootstrap_astrooda || true
	(cd drupal7-for-astrooda/sites/all/themes/bootstrap_astrooda; git pull)
	git clone git@gitlab.astro.unige.ch:cdci/frontend/astrooda.git drupal7-for-astrooda/sites/all/modules/astrooda || true
	(cd drupal7-for-astrooda/sites/all/modules/astrooda; git pull)
#	git clone git@gitlab.astro.unige.ch:cdci/frontend/drupal7-db-for-astrooda.git drupal7-db-for-astrooda || true
#	(cd drupal7-db-for-astrooda; git pull)

build:
	docker build -t $(image_name) .

push: build
	docker push $(image_name)  


pull:
	git submodule foreach  --recursive git pull origin staging-1.2
