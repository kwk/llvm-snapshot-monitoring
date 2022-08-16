#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER grafanawriter PASSWORD 'grafanawriter_password';
    CREATE USER grafanareader PASSWORD 'grafanareader_password';
    CREATE USER logwriter PASSWORD 'logwriter_password';
EOSQL

