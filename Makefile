REPORTER = dot

name				= "docker-zabbix"
image_name	= "berngp/$(name)"


build:
	@docker build -t $(image_name) .


run:
	@docker run --rm -it \
							--hostname=$(name) \
							--name=$(name) \
							-P \
							$(image_name)

run-shell:
	@docker run --rm -it \
							--hostname=$(name) \
							--name=$(name) \
							-P \
							$(image_name) \
							shell

exec:
	@docker exec -it $(name) /bin/bash

rmi:
	-@docker rmi $(image_name)

rm:
	-@docker rm $(name)

clean: rm rmi

tag: build
	-@docker tag $(image_name) $(image_name)

push: tag
	docker push $(image_name)

.PHONY: build run exec rmi rm clean tag push
