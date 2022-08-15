# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash

include ./help.mk

DOCKER_BIN ?= podman
DOCKER_COMPOSE_BIN ?= podman-compose

.PHONY: all
## Runs the "start" target
all: start

.PHONY: stop
## Stops all services
stop: stop-all

# When wildcard is "all", it will be thrown away to start all services.
stop-%:
	$(eval service:=$(subst stop-,,$@))
	$(eval service:=$(subst all,,$(service)))
	$(DOCKER_COMPOSE_BIN) down --volumes --timeout 0 $(service)

.PHONY: build
## Builds the image for all services
build:
	$(DOCKER_COMPOSE_BIN) build

.PHONY: push
## Pushes the images for all services to the container registry
push:
	$(DOCKER_COMPOSE_BIN) push

.PHONY: pull
## Pulls all the images for all servies from the registry
pull:
	$(DOCKER_COMPOSE_BIN) pull

.PHONY: start
## Starts all services
start: start-all logs-all

# When wildcard is "all", it will be thrown away to start all services.
start-%:
	$(eval service:=$(subst start-,,$@))
	$(eval service:=$(subst all,,$(service)))
	-$(DOCKER_COMPOSE_BIN) up --no-build --force-recreate --renew-anon-volumes -d $(service)

# When wildcard is "all", it will be thrown away to output logs for all services.
logs-%:
	$(eval service:=$(subst logs-,,$@))
	$(eval service:=$(subst all,,$(service)))
	$(DOCKER_COMPOSE_BIN) logs -f  $(service)
	
.PHONY: secret-files
## DUMMY: This creates placeholder comments in ./secrets to be overwritten with
## the actual secrets.
secret-files:
	@mkdir -p secrets
	@echo "grafanareader_password" > ./secrets/grafanareader_password.txt
	@echo "grafanawriter_password" > ./secrets/grafanawriter_password.txt
	@echo "logwriter_password" > ./secrets/logwriter_password.txt
	@echo "postgres_password" > ./secrets/postgres_password.txt

.PHONY: remove-secrets
## Removes the podman/docker secrets defined by the "secrets" target".
remove-secrets:
	-$(DOCKER_BIN) secret rm secret_grafanareader &>/dev/null
	-$(DOCKER_BIN) secret rm secret_grafanawriter &>/dev/null
	-$(DOCKER_BIN) secret rm secret_logwriter &>/dev/null
	-$(DOCKER_BIN) secret rm secret_postgres &>/dev/null

.PHONY: secrets
## Takes the secrets defined in ./secrets and makes podman/docker secrets out of
## it.
secrets: remove-secrets secret-files 
	$(DOCKER_BIN) secret create secret_grafanareader ./secrets/grafanareader_password.txt
	$(DOCKER_BIN) secret create secret_grafanawriter ./secrets/grafanawriter_password.txt
	$(DOCKER_BIN) secret create secret_logwriter ./secrets/logwriter_password.txt
	$(DOCKER_BIN) secret create secret_postgres ./secrets/postgres_password.txt
