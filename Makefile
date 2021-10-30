DOCKER = docker
IMAGE = iamsalvamartini/aosp

aosp: Dockerfile
	$(DOCKER) build -t $(IMAGE) .

all: aosp

.PHONY: all
