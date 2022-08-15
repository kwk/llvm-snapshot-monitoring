#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	-- This is for grafana being able to manage its settings
	CREATE USER grafanawriter PASSWORD 'grafanawriter_password';
	CREATE DATABASE grafana;
	GRANT ALL PRIVILEGES ON DATABASE grafana TO grafanawriter;
EOSQL
