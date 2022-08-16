#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	GRANT ALL PRIVILEGES ON DATABASE logs TO logwriter;
EOSQL

psql -v ON_ERROR_STOP=1 --username "logwriter" --dbname "logs" <<-EOSQL
DROP TABLE IF EXISTS "buildbot_build_logs";

-- https://lab.llvm.org/staging/api/v2/builders/1/builds
-- {
--   "builds": [
--     {
--       "builderid": 1,
--       "buildid": 13257,
--       "buildrequestid": 226034,
--       "complete": true,
--       "complete_at": 1611823152,
--       "masterid": 2,
--       "number": 1,
--       "properties": {},
--       "results": 4,
--       "started_at": 1611822816,
--       "state_string": "exception 'python ../sanitizer_buildbot/sanitizers/zorg/buildbot/builders/sanitizers/buildbot_selector.py'",
--       "workerid": 3
--     },
-- 
-- https://lab.llvm.org/staging/api/v2/builders
-- {
--   "builders": [
--     {
--       "builderid": 1,
--       "description": null,
--       "masterids": [
--         2
--       ],
--       "name": "sanitizer-x86_64-linux-android",
--       "tags": [
--         "sanitizer"
--       ]
--     },

CREATE TABLE "public"."buildbot_build_logs" (
    "builder_builderid" bigint NOT NULL,
    "builder_description" text,
    "builder_masterids" bigint[],
    "builder_name" text,
    "builder_tags" text[],

    "build_buildid" bigint NOT NULL,
    "build_buildrequestid" bigint NOT NULL,
    "build_complete" boolean NOT NULL,
    "build_complete_at" timestamp without time zone DEFAULT NULL,
    "build_masterid" bigint NOT NULL,
    "build_number" bigint NOT NULL,
    "build_properties" jsonb NOT NULL,
    "build_results" integer DEFAULT NULL,
    "build_started_at" timestamp without time zone NOT NULL,
    "build_state_string" text,
    "build_workerid" bigint NOT NULL,
    "last_modified" timestamp WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "buildbot_build_logs_pkey" PRIMARY KEY ("builder_builderid", "build_buildid")
);

CREATE OR REPLACE FUNCTION update_last_modified()
RETURNS TRIGGER AS \$\$
BEGIN
    NEW.last_modified = now();
    RETURN NEW;
END;
\$\$ language 'plpgsql';

CREATE OR REPLACE TRIGGER buildbot_logs_last_modified
BEFORE INSERT OR UPDATE
ON buildbot_build_logs
FOR EACH ROW
EXECUTE PROCEDURE update_last_modified();

GRANT SELECT ON buildbot_build_logs TO grafanareader;
EOSQL
