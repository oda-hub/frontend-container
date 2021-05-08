
image_version := $(shell bash compute_version.sh)


image_name := odahub/frontend:$(shell git describe --always)

build:
	docker build -t $(image_name) .

update:
	# because no to submodules
	bash make.sh clone_all_latest


push: build
	docker push $(image_name)  


pull:
	git submodule foreach  --recursive git pull origin staging-1.2

run: build
	docker run -p 8000:80 $(image_name)
