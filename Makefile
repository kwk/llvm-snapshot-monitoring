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
	$(DOCKER_BIN) volume rm -f $(shell $(DOCKER_BIN) volume ls -q)

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
## Starts all services and follows the logs of each service
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
## DUMMY: This creates placeholder passwords in ./secrets to be overwritten with
## the actual secrets.
secret-files:
	@mkdir -p secrets
	@echo "grafanareader_password" > ./secrets/grafanareader_password.txt
	@echo "grafanawriter_password" > ./secrets/grafanawriter_password.txt
	@echo "logwriter_password" > ./secrets/logwriter_password.txt
	@echo "postgres_password" > ./secrets/postgres_password.txt
	@echo "admin" > ./secrets/grafana_admin_password.txt

.PHONY: remove-secrets
## Removes the podman/docker secrets defined by the "secrets" target".
remove-secrets:
	-$(DOCKER_BIN) secret rm secret_grafanareader_password &>/dev/null
	-$(DOCKER_BIN) secret rm secret_grafanawriter_password &>/dev/null
	-$(DOCKER_BIN) secret rm secret_logwriter_password &>/dev/null
	-$(DOCKER_BIN) secret rm secret_postgres_password &>/dev/null
	-$(DOCKER_BIN) secret rm secret_grafana_admin_password &>/dev/null

.PHONY: secrets
## Takes the secrets defined in ./secrets and makes podman/docker secrets out of
## it.
secrets: remove-secrets secret-files
	$(DOCKER_BIN) secret create secret_grafanareader_password ./secrets/grafanareader_password.txt
	$(DOCKER_BIN) secret create secret_grafanawriter_password ./secrets/grafanawriter_password.txt
	$(DOCKER_BIN) secret create secret_logwriter_password ./secrets/logwriter_password.txt
	$(DOCKER_BIN) secret create secret_postgres_password ./secrets/postgres_password.txt
	$(DOCKER_BIN) secret create secret_grafana_admin_password ./secrets/grafana_admin_password.txt
