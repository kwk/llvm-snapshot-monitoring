#!/bin/sh

set -e
set -x

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_timescaledb' template db
psql -U $PGUSER <<- 'EOSQL'
CREATE DATABASE template_timescaledb IS_TEMPLATE true;
EOSQL

# Load timescale into both template_timescaledb and $POSTGRES_DB
for DB in template_timescaledb "$POSTGRES_DB"; do
	echo "Loading TimescaleDB extensions into $DB"
	psql -U $PGUSER --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS timescaledb;
EOSQL
done

# # Grafana setup
# # See https://grafana.com/docs/grafana/v7.5/datasources/postgres/#database-user-permissions-important
# psql -U $PGUSER <<- 'EOSQL'
# CREATE USER grafanareader WITH PASSWORD 'example';
# GRANT USAGE ON SCHEMA schema TO grafanareader;
# GRANT SELECT ON schema.table TO grafanareader;
# EOSQL