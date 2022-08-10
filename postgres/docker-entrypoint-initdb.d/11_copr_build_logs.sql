DROP TABLE IF EXISTS "copr_build_logs";

-- See common/copr_common/enums.py for the definition of the enum
-- "failed": 0,     # build failed
-- "succeeded": 1,  # build succeeded
-- "canceled": 2,   # build was canceled
-- "running": 3,    # SRPM or RPM build is running
-- "pending": 4,    # build(-chroot) is waiting to be picked
-- "skipped": 5,    # if there was this package built already
-- "starting": 6,   # build was picked by worker but no VM initialized yet
-- "importing": 7,  # SRPM is being imported into dist-git
-- "forked": 8,     # build(-chroot) was forked
-- "waiting": 9,    # build(-chroot) is waiting for something else to finish
-- "unknown": 1000, # undefined
DROP TYPE IF EXISTS copr_build_logs_state_type;
CREATE TYPE copr_build_logs_state_type AS ENUM ('failed', 'succeeded', 'canceled', 'running', 'pending', 'skipped', 'starting', 'importing', 'forked', 'waiting', 'unknown');

-- This creates a dynamic lookup table for the states that looks like this:
--
-- SELECT * FROM copr_build_logs_state_lut;
--
-- state     state_enum
-- --------  ----------
-- failed    1
-- succeeded 2
-- canceled  3
-- running   4
-- pending   5
-- skipped   6
-- starting  7
-- importing 8
-- forked    9
-- waiting   10
-- unknown   11
CREATE OR REPLACE VIEW copr_build_logs_state_lut AS
  SELECT s.state, ROW_NUMBER() OVER (ORDER BY 1) as state_enum FROM
  (SELECT unnest(enum_range(NULL::copr_build_logs_state_type)) as "state") as s;



CREATE TABLE "public"."copr_build_logs" (
    "owner_name" text NOT NULL,
    "project_name" text NOT NULL,
    "owner_and_project" text NOT NULL GENERATED ALWAYS AS (owner_name || '/' || project_name) STORED,
    "build_id" bigint NOT NULL,

    "started_on_ts"  TIMESTAMP WITHOUT TIME ZONE,
    "started_on_date" DATE GENERATED ALWAYS AS (started_on_ts::date) STORED,
    "ended_on_ts" TIMESTAMP WITHOUT TIME ZONE,
    "ended_on_date" DATE GENERATED ALWAYS AS (ended_on_ts::date) STORED,
    "build_time_secs" bigint GENERATED ALWAYS AS (EXTRACT(epoch FROM ended_on_ts) - EXTRACT(epoch FROM started_on_ts)) STORED,

    "started_on_year" integer GENERATED ALWAYS AS (EXTRACT (year FROM started_on_ts)) STORED,
    "started_on_month" integer GENERATED ALWAYS AS (EXTRACT (month FROM started_on_ts)) STORED,
    "started_on_hour" integer GENERATED ALWAYS AS (EXTRACT (hour FROM started_on_ts)) STORED,
    "started_on_minute" integer GENERATED ALWAYS AS (EXTRACT (minute FROM started_on_ts)) STORED,
    "started_on_isodow" integer GENERATED ALWAYS AS (EXTRACT (isodow FROM started_on_ts)) STORED,
    "started_on_week" integer GENERATED ALWAYS AS (EXTRACT (week FROM started_on_ts)) STORED,

    "ended_on_year" integer GENERATED ALWAYS AS (EXTRACT (year FROM ended_on_ts)) STORED,
    "ended_on_month" integer GENERATED ALWAYS AS (EXTRACT (month FROM ended_on_ts)) STORED,
    "ended_on_hour" integer GENERATED ALWAYS AS (EXTRACT (hour FROM ended_on_ts)) STORED,
    "ended_on_minute" integer GENERATED ALWAYS AS (EXTRACT (minute FROM ended_on_ts)) STORED,
    "ended_on_isodow" integer GENERATED ALWAYS AS (EXTRACT (isodow FROM ended_on_ts)) STORED,
    "ended_on_week" integer GENERATED ALWAYS AS (EXTRACT (week FROM ended_on_ts)) STORED,

    "is_background" boolean,
    "project_dirname" text NOT NULL,
    "repo_url" text NOT NULL,
    "source_package_name" text NOT NULL,
    "source_package_url" text NOT NULL,
    "source_package_version" text NOT NULL,
    "submitted_on" timestamp NOT NULL,
    "submitter" text NOT NULL,
    "chroots" text[],
    "state" copr_build_logs_state_type NOT NULL,
    "last_modified" timestamp WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "copr_build_logs_pkey" PRIMARY KEY ("owner_name", "project_name", "build_id")
);

CREATE OR REPLACE FUNCTION update_last_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_modified = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE OR REPLACE TRIGGER copr_logs_last_modified
BEFORE INSERT OR UPDATE
ON copr_build_logs
FOR EACH ROW
EXECUTE PROCEDURE update_last_modified();