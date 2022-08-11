DOCKER_BIN ?= podman
DOCKER_COMPOSE_BIN ?= podman-compose

.PHONY: all
all: stop build start

.PHONY: stop
stop:
	$(DOCKER_COMPOSE_BIN) down --volumes --timeout 0

.PHONY: build
build:
	$(DOCKER_COMPOSE_BIN) build

.PHONY: start
start:
	-$(DOCKER_COMPOSE_BIN) up --force-recreate --renew-anon-volumes -d
	$(DOCKER_COMPOSE_BIN) logs -f
