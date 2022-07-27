#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

TIMESCALEDB_VERSION="${TIMESCALEDB_VERSION%%+*}"

# Load timescale into both template_database and $POSTGRES_DB
for DB in template_timescaledb "$POSTGRES_DB" "${@}"; do
    echo "Updating TimescaleDB extensions '$DB' to $TIMESCALEDB_VERSION"
    psql -U $PGUSER --dbname="$DB" -c "
        -- Upgrade TimescaleDB
        CREATE EXTENSION IF NOT EXISTS timescaledb VERSION '$TIMESCALEDB_VERSION';
        ALTER EXTENSION timescaledb UPDATE TO '$TIMESCALEDB_VERSION';
    "
done