.PHONY: all
all: clean build up

.PHONY: clean
clean:
	sudo rm -rf postgres/data
	mkdir -pv postgres/data
	-podman rm -f --volumes postgres-container grafana-container adminer-container pgadmin-container

.PHONY: build
build:
	podman-compose build

.PHONY: up
up:
	podman-compose up
