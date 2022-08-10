CREATE USER grafanareader WITH PASSWORD 'password';
GRANT USAGE ON SCHEMA postgres TO grafanareader;
GRANT SELECT ON postgres.copr_build_logs TO grafanareader;