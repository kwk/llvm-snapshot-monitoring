DOCKER_BIN ?= podman
DOCKER_COMPOSE_BIN ?= podman-compose

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

.PHONY: pull
pull:
	$(DOCKER_COMPOSE_BIN) pull

.PHONY: start
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
## Comment out the echos in this recipe and use your own secret files. 
secret-files:
	@mkdir -p secrets
	@echo "grafanareader_password" > ./secrets/grafanareader_password.txt
	@echo "grafanawriter_password" > ./secrets/grafanawriter_password.txt
	@echo "logwriter_password" > ./secrets/logwriter_password.txt
	@echo "postgres_password" > ./secrets/postgres_password.txt

.PHONY: remove-secrets
remove-secrets:
	-$(DOCKER_BIN) secret rm secret_grafanareader &>/dev/null
	-$(DOCKER_BIN) secret rm secret_grafanawriter &>/dev/null
	-$(DOCKER_BIN) secret rm secret_logwriter &>/dev/null
	-$(DOCKER_BIN) secret rm secret_postgres &>/dev/null

.PHONY: secrets
secrets: remove-secrets secret-files 
	$(DOCKER_BIN) secret create secret_grafanareader ./secrets/grafanareader_password.txt
	$(DOCKER_BIN) secret create secret_grafanawriter ./secrets/grafanawriter_password.txt
	$(DOCKER_BIN) secret create secret_logwriter ./secrets/logwriter_password.txt
	$(DOCKER_BIN) secret create secret_postgres ./secrets/postgres_password.txt
