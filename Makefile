image_version := $(shell git branch | awk '{print $$2}')-at-$(shell git describe --abbrev=8 --always --tags)

image_name := cdcihn.isdc.unige.ch:443/frontend:$(strip $(image_version))

build:
	docker build -t $(image_name) .

push: build
	docker push $(image_name)  



