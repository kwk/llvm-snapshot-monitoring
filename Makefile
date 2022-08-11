DOCKER_BIN ?= podman
DOCKER_COMPOSE_BIN ?= podman-compose

.PHONY: show
show:
	@echo "DOCKER_BIN: ${DOCKER_BIN}"
	@echo "DOCKER_COMPOSE_BIN: ${DOCKER_COMPOSE_BIN}"

.PHONY: all
all: start

.PHONY: stop
stop:
	$(DOCKER_COMPOSE_BIN) down --volumes --timeout 0

.PHONY: build
build:
	$(DOCKER_COMPOSE_BIN) build

.PHONY: push
push:
	$(DOCKER_COMPOSE_BIN) push

.PHONY: start
start:
	-$(DOCKER_COMPOSE_BIN) up --force-recreate --renew-anon-volumes -d
	$(DOCKER_COMPOSE_BIN) logs -f
