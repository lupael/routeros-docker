#!make

ROUTEROS_VERSION := 7.22.1
TARGET := lupael/routeros

all: buildx-setup build latest

buildx-setup:
	docker buildx create --use

build: buildx-setup
	docker buildx build --build-arg ROUTEROS_VERSION=$(ROUTEROS_VERSION) --platform=linux/amd64,linux/arm64 -t $(TARGET):$(ROUTEROS_VERSION) --push .

latest: buildx-setup
	docker buildx build --build-arg ROUTEROS_VERSION=$(ROUTEROS_VERSION) --platform=linux/amd64,linux/arm64 -t $(TARGET):latest --push .

lint:
	ruff check bin/generate-dhcpd-conf.py; ruff check bin/generate-dhcpd-conf.py --diff

format:
	ruff format bin/generate-dhcpd-conf.py; ruff check bin/generate-dhcpd-conf.py --fix

changelog:
	curl -s https://download.mikrotik.com/routeros/$(ROUTEROS_VERSION)/CHANGELOG -o CHANGELOG.temp

.PHONY: all buildx-setup build latest lint format changelog
