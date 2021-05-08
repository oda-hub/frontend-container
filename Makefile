
image_version := $(shell bash make.sh compute-version)


image_name := odahub/frontend:$(shell bash make.sh compute-version)

push: build
	docker push $(image_name)  

build: update
	docker build -t $(image_name) .

update:
	# because no to submodules
	bash make.sh clone_all_latest


run: build
	docker run -p 8000:80 $(image_name)
