-- Adminer 4.8.1 PostgreSQL 14.4 (Debian 14.4-1.pgdg110+1) dump

\connect "grafana_db";

DROP TABLE IF EXISTS "alert";
DROP SEQUENCE IF EXISTS alert_id_seq;
CREATE SEQUENCE alert_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."alert" (
    "id" integer DEFAULT nextval('alert_id_seq') NOT NULL,
    "version" bigint NOT NULL,
    "dashboard_id" bigint NOT NULL,
    "panel_id" bigint NOT NULL,
    "org_id" bigint NOT NULL,
    "name" character varying(255) NOT NULL,
    "message" text NOT NULL,
    "state" character varying(190) NOT NULL,
    "settings" text NOT NULL,
    "frequency" bigint NOT NULL,
    "handler" bigint NOT NULL,
    "severity" text NOT NULL,
    "silenced" boolean NOT NULL,
    "execution_error" text NOT NULL,
    "eval_data" text,
    "eval_date" timestamp,
    "new_state_date" timestamp NOT NULL,
    "state_changes" integer NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "for" bigint,
    CONSTRAINT "alert_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_alert_dashboard_id" ON "public"."alert" USING btree ("dashboard_id");

CREATE INDEX "IDX_alert_org_id_id" ON "public"."alert" USING btree ("org_id", "id");

CREATE INDEX "IDX_alert_state" ON "public"."alert" USING btree ("state");

TRUNCATE "alert";

DROP TABLE IF EXISTS "alert_configuration";
DROP SEQUENCE IF EXISTS alert_configuration_id_seq;
CREATE SEQUENCE alert_configuration_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;

CREATE TABLE "public"."alert_configuration" (
    "id" integer DEFAULT nextval('alert_configuration_id_seq') NOT NULL,
    "alertmanager_configuration" text NOT NULL,
    "configuration_version" character varying(3) NOT NULL,
    "created_at" integer NOT NULL,
    "default" boolean DEFAULT false NOT NULL,
    "org_id" bigint DEFAULT '0' NOT NULL,
    "configuration_hash" character varying(32) DEFAULT 'not-yet-calculated' NOT NULL,
    CONSTRAINT "alert_configuration_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_alert_configuration_org_id" ON "public"."alert_configuration" USING btree ("org_id");

TRUNCATE "alert_configuration";
INSERT INTO "alert_configuration" ("id", "alertmanager_configuration", "configuration_version", "created_at", "default", "org_id", "configuration_hash") VALUES
(1,	'{
	"alertmanager_config": {
		"route": {
			"receiver": "grafana-default-email"
		},
		"receivers": [{
			"name": "grafana-default-email",
			"grafana_managed_receiver_configs": [{
				"uid": "",
				"name": "email receiver",
				"type": "email",
				"isDefault": true,
				"settings": {
					"addresses": "<example@email.com>"
				}
			}]
		}]
	}
}
',	'v1',	1658940558,	'1',	1,	'8c409350c88d78d2ee938448449e628d');

DROP TABLE IF EXISTS "alert_image";
DROP SEQUENCE IF EXISTS alert_image_id_seq;
CREATE SEQUENCE alert_image_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."alert_image" (
    "id" integer DEFAULT nextval('alert_image_id_seq') NOT NULL,
    "token" character varying(190) NOT NULL,
    "path" character varying(190) NOT NULL,
    "url" character varying(190) NOT NULL,
    "created_at" timestamp NOT NULL,
    "expires_at" timestamp NOT NULL,
    CONSTRAINT "UQE_alert_image_token" UNIQUE ("token"),
    CONSTRAINT "alert_image_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "alert_image";

DROP TABLE IF EXISTS "alert_instance";
CREATE TABLE "public"."alert_instance" (
    "rule_org_id" bigint NOT NULL,
    "rule_uid" character varying(40) DEFAULT '0' NOT NULL,
    "labels" text NOT NULL,
    "labels_hash" character varying(190) NOT NULL,
    "current_state" character varying(190) NOT NULL,
    "current_state_since" bigint NOT NULL,
    "last_eval_time" bigint NOT NULL,
    "current_state_end" bigint DEFAULT '0' NOT NULL,
    "current_reason" character varying(190),
    CONSTRAINT "alert_instance_pkey" PRIMARY KEY ("rule_org_id", "rule_uid", "labels_hash")
) WITH (oids = false);

CREATE INDEX "IDX_alert_instance_rule_org_id_current_state" ON "public"."alert_instance" USING btree ("rule_org_id", "current_state");

CREATE INDEX "IDX_alert_instance_rule_org_id_rule_uid_current_state" ON "public"."alert_instance" USING btree ("rule_org_id", "rule_uid", "current_state");

TRUNCATE "alert_instance";

DROP TABLE IF EXISTS "alert_notification";
DROP SEQUENCE IF EXISTS alert_notification_id_seq;
CREATE SEQUENCE alert_notification_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."alert_notification" (
    "id" integer DEFAULT nextval('alert_notification_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "name" character varying(190) NOT NULL,
    "type" character varying(255) NOT NULL,
    "settings" text NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "is_default" boolean DEFAULT false NOT NULL,
    "frequency" bigint,
    "send_reminder" boolean DEFAULT false,
    "disable_resolve_message" boolean DEFAULT false NOT NULL,
    "uid" character varying(40),
    "secure_settings" text,
    CONSTRAINT "UQE_alert_notification_org_id_uid" UNIQUE ("org_id", "uid"),
    CONSTRAINT "alert_notification_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "alert_notification";

DROP TABLE IF EXISTS "alert_notification_state";
DROP SEQUENCE IF EXISTS alert_notification_state_id_seq;
CREATE SEQUENCE alert_notification_state_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."alert_notification_state" (
    "id" integer DEFAULT nextval('alert_notification_state_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "alert_id" bigint NOT NULL,
    "notifier_id" bigint NOT NULL,
    "state" character varying(50) NOT NULL,
    "version" bigint NOT NULL,
    "updated_at" bigint NOT NULL,
    "alert_rule_state_updated_version" bigint NOT NULL,
    CONSTRAINT "UQE_alert_notification_state_org_id_alert_id_notifier_id" UNIQUE ("org_id", "alert_id", "notifier_id"),
    CONSTRAINT "alert_notification_state_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_alert_notification_state_alert_id" ON "public"."alert_notification_state" USING btree ("alert_id");

TRUNCATE "alert_notification_state";

DROP TABLE IF EXISTS "alert_rule";
DROP SEQUENCE IF EXISTS alert_rule_id_seq;
CREATE SEQUENCE alert_rule_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."alert_rule" (
    "id" integer DEFAULT nextval('alert_rule_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "title" character varying(190) NOT NULL,
    "condition" character varying(190) NOT NULL,
    "data" text NOT NULL,
    "updated" timestamp NOT NULL,
    "interval_seconds" bigint DEFAULT '60' NOT NULL,
    "version" integer DEFAULT '0' NOT NULL,
    "uid" character varying(40) DEFAULT '0' NOT NULL,
    "namespace_uid" character varying(40) NOT NULL,
    "rule_group" character varying(190) NOT NULL,
    "no_data_state" character varying(15) DEFAULT 'NoData' NOT NULL,
    "exec_err_state" character varying(15) DEFAULT 'Alerting' NOT NULL,
    "for" bigint DEFAULT '0' NOT NULL,
    "annotations" text,
    "labels" text,
    "dashboard_uid" character varying(40),
    "panel_id" bigint,
    CONSTRAINT "UQE_alert_rule_org_id_namespace_uid_title" UNIQUE ("org_id", "namespace_uid", "title"),
    CONSTRAINT "UQE_alert_rule_org_id_uid" UNIQUE ("org_id", "uid"),
    CONSTRAINT "alert_rule_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_alert_rule_org_id_dashboard_uid_panel_id" ON "public"."alert_rule" USING btree ("org_id", "dashboard_uid", "panel_id");

CREATE INDEX "IDX_alert_rule_org_id_namespace_uid_rule_group" ON "public"."alert_rule" USING btree ("org_id", "namespace_uid", "rule_group");

TRUNCATE "alert_rule";

DROP TABLE IF EXISTS "alert_rule_tag";
DROP SEQUENCE IF EXISTS alert_rule_tag_id_seq;
CREATE SEQUENCE alert_rule_tag_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."alert_rule_tag" (
    "id" integer DEFAULT nextval('alert_rule_tag_id_seq') NOT NULL,
    "alert_id" bigint NOT NULL,
    "tag_id" bigint NOT NULL,
    CONSTRAINT "UQE_alert_rule_tag_alert_id_tag_id" UNIQUE ("alert_id", "tag_id"),
    CONSTRAINT "alert_rule_tag_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_alert_rule_tag_alert_id" ON "public"."alert_rule_tag" USING btree ("alert_id");

TRUNCATE "alert_rule_tag";

DROP TABLE IF EXISTS "alert_rule_version";
DROP SEQUENCE IF EXISTS alert_rule_version_id_seq;
CREATE SEQUENCE alert_rule_version_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."alert_rule_version" (
    "id" integer DEFAULT nextval('alert_rule_version_id_seq') NOT NULL,
    "rule_org_id" bigint NOT NULL,
    "rule_uid" character varying(40) DEFAULT '0' NOT NULL,
    "rule_namespace_uid" character varying(40) NOT NULL,
    "rule_group" character varying(190) NOT NULL,
    "parent_version" integer NOT NULL,
    "restored_from" integer NOT NULL,
    "version" integer NOT NULL,
    "created" timestamp NOT NULL,
    "title" character varying(190) NOT NULL,
    "condition" character varying(190) NOT NULL,
    "data" text NOT NULL,
    "interval_seconds" bigint NOT NULL,
    "no_data_state" character varying(15) DEFAULT 'NoData' NOT NULL,
    "exec_err_state" character varying(15) DEFAULT 'Alerting' NOT NULL,
    "for" bigint DEFAULT '0' NOT NULL,
    "annotations" text,
    "labels" text,
    CONSTRAINT "UQE_alert_rule_version_rule_org_id_rule_uid_version" UNIQUE ("rule_org_id", "rule_uid", "version"),
    CONSTRAINT "alert_rule_version_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_alert_rule_version_rule_org_id_rule_namespace_uid_rule_grou" ON "public"."alert_rule_version" USING btree ("rule_org_id", "rule_namespace_uid", "rule_group");

TRUNCATE "alert_rule_version";

DROP TABLE IF EXISTS "annotation";
DROP SEQUENCE IF EXISTS annotation_id_seq;
CREATE SEQUENCE annotation_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."annotation" (
    "id" integer DEFAULT nextval('annotation_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "alert_id" bigint,
    "user_id" bigint,
    "dashboard_id" bigint,
    "panel_id" bigint,
    "category_id" bigint,
    "type" character varying(25) NOT NULL,
    "title" text NOT NULL,
    "text" text NOT NULL,
    "metric" character varying(255),
    "prev_state" character varying(25) NOT NULL,
    "new_state" character varying(25) NOT NULL,
    "data" text NOT NULL,
    "epoch" bigint NOT NULL,
    "region_id" bigint DEFAULT '0',
    "tags" character varying(500),
    "created" bigint DEFAULT '0',
    "updated" bigint DEFAULT '0',
    "epoch_end" bigint DEFAULT '0' NOT NULL,
    CONSTRAINT "annotation_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_annotation_alert_id" ON "public"."annotation" USING btree ("alert_id");

CREATE INDEX "IDX_annotation_org_id_alert_id" ON "public"."annotation" USING btree ("org_id", "alert_id");

CREATE INDEX "IDX_annotation_org_id_created" ON "public"."annotation" USING btree ("org_id", "created");

CREATE INDEX "IDX_annotation_org_id_dashboard_id_epoch_end_epoch" ON "public"."annotation" USING btree ("org_id", "dashboard_id", "epoch_end", "epoch");

CREATE INDEX "IDX_annotation_org_id_epoch_end_epoch" ON "public"."annotation" USING btree ("org_id", "epoch_end", "epoch");

CREATE INDEX "IDX_annotation_org_id_type" ON "public"."annotation" USING btree ("org_id", "type");

CREATE INDEX "IDX_annotation_org_id_updated" ON "public"."annotation" USING btree ("org_id", "updated");

TRUNCATE "annotation";

DROP TABLE IF EXISTS "annotation_tag";
DROP SEQUENCE IF EXISTS annotation_tag_id_seq;
CREATE SEQUENCE annotation_tag_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."annotation_tag" (
    "id" integer DEFAULT nextval('annotation_tag_id_seq') NOT NULL,
    "annotation_id" bigint NOT NULL,
    "tag_id" bigint NOT NULL,
    CONSTRAINT "UQE_annotation_tag_annotation_id_tag_id" UNIQUE ("annotation_id", "tag_id"),
    CONSTRAINT "annotation_tag_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "annotation_tag";

DROP TABLE IF EXISTS "api_key";
DROP SEQUENCE IF EXISTS api_key_id_seq1;
CREATE SEQUENCE api_key_id_seq1 INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."api_key" (
    "id" integer DEFAULT nextval('api_key_id_seq1') NOT NULL,
    "org_id" bigint NOT NULL,
    "name" character varying(190) NOT NULL,
    "key" character varying(190) NOT NULL,
    "role" character varying(255) NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "expires" bigint,
    "service_account_id" bigint,
    CONSTRAINT "UQE_api_key_key" UNIQUE ("key"),
    CONSTRAINT "UQE_api_key_org_id_name" UNIQUE ("org_id", "name"),
    CONSTRAINT "api_key_pkey1" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_api_key_org_id" ON "public"."api_key" USING btree ("org_id");

TRUNCATE "api_key";

DROP TABLE IF EXISTS "builtin_role";
DROP SEQUENCE IF EXISTS builtin_role_id_seq;
CREATE SEQUENCE builtin_role_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."builtin_role" (
    "id" integer DEFAULT nextval('builtin_role_id_seq') NOT NULL,
    "role" character varying(190) NOT NULL,
    "role_id" bigint NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "org_id" bigint DEFAULT '0' NOT NULL,
    CONSTRAINT "UQE_builtin_role_org_id_role_id_role" UNIQUE ("org_id", "role_id", "role"),
    CONSTRAINT "builtin_role_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_builtin_role_org_id" ON "public"."builtin_role" USING btree ("org_id");

CREATE INDEX "IDX_builtin_role_role" ON "public"."builtin_role" USING btree ("role");

CREATE INDEX "IDX_builtin_role_role_id" ON "public"."builtin_role" USING btree ("role_id");

TRUNCATE "builtin_role";

DROP TABLE IF EXISTS "cache_data";
CREATE TABLE "public"."cache_data" (
    "cache_key" character varying(168) NOT NULL,
    "data" bytea NOT NULL,
    "expires" integer NOT NULL,
    "created_at" integer NOT NULL,
    CONSTRAINT "UQE_cache_data_cache_key" UNIQUE ("cache_key"),
    CONSTRAINT "cache_data_pkey" PRIMARY KEY ("cache_key")
) WITH (oids = false);

TRUNCATE "cache_data";

DROP TABLE IF EXISTS "dashboard";
DROP SEQUENCE IF EXISTS dashboard_id_seq1;
CREATE SEQUENCE dashboard_id_seq1 INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."dashboard" (
    "id" integer DEFAULT nextval('dashboard_id_seq1') NOT NULL,
    "version" integer NOT NULL,
    "slug" character varying(189) NOT NULL,
    "title" character varying(189) NOT NULL,
    "data" text NOT NULL,
    "org_id" bigint NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "updated_by" integer,
    "created_by" integer,
    "gnet_id" bigint,
    "plugin_id" character varying(189),
    "folder_id" bigint DEFAULT '0' NOT NULL,
    "is_folder" boolean DEFAULT false NOT NULL,
    "has_acl" boolean DEFAULT false NOT NULL,
    "uid" character varying(40),
    "is_public" boolean DEFAULT false NOT NULL,
    CONSTRAINT "UQE_dashboard_org_id_folder_id_title" UNIQUE ("org_id", "folder_id", "title"),
    CONSTRAINT "UQE_dashboard_org_id_uid" UNIQUE ("org_id", "uid"),
    CONSTRAINT "dashboard_pkey1" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_dashboard_gnet_id" ON "public"."dashboard" USING btree ("gnet_id");

CREATE INDEX "IDX_dashboard_is_folder" ON "public"."dashboard" USING btree ("is_folder");

CREATE INDEX "IDX_dashboard_org_id" ON "public"."dashboard" USING btree ("org_id");

CREATE INDEX "IDX_dashboard_org_id_plugin_id" ON "public"."dashboard" USING btree ("org_id", "plugin_id");

CREATE INDEX "IDX_dashboard_title" ON "public"."dashboard" USING btree ("title");

TRUNCATE "dashboard";

DROP TABLE IF EXISTS "dashboard_acl";
DROP SEQUENCE IF EXISTS dashboard_acl_id_seq;
CREATE SEQUENCE dashboard_acl_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 2 CACHE 1;

CREATE TABLE "public"."dashboard_acl" (
    "id" integer DEFAULT nextval('dashboard_acl_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "dashboard_id" bigint NOT NULL,
    "user_id" bigint,
    "team_id" bigint,
    "permission" smallint DEFAULT '4' NOT NULL,
    "role" character varying(20),
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    CONSTRAINT "UQE_dashboard_acl_dashboard_id_team_id" UNIQUE ("dashboard_id", "team_id"),
    CONSTRAINT "UQE_dashboard_acl_dashboard_id_user_id" UNIQUE ("dashboard_id", "user_id"),
    CONSTRAINT "dashboard_acl_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_dashboard_acl_dashboard_id" ON "public"."dashboard_acl" USING btree ("dashboard_id");

CREATE INDEX "IDX_dashboard_acl_org_id_role" ON "public"."dashboard_acl" USING btree ("org_id", "role");

CREATE INDEX "IDX_dashboard_acl_permission" ON "public"."dashboard_acl" USING btree ("permission");

CREATE INDEX "IDX_dashboard_acl_team_id" ON "public"."dashboard_acl" USING btree ("team_id");

CREATE INDEX "IDX_dashboard_acl_user_id" ON "public"."dashboard_acl" USING btree ("user_id");

TRUNCATE "dashboard_acl";
INSERT INTO "dashboard_acl" ("id", "org_id", "dashboard_id", "user_id", "team_id", "permission", "role", "created", "updated") VALUES
(1,	-1,	-1,	NULL,	NULL,	1,	'Viewer',	'2017-06-20 00:00:00',	'2017-06-20 00:00:00'),
(2,	-1,	-1,	NULL,	NULL,	2,	'Editor',	'2017-06-20 00:00:00',	'2017-06-20 00:00:00');

DROP TABLE IF EXISTS "dashboard_provisioning";
DROP SEQUENCE IF EXISTS dashboard_provisioning_id_seq1;
CREATE SEQUENCE dashboard_provisioning_id_seq1 INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."dashboard_provisioning" (
    "id" integer DEFAULT nextval('dashboard_provisioning_id_seq1') NOT NULL,
    "dashboard_id" bigint,
    "name" character varying(150) NOT NULL,
    "external_id" text NOT NULL,
    "updated" integer DEFAULT '0' NOT NULL,
    "check_sum" character varying(32),
    CONSTRAINT "dashboard_provisioning_pkey1" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_dashboard_provisioning_dashboard_id" ON "public"."dashboard_provisioning" USING btree ("dashboard_id");

CREATE INDEX "IDX_dashboard_provisioning_dashboard_id_name" ON "public"."dashboard_provisioning" USING btree ("dashboard_id", "name");

TRUNCATE "dashboard_provisioning";

DROP TABLE IF EXISTS "dashboard_public_config";
CREATE TABLE "public"."dashboard_public_config" (
    "uid" bigint NOT NULL,
    "dashboard_uid" character varying(40) NOT NULL,
    "org_id" bigint NOT NULL,
    "refresh_rate" integer DEFAULT '30' NOT NULL,
    "template_variables" text,
    "time_variables" text NOT NULL,
    CONSTRAINT "UQE_dashboard_public_config_uid" UNIQUE ("uid"),
    CONSTRAINT "dashboard_public_config_pkey" PRIMARY KEY ("uid")
) WITH (oids = false);

CREATE INDEX "IDX_dashboard_public_config_org_id_dashboard_uid" ON "public"."dashboard_public_config" USING btree ("org_id", "dashboard_uid");

TRUNCATE "dashboard_public_config";

DROP TABLE IF EXISTS "dashboard_snapshot";
DROP SEQUENCE IF EXISTS dashboard_snapshot_id_seq;
CREATE SEQUENCE dashboard_snapshot_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."dashboard_snapshot" (
    "id" integer DEFAULT nextval('dashboard_snapshot_id_seq') NOT NULL,
    "name" character varying(255) NOT NULL,
    "key" character varying(190) NOT NULL,
    "delete_key" character varying(190) NOT NULL,
    "org_id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "external" boolean NOT NULL,
    "external_url" character varying(255) NOT NULL,
    "dashboard" text NOT NULL,
    "expires" timestamp NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "external_delete_url" character varying(255),
    "dashboard_encrypted" bytea,
    CONSTRAINT "UQE_dashboard_snapshot_delete_key" UNIQUE ("delete_key"),
    CONSTRAINT "UQE_dashboard_snapshot_key" UNIQUE ("key"),
    CONSTRAINT "dashboard_snapshot_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_dashboard_snapshot_user_id" ON "public"."dashboard_snapshot" USING btree ("user_id");

TRUNCATE "dashboard_snapshot";

DROP TABLE IF EXISTS "dashboard_tag";
DROP SEQUENCE IF EXISTS dashboard_tag_id_seq;
CREATE SEQUENCE dashboard_tag_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."dashboard_tag" (
    "id" integer DEFAULT nextval('dashboard_tag_id_seq') NOT NULL,
    "dashboard_id" bigint NOT NULL,
    "term" character varying(50) NOT NULL,
    CONSTRAINT "dashboard_tag_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_dashboard_tag_dashboard_id" ON "public"."dashboard_tag" USING btree ("dashboard_id");

TRUNCATE "dashboard_tag";

DROP TABLE IF EXISTS "dashboard_version";
DROP SEQUENCE IF EXISTS dashboard_version_id_seq;
CREATE SEQUENCE dashboard_version_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."dashboard_version" (
    "id" integer DEFAULT nextval('dashboard_version_id_seq') NOT NULL,
    "dashboard_id" bigint NOT NULL,
    "parent_version" integer NOT NULL,
    "restored_from" integer NOT NULL,
    "version" integer NOT NULL,
    "created" timestamp NOT NULL,
    "created_by" bigint NOT NULL,
    "message" text NOT NULL,
    "data" text NOT NULL,
    CONSTRAINT "UQE_dashboard_version_dashboard_id_version" UNIQUE ("dashboard_id", "version"),
    CONSTRAINT "dashboard_version_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_dashboard_version_dashboard_id" ON "public"."dashboard_version" USING btree ("dashboard_id");

TRUNCATE "dashboard_version";

DROP TABLE IF EXISTS "data_keys";
CREATE TABLE "public"."data_keys" (
    "name" character varying(100) NOT NULL,
    "active" boolean NOT NULL,
    "scope" character varying(30) NOT NULL,
    "provider" character varying(50) NOT NULL,
    "encrypted_data" bytea NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "label" character varying(100) DEFAULT '' NOT NULL,
    CONSTRAINT "data_keys_pkey" PRIMARY KEY ("name")
) WITH (oids = false);

TRUNCATE "data_keys";

DROP TABLE IF EXISTS "data_source";
DROP SEQUENCE IF EXISTS data_source_id_seq1;
CREATE SEQUENCE data_source_id_seq1 INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."data_source" (
    "id" integer DEFAULT nextval('data_source_id_seq1') NOT NULL,
    "org_id" bigint NOT NULL,
    "version" integer NOT NULL,
    "type" character varying(255) NOT NULL,
    "name" character varying(190) NOT NULL,
    "access" character varying(255) NOT NULL,
    "url" character varying(255) NOT NULL,
    "password" character varying(255),
    "user" character varying(255),
    "database" character varying(255),
    "basic_auth" boolean NOT NULL,
    "basic_auth_user" character varying(255),
    "basic_auth_password" character varying(255),
    "is_default" boolean NOT NULL,
    "json_data" text,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "with_credentials" boolean DEFAULT false NOT NULL,
    "secure_json_data" text,
    "read_only" boolean,
    "uid" character varying(40) DEFAULT '0' NOT NULL,
    CONSTRAINT "UQE_data_source_org_id_name" UNIQUE ("org_id", "name"),
    CONSTRAINT "UQE_data_source_org_id_uid" UNIQUE ("org_id", "uid"),
    CONSTRAINT "data_source_pkey1" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_data_source_org_id" ON "public"."data_source" USING btree ("org_id");

CREATE INDEX "IDX_data_source_org_id_is_default" ON "public"."data_source" USING btree ("org_id", "is_default");

TRUNCATE "data_source";

DROP TABLE IF EXISTS "entity_event";
DROP SEQUENCE IF EXISTS entity_event_id_seq;
CREATE SEQUENCE entity_event_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."entity_event" (
    "id" integer DEFAULT nextval('entity_event_id_seq') NOT NULL,
    "entity_id" character varying(1024) NOT NULL,
    "event_type" character varying(8) NOT NULL,
    "created" bigint NOT NULL,
    CONSTRAINT "entity_event_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "entity_event";

DROP TABLE IF EXISTS "file";
CREATE TABLE "public"."file" (
    "path" character varying(1024) NOT NULL,
    "path_hash" character varying(64) NOT NULL,
    "parent_folder_path_hash" character varying(64) NOT NULL,
    "contents" bytea NOT NULL,
    "etag" character varying(32) NOT NULL,
    "cache_control" character varying(128) NOT NULL,
    "content_disposition" character varying(128) NOT NULL,
    "updated" timestamp NOT NULL,
    "created" timestamp NOT NULL,
    "size" bigint NOT NULL,
    "mime_type" character varying(255) NOT NULL,
    CONSTRAINT "UQE_file_path_hash" UNIQUE ("path_hash")
) WITH (oids = false);

CREATE INDEX "IDX_file_parent_folder_path_hash" ON "public"."file" USING btree ("parent_folder_path_hash");

TRUNCATE "file";

DROP TABLE IF EXISTS "file_meta";
CREATE TABLE "public"."file_meta" (
    "path_hash" character varying(64) NOT NULL,
    "key" character varying(191) NOT NULL,
    "value" character varying(1024) NOT NULL,
    CONSTRAINT "UQE_file_meta_path_hash_key" UNIQUE ("path_hash", "key")
) WITH (oids = false);

TRUNCATE "file_meta";

DROP TABLE IF EXISTS "kv_store";
DROP SEQUENCE IF EXISTS kv_store_id_seq;
CREATE SEQUENCE kv_store_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."kv_store" (
    "id" integer DEFAULT nextval('kv_store_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "namespace" character varying(190) NOT NULL,
    "key" character varying(190) NOT NULL,
    "value" text NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    CONSTRAINT "UQE_kv_store_org_id_namespace_key" UNIQUE ("org_id", "namespace", "key"),
    CONSTRAINT "kv_store_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "kv_store";

DROP TABLE IF EXISTS "library_element";
DROP SEQUENCE IF EXISTS library_element_id_seq;
CREATE SEQUENCE library_element_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."library_element" (
    "id" integer DEFAULT nextval('library_element_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "folder_id" bigint NOT NULL,
    "uid" character varying(40) NOT NULL,
    "name" character varying(150) NOT NULL,
    "kind" bigint NOT NULL,
    "type" character varying(40) NOT NULL,
    "description" character varying(2048) NOT NULL,
    "model" text NOT NULL,
    "created" timestamp NOT NULL,
    "created_by" bigint NOT NULL,
    "updated" timestamp NOT NULL,
    "updated_by" bigint NOT NULL,
    "version" bigint NOT NULL,
    CONSTRAINT "UQE_library_element_org_id_folder_id_name_kind" UNIQUE ("org_id", "folder_id", "name", "kind"),
    CONSTRAINT "UQE_library_element_org_id_uid" UNIQUE ("org_id", "uid"),
    CONSTRAINT "library_element_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "library_element";

DROP TABLE IF EXISTS "library_element_connection";
DROP SEQUENCE IF EXISTS library_element_connection_id_seq;
CREATE SEQUENCE library_element_connection_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."library_element_connection" (
    "id" integer DEFAULT nextval('library_element_connection_id_seq') NOT NULL,
    "element_id" bigint NOT NULL,
    "kind" bigint NOT NULL,
    "connection_id" bigint NOT NULL,
    "created" timestamp NOT NULL,
    "created_by" bigint NOT NULL,
    CONSTRAINT "UQE_library_element_connection_element_id_kind_connection_id" UNIQUE ("element_id", "kind", "connection_id"),
    CONSTRAINT "library_element_connection_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "library_element_connection";

DROP TABLE IF EXISTS "login_attempt";
DROP SEQUENCE IF EXISTS login_attempt_id_seq1;
CREATE SEQUENCE login_attempt_id_seq1 INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."login_attempt" (
    "id" integer DEFAULT nextval('login_attempt_id_seq1') NOT NULL,
    "username" character varying(190) NOT NULL,
    "ip_address" character varying(30) NOT NULL,
    "created" integer DEFAULT '0' NOT NULL,
    CONSTRAINT "login_attempt_pkey1" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_login_attempt_username" ON "public"."login_attempt" USING btree ("username");

TRUNCATE "login_attempt";

DROP TABLE IF EXISTS "migration_log";
DROP SEQUENCE IF EXISTS migration_log_id_seq;
CREATE SEQUENCE migration_log_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 429 CACHE 1;

CREATE TABLE "public"."migration_log" (
    "id" integer DEFAULT nextval('migration_log_id_seq') NOT NULL,
    "migration_id" character varying(255) NOT NULL,
    "sql" text NOT NULL,
    "success" boolean NOT NULL,
    "error" text NOT NULL,
    "timestamp" timestamp NOT NULL,
    CONSTRAINT "migration_log_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "migration_log";
INSERT INTO "migration_log" ("id", "migration_id", "sql", "success", "error", "timestamp") VALUES
(1,	'create migration_log table',	'CREATE TABLE IF NOT EXISTS "migration_log" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "migration_id" VARCHAR(255) NOT NULL
, "sql" TEXT NOT NULL
, "success" BOOL NOT NULL
, "error" TEXT NOT NULL
, "timestamp" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:16'),
(2,	'create user table',	'CREATE TABLE IF NOT EXISTS "user" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "version" INTEGER NOT NULL
, "login" VARCHAR(190) NOT NULL
, "email" VARCHAR(190) NOT NULL
, "name" VARCHAR(255) NULL
, "password" VARCHAR(255) NULL
, "salt" VARCHAR(50) NULL
, "rands" VARCHAR(50) NULL
, "company" VARCHAR(255) NULL
, "account_id" BIGINT NOT NULL
, "is_admin" BOOL NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:16'),
(3,	'add unique index user.login',	'CREATE UNIQUE INDEX "UQE_user_login" ON "user" ("login");',	'1',	'',	'2022-07-27 16:49:16'),
(4,	'add unique index user.email',	'CREATE UNIQUE INDEX "UQE_user_email" ON "user" ("email");',	'1',	'',	'2022-07-27 16:49:16'),
(5,	'drop index UQE_user_login - v1',	'DROP INDEX "UQE_user_login" CASCADE',	'1',	'',	'2022-07-27 16:49:16'),
(6,	'drop index UQE_user_email - v1',	'DROP INDEX "UQE_user_email" CASCADE',	'1',	'',	'2022-07-27 16:49:16'),
(7,	'Rename table user to user_v1 - v1',	'ALTER TABLE "user" RENAME TO "user_v1"',	'1',	'',	'2022-07-27 16:49:16'),
(8,	'create user table v2',	'CREATE TABLE IF NOT EXISTS "user" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "version" INTEGER NOT NULL
, "login" VARCHAR(190) NOT NULL
, "email" VARCHAR(190) NOT NULL
, "name" VARCHAR(255) NULL
, "password" VARCHAR(255) NULL
, "salt" VARCHAR(50) NULL
, "rands" VARCHAR(50) NULL
, "company" VARCHAR(255) NULL
, "org_id" BIGINT NOT NULL
, "is_admin" BOOL NOT NULL
, "email_verified" BOOL NULL
, "theme" VARCHAR(255) NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:16'),
(9,	'create index UQE_user_login - v2',	'CREATE UNIQUE INDEX "UQE_user_login" ON "user" ("login");',	'1',	'',	'2022-07-27 16:49:16'),
(10,	'create index UQE_user_email - v2',	'CREATE UNIQUE INDEX "UQE_user_email" ON "user" ("email");',	'1',	'',	'2022-07-27 16:49:16'),
(11,	'copy data_source v1 to v2',	'INSERT INTO "user" ("created"
, "updated"
, "version"
, "login"
, "password"
, "rands"
, "org_id"
, "is_admin"
, "id"
, "email"
, "name"
, "salt"
, "company") SELECT "created"
, "updated"
, "version"
, "login"
, "password"
, "rands"
, "account_id"
, "is_admin"
, "id"
, "email"
, "name"
, "salt"
, "company" FROM "user_v1"',	'1',	'',	'2022-07-27 16:49:16'),
(12,	'Drop old table user_v1',	'DROP TABLE IF EXISTS "user_v1"',	'1',	'',	'2022-07-27 16:49:16'),
(13,	'Add column help_flags1 to user table',	'alter table "user" ADD COLUMN "help_flags1" BIGINT NOT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:16'),
(14,	'Update user table charset',	'ALTER TABLE "user" ALTER "login" TYPE VARCHAR(190), ALTER "email" TYPE VARCHAR(190), ALTER "name" TYPE VARCHAR(255), ALTER "password" TYPE VARCHAR(255), ALTER "salt" TYPE VARCHAR(50), ALTER "rands" TYPE VARCHAR(50), ALTER "company" TYPE VARCHAR(255), ALTER "theme" TYPE VARCHAR(255);',	'1',	'',	'2022-07-27 16:49:16'),
(15,	'Add last_seen_at column to user',	'alter table "user" ADD COLUMN "last_seen_at" TIMESTAMP NULL ',	'1',	'',	'2022-07-27 16:49:16'),
(16,	'Add missing user data',	'code migration',	'1',	'',	'2022-07-27 16:49:16'),
(17,	'Add is_disabled column to user',	'alter table "user" ADD COLUMN "is_disabled" BOOL NOT NULL DEFAULT FALSE ',	'1',	'',	'2022-07-27 16:49:16'),
(18,	'Add index user.login/user.email',	'CREATE INDEX "IDX_user_login_email" ON "user" ("login","email");',	'1',	'',	'2022-07-27 16:49:16'),
(19,	'Add is_service_account column to user',	'alter table "user" ADD COLUMN "is_service_account" BOOL NOT NULL DEFAULT FALSE ',	'1',	'',	'2022-07-27 16:49:16'),
(20,	'Update is_service_account column to nullable',	'ALTER TABLE `user` ALTER COLUMN is_service_account DROP NOT NULL;',	'1',	'',	'2022-07-27 16:49:16'),
(21,	'create temp user table v1-7',	'CREATE TABLE IF NOT EXISTS "temp_user" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "version" INTEGER NOT NULL
, "email" VARCHAR(190) NOT NULL
, "name" VARCHAR(255) NULL
, "role" VARCHAR(20) NULL
, "code" VARCHAR(190) NOT NULL
, "status" VARCHAR(20) NOT NULL
, "invited_by_user_id" BIGINT NULL
, "email_sent" BOOL NOT NULL
, "email_sent_on" TIMESTAMP NULL
, "remote_addr" VARCHAR(255) NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:16'),
(22,	'create index IDX_temp_user_email - v1-7',	'CREATE INDEX "IDX_temp_user_email" ON "temp_user" ("email");',	'1',	'',	'2022-07-27 16:49:16'),
(23,	'create index IDX_temp_user_org_id - v1-7',	'CREATE INDEX "IDX_temp_user_org_id" ON "temp_user" ("org_id");',	'1',	'',	'2022-07-27 16:49:16'),
(24,	'create index IDX_temp_user_code - v1-7',	'CREATE INDEX "IDX_temp_user_code" ON "temp_user" ("code");',	'1',	'',	'2022-07-27 16:49:16'),
(25,	'create index IDX_temp_user_status - v1-7',	'CREATE INDEX "IDX_temp_user_status" ON "temp_user" ("status");',	'1',	'',	'2022-07-27 16:49:16'),
(26,	'Update temp_user table charset',	'ALTER TABLE "temp_user" ALTER "email" TYPE VARCHAR(190), ALTER "name" TYPE VARCHAR(255), ALTER "role" TYPE VARCHAR(20), ALTER "code" TYPE VARCHAR(190), ALTER "status" TYPE VARCHAR(20), ALTER "remote_addr" TYPE VARCHAR(255);',	'1',	'',	'2022-07-27 16:49:16'),
(27,	'drop index IDX_temp_user_email - v1',	'DROP INDEX "IDX_temp_user_email" CASCADE',	'1',	'',	'2022-07-27 16:49:16'),
(28,	'drop index IDX_temp_user_org_id - v1',	'DROP INDEX "IDX_temp_user_org_id" CASCADE',	'1',	'',	'2022-07-27 16:49:16'),
(29,	'drop index IDX_temp_user_code - v1',	'DROP INDEX "IDX_temp_user_code" CASCADE',	'1',	'',	'2022-07-27 16:49:16'),
(30,	'drop index IDX_temp_user_status - v1',	'DROP INDEX "IDX_temp_user_status" CASCADE',	'1',	'',	'2022-07-27 16:49:16'),
(31,	'Rename table temp_user to temp_user_tmp_qwerty - v1',	'ALTER TABLE "temp_user" RENAME TO "temp_user_tmp_qwerty"',	'1',	'',	'2022-07-27 16:49:16'),
(32,	'create temp_user v2',	'CREATE TABLE IF NOT EXISTS "temp_user" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "version" INTEGER NOT NULL
, "email" VARCHAR(190) NOT NULL
, "name" VARCHAR(255) NULL
, "role" VARCHAR(20) NULL
, "code" VARCHAR(190) NOT NULL
, "status" VARCHAR(20) NOT NULL
, "invited_by_user_id" BIGINT NULL
, "email_sent" BOOL NOT NULL
, "email_sent_on" TIMESTAMP NULL
, "remote_addr" VARCHAR(255) NULL
, "created" INTEGER NOT NULL DEFAULT 0
, "updated" INTEGER NOT NULL DEFAULT 0
);',	'1',	'',	'2022-07-27 16:49:16'),
(33,	'create index IDX_temp_user_email - v2',	'CREATE INDEX "IDX_temp_user_email" ON "temp_user" ("email");',	'1',	'',	'2022-07-27 16:49:16'),
(34,	'create index IDX_temp_user_org_id - v2',	'CREATE INDEX "IDX_temp_user_org_id" ON "temp_user" ("org_id");',	'1',	'',	'2022-07-27 16:49:16'),
(35,	'create index IDX_temp_user_code - v2',	'CREATE INDEX "IDX_temp_user_code" ON "temp_user" ("code");',	'1',	'',	'2022-07-27 16:49:16'),
(36,	'create index IDX_temp_user_status - v2',	'CREATE INDEX "IDX_temp_user_status" ON "temp_user" ("status");',	'1',	'',	'2022-07-27 16:49:16'),
(37,	'copy temp_user v1 to v2',	'INSERT INTO "temp_user" ("invited_by_user_id"
, "email_sent"
, "remote_addr"
, "org_id"
, "version"
, "role"
, "status"
, "email_sent_on"
, "id"
, "email"
, "name"
, "code") SELECT "invited_by_user_id"
, "email_sent"
, "remote_addr"
, "org_id"
, "version"
, "role"
, "status"
, "email_sent_on"
, "id"
, "email"
, "name"
, "code" FROM "temp_user_tmp_qwerty"',	'1',	'',	'2022-07-27 16:49:16'),
(38,	'drop temp_user_tmp_qwerty',	'DROP TABLE IF EXISTS "temp_user_tmp_qwerty"',	'1',	'',	'2022-07-27 16:49:16'),
(39,	'Set created for temp users that will otherwise prematurely expire',	'code migration',	'1',	'',	'2022-07-27 16:49:16'),
(122,	'drop index UQE_api_key_key - v1',	'DROP INDEX "UQE_api_key_key" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(40,	'create star table',	'CREATE TABLE IF NOT EXISTS "star" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "user_id" BIGINT NOT NULL
, "dashboard_id" BIGINT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:16'),
(41,	'add unique index star.user_id_dashboard_id',	'CREATE UNIQUE INDEX "UQE_star_user_id_dashboard_id" ON "star" ("user_id","dashboard_id");',	'1',	'',	'2022-07-27 16:49:16'),
(42,	'create org table v1',	'CREATE TABLE IF NOT EXISTS "org" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "version" INTEGER NOT NULL
, "name" VARCHAR(190) NOT NULL
, "address1" VARCHAR(255) NULL
, "address2" VARCHAR(255) NULL
, "city" VARCHAR(255) NULL
, "state" VARCHAR(255) NULL
, "zip_code" VARCHAR(50) NULL
, "country" VARCHAR(255) NULL
, "billing_email" VARCHAR(255) NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:16'),
(43,	'create index UQE_org_name - v1',	'CREATE UNIQUE INDEX "UQE_org_name" ON "org" ("name");',	'1',	'',	'2022-07-27 16:49:16'),
(44,	'create org_user table v1',	'CREATE TABLE IF NOT EXISTS "org_user" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "user_id" BIGINT NOT NULL
, "role" VARCHAR(20) NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:16'),
(45,	'create index IDX_org_user_org_id - v1',	'CREATE INDEX "IDX_org_user_org_id" ON "org_user" ("org_id");',	'1',	'',	'2022-07-27 16:49:16'),
(46,	'create index UQE_org_user_org_id_user_id - v1',	'CREATE UNIQUE INDEX "UQE_org_user_org_id_user_id" ON "org_user" ("org_id","user_id");',	'1',	'',	'2022-07-27 16:49:16'),
(47,	'create index IDX_org_user_user_id - v1',	'CREATE INDEX "IDX_org_user_user_id" ON "org_user" ("user_id");',	'1',	'',	'2022-07-27 16:49:16'),
(48,	'Update org table charset',	'ALTER TABLE "org" ALTER "name" TYPE VARCHAR(190), ALTER "address1" TYPE VARCHAR(255), ALTER "address2" TYPE VARCHAR(255), ALTER "city" TYPE VARCHAR(255), ALTER "state" TYPE VARCHAR(255), ALTER "zip_code" TYPE VARCHAR(50), ALTER "country" TYPE VARCHAR(255), ALTER "billing_email" TYPE VARCHAR(255);',	'1',	'',	'2022-07-27 16:49:16'),
(49,	'Update org_user table charset',	'ALTER TABLE "org_user" ALTER "role" TYPE VARCHAR(20);',	'1',	'',	'2022-07-27 16:49:16'),
(50,	'Migrate all Read Only Viewers to Viewers',	'UPDATE org_user SET role = ''Viewer'' WHERE role = ''Read Only Editor''',	'1',	'',	'2022-07-27 16:49:16'),
(51,	'create dashboard table',	'CREATE TABLE IF NOT EXISTS "dashboard" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "version" INTEGER NOT NULL
, "slug" VARCHAR(189) NOT NULL
, "title" VARCHAR(255) NOT NULL
, "data" TEXT NOT NULL
, "account_id" BIGINT NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:16'),
(52,	'add index dashboard.account_id',	'CREATE INDEX "IDX_dashboard_account_id" ON "dashboard" ("account_id");',	'1',	'',	'2022-07-27 16:49:16'),
(53,	'add unique index dashboard_account_id_slug',	'CREATE UNIQUE INDEX "UQE_dashboard_account_id_slug" ON "dashboard" ("account_id","slug");',	'1',	'',	'2022-07-27 16:49:16'),
(54,	'create dashboard_tag table',	'CREATE TABLE IF NOT EXISTS "dashboard_tag" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "dashboard_id" BIGINT NOT NULL
, "term" VARCHAR(50) NOT NULL
);',	'1',	'',	'2022-07-27 16:49:16'),
(55,	'add unique index dashboard_tag.dasboard_id_term',	'CREATE UNIQUE INDEX "UQE_dashboard_tag_dashboard_id_term" ON "dashboard_tag" ("dashboard_id","term");',	'1',	'',	'2022-07-27 16:49:16'),
(56,	'drop index UQE_dashboard_tag_dashboard_id_term - v1',	'DROP INDEX "UQE_dashboard_tag_dashboard_id_term" CASCADE',	'1',	'',	'2022-07-27 16:49:16'),
(57,	'Rename table dashboard to dashboard_v1 - v1',	'ALTER TABLE "dashboard" RENAME TO "dashboard_v1"',	'1',	'',	'2022-07-27 16:49:16'),
(58,	'create dashboard v2',	'CREATE TABLE IF NOT EXISTS "dashboard" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "version" INTEGER NOT NULL
, "slug" VARCHAR(189) NOT NULL
, "title" VARCHAR(255) NOT NULL
, "data" TEXT NOT NULL
, "org_id" BIGINT NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:16'),
(59,	'create index IDX_dashboard_org_id - v2',	'CREATE INDEX "IDX_dashboard_org_id" ON "dashboard" ("org_id");',	'1',	'',	'2022-07-27 16:49:16'),
(60,	'create index UQE_dashboard_org_id_slug - v2',	'CREATE UNIQUE INDEX "UQE_dashboard_org_id_slug" ON "dashboard" ("org_id","slug");',	'1',	'',	'2022-07-27 16:49:16'),
(61,	'copy dashboard v1 to v2',	'INSERT INTO "dashboard" ("id"
, "version"
, "slug"
, "title"
, "data"
, "org_id"
, "created"
, "updated") SELECT "id"
, "version"
, "slug"
, "title"
, "data"
, "account_id"
, "created"
, "updated" FROM "dashboard_v1"',	'1',	'',	'2022-07-27 16:49:16'),
(62,	'drop table dashboard_v1',	'DROP TABLE IF EXISTS "dashboard_v1"',	'1',	'',	'2022-07-27 16:49:16'),
(63,	'alter dashboard.data to mediumtext v1',	'SELECT 0;',	'1',	'',	'2022-07-27 16:49:16'),
(64,	'Add column updated_by in dashboard - v2',	'alter table "dashboard" ADD COLUMN "updated_by" INTEGER NULL ',	'1',	'',	'2022-07-27 16:49:16'),
(65,	'Add column created_by in dashboard - v2',	'alter table "dashboard" ADD COLUMN "created_by" INTEGER NULL ',	'1',	'',	'2022-07-27 16:49:16'),
(66,	'Add column gnetId in dashboard',	'alter table "dashboard" ADD COLUMN "gnet_id" BIGINT NULL ',	'1',	'',	'2022-07-27 16:49:16'),
(67,	'Add index for gnetId in dashboard',	'CREATE INDEX "IDX_dashboard_gnet_id" ON "dashboard" ("gnet_id");',	'1',	'',	'2022-07-27 16:49:16'),
(68,	'Add column plugin_id in dashboard',	'alter table "dashboard" ADD COLUMN "plugin_id" VARCHAR(189) NULL ',	'1',	'',	'2022-07-27 16:49:16'),
(69,	'Add index for plugin_id in dashboard',	'CREATE INDEX "IDX_dashboard_org_id_plugin_id" ON "dashboard" ("org_id","plugin_id");',	'1',	'',	'2022-07-27 16:49:16'),
(70,	'Add index for dashboard_id in dashboard_tag',	'CREATE INDEX "IDX_dashboard_tag_dashboard_id" ON "dashboard_tag" ("dashboard_id");',	'1',	'',	'2022-07-27 16:49:16'),
(71,	'Update dashboard table charset',	'ALTER TABLE "dashboard" ALTER "slug" TYPE VARCHAR(189), ALTER "title" TYPE VARCHAR(255), ALTER "plugin_id" TYPE VARCHAR(189), ALTER "data" TYPE TEXT;',	'1',	'',	'2022-07-27 16:49:16'),
(72,	'Update dashboard_tag table charset',	'ALTER TABLE "dashboard_tag" ALTER "term" TYPE VARCHAR(50);',	'1',	'',	'2022-07-27 16:49:16'),
(73,	'Add column folder_id in dashboard',	'alter table "dashboard" ADD COLUMN "folder_id" BIGINT NOT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:17'),
(74,	'Add column isFolder in dashboard',	'alter table "dashboard" ADD COLUMN "is_folder" BOOL NOT NULL DEFAULT FALSE ',	'1',	'',	'2022-07-27 16:49:17'),
(75,	'Add column has_acl in dashboard',	'alter table "dashboard" ADD COLUMN "has_acl" BOOL NOT NULL DEFAULT FALSE ',	'1',	'',	'2022-07-27 16:49:17'),
(76,	'Add column uid in dashboard',	'alter table "dashboard" ADD COLUMN "uid" VARCHAR(40) NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(77,	'Update uid column values in dashboard',	'UPDATE dashboard SET uid=lpad('''' || id::text,9,''0'') WHERE uid IS NULL;',	'1',	'',	'2022-07-27 16:49:17'),
(78,	'Add unique index dashboard_org_id_uid',	'CREATE UNIQUE INDEX "UQE_dashboard_org_id_uid" ON "dashboard" ("org_id","uid");',	'1',	'',	'2022-07-27 16:49:17'),
(79,	'Remove unique index org_id_slug',	'DROP INDEX "UQE_dashboard_org_id_slug" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(80,	'Update dashboard title length',	'ALTER TABLE "dashboard" ALTER "title" TYPE VARCHAR(189);',	'1',	'',	'2022-07-27 16:49:17'),
(81,	'Add unique index for dashboard_org_id_title_folder_id',	'CREATE UNIQUE INDEX "UQE_dashboard_org_id_folder_id_title" ON "dashboard" ("org_id","folder_id","title");',	'1',	'',	'2022-07-27 16:49:17'),
(82,	'create dashboard_provisioning',	'CREATE TABLE IF NOT EXISTS "dashboard_provisioning" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "dashboard_id" BIGINT NULL
, "name" VARCHAR(150) NOT NULL
, "external_id" TEXT NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(83,	'Rename table dashboard_provisioning to dashboard_provisioning_tmp_qwerty - v1',	'ALTER TABLE "dashboard_provisioning" RENAME TO "dashboard_provisioning_tmp_qwerty"',	'1',	'',	'2022-07-27 16:49:17'),
(84,	'create dashboard_provisioning v2',	'CREATE TABLE IF NOT EXISTS "dashboard_provisioning" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "dashboard_id" BIGINT NULL
, "name" VARCHAR(150) NOT NULL
, "external_id" TEXT NOT NULL
, "updated" INTEGER NOT NULL DEFAULT 0
);',	'1',	'',	'2022-07-27 16:49:17'),
(85,	'create index IDX_dashboard_provisioning_dashboard_id - v2',	'CREATE INDEX "IDX_dashboard_provisioning_dashboard_id" ON "dashboard_provisioning" ("dashboard_id");',	'1',	'',	'2022-07-27 16:49:17'),
(86,	'create index IDX_dashboard_provisioning_dashboard_id_name - v2',	'CREATE INDEX "IDX_dashboard_provisioning_dashboard_id_name" ON "dashboard_provisioning" ("dashboard_id","name");',	'1',	'',	'2022-07-27 16:49:17'),
(87,	'copy dashboard_provisioning v1 to v2',	'INSERT INTO "dashboard_provisioning" ("id"
, "dashboard_id"
, "name"
, "external_id") SELECT "id"
, "dashboard_id"
, "name"
, "external_id" FROM "dashboard_provisioning_tmp_qwerty"',	'1',	'',	'2022-07-27 16:49:17'),
(88,	'drop dashboard_provisioning_tmp_qwerty',	'DROP TABLE IF EXISTS "dashboard_provisioning_tmp_qwerty"',	'1',	'',	'2022-07-27 16:49:17'),
(89,	'Add check_sum column',	'alter table "dashboard_provisioning" ADD COLUMN "check_sum" VARCHAR(32) NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(90,	'Add index for dashboard_title',	'CREATE INDEX "IDX_dashboard_title" ON "dashboard" ("title");',	'1',	'',	'2022-07-27 16:49:17'),
(91,	'delete tags for deleted dashboards',	'DELETE FROM dashboard_tag WHERE dashboard_id NOT IN (SELECT id FROM dashboard)',	'1',	'',	'2022-07-27 16:49:17'),
(92,	'delete stars for deleted dashboards',	'DELETE FROM star WHERE dashboard_id NOT IN (SELECT id FROM dashboard)',	'1',	'',	'2022-07-27 16:49:17'),
(93,	'Add index for dashboard_is_folder',	'CREATE INDEX "IDX_dashboard_is_folder" ON "dashboard" ("is_folder");',	'1',	'',	'2022-07-27 16:49:17'),
(94,	'Add isPublic for dashboard',	'alter table "dashboard" ADD COLUMN "is_public" BOOL NOT NULL DEFAULT FALSE ',	'1',	'',	'2022-07-27 16:49:17'),
(95,	'create data_source table',	'CREATE TABLE IF NOT EXISTS "data_source" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "account_id" BIGINT NOT NULL
, "version" INTEGER NOT NULL
, "type" VARCHAR(255) NOT NULL
, "name" VARCHAR(190) NOT NULL
, "access" VARCHAR(255) NOT NULL
, "url" VARCHAR(255) NOT NULL
, "password" VARCHAR(255) NULL
, "user" VARCHAR(255) NULL
, "database" VARCHAR(255) NULL
, "basic_auth" BOOL NOT NULL
, "basic_auth_user" VARCHAR(255) NULL
, "basic_auth_password" VARCHAR(255) NULL
, "is_default" BOOL NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(96,	'add index data_source.account_id',	'CREATE INDEX "IDX_data_source_account_id" ON "data_source" ("account_id");',	'1',	'',	'2022-07-27 16:49:17'),
(97,	'add unique index data_source.account_id_name',	'CREATE UNIQUE INDEX "UQE_data_source_account_id_name" ON "data_source" ("account_id","name");',	'1',	'',	'2022-07-27 16:49:17'),
(98,	'drop index IDX_data_source_account_id - v1',	'DROP INDEX "IDX_data_source_account_id" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(99,	'drop index UQE_data_source_account_id_name - v1',	'DROP INDEX "UQE_data_source_account_id_name" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(100,	'Rename table data_source to data_source_v1 - v1',	'ALTER TABLE "data_source" RENAME TO "data_source_v1"',	'1',	'',	'2022-07-27 16:49:17'),
(101,	'create data_source table v2',	'CREATE TABLE IF NOT EXISTS "data_source" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "version" INTEGER NOT NULL
, "type" VARCHAR(255) NOT NULL
, "name" VARCHAR(190) NOT NULL
, "access" VARCHAR(255) NOT NULL
, "url" VARCHAR(255) NOT NULL
, "password" VARCHAR(255) NULL
, "user" VARCHAR(255) NULL
, "database" VARCHAR(255) NULL
, "basic_auth" BOOL NOT NULL
, "basic_auth_user" VARCHAR(255) NULL
, "basic_auth_password" VARCHAR(255) NULL
, "is_default" BOOL NOT NULL
, "json_data" TEXT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(102,	'create index IDX_data_source_org_id - v2',	'CREATE INDEX "IDX_data_source_org_id" ON "data_source" ("org_id");',	'1',	'',	'2022-07-27 16:49:17'),
(103,	'create index UQE_data_source_org_id_name - v2',	'CREATE UNIQUE INDEX "UQE_data_source_org_id_name" ON "data_source" ("org_id","name");',	'1',	'',	'2022-07-27 16:49:17'),
(104,	'copy data_source v1 to v2',	'INSERT INTO "data_source" ("id"
, "name"
, "basic_auth"
, "created"
, "access"
, "basic_auth_password"
, "is_default"
, "updated"
, "org_id"
, "version"
, "type"
, "url"
, "user"
, "password"
, "basic_auth_user"
, "database") SELECT "id"
, "name"
, "basic_auth"
, "created"
, "access"
, "basic_auth_password"
, "is_default"
, "updated"
, "account_id"
, "version"
, "type"
, "url"
, "user"
, "password"
, "basic_auth_user"
, "database" FROM "data_source_v1"',	'1',	'',	'2022-07-27 16:49:17'),
(105,	'Drop old table data_source_v1 #2',	'DROP TABLE IF EXISTS "data_source_v1"',	'1',	'',	'2022-07-27 16:49:17'),
(106,	'Add column with_credentials',	'alter table "data_source" ADD COLUMN "with_credentials" BOOL NOT NULL DEFAULT FALSE ',	'1',	'',	'2022-07-27 16:49:17'),
(107,	'Add secure json data column',	'alter table "data_source" ADD COLUMN "secure_json_data" TEXT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(108,	'Update data_source table charset',	'ALTER TABLE "data_source" ALTER "type" TYPE VARCHAR(255), ALTER "name" TYPE VARCHAR(190), ALTER "access" TYPE VARCHAR(255), ALTER "url" TYPE VARCHAR(255), ALTER "password" TYPE VARCHAR(255), ALTER "user" TYPE VARCHAR(255), ALTER "database" TYPE VARCHAR(255), ALTER "basic_auth_user" TYPE VARCHAR(255), ALTER "basic_auth_password" TYPE VARCHAR(255), ALTER "json_data" TYPE TEXT, ALTER "secure_json_data" TYPE TEXT;',	'1',	'',	'2022-07-27 16:49:17'),
(109,	'Update initial version to 1',	'UPDATE data_source SET version = 1 WHERE version = 0',	'1',	'',	'2022-07-27 16:49:17'),
(110,	'Add read_only data column',	'alter table "data_source" ADD COLUMN "read_only" BOOL NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(111,	'Migrate logging ds to loki ds',	'UPDATE data_source SET type = ''loki'' WHERE type = ''logging''',	'1',	'',	'2022-07-27 16:49:17'),
(112,	'Update json_data with nulls',	'UPDATE data_source SET json_data = ''{}'' WHERE json_data is null',	'1',	'',	'2022-07-27 16:49:17'),
(113,	'Add uid column',	'alter table "data_source" ADD COLUMN "uid" VARCHAR(40) NOT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:17'),
(114,	'Update uid value',	'UPDATE data_source SET uid=lpad('''' || id::text,9,''0'');',	'1',	'',	'2022-07-27 16:49:17'),
(115,	'Add unique index datasource_org_id_uid',	'CREATE UNIQUE INDEX "UQE_data_source_org_id_uid" ON "data_source" ("org_id","uid");',	'1',	'',	'2022-07-27 16:49:17'),
(116,	'add unique index datasource_org_id_is_default',	'CREATE INDEX "IDX_data_source_org_id_is_default" ON "data_source" ("org_id","is_default");',	'1',	'',	'2022-07-27 16:49:17'),
(117,	'create api_key table',	'CREATE TABLE IF NOT EXISTS "api_key" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "account_id" BIGINT NOT NULL
, "name" VARCHAR(190) NOT NULL
, "key" VARCHAR(64) NOT NULL
, "role" VARCHAR(255) NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(118,	'add index api_key.account_id',	'CREATE INDEX "IDX_api_key_account_id" ON "api_key" ("account_id");',	'1',	'',	'2022-07-27 16:49:17'),
(119,	'add index api_key.key',	'CREATE UNIQUE INDEX "UQE_api_key_key" ON "api_key" ("key");',	'1',	'',	'2022-07-27 16:49:17'),
(120,	'add index api_key.account_id_name',	'CREATE UNIQUE INDEX "UQE_api_key_account_id_name" ON "api_key" ("account_id","name");',	'1',	'',	'2022-07-27 16:49:17'),
(121,	'drop index IDX_api_key_account_id - v1',	'DROP INDEX "IDX_api_key_account_id" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(123,	'drop index UQE_api_key_account_id_name - v1',	'DROP INDEX "UQE_api_key_account_id_name" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(124,	'Rename table api_key to api_key_v1 - v1',	'ALTER TABLE "api_key" RENAME TO "api_key_v1"',	'1',	'',	'2022-07-27 16:49:17'),
(125,	'create api_key table v2',	'CREATE TABLE IF NOT EXISTS "api_key" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "name" VARCHAR(190) NOT NULL
, "key" VARCHAR(190) NOT NULL
, "role" VARCHAR(255) NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(126,	'create index IDX_api_key_org_id - v2',	'CREATE INDEX "IDX_api_key_org_id" ON "api_key" ("org_id");',	'1',	'',	'2022-07-27 16:49:17'),
(127,	'create index UQE_api_key_key - v2',	'CREATE UNIQUE INDEX "UQE_api_key_key" ON "api_key" ("key");',	'1',	'',	'2022-07-27 16:49:17'),
(128,	'create index UQE_api_key_org_id_name - v2',	'CREATE UNIQUE INDEX "UQE_api_key_org_id_name" ON "api_key" ("org_id","name");',	'1',	'',	'2022-07-27 16:49:17'),
(129,	'copy api_key v1 to v2',	'INSERT INTO "api_key" ("id"
, "org_id"
, "name"
, "key"
, "role"
, "created"
, "updated") SELECT "id"
, "account_id"
, "name"
, "key"
, "role"
, "created"
, "updated" FROM "api_key_v1"',	'1',	'',	'2022-07-27 16:49:17'),
(130,	'Drop old table api_key_v1',	'DROP TABLE IF EXISTS "api_key_v1"',	'1',	'',	'2022-07-27 16:49:17'),
(131,	'Update api_key table charset',	'ALTER TABLE "api_key" ALTER "name" TYPE VARCHAR(190), ALTER "key" TYPE VARCHAR(190), ALTER "role" TYPE VARCHAR(255);',	'1',	'',	'2022-07-27 16:49:17'),
(132,	'Add expires to api_key table',	'alter table "api_key" ADD COLUMN "expires" BIGINT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(133,	'Add service account foreign key',	'alter table "api_key" ADD COLUMN "service_account_id" BIGINT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(134,	'set service account foreign key to nil if 0',	'UPDATE api_key SET service_account_id = NULL WHERE service_account_id = 0;',	'1',	'',	'2022-07-27 16:49:17'),
(135,	'create dashboard_snapshot table v4',	'CREATE TABLE IF NOT EXISTS "dashboard_snapshot" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "name" VARCHAR(255) NOT NULL
, "key" VARCHAR(190) NOT NULL
, "dashboard" TEXT NOT NULL
, "expires" TIMESTAMP NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(136,	'drop table dashboard_snapshot_v4 #1',	'DROP TABLE IF EXISTS "dashboard_snapshot"',	'1',	'',	'2022-07-27 16:49:17'),
(137,	'create dashboard_snapshot table v5 #2',	'CREATE TABLE IF NOT EXISTS "dashboard_snapshot" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "name" VARCHAR(255) NOT NULL
, "key" VARCHAR(190) NOT NULL
, "delete_key" VARCHAR(190) NOT NULL
, "org_id" BIGINT NOT NULL
, "user_id" BIGINT NOT NULL
, "external" BOOL NOT NULL
, "external_url" VARCHAR(255) NOT NULL
, "dashboard" TEXT NOT NULL
, "expires" TIMESTAMP NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(138,	'create index UQE_dashboard_snapshot_key - v5',	'CREATE UNIQUE INDEX "UQE_dashboard_snapshot_key" ON "dashboard_snapshot" ("key");',	'1',	'',	'2022-07-27 16:49:17'),
(139,	'create index UQE_dashboard_snapshot_delete_key - v5',	'CREATE UNIQUE INDEX "UQE_dashboard_snapshot_delete_key" ON "dashboard_snapshot" ("delete_key");',	'1',	'',	'2022-07-27 16:49:17'),
(140,	'create index IDX_dashboard_snapshot_user_id - v5',	'CREATE INDEX "IDX_dashboard_snapshot_user_id" ON "dashboard_snapshot" ("user_id");',	'1',	'',	'2022-07-27 16:49:17'),
(141,	'alter dashboard_snapshot to mediumtext v2',	'SELECT 0;',	'1',	'',	'2022-07-27 16:49:17'),
(142,	'Update dashboard_snapshot table charset',	'ALTER TABLE "dashboard_snapshot" ALTER "name" TYPE VARCHAR(255), ALTER "key" TYPE VARCHAR(190), ALTER "delete_key" TYPE VARCHAR(190), ALTER "external_url" TYPE VARCHAR(255), ALTER "dashboard" TYPE TEXT;',	'1',	'',	'2022-07-27 16:49:17'),
(143,	'Add column external_delete_url to dashboard_snapshots table',	'alter table "dashboard_snapshot" ADD COLUMN "external_delete_url" VARCHAR(255) NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(144,	'Add encrypted dashboard json column',	'alter table "dashboard_snapshot" ADD COLUMN "dashboard_encrypted" BYTEA NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(145,	'Change dashboard_encrypted column to MEDIUMBLOB',	'SELECT 0;',	'1',	'',	'2022-07-27 16:49:17'),
(146,	'create quota table v1',	'CREATE TABLE IF NOT EXISTS "quota" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NULL
, "user_id" BIGINT NULL
, "target" VARCHAR(190) NOT NULL
, "limit" BIGINT NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(147,	'create index UQE_quota_org_id_user_id_target - v1',	'CREATE UNIQUE INDEX "UQE_quota_org_id_user_id_target" ON "quota" ("org_id","user_id","target");',	'1',	'',	'2022-07-27 16:49:17'),
(148,	'Update quota table charset',	'ALTER TABLE "quota" ALTER "target" TYPE VARCHAR(190);',	'1',	'',	'2022-07-27 16:49:17'),
(149,	'create plugin_setting table',	'CREATE TABLE IF NOT EXISTS "plugin_setting" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NULL
, "plugin_id" VARCHAR(190) NOT NULL
, "enabled" BOOL NOT NULL
, "pinned" BOOL NOT NULL
, "json_data" TEXT NULL
, "secure_json_data" TEXT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(150,	'create index UQE_plugin_setting_org_id_plugin_id - v1',	'CREATE UNIQUE INDEX "UQE_plugin_setting_org_id_plugin_id" ON "plugin_setting" ("org_id","plugin_id");',	'1',	'',	'2022-07-27 16:49:17'),
(151,	'Add column plugin_version to plugin_settings',	'alter table "plugin_setting" ADD COLUMN "plugin_version" VARCHAR(50) NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(152,	'Update plugin_setting table charset',	'ALTER TABLE "plugin_setting" ALTER "plugin_id" TYPE VARCHAR(190), ALTER "json_data" TYPE TEXT, ALTER "secure_json_data" TYPE TEXT, ALTER "plugin_version" TYPE VARCHAR(50);',	'1',	'',	'2022-07-27 16:49:17'),
(153,	'create session table',	'CREATE TABLE IF NOT EXISTS "session" (
"key" CHAR(16) PRIMARY KEY NOT NULL
, "data" BYTEA NOT NULL
, "expiry" INTEGER NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(154,	'Drop old table playlist table',	'DROP TABLE IF EXISTS "playlist"',	'1',	'',	'2022-07-27 16:49:17'),
(155,	'Drop old table playlist_item table',	'DROP TABLE IF EXISTS "playlist_item"',	'1',	'',	'2022-07-27 16:49:17'),
(156,	'create playlist table v2',	'CREATE TABLE IF NOT EXISTS "playlist" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "name" VARCHAR(255) NOT NULL
, "interval" VARCHAR(255) NOT NULL
, "org_id" BIGINT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(157,	'create playlist item table v2',	'CREATE TABLE IF NOT EXISTS "playlist_item" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "playlist_id" BIGINT NOT NULL
, "type" VARCHAR(255) NOT NULL
, "value" TEXT NOT NULL
, "title" TEXT NOT NULL
, "order" INTEGER NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(158,	'Update playlist table charset',	'ALTER TABLE "playlist" ALTER "name" TYPE VARCHAR(255), ALTER "interval" TYPE VARCHAR(255);',	'1',	'',	'2022-07-27 16:49:17'),
(159,	'Update playlist_item table charset',	'ALTER TABLE "playlist_item" ALTER "type" TYPE VARCHAR(255), ALTER "value" TYPE TEXT, ALTER "title" TYPE TEXT;',	'1',	'',	'2022-07-27 16:49:17'),
(160,	'drop preferences table v2',	'DROP TABLE IF EXISTS "preferences"',	'1',	'',	'2022-07-27 16:49:17'),
(161,	'drop preferences table v3',	'DROP TABLE IF EXISTS "preferences"',	'1',	'',	'2022-07-27 16:49:17'),
(162,	'create preferences table v3',	'CREATE TABLE IF NOT EXISTS "preferences" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "user_id" BIGINT NOT NULL
, "version" INTEGER NOT NULL
, "home_dashboard_id" BIGINT NOT NULL
, "timezone" VARCHAR(50) NOT NULL
, "theme" VARCHAR(20) NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(405,	'dashboard permissions',	'code migration',	'1',	'',	'2022-07-27 16:49:18'),
(163,	'Update preferences table charset',	'ALTER TABLE "preferences" ALTER "timezone" TYPE VARCHAR(50), ALTER "theme" TYPE VARCHAR(20);',	'1',	'',	'2022-07-27 16:49:17'),
(164,	'Add column team_id in preferences',	'alter table "preferences" ADD COLUMN "team_id" BIGINT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(165,	'Update team_id column values in preferences',	'UPDATE preferences SET team_id=0 WHERE team_id IS NULL;',	'1',	'',	'2022-07-27 16:49:17'),
(166,	'Add column week_start in preferences',	'alter table "preferences" ADD COLUMN "week_start" VARCHAR(10) NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(167,	'Add column preferences.json_data',	'alter table "preferences" ADD COLUMN "json_data" TEXT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(168,	'alter preferences.json_data to mediumtext v1',	'SELECT 0;',	'1',	'',	'2022-07-27 16:49:17'),
(169,	'create alert table v1',	'CREATE TABLE IF NOT EXISTS "alert" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "version" BIGINT NOT NULL
, "dashboard_id" BIGINT NOT NULL
, "panel_id" BIGINT NOT NULL
, "org_id" BIGINT NOT NULL
, "name" VARCHAR(255) NOT NULL
, "message" TEXT NOT NULL
, "state" VARCHAR(190) NOT NULL
, "settings" TEXT NOT NULL
, "frequency" BIGINT NOT NULL
, "handler" BIGINT NOT NULL
, "severity" TEXT NOT NULL
, "silenced" BOOL NOT NULL
, "execution_error" TEXT NOT NULL
, "eval_data" TEXT NULL
, "eval_date" TIMESTAMP NULL
, "new_state_date" TIMESTAMP NOT NULL
, "state_changes" INTEGER NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(170,	'add index alert org_id & id ',	'CREATE INDEX "IDX_alert_org_id_id" ON "alert" ("org_id","id");',	'1',	'',	'2022-07-27 16:49:17'),
(171,	'add index alert state',	'CREATE INDEX "IDX_alert_state" ON "alert" ("state");',	'1',	'',	'2022-07-27 16:49:17'),
(172,	'add index alert dashboard_id',	'CREATE INDEX "IDX_alert_dashboard_id" ON "alert" ("dashboard_id");',	'1',	'',	'2022-07-27 16:49:17'),
(173,	'Create alert_rule_tag table v1',	'CREATE TABLE IF NOT EXISTS "alert_rule_tag" (
"alert_id" BIGINT NOT NULL
, "tag_id" BIGINT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(174,	'Add unique index alert_rule_tag.alert_id_tag_id',	'CREATE UNIQUE INDEX "UQE_alert_rule_tag_alert_id_tag_id" ON "alert_rule_tag" ("alert_id","tag_id");',	'1',	'',	'2022-07-27 16:49:17'),
(175,	'drop index UQE_alert_rule_tag_alert_id_tag_id - v1',	'DROP INDEX "UQE_alert_rule_tag_alert_id_tag_id" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(176,	'Rename table alert_rule_tag to alert_rule_tag_v1 - v1',	'ALTER TABLE "alert_rule_tag" RENAME TO "alert_rule_tag_v1"',	'1',	'',	'2022-07-27 16:49:17'),
(177,	'Create alert_rule_tag table v2',	'CREATE TABLE IF NOT EXISTS "alert_rule_tag" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "alert_id" BIGINT NOT NULL
, "tag_id" BIGINT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(178,	'create index UQE_alert_rule_tag_alert_id_tag_id - Add unique index alert_rule_tag.alert_id_tag_id V2',	'CREATE UNIQUE INDEX "UQE_alert_rule_tag_alert_id_tag_id" ON "alert_rule_tag" ("alert_id","tag_id");',	'1',	'',	'2022-07-27 16:49:17'),
(179,	'copy alert_rule_tag v1 to v2',	'INSERT INTO "alert_rule_tag" ("alert_id"
, "tag_id") SELECT "alert_id"
, "tag_id" FROM "alert_rule_tag_v1"',	'1',	'',	'2022-07-27 16:49:17'),
(180,	'drop table alert_rule_tag_v1',	'DROP TABLE IF EXISTS "alert_rule_tag_v1"',	'1',	'',	'2022-07-27 16:49:17'),
(181,	'create alert_notification table v1',	'CREATE TABLE IF NOT EXISTS "alert_notification" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "name" VARCHAR(190) NOT NULL
, "type" VARCHAR(255) NOT NULL
, "settings" TEXT NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(182,	'Add column is_default',	'alter table "alert_notification" ADD COLUMN "is_default" BOOL NOT NULL DEFAULT FALSE ',	'1',	'',	'2022-07-27 16:49:17'),
(183,	'Add column frequency',	'alter table "alert_notification" ADD COLUMN "frequency" BIGINT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(184,	'Add column send_reminder',	'alter table "alert_notification" ADD COLUMN "send_reminder" BOOL NULL DEFAULT FALSE ',	'1',	'',	'2022-07-27 16:49:17'),
(185,	'Add column disable_resolve_message',	'alter table "alert_notification" ADD COLUMN "disable_resolve_message" BOOL NOT NULL DEFAULT FALSE ',	'1',	'',	'2022-07-27 16:49:17'),
(186,	'add index alert_notification org_id & name',	'CREATE UNIQUE INDEX "UQE_alert_notification_org_id_name" ON "alert_notification" ("org_id","name");',	'1',	'',	'2022-07-27 16:49:17'),
(187,	'Update alert table charset',	'ALTER TABLE "alert" ALTER "name" TYPE VARCHAR(255), ALTER "message" TYPE TEXT, ALTER "state" TYPE VARCHAR(190), ALTER "settings" TYPE TEXT, ALTER "severity" TYPE TEXT, ALTER "execution_error" TYPE TEXT, ALTER "eval_data" TYPE TEXT;',	'1',	'',	'2022-07-27 16:49:17'),
(188,	'Update alert_notification table charset',	'ALTER TABLE "alert_notification" ALTER "name" TYPE VARCHAR(190), ALTER "type" TYPE VARCHAR(255), ALTER "settings" TYPE TEXT;',	'1',	'',	'2022-07-27 16:49:17'),
(189,	'create notification_journal table v1',	'CREATE TABLE IF NOT EXISTS "alert_notification_journal" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "alert_id" BIGINT NOT NULL
, "notifier_id" BIGINT NOT NULL
, "sent_at" BIGINT NOT NULL
, "success" BOOL NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(190,	'add index notification_journal org_id & alert_id & notifier_id',	'CREATE INDEX "IDX_alert_notification_journal_org_id_alert_id_notifier_id" ON "alert_notification_journal" ("org_id","alert_id","notifier_id");',	'1',	'',	'2022-07-27 16:49:17'),
(191,	'drop alert_notification_journal',	'DROP TABLE IF EXISTS "alert_notification_journal"',	'1',	'',	'2022-07-27 16:49:17'),
(192,	'create alert_notification_state table v1',	'CREATE TABLE IF NOT EXISTS "alert_notification_state" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "alert_id" BIGINT NOT NULL
, "notifier_id" BIGINT NOT NULL
, "state" VARCHAR(50) NOT NULL
, "version" BIGINT NOT NULL
, "updated_at" BIGINT NOT NULL
, "alert_rule_state_updated_version" BIGINT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(193,	'add index alert_notification_state org_id & alert_id & notifier_id',	'CREATE UNIQUE INDEX "UQE_alert_notification_state_org_id_alert_id_notifier_id" ON "alert_notification_state" ("org_id","alert_id","notifier_id");',	'1',	'',	'2022-07-27 16:49:17'),
(194,	'Add for to alert table',	'alter table "alert" ADD COLUMN "for" BIGINT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(195,	'Add column uid in alert_notification',	'alter table "alert_notification" ADD COLUMN "uid" VARCHAR(40) NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(196,	'Update uid column values in alert_notification',	'UPDATE alert_notification SET uid=lpad('''' || id::text,9,''0'') WHERE uid IS NULL;',	'1',	'',	'2022-07-27 16:49:17'),
(197,	'Add unique index alert_notification_org_id_uid',	'CREATE UNIQUE INDEX "UQE_alert_notification_org_id_uid" ON "alert_notification" ("org_id","uid");',	'1',	'',	'2022-07-27 16:49:17'),
(198,	'Remove unique index org_id_name',	'DROP INDEX "UQE_alert_notification_org_id_name" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(199,	'Add column secure_settings in alert_notification',	'alter table "alert_notification" ADD COLUMN "secure_settings" TEXT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(200,	'alter alert.settings to mediumtext',	'SELECT 0;',	'1',	'',	'2022-07-27 16:49:17'),
(201,	'Add non-unique index alert_notification_state_alert_id',	'CREATE INDEX "IDX_alert_notification_state_alert_id" ON "alert_notification_state" ("alert_id");',	'1',	'',	'2022-07-27 16:49:17'),
(202,	'Add non-unique index alert_rule_tag_alert_id',	'CREATE INDEX "IDX_alert_rule_tag_alert_id" ON "alert_rule_tag" ("alert_id");',	'1',	'',	'2022-07-27 16:49:17'),
(203,	'Drop old annotation table v4',	'DROP TABLE IF EXISTS "annotation"',	'1',	'',	'2022-07-27 16:49:17'),
(287,	'add unique index user_auth_token.auth_token',	'CREATE UNIQUE INDEX "UQE_user_auth_token_auth_token" ON "user_auth_token" ("auth_token");',	'1',	'',	'2022-07-27 16:49:17'),
(204,	'create annotation table v5',	'CREATE TABLE IF NOT EXISTS "annotation" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "alert_id" BIGINT NULL
, "user_id" BIGINT NULL
, "dashboard_id" BIGINT NULL
, "panel_id" BIGINT NULL
, "category_id" BIGINT NULL
, "type" VARCHAR(25) NOT NULL
, "title" TEXT NOT NULL
, "text" TEXT NOT NULL
, "metric" VARCHAR(255) NULL
, "prev_state" VARCHAR(25) NOT NULL
, "new_state" VARCHAR(25) NOT NULL
, "data" TEXT NOT NULL
, "epoch" BIGINT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(205,	'add index annotation 0 v3',	'CREATE INDEX "IDX_annotation_org_id_alert_id" ON "annotation" ("org_id","alert_id");',	'1',	'',	'2022-07-27 16:49:17'),
(206,	'add index annotation 1 v3',	'CREATE INDEX "IDX_annotation_org_id_type" ON "annotation" ("org_id","type");',	'1',	'',	'2022-07-27 16:49:17'),
(207,	'add index annotation 2 v3',	'CREATE INDEX "IDX_annotation_org_id_category_id" ON "annotation" ("org_id","category_id");',	'1',	'',	'2022-07-27 16:49:17'),
(208,	'add index annotation 3 v3',	'CREATE INDEX "IDX_annotation_org_id_dashboard_id_panel_id_epoch" ON "annotation" ("org_id","dashboard_id","panel_id","epoch");',	'1',	'',	'2022-07-27 16:49:17'),
(209,	'add index annotation 4 v3',	'CREATE INDEX "IDX_annotation_org_id_epoch" ON "annotation" ("org_id","epoch");',	'1',	'',	'2022-07-27 16:49:17'),
(210,	'Update annotation table charset',	'ALTER TABLE "annotation" ALTER "type" TYPE VARCHAR(25), ALTER "title" TYPE TEXT, ALTER "text" TYPE TEXT, ALTER "metric" TYPE VARCHAR(255), ALTER "prev_state" TYPE VARCHAR(25), ALTER "new_state" TYPE VARCHAR(25), ALTER "data" TYPE TEXT;',	'1',	'',	'2022-07-27 16:49:17'),
(211,	'Add column region_id to annotation table',	'alter table "annotation" ADD COLUMN "region_id" BIGINT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:17'),
(212,	'Drop category_id index',	'DROP INDEX "IDX_annotation_org_id_category_id" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(213,	'Add column tags to annotation table',	'alter table "annotation" ADD COLUMN "tags" VARCHAR(500) NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(214,	'Create annotation_tag table v2',	'CREATE TABLE IF NOT EXISTS "annotation_tag" (
"annotation_id" BIGINT NOT NULL
, "tag_id" BIGINT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(215,	'Add unique index annotation_tag.annotation_id_tag_id',	'CREATE UNIQUE INDEX "UQE_annotation_tag_annotation_id_tag_id" ON "annotation_tag" ("annotation_id","tag_id");',	'1',	'',	'2022-07-27 16:49:17'),
(216,	'drop index UQE_annotation_tag_annotation_id_tag_id - v2',	'DROP INDEX "UQE_annotation_tag_annotation_id_tag_id" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(217,	'Rename table annotation_tag to annotation_tag_v2 - v2',	'ALTER TABLE "annotation_tag" RENAME TO "annotation_tag_v2"',	'1',	'',	'2022-07-27 16:49:17'),
(218,	'Create annotation_tag table v3',	'CREATE TABLE IF NOT EXISTS "annotation_tag" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "annotation_id" BIGINT NOT NULL
, "tag_id" BIGINT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(219,	'create index UQE_annotation_tag_annotation_id_tag_id - Add unique index annotation_tag.annotation_id_tag_id V3',	'CREATE UNIQUE INDEX "UQE_annotation_tag_annotation_id_tag_id" ON "annotation_tag" ("annotation_id","tag_id");',	'1',	'',	'2022-07-27 16:49:17'),
(220,	'copy annotation_tag v2 to v3',	'INSERT INTO "annotation_tag" ("annotation_id"
, "tag_id") SELECT "annotation_id"
, "tag_id" FROM "annotation_tag_v2"',	'1',	'',	'2022-07-27 16:49:17'),
(221,	'drop table annotation_tag_v2',	'DROP TABLE IF EXISTS "annotation_tag_v2"',	'1',	'',	'2022-07-27 16:49:17'),
(222,	'Update alert annotations and set TEXT to empty',	'UPDATE annotation SET TEXT = '''' WHERE alert_id > 0',	'1',	'',	'2022-07-27 16:49:17'),
(223,	'Add created time to annotation table',	'alter table "annotation" ADD COLUMN "created" BIGINT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:17'),
(224,	'Add updated time to annotation table',	'alter table "annotation" ADD COLUMN "updated" BIGINT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:17'),
(225,	'Add index for created in annotation table',	'CREATE INDEX "IDX_annotation_org_id_created" ON "annotation" ("org_id","created");',	'1',	'',	'2022-07-27 16:49:17'),
(226,	'Add index for updated in annotation table',	'CREATE INDEX "IDX_annotation_org_id_updated" ON "annotation" ("org_id","updated");',	'1',	'',	'2022-07-27 16:49:17'),
(227,	'Convert existing annotations from seconds to milliseconds',	'UPDATE annotation SET epoch = (epoch*1000) where epoch < 9999999999',	'1',	'',	'2022-07-27 16:49:17'),
(228,	'Add epoch_end column',	'alter table "annotation" ADD COLUMN "epoch_end" BIGINT NOT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:17'),
(229,	'Add index for epoch_end',	'CREATE INDEX "IDX_annotation_org_id_epoch_epoch_end" ON "annotation" ("org_id","epoch","epoch_end");',	'1',	'',	'2022-07-27 16:49:17'),
(230,	'Make epoch_end the same as epoch',	'UPDATE annotation SET epoch_end = epoch',	'1',	'',	'2022-07-27 16:49:17'),
(231,	'Move region to single row',	'code migration',	'1',	'',	'2022-07-27 16:49:17'),
(232,	'Remove index org_id_epoch from annotation table',	'DROP INDEX "IDX_annotation_org_id_epoch" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(233,	'Remove index org_id_dashboard_id_panel_id_epoch from annotation table',	'DROP INDEX "IDX_annotation_org_id_dashboard_id_panel_id_epoch" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(234,	'Add index for org_id_dashboard_id_epoch_end_epoch on annotation table',	'CREATE INDEX "IDX_annotation_org_id_dashboard_id_epoch_end_epoch" ON "annotation" ("org_id","dashboard_id","epoch_end","epoch");',	'1',	'',	'2022-07-27 16:49:17'),
(235,	'Add index for org_id_epoch_end_epoch on annotation table',	'CREATE INDEX "IDX_annotation_org_id_epoch_end_epoch" ON "annotation" ("org_id","epoch_end","epoch");',	'1',	'',	'2022-07-27 16:49:17'),
(236,	'Remove index org_id_epoch_epoch_end from annotation table',	'DROP INDEX "IDX_annotation_org_id_epoch_epoch_end" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(237,	'Add index for alert_id on annotation table',	'CREATE INDEX "IDX_annotation_alert_id" ON "annotation" ("alert_id");',	'1',	'',	'2022-07-27 16:49:17'),
(238,	'create test_data table',	'CREATE TABLE IF NOT EXISTS "test_data" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "metric1" VARCHAR(20) NULL
, "metric2" VARCHAR(150) NULL
, "value_big_int" BIGINT NULL
, "value_double" DOUBLE PRECISION NULL
, "value_float" REAL NULL
, "value_int" INTEGER NULL
, "time_epoch" BIGINT NOT NULL
, "time_date_time" TIMESTAMP NOT NULL
, "time_time_stamp" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(239,	'create dashboard_version table v1',	'CREATE TABLE IF NOT EXISTS "dashboard_version" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "dashboard_id" BIGINT NOT NULL
, "parent_version" INTEGER NOT NULL
, "restored_from" INTEGER NOT NULL
, "version" INTEGER NOT NULL
, "created" TIMESTAMP NOT NULL
, "created_by" BIGINT NOT NULL
, "message" TEXT NOT NULL
, "data" TEXT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(240,	'add index dashboard_version.dashboard_id',	'CREATE INDEX "IDX_dashboard_version_dashboard_id" ON "dashboard_version" ("dashboard_id");',	'1',	'',	'2022-07-27 16:49:17'),
(241,	'add unique index dashboard_version.dashboard_id and dashboard_version.version',	'CREATE UNIQUE INDEX "UQE_dashboard_version_dashboard_id_version" ON "dashboard_version" ("dashboard_id","version");',	'1',	'',	'2022-07-27 16:49:17'),
(242,	'Set dashboard version to 1 where 0',	'UPDATE dashboard SET version = 1 WHERE version = 0',	'1',	'',	'2022-07-27 16:49:17'),
(243,	'save existing dashboard data in dashboard_version table v1',	'INSERT INTO dashboard_version
(
	dashboard_id,
	version,
	parent_version,
	restored_from,
	created,
	created_by,
	message,
	data
)
SELECT
	dashboard.id,
	dashboard.version,
	dashboard.version,
	dashboard.version,
	dashboard.updated,
	COALESCE(dashboard.updated_by, -1),
	'''',
	dashboard.data
FROM dashboard;',	'1',	'',	'2022-07-27 16:49:17'),
(244,	'alter dashboard_version.data to mediumtext v1',	'SELECT 0;',	'1',	'',	'2022-07-27 16:49:17'),
(245,	'create team table',	'CREATE TABLE IF NOT EXISTS "team" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "name" VARCHAR(190) NOT NULL
, "org_id" BIGINT NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(246,	'add index team.org_id',	'CREATE INDEX "IDX_team_org_id" ON "team" ("org_id");',	'1',	'',	'2022-07-27 16:49:17'),
(247,	'add unique index team_org_id_name',	'CREATE UNIQUE INDEX "UQE_team_org_id_name" ON "team" ("org_id","name");',	'1',	'',	'2022-07-27 16:49:17'),
(248,	'create team member table',	'CREATE TABLE IF NOT EXISTS "team_member" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "team_id" BIGINT NOT NULL
, "user_id" BIGINT NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(249,	'add index team_member.org_id',	'CREATE INDEX "IDX_team_member_org_id" ON "team_member" ("org_id");',	'1',	'',	'2022-07-27 16:49:17'),
(250,	'add unique index team_member_org_id_team_id_user_id',	'CREATE UNIQUE INDEX "UQE_team_member_org_id_team_id_user_id" ON "team_member" ("org_id","team_id","user_id");',	'1',	'',	'2022-07-27 16:49:17'),
(251,	'add index team_member.team_id',	'CREATE INDEX "IDX_team_member_team_id" ON "team_member" ("team_id");',	'1',	'',	'2022-07-27 16:49:17'),
(252,	'Add column email to team table',	'alter table "team" ADD COLUMN "email" VARCHAR(190) NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(253,	'Add column external to team_member table',	'alter table "team_member" ADD COLUMN "external" BOOL NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(254,	'Add column permission to team_member table',	'alter table "team_member" ADD COLUMN "permission" SMALLINT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(255,	'create dashboard acl table',	'CREATE TABLE IF NOT EXISTS "dashboard_acl" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "dashboard_id" BIGINT NOT NULL
, "user_id" BIGINT NULL
, "team_id" BIGINT NULL
, "permission" SMALLINT NOT NULL DEFAULT 4
, "role" VARCHAR(20) NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(256,	'add index dashboard_acl_dashboard_id',	'CREATE INDEX "IDX_dashboard_acl_dashboard_id" ON "dashboard_acl" ("dashboard_id");',	'1',	'',	'2022-07-27 16:49:17'),
(257,	'add unique index dashboard_acl_dashboard_id_user_id',	'CREATE UNIQUE INDEX "UQE_dashboard_acl_dashboard_id_user_id" ON "dashboard_acl" ("dashboard_id","user_id");',	'1',	'',	'2022-07-27 16:49:17'),
(258,	'add unique index dashboard_acl_dashboard_id_team_id',	'CREATE UNIQUE INDEX "UQE_dashboard_acl_dashboard_id_team_id" ON "dashboard_acl" ("dashboard_id","team_id");',	'1',	'',	'2022-07-27 16:49:17'),
(259,	'add index dashboard_acl_user_id',	'CREATE INDEX "IDX_dashboard_acl_user_id" ON "dashboard_acl" ("user_id");',	'1',	'',	'2022-07-27 16:49:17'),
(260,	'add index dashboard_acl_team_id',	'CREATE INDEX "IDX_dashboard_acl_team_id" ON "dashboard_acl" ("team_id");',	'1',	'',	'2022-07-27 16:49:17'),
(261,	'add index dashboard_acl_org_id_role',	'CREATE INDEX "IDX_dashboard_acl_org_id_role" ON "dashboard_acl" ("org_id","role");',	'1',	'',	'2022-07-27 16:49:17'),
(262,	'add index dashboard_permission',	'CREATE INDEX "IDX_dashboard_acl_permission" ON "dashboard_acl" ("permission");',	'1',	'',	'2022-07-27 16:49:17'),
(263,	'save default acl rules in dashboard_acl table',	'
INSERT INTO dashboard_acl
	(
		org_id,
		dashboard_id,
		permission,
		role,
		created,
		updated
	)
	VALUES
		(-1,-1, 1,''Viewer'',''2017-06-20'',''2017-06-20''),
		(-1,-1, 2,''Editor'',''2017-06-20'',''2017-06-20'')
	',	'1',	'',	'2022-07-27 16:49:17'),
(264,	'delete acl rules for deleted dashboards and folders',	'DELETE FROM dashboard_acl WHERE dashboard_id NOT IN (SELECT id FROM dashboard) AND dashboard_id != -1',	'1',	'',	'2022-07-27 16:49:17'),
(265,	'create tag table',	'CREATE TABLE IF NOT EXISTS "tag" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "key" VARCHAR(100) NOT NULL
, "value" VARCHAR(100) NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(266,	'add index tag.key_value',	'CREATE UNIQUE INDEX "UQE_tag_key_value" ON "tag" ("key","value");',	'1',	'',	'2022-07-27 16:49:17'),
(267,	'create login attempt table',	'CREATE TABLE IF NOT EXISTS "login_attempt" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "username" VARCHAR(190) NOT NULL
, "ip_address" VARCHAR(30) NOT NULL
, "created" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(268,	'add index login_attempt.username',	'CREATE INDEX "IDX_login_attempt_username" ON "login_attempt" ("username");',	'1',	'',	'2022-07-27 16:49:17'),
(269,	'drop index IDX_login_attempt_username - v1',	'DROP INDEX "IDX_login_attempt_username" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(270,	'Rename table login_attempt to login_attempt_tmp_qwerty - v1',	'ALTER TABLE "login_attempt" RENAME TO "login_attempt_tmp_qwerty"',	'1',	'',	'2022-07-27 16:49:17'),
(271,	'create login_attempt v2',	'CREATE TABLE IF NOT EXISTS "login_attempt" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "username" VARCHAR(190) NOT NULL
, "ip_address" VARCHAR(30) NOT NULL
, "created" INTEGER NOT NULL DEFAULT 0
);',	'1',	'',	'2022-07-27 16:49:17'),
(272,	'create index IDX_login_attempt_username - v2',	'CREATE INDEX "IDX_login_attempt_username" ON "login_attempt" ("username");',	'1',	'',	'2022-07-27 16:49:17'),
(273,	'copy login_attempt v1 to v2',	'INSERT INTO "login_attempt" ("username"
, "ip_address"
, "id") SELECT "username"
, "ip_address"
, "id" FROM "login_attempt_tmp_qwerty"',	'1',	'',	'2022-07-27 16:49:17'),
(274,	'drop login_attempt_tmp_qwerty',	'DROP TABLE IF EXISTS "login_attempt_tmp_qwerty"',	'1',	'',	'2022-07-27 16:49:17'),
(275,	'create user auth table',	'CREATE TABLE IF NOT EXISTS "user_auth" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "user_id" BIGINT NOT NULL
, "auth_module" VARCHAR(190) NOT NULL
, "auth_id" VARCHAR(100) NOT NULL
, "created" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(276,	'create index IDX_user_auth_auth_module_auth_id - v1',	'CREATE INDEX "IDX_user_auth_auth_module_auth_id" ON "user_auth" ("auth_module","auth_id");',	'1',	'',	'2022-07-27 16:49:17'),
(277,	'alter user_auth.auth_id to length 190',	'ALTER TABLE user_auth ALTER COLUMN auth_id TYPE VARCHAR(190);',	'1',	'',	'2022-07-27 16:49:17'),
(278,	'Add OAuth access token to user_auth',	'alter table "user_auth" ADD COLUMN "o_auth_access_token" TEXT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(279,	'Add OAuth refresh token to user_auth',	'alter table "user_auth" ADD COLUMN "o_auth_refresh_token" TEXT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(280,	'Add OAuth token type to user_auth',	'alter table "user_auth" ADD COLUMN "o_auth_token_type" TEXT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(281,	'Add OAuth expiry to user_auth',	'alter table "user_auth" ADD COLUMN "o_auth_expiry" TIMESTAMP NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(282,	'Add index to user_id column in user_auth',	'CREATE INDEX "IDX_user_auth_user_id" ON "user_auth" ("user_id");',	'1',	'',	'2022-07-27 16:49:17'),
(283,	'Add OAuth ID token to user_auth',	'alter table "user_auth" ADD COLUMN "o_auth_id_token" TEXT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(284,	'create server_lock table',	'CREATE TABLE IF NOT EXISTS "server_lock" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "operation_uid" VARCHAR(100) NOT NULL
, "version" BIGINT NOT NULL
, "last_execution" BIGINT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(285,	'add index server_lock.operation_uid',	'CREATE UNIQUE INDEX "UQE_server_lock_operation_uid" ON "server_lock" ("operation_uid");',	'1',	'',	'2022-07-27 16:49:17'),
(286,	'create user auth token table',	'CREATE TABLE IF NOT EXISTS "user_auth_token" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "user_id" BIGINT NOT NULL
, "auth_token" VARCHAR(100) NOT NULL
, "prev_auth_token" VARCHAR(100) NOT NULL
, "user_agent" VARCHAR(255) NOT NULL
, "client_ip" VARCHAR(255) NOT NULL
, "auth_token_seen" BOOL NOT NULL
, "seen_at" INTEGER NULL
, "rotated_at" INTEGER NOT NULL
, "created_at" INTEGER NOT NULL
, "updated_at" INTEGER NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(288,	'add unique index user_auth_token.prev_auth_token',	'CREATE UNIQUE INDEX "UQE_user_auth_token_prev_auth_token" ON "user_auth_token" ("prev_auth_token");',	'1',	'',	'2022-07-27 16:49:17'),
(289,	'add index user_auth_token.user_id',	'CREATE INDEX "IDX_user_auth_token_user_id" ON "user_auth_token" ("user_id");',	'1',	'',	'2022-07-27 16:49:17'),
(290,	'Add revoked_at to the user auth token',	'alter table "user_auth_token" ADD COLUMN "revoked_at" INTEGER NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(291,	'create cache_data table',	'CREATE TABLE IF NOT EXISTS "cache_data" (
"cache_key" VARCHAR(168) PRIMARY KEY NOT NULL
, "data" BYTEA NOT NULL
, "expires" INTEGER NOT NULL
, "created_at" INTEGER NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(292,	'add unique index cache_data.cache_key',	'CREATE UNIQUE INDEX "UQE_cache_data_cache_key" ON "cache_data" ("cache_key");',	'1',	'',	'2022-07-27 16:49:17'),
(293,	'create short_url table v1',	'CREATE TABLE IF NOT EXISTS "short_url" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "uid" VARCHAR(40) NOT NULL
, "path" TEXT NOT NULL
, "created_by" INTEGER NOT NULL
, "created_at" INTEGER NOT NULL
, "last_seen_at" INTEGER NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(294,	'add index short_url.org_id-uid',	'CREATE UNIQUE INDEX "UQE_short_url_org_id_uid" ON "short_url" ("org_id","uid");',	'1',	'',	'2022-07-27 16:49:17'),
(295,	'delete alert_definition table',	'DROP TABLE IF EXISTS "alert_definition"',	'1',	'',	'2022-07-27 16:49:17'),
(296,	'recreate alert_definition table',	'CREATE TABLE IF NOT EXISTS "alert_definition" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "title" VARCHAR(190) NOT NULL
, "condition" VARCHAR(190) NOT NULL
, "data" TEXT NOT NULL
, "updated" TIMESTAMP NOT NULL
, "interval_seconds" BIGINT NOT NULL DEFAULT 60
, "version" INTEGER NOT NULL DEFAULT 0
, "uid" VARCHAR(40) NOT NULL DEFAULT 0
);',	'1',	'',	'2022-07-27 16:49:17'),
(297,	'add index in alert_definition on org_id and title columns',	'CREATE INDEX "IDX_alert_definition_org_id_title" ON "alert_definition" ("org_id","title");',	'1',	'',	'2022-07-27 16:49:17'),
(298,	'add index in alert_definition on org_id and uid columns',	'CREATE INDEX "IDX_alert_definition_org_id_uid" ON "alert_definition" ("org_id","uid");',	'1',	'',	'2022-07-27 16:49:17'),
(299,	'alter alert_definition table data column to mediumtext in mysql',	'SELECT 0;',	'1',	'',	'2022-07-27 16:49:17'),
(300,	'drop index in alert_definition on org_id and title columns',	'DROP INDEX "IDX_alert_definition_org_id_title" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(301,	'drop index in alert_definition on org_id and uid columns',	'DROP INDEX "IDX_alert_definition_org_id_uid" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(302,	'add unique index in alert_definition on org_id and title columns',	'CREATE UNIQUE INDEX "UQE_alert_definition_org_id_title" ON "alert_definition" ("org_id","title");',	'1',	'',	'2022-07-27 16:49:17'),
(303,	'add unique index in alert_definition on org_id and uid columns',	'CREATE UNIQUE INDEX "UQE_alert_definition_org_id_uid" ON "alert_definition" ("org_id","uid");',	'1',	'',	'2022-07-27 16:49:17'),
(304,	'Add column paused in alert_definition',	'alter table "alert_definition" ADD COLUMN "paused" BOOL NOT NULL DEFAULT FALSE ',	'1',	'',	'2022-07-27 16:49:17'),
(305,	'drop alert_definition table',	'DROP TABLE IF EXISTS "alert_definition"',	'1',	'',	'2022-07-27 16:49:17'),
(306,	'delete alert_definition_version table',	'DROP TABLE IF EXISTS "alert_definition_version"',	'1',	'',	'2022-07-27 16:49:17'),
(307,	'recreate alert_definition_version table',	'CREATE TABLE IF NOT EXISTS "alert_definition_version" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "alert_definition_id" BIGINT NOT NULL
, "alert_definition_uid" VARCHAR(40) NOT NULL DEFAULT 0
, "parent_version" INTEGER NOT NULL
, "restored_from" INTEGER NOT NULL
, "version" INTEGER NOT NULL
, "created" TIMESTAMP NOT NULL
, "title" VARCHAR(190) NOT NULL
, "condition" VARCHAR(190) NOT NULL
, "data" TEXT NOT NULL
, "interval_seconds" BIGINT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(308,	'add index in alert_definition_version table on alert_definition_id and version columns',	'CREATE UNIQUE INDEX "UQE_alert_definition_version_alert_definition_id_version" ON "alert_definition_version" ("alert_definition_id","version");',	'1',	'',	'2022-07-27 16:49:17'),
(309,	'add index in alert_definition_version table on alert_definition_uid and version columns',	'CREATE UNIQUE INDEX "UQE_alert_definition_version_alert_definition_uid_version" ON "alert_definition_version" ("alert_definition_uid","version");',	'1',	'',	'2022-07-27 16:49:17'),
(310,	'alter alert_definition_version table data column to mediumtext in mysql',	'SELECT 0;',	'1',	'',	'2022-07-27 16:49:17'),
(311,	'drop alert_definition_version table',	'DROP TABLE IF EXISTS "alert_definition_version"',	'1',	'',	'2022-07-27 16:49:17'),
(312,	'create alert_instance table',	'CREATE TABLE IF NOT EXISTS "alert_instance" (
"def_org_id" BIGINT NOT NULL
, "def_uid" VARCHAR(40) NOT NULL DEFAULT 0
, "labels" TEXT NOT NULL
, "labels_hash" VARCHAR(190) NOT NULL
, "current_state" VARCHAR(190) NOT NULL
, "current_state_since" BIGINT NOT NULL
, "last_eval_time" BIGINT NOT NULL
, PRIMARY KEY ( "def_org_id","def_uid","labels_hash" ));',	'1',	'',	'2022-07-27 16:49:17'),
(313,	'add index in alert_instance table on def_org_id, def_uid and current_state columns',	'CREATE INDEX "IDX_alert_instance_def_org_id_def_uid_current_state" ON "alert_instance" ("def_org_id","def_uid","current_state");',	'1',	'',	'2022-07-27 16:49:17'),
(314,	'add index in alert_instance table on def_org_id, current_state columns',	'CREATE INDEX "IDX_alert_instance_def_org_id_current_state" ON "alert_instance" ("def_org_id","current_state");',	'1',	'',	'2022-07-27 16:49:17'),
(315,	'add column current_state_end to alert_instance',	'alter table "alert_instance" ADD COLUMN "current_state_end" BIGINT NOT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:17'),
(316,	'remove index def_org_id, def_uid, current_state on alert_instance',	'DROP INDEX "IDX_alert_instance_def_org_id_def_uid_current_state" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(317,	'remove index def_org_id, current_state on alert_instance',	'DROP INDEX "IDX_alert_instance_def_org_id_current_state" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(318,	'rename def_org_id to rule_org_id in alert_instance',	'ALTER TABLE alert_instance RENAME COLUMN def_org_id TO rule_org_id;',	'1',	'',	'2022-07-27 16:49:17'),
(319,	'rename def_uid to rule_uid in alert_instance',	'ALTER TABLE alert_instance RENAME COLUMN def_uid TO rule_uid;',	'1',	'',	'2022-07-27 16:49:17'),
(320,	'add index rule_org_id, rule_uid, current_state on alert_instance',	'CREATE INDEX "IDX_alert_instance_rule_org_id_rule_uid_current_state" ON "alert_instance" ("rule_org_id","rule_uid","current_state");',	'1',	'',	'2022-07-27 16:49:17'),
(321,	'add index rule_org_id, current_state on alert_instance',	'CREATE INDEX "IDX_alert_instance_rule_org_id_current_state" ON "alert_instance" ("rule_org_id","current_state");',	'1',	'',	'2022-07-27 16:49:17'),
(322,	'add current_reason column related to current_state',	'alter table "alert_instance" ADD COLUMN "current_reason" VARCHAR(190) NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(323,	'create alert_rule table',	'CREATE TABLE IF NOT EXISTS "alert_rule" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "title" VARCHAR(190) NOT NULL
, "condition" VARCHAR(190) NOT NULL
, "data" TEXT NOT NULL
, "updated" TIMESTAMP NOT NULL
, "interval_seconds" BIGINT NOT NULL DEFAULT 60
, "version" INTEGER NOT NULL DEFAULT 0
, "uid" VARCHAR(40) NOT NULL DEFAULT 0
, "namespace_uid" VARCHAR(40) NOT NULL
, "rule_group" VARCHAR(190) NOT NULL
, "no_data_state" VARCHAR(15) NOT NULL DEFAULT ''NoData''
, "exec_err_state" VARCHAR(15) NOT NULL DEFAULT ''Alerting''
);',	'1',	'',	'2022-07-27 16:49:17'),
(324,	'add index in alert_rule on org_id and title columns',	'CREATE UNIQUE INDEX "UQE_alert_rule_org_id_title" ON "alert_rule" ("org_id","title");',	'1',	'',	'2022-07-27 16:49:17'),
(325,	'add index in alert_rule on org_id and uid columns',	'CREATE UNIQUE INDEX "UQE_alert_rule_org_id_uid" ON "alert_rule" ("org_id","uid");',	'1',	'',	'2022-07-27 16:49:17'),
(326,	'add index in alert_rule on org_id, namespace_uid, group_uid columns',	'CREATE INDEX "IDX_alert_rule_org_id_namespace_uid_rule_group" ON "alert_rule" ("org_id","namespace_uid","rule_group");',	'1',	'',	'2022-07-27 16:49:17'),
(327,	'alter alert_rule table data column to mediumtext in mysql',	'SELECT 0;',	'1',	'',	'2022-07-27 16:49:17'),
(328,	'add column for to alert_rule',	'alter table "alert_rule" ADD COLUMN "for" BIGINT NOT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:17'),
(329,	'add column annotations to alert_rule',	'alter table "alert_rule" ADD COLUMN "annotations" TEXT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(330,	'add column labels to alert_rule',	'alter table "alert_rule" ADD COLUMN "labels" TEXT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(331,	'remove unique index from alert_rule on org_id, title columns',	'DROP INDEX "UQE_alert_rule_org_id_title" CASCADE',	'1',	'',	'2022-07-27 16:49:17'),
(332,	'add index in alert_rule on org_id, namespase_uid and title columns',	'CREATE UNIQUE INDEX "UQE_alert_rule_org_id_namespace_uid_title" ON "alert_rule" ("org_id","namespace_uid","title");',	'1',	'',	'2022-07-27 16:49:17'),
(333,	'add dashboard_uid column to alert_rule',	'alter table "alert_rule" ADD COLUMN "dashboard_uid" VARCHAR(40) NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(334,	'add panel_id column to alert_rule',	'alter table "alert_rule" ADD COLUMN "panel_id" BIGINT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(335,	'add index in alert_rule on org_id, dashboard_uid and panel_id columns',	'CREATE INDEX "IDX_alert_rule_org_id_dashboard_uid_panel_id" ON "alert_rule" ("org_id","dashboard_uid","panel_id");',	'1',	'',	'2022-07-27 16:49:17'),
(336,	'create alert_rule_version table',	'CREATE TABLE IF NOT EXISTS "alert_rule_version" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "rule_org_id" BIGINT NOT NULL
, "rule_uid" VARCHAR(40) NOT NULL DEFAULT 0
, "rule_namespace_uid" VARCHAR(40) NOT NULL
, "rule_group" VARCHAR(190) NOT NULL
, "parent_version" INTEGER NOT NULL
, "restored_from" INTEGER NOT NULL
, "version" INTEGER NOT NULL
, "created" TIMESTAMP NOT NULL
, "title" VARCHAR(190) NOT NULL
, "condition" VARCHAR(190) NOT NULL
, "data" TEXT NOT NULL
, "interval_seconds" BIGINT NOT NULL
, "no_data_state" VARCHAR(15) NOT NULL DEFAULT ''NoData''
, "exec_err_state" VARCHAR(15) NOT NULL DEFAULT ''Alerting''
);',	'1',	'',	'2022-07-27 16:49:17'),
(337,	'add index in alert_rule_version table on rule_org_id, rule_uid and version columns',	'CREATE UNIQUE INDEX "UQE_alert_rule_version_rule_org_id_rule_uid_version" ON "alert_rule_version" ("rule_org_id","rule_uid","version");',	'1',	'',	'2022-07-27 16:49:17'),
(338,	'add index in alert_rule_version table on rule_org_id, rule_namespace_uid and rule_group columns',	'CREATE INDEX "IDX_alert_rule_version_rule_org_id_rule_namespace_uid_rule_group" ON "alert_rule_version" ("rule_org_id","rule_namespace_uid","rule_group");',	'1',	'',	'2022-07-27 16:49:17'),
(339,	'alter alert_rule_version table data column to mediumtext in mysql',	'SELECT 0;',	'1',	'',	'2022-07-27 16:49:17'),
(340,	'add column for to alert_rule_version',	'alter table "alert_rule_version" ADD COLUMN "for" BIGINT NOT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:17'),
(341,	'add column annotations to alert_rule_version',	'alter table "alert_rule_version" ADD COLUMN "annotations" TEXT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(342,	'add column labels to alert_rule_version',	'alter table "alert_rule_version" ADD COLUMN "labels" TEXT NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(343,	'create_alert_configuration_table',	'CREATE TABLE IF NOT EXISTS "alert_configuration" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "alertmanager_configuration" TEXT NOT NULL
, "configuration_version" VARCHAR(3) NOT NULL
, "created_at" INTEGER NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(344,	'Add column default in alert_configuration',	'alter table "alert_configuration" ADD COLUMN "default" BOOL NOT NULL DEFAULT FALSE ',	'1',	'',	'2022-07-27 16:49:17'),
(345,	'alert alert_configuration alertmanager_configuration column from TEXT to MEDIUMTEXT if mysql',	'SELECT 0;',	'1',	'',	'2022-07-27 16:49:17'),
(346,	'add column org_id in alert_configuration',	'alter table "alert_configuration" ADD COLUMN "org_id" BIGINT NOT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:17'),
(347,	'add index in alert_configuration table on org_id column',	'CREATE INDEX "IDX_alert_configuration_org_id" ON "alert_configuration" ("org_id");',	'1',	'',	'2022-07-27 16:49:17'),
(348,	'add configuration_hash column to alert_configuration',	'alter table "alert_configuration" ADD COLUMN "configuration_hash" VARCHAR(32) NOT NULL DEFAULT ''not-yet-calculated'' ',	'1',	'',	'2022-07-27 16:49:17'),
(349,	'create_ngalert_configuration_table',	'CREATE TABLE IF NOT EXISTS "ngalert_configuration" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "alertmanagers" TEXT NULL
, "created_at" INTEGER NOT NULL
, "updated_at" INTEGER NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(350,	'add index in ngalert_configuration on org_id column',	'CREATE UNIQUE INDEX "UQE_ngalert_configuration_org_id" ON "ngalert_configuration" ("org_id");',	'1',	'',	'2022-07-27 16:49:17'),
(351,	'add column send_alerts_to in ngalert_configuration',	'alter table "ngalert_configuration" ADD COLUMN "send_alerts_to" SMALLINT NOT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:17'),
(352,	'create provenance_type table',	'CREATE TABLE IF NOT EXISTS "provenance_type" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "record_key" VARCHAR(190) NOT NULL
, "record_type" VARCHAR(190) NOT NULL
, "provenance" VARCHAR(190) NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(353,	'add index to uniquify (record_key, record_type, org_id) columns',	'CREATE UNIQUE INDEX "UQE_provenance_type_record_type_record_key_org_id" ON "provenance_type" ("record_type","record_key","org_id");',	'1',	'',	'2022-07-27 16:49:17'),
(354,	'create alert_image table',	'CREATE TABLE IF NOT EXISTS "alert_image" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "token" VARCHAR(190) NOT NULL
, "path" VARCHAR(190) NOT NULL
, "url" VARCHAR(190) NOT NULL
, "created_at" TIMESTAMP NOT NULL
, "expires_at" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(355,	'add unique index on token to alert_image table',	'CREATE UNIQUE INDEX "UQE_alert_image_token" ON "alert_image" ("token");',	'1',	'',	'2022-07-27 16:49:17'),
(356,	'move dashboard alerts to unified alerting',	'code migration',	'1',	'',	'2022-07-27 16:49:17'),
(357,	'create library_element table v1',	'CREATE TABLE IF NOT EXISTS "library_element" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "folder_id" BIGINT NOT NULL
, "uid" VARCHAR(40) NOT NULL
, "name" VARCHAR(150) NOT NULL
, "kind" BIGINT NOT NULL
, "type" VARCHAR(40) NOT NULL
, "description" VARCHAR(255) NOT NULL
, "model" TEXT NOT NULL
, "created" TIMESTAMP NOT NULL
, "created_by" BIGINT NOT NULL
, "updated" TIMESTAMP NOT NULL
, "updated_by" BIGINT NOT NULL
, "version" BIGINT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(358,	'add index library_element org_id-folder_id-name-kind',	'CREATE UNIQUE INDEX "UQE_library_element_org_id_folder_id_name_kind" ON "library_element" ("org_id","folder_id","name","kind");',	'1',	'',	'2022-07-27 16:49:17'),
(359,	'create library_element_connection table v1',	'CREATE TABLE IF NOT EXISTS "library_element_connection" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "element_id" BIGINT NOT NULL
, "kind" BIGINT NOT NULL
, "connection_id" BIGINT NOT NULL
, "created" TIMESTAMP NOT NULL
, "created_by" BIGINT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(360,	'add index library_element_connection element_id-kind-connection_id',	'CREATE UNIQUE INDEX "UQE_library_element_connection_element_id_kind_connection_id" ON "library_element_connection" ("element_id","kind","connection_id");',	'1',	'',	'2022-07-27 16:49:17'),
(404,	'teams permissions migration',	'code migration',	'1',	'',	'2022-07-27 16:49:18'),
(361,	'add unique index library_element org_id_uid',	'CREATE UNIQUE INDEX "UQE_library_element_org_id_uid" ON "library_element" ("org_id","uid");',	'1',	'',	'2022-07-27 16:49:17'),
(362,	'increase max description length to 2048',	'ALTER TABLE "library_element" ALTER "description" TYPE VARCHAR(2048);',	'1',	'',	'2022-07-27 16:49:17'),
(363,	'clone move dashboard alerts to unified alerting',	'code migration',	'1',	'',	'2022-07-27 16:49:17'),
(364,	'create data_keys table',	'CREATE TABLE IF NOT EXISTS "data_keys" (
"name" VARCHAR(100) PRIMARY KEY NOT NULL
, "active" BOOL NOT NULL
, "scope" VARCHAR(30) NOT NULL
, "provider" VARCHAR(50) NOT NULL
, "encrypted_data" BYTEA NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(365,	'create secrets table',	'CREATE TABLE IF NOT EXISTS "secrets" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "namespace" VARCHAR(255) NOT NULL
, "type" VARCHAR(255) NOT NULL
, "value" TEXT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(366,	'rename data_keys name column to id',	'ALTER TABLE "data_keys" RENAME COLUMN "name" TO "id"',	'1',	'',	'2022-07-27 16:49:17'),
(367,	'add name column into data_keys',	'alter table "data_keys" ADD COLUMN "name" VARCHAR(100) NOT NULL DEFAULT '''' ',	'1',	'',	'2022-07-27 16:49:17'),
(368,	'copy data_keys id column values into name',	'UPDATE data_keys SET name = id',	'1',	'',	'2022-07-27 16:49:17'),
(369,	'rename data_keys name column to label',	'ALTER TABLE "data_keys" RENAME COLUMN "name" TO "label"',	'1',	'',	'2022-07-27 16:49:17'),
(370,	'rename data_keys id column back to name',	'ALTER TABLE "data_keys" RENAME COLUMN "id" TO "name"',	'1',	'',	'2022-07-27 16:49:17'),
(371,	'create kv_store table v1',	'CREATE TABLE IF NOT EXISTS "kv_store" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "namespace" VARCHAR(190) NOT NULL
, "key" VARCHAR(190) NOT NULL
, "value" TEXT NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(372,	'add index kv_store.org_id-namespace-key',	'CREATE UNIQUE INDEX "UQE_kv_store_org_id_namespace_key" ON "kv_store" ("org_id","namespace","key");',	'1',	'',	'2022-07-27 16:49:17'),
(373,	'update dashboard_uid and panel_id from existing annotations',	'set dashboard_uid and panel_id migration',	'1',	'',	'2022-07-27 16:49:17'),
(374,	'create permission table',	'CREATE TABLE IF NOT EXISTS "permission" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "role_id" BIGINT NOT NULL
, "action" VARCHAR(190) NOT NULL
, "scope" VARCHAR(190) NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(375,	'add unique index permission.role_id',	'CREATE INDEX "IDX_permission_role_id" ON "permission" ("role_id");',	'1',	'',	'2022-07-27 16:49:17'),
(376,	'add unique index role_id_action_scope',	'CREATE UNIQUE INDEX "UQE_permission_role_id_action_scope" ON "permission" ("role_id","action","scope");',	'1',	'',	'2022-07-27 16:49:17'),
(377,	'create role table',	'CREATE TABLE IF NOT EXISTS "role" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "name" VARCHAR(190) NOT NULL
, "description" TEXT NULL
, "version" BIGINT NOT NULL
, "org_id" BIGINT NOT NULL
, "uid" VARCHAR(40) NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:17'),
(378,	'add column display_name',	'alter table "role" ADD COLUMN "display_name" VARCHAR(190) NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(379,	'add column group_name',	'alter table "role" ADD COLUMN "group_name" VARCHAR(190) NULL ',	'1',	'',	'2022-07-27 16:49:17'),
(380,	'add index role.org_id',	'CREATE INDEX "IDX_role_org_id" ON "role" ("org_id");',	'1',	'',	'2022-07-27 16:49:17'),
(381,	'add unique index role_org_id_name',	'CREATE UNIQUE INDEX "UQE_role_org_id_name" ON "role" ("org_id","name");',	'1',	'',	'2022-07-27 16:49:18'),
(382,	'add index role_org_id_uid',	'CREATE UNIQUE INDEX "UQE_role_org_id_uid" ON "role" ("org_id","uid");',	'1',	'',	'2022-07-27 16:49:18'),
(383,	'create team role table',	'CREATE TABLE IF NOT EXISTS "team_role" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "team_id" BIGINT NOT NULL
, "role_id" BIGINT NOT NULL
, "created" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:18'),
(384,	'add index team_role.org_id',	'CREATE INDEX "IDX_team_role_org_id" ON "team_role" ("org_id");',	'1',	'',	'2022-07-27 16:49:18'),
(385,	'add unique index team_role_org_id_team_id_role_id',	'CREATE UNIQUE INDEX "UQE_team_role_org_id_team_id_role_id" ON "team_role" ("org_id","team_id","role_id");',	'1',	'',	'2022-07-27 16:49:18'),
(386,	'add index team_role.team_id',	'CREATE INDEX "IDX_team_role_team_id" ON "team_role" ("team_id");',	'1',	'',	'2022-07-27 16:49:18'),
(387,	'create user role table',	'CREATE TABLE IF NOT EXISTS "user_role" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "org_id" BIGINT NOT NULL
, "user_id" BIGINT NOT NULL
, "role_id" BIGINT NOT NULL
, "created" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:18'),
(388,	'add index user_role.org_id',	'CREATE INDEX "IDX_user_role_org_id" ON "user_role" ("org_id");',	'1',	'',	'2022-07-27 16:49:18'),
(389,	'add unique index user_role_org_id_user_id_role_id',	'CREATE UNIQUE INDEX "UQE_user_role_org_id_user_id_role_id" ON "user_role" ("org_id","user_id","role_id");',	'1',	'',	'2022-07-27 16:49:18'),
(390,	'add index user_role.user_id',	'CREATE INDEX "IDX_user_role_user_id" ON "user_role" ("user_id");',	'1',	'',	'2022-07-27 16:49:18'),
(391,	'create builtin role table',	'CREATE TABLE IF NOT EXISTS "builtin_role" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "role" VARCHAR(190) NOT NULL
, "role_id" BIGINT NOT NULL
, "created" TIMESTAMP NOT NULL
, "updated" TIMESTAMP NOT NULL
);',	'1',	'',	'2022-07-27 16:49:18'),
(392,	'add index builtin_role.role_id',	'CREATE INDEX "IDX_builtin_role_role_id" ON "builtin_role" ("role_id");',	'1',	'',	'2022-07-27 16:49:18'),
(393,	'add index builtin_role.name',	'CREATE INDEX "IDX_builtin_role_role" ON "builtin_role" ("role");',	'1',	'',	'2022-07-27 16:49:18'),
(394,	'Add column org_id to builtin_role table',	'alter table "builtin_role" ADD COLUMN "org_id" BIGINT NOT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:18'),
(395,	'add index builtin_role.org_id',	'CREATE INDEX "IDX_builtin_role_org_id" ON "builtin_role" ("org_id");',	'1',	'',	'2022-07-27 16:49:18'),
(396,	'add unique index builtin_role_org_id_role_id_role',	'CREATE UNIQUE INDEX "UQE_builtin_role_org_id_role_id_role" ON "builtin_role" ("org_id","role_id","role");',	'1',	'',	'2022-07-27 16:49:18'),
(397,	'Remove unique index role_org_id_uid',	'DROP INDEX "UQE_role_org_id_uid" CASCADE',	'1',	'',	'2022-07-27 16:49:18'),
(398,	'add unique index role.uid',	'CREATE UNIQUE INDEX "UQE_role_uid" ON "role" ("uid");',	'1',	'',	'2022-07-27 16:49:18'),
(399,	'create seed assignment table',	'CREATE TABLE IF NOT EXISTS "seed_assignment" (
"builtin_role" VARCHAR(190) NOT NULL
, "role_name" VARCHAR(190) NOT NULL
);',	'1',	'',	'2022-07-27 16:49:18'),
(400,	'add unique index builtin_role_role_name',	'CREATE UNIQUE INDEX "UQE_seed_assignment_builtin_role_role_name" ON "seed_assignment" ("builtin_role","role_name");',	'1',	'',	'2022-07-27 16:49:18'),
(401,	'add column hidden to role table',	'alter table "role" ADD COLUMN "hidden" BOOL NOT NULL DEFAULT FALSE ',	'1',	'',	'2022-07-27 16:49:18'),
(402,	'create query_history table v1',	'CREATE TABLE IF NOT EXISTS "query_history" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "uid" VARCHAR(40) NOT NULL
, "org_id" BIGINT NOT NULL
, "datasource_uid" VARCHAR(40) NOT NULL
, "created_by" INTEGER NOT NULL
, "created_at" INTEGER NOT NULL
, "comment" TEXT NOT NULL
, "queries" TEXT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:18'),
(403,	'add index query_history.org_id-created_by-datasource_uid',	'CREATE INDEX "IDX_query_history_org_id_created_by_datasource_uid" ON "query_history" ("org_id","created_by","datasource_uid");',	'1',	'',	'2022-07-27 16:49:18'),
(406,	'dashboard permissions uid scopes',	'code migration',	'1',	'',	'2022-07-27 16:49:18'),
(407,	'drop managed folder create actions',	'code migration',	'1',	'',	'2022-07-27 16:49:18'),
(408,	'alerting notification permissions',	'code migration',	'1',	'',	'2022-07-27 16:49:18'),
(409,	'create query_history_star table v1',	'CREATE TABLE IF NOT EXISTS "query_history_star" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "query_uid" VARCHAR(40) NOT NULL
, "user_id" INTEGER NOT NULL
);',	'1',	'',	'2022-07-27 16:49:18'),
(410,	'add index query_history.user_id-query_uid',	'CREATE UNIQUE INDEX "UQE_query_history_star_user_id_query_uid" ON "query_history_star" ("user_id","query_uid");',	'1',	'',	'2022-07-27 16:49:18'),
(411,	'add column org_id in query_history_star',	'alter table "query_history_star" ADD COLUMN "org_id" BIGINT NOT NULL DEFAULT 1 ',	'1',	'',	'2022-07-27 16:49:18'),
(412,	'create entity_events table',	'CREATE TABLE IF NOT EXISTS "entity_event" (
"id" SERIAL PRIMARY KEY  NOT NULL
, "entity_id" VARCHAR(1024) NOT NULL
, "event_type" VARCHAR(8) NOT NULL
, "created" BIGINT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:18'),
(413,	'create dashboard public config v1',	'CREATE TABLE IF NOT EXISTS "dashboard_public_config" (
"uid" BIGINT PRIMARY KEY NOT NULL
, "dashboard_uid" VARCHAR(40) NOT NULL
, "org_id" BIGINT NOT NULL
, "refresh_rate" INTEGER NOT NULL DEFAULT 30
, "template_variables" TEXT NULL
, "time_variables" TEXT NOT NULL
);',	'1',	'',	'2022-07-27 16:49:18'),
(414,	'create index UQE_dashboard_public_config_uid - v1',	'CREATE UNIQUE INDEX "UQE_dashboard_public_config_uid" ON "dashboard_public_config" ("uid");',	'1',	'',	'2022-07-27 16:49:18'),
(415,	'create index IDX_dashboard_public_config_org_id_dashboard_uid - v1',	'CREATE INDEX "IDX_dashboard_public_config_org_id_dashboard_uid" ON "dashboard_public_config" ("org_id","dashboard_uid");',	'1',	'',	'2022-07-27 16:49:18'),
(416,	'create default alerting folders',	'code migration',	'1',	'',	'2022-07-27 16:49:18'),
(417,	'create file table',	'CREATE TABLE IF NOT EXISTS "file" (
"path" VARCHAR(1024) NOT NULL
, "path_hash" VARCHAR(64) NOT NULL
, "parent_folder_path_hash" VARCHAR(64) NOT NULL
, "contents" BYTEA NOT NULL
, "etag" VARCHAR(32) NOT NULL
, "cache_control" VARCHAR(128) NOT NULL
, "content_disposition" VARCHAR(128) NOT NULL
, "updated" TIMESTAMP NOT NULL
, "created" TIMESTAMP NOT NULL
, "size" BIGINT NOT NULL
, "mime_type" VARCHAR(255) NOT NULL
);',	'1',	'',	'2022-07-27 16:49:18'),
(418,	'file table idx: path natural pk',	'CREATE UNIQUE INDEX "UQE_file_path_hash" ON "file" ("path_hash");',	'1',	'',	'2022-07-27 16:49:18'),
(419,	'file table idx: parent_folder_path_hash fast folder retrieval',	'CREATE INDEX "IDX_file_parent_folder_path_hash" ON "file" ("parent_folder_path_hash");',	'1',	'',	'2022-07-27 16:49:18'),
(420,	'create file_meta table',	'CREATE TABLE IF NOT EXISTS "file_meta" (
"path_hash" VARCHAR(64) NOT NULL
, "key" VARCHAR(191) NOT NULL
, "value" VARCHAR(1024) NOT NULL
);',	'1',	'',	'2022-07-27 16:49:18'),
(421,	'file table idx: path key',	'CREATE UNIQUE INDEX "UQE_file_meta_path_hash_key" ON "file_meta" ("path_hash","key");',	'1',	'',	'2022-07-27 16:49:18'),
(422,	'set path collation in file table',	'ALTER TABLE file ALTER COLUMN path TYPE VARCHAR(1024) COLLATE "C";',	'1',	'',	'2022-07-27 16:49:18'),
(423,	'managed permissions migration',	'code migration',	'1',	'',	'2022-07-27 16:49:18'),
(424,	'managed folder permissions alert actions migration',	'code migration',	'1',	'',	'2022-07-27 16:49:18'),
(425,	'RBAC action name migrator',	'code migration',	'1',	'',	'2022-07-27 16:49:18'),
(426,	'Add UID column to playlist',	'alter table "playlist" ADD COLUMN "uid" VARCHAR(80) NOT NULL DEFAULT 0 ',	'1',	'',	'2022-07-27 16:49:18'),
(427,	'Update uid column values in playlist',	'UPDATE playlist SET uid=id::text;',	'1',	'',	'2022-07-27 16:49:18'),
(428,	'Add index for uid in playlist',	'CREATE UNIQUE INDEX "UQE_playlist_org_id_uid" ON "playlist" ("org_id","uid");',	'1',	'',	'2022-07-27 16:49:18'),
(429,	'managed folder permissions alert actions repeated migration',	'code migration',	'1',	'',	'2022-07-27 16:49:18');

DROP TABLE IF EXISTS "ngalert_configuration";
DROP SEQUENCE IF EXISTS ngalert_configuration_id_seq;
CREATE SEQUENCE ngalert_configuration_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."ngalert_configuration" (
    "id" integer DEFAULT nextval('ngalert_configuration_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "alertmanagers" text,
    "created_at" integer NOT NULL,
    "updated_at" integer NOT NULL,
    "send_alerts_to" smallint DEFAULT '0' NOT NULL,
    CONSTRAINT "UQE_ngalert_configuration_org_id" UNIQUE ("org_id"),
    CONSTRAINT "ngalert_configuration_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "ngalert_configuration";

DROP TABLE IF EXISTS "org";
DROP SEQUENCE IF EXISTS org_id_seq;
CREATE SEQUENCE org_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;

CREATE TABLE "public"."org" (
    "id" integer DEFAULT nextval('org_id_seq') NOT NULL,
    "version" integer NOT NULL,
    "name" character varying(190) NOT NULL,
    "address1" character varying(255),
    "address2" character varying(255),
    "city" character varying(255),
    "state" character varying(255),
    "zip_code" character varying(50),
    "country" character varying(255),
    "billing_email" character varying(255),
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    CONSTRAINT "UQE_org_name" UNIQUE ("name"),
    CONSTRAINT "org_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "org";
INSERT INTO "org" ("id", "version", "name", "address1", "address2", "city", "state", "zip_code", "country", "billing_email", "created", "updated") VALUES
(1,	0,	'Main Org.',	'',	'',	'',	'',	'',	'',	NULL,	'2022-07-27 16:49:18',	'2022-07-27 16:49:18');

DROP TABLE IF EXISTS "org_user";
DROP SEQUENCE IF EXISTS org_user_id_seq;
CREATE SEQUENCE org_user_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;

CREATE TABLE "public"."org_user" (
    "id" integer DEFAULT nextval('org_user_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "role" character varying(20) NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    CONSTRAINT "UQE_org_user_org_id_user_id" UNIQUE ("org_id", "user_id"),
    CONSTRAINT "org_user_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_org_user_org_id" ON "public"."org_user" USING btree ("org_id");

CREATE INDEX "IDX_org_user_user_id" ON "public"."org_user" USING btree ("user_id");

TRUNCATE "org_user";
INSERT INTO "org_user" ("id", "org_id", "user_id", "role", "created", "updated") VALUES
(1,	1,	1,	'Admin',	'2022-07-27 16:49:18',	'2022-07-27 16:49:18');

DROP TABLE IF EXISTS "permission";
DROP SEQUENCE IF EXISTS permission_id_seq;
CREATE SEQUENCE permission_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."permission" (
    "id" integer DEFAULT nextval('permission_id_seq') NOT NULL,
    "role_id" bigint NOT NULL,
    "action" character varying(190) NOT NULL,
    "scope" character varying(190) NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    CONSTRAINT "UQE_permission_role_id_action_scope" UNIQUE ("role_id", "action", "scope"),
    CONSTRAINT "permission_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_permission_role_id" ON "public"."permission" USING btree ("role_id");

TRUNCATE "permission";

DROP TABLE IF EXISTS "playlist";
DROP SEQUENCE IF EXISTS playlist_id_seq;
CREATE SEQUENCE playlist_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."playlist" (
    "id" integer DEFAULT nextval('playlist_id_seq') NOT NULL,
    "name" character varying(255) NOT NULL,
    "interval" character varying(255) NOT NULL,
    "org_id" bigint NOT NULL,
    "uid" character varying(80) DEFAULT '0' NOT NULL,
    CONSTRAINT "UQE_playlist_org_id_uid" UNIQUE ("org_id", "uid"),
    CONSTRAINT "playlist_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "playlist";

DROP TABLE IF EXISTS "playlist_item";
DROP SEQUENCE IF EXISTS playlist_item_id_seq;
CREATE SEQUENCE playlist_item_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."playlist_item" (
    "id" integer DEFAULT nextval('playlist_item_id_seq') NOT NULL,
    "playlist_id" bigint NOT NULL,
    "type" character varying(255) NOT NULL,
    "value" text NOT NULL,
    "title" text NOT NULL,
    "order" integer NOT NULL,
    CONSTRAINT "playlist_item_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "playlist_item";

DROP TABLE IF EXISTS "plugin_setting";
DROP SEQUENCE IF EXISTS plugin_setting_id_seq;
CREATE SEQUENCE plugin_setting_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."plugin_setting" (
    "id" integer DEFAULT nextval('plugin_setting_id_seq') NOT NULL,
    "org_id" bigint,
    "plugin_id" character varying(190) NOT NULL,
    "enabled" boolean NOT NULL,
    "pinned" boolean NOT NULL,
    "json_data" text,
    "secure_json_data" text,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "plugin_version" character varying(50),
    CONSTRAINT "UQE_plugin_setting_org_id_plugin_id" UNIQUE ("org_id", "plugin_id"),
    CONSTRAINT "plugin_setting_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "plugin_setting";

DROP TABLE IF EXISTS "preferences";
DROP SEQUENCE IF EXISTS preferences_id_seq;
CREATE SEQUENCE preferences_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."preferences" (
    "id" integer DEFAULT nextval('preferences_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "version" integer NOT NULL,
    "home_dashboard_id" bigint NOT NULL,
    "timezone" character varying(50) NOT NULL,
    "theme" character varying(20) NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "team_id" bigint,
    "week_start" character varying(10),
    "json_data" text,
    CONSTRAINT "preferences_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "preferences";

DROP TABLE IF EXISTS "provenance_type";
DROP SEQUENCE IF EXISTS provenance_type_id_seq;
CREATE SEQUENCE provenance_type_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."provenance_type" (
    "id" integer DEFAULT nextval('provenance_type_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "record_key" character varying(190) NOT NULL,
    "record_type" character varying(190) NOT NULL,
    "provenance" character varying(190) NOT NULL,
    CONSTRAINT "UQE_provenance_type_record_type_record_key_org_id" UNIQUE ("record_type", "record_key", "org_id"),
    CONSTRAINT "provenance_type_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "provenance_type";

DROP TABLE IF EXISTS "query_history";
DROP SEQUENCE IF EXISTS query_history_id_seq;
CREATE SEQUENCE query_history_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."query_history" (
    "id" integer DEFAULT nextval('query_history_id_seq') NOT NULL,
    "uid" character varying(40) NOT NULL,
    "org_id" bigint NOT NULL,
    "datasource_uid" character varying(40) NOT NULL,
    "created_by" integer NOT NULL,
    "created_at" integer NOT NULL,
    "comment" text NOT NULL,
    "queries" text NOT NULL,
    CONSTRAINT "query_history_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_query_history_org_id_created_by_datasource_uid" ON "public"."query_history" USING btree ("org_id", "created_by", "datasource_uid");

TRUNCATE "query_history";

DROP TABLE IF EXISTS "query_history_star";
DROP SEQUENCE IF EXISTS query_history_star_id_seq;
CREATE SEQUENCE query_history_star_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."query_history_star" (
    "id" integer DEFAULT nextval('query_history_star_id_seq') NOT NULL,
    "query_uid" character varying(40) NOT NULL,
    "user_id" integer NOT NULL,
    "org_id" bigint DEFAULT '1' NOT NULL,
    CONSTRAINT "UQE_query_history_star_user_id_query_uid" UNIQUE ("user_id", "query_uid"),
    CONSTRAINT "query_history_star_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "query_history_star";

DROP TABLE IF EXISTS "quota";
DROP SEQUENCE IF EXISTS quota_id_seq;
CREATE SEQUENCE quota_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."quota" (
    "id" integer DEFAULT nextval('quota_id_seq') NOT NULL,
    "org_id" bigint,
    "user_id" bigint,
    "target" character varying(190) NOT NULL,
    "limit" bigint NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    CONSTRAINT "UQE_quota_org_id_user_id_target" UNIQUE ("org_id", "user_id", "target"),
    CONSTRAINT "quota_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "quota";

DROP TABLE IF EXISTS "role";
DROP SEQUENCE IF EXISTS role_id_seq;
CREATE SEQUENCE role_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."role" (
    "id" integer DEFAULT nextval('role_id_seq') NOT NULL,
    "name" character varying(190) NOT NULL,
    "description" text,
    "version" bigint NOT NULL,
    "org_id" bigint NOT NULL,
    "uid" character varying(40) NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "display_name" character varying(190),
    "group_name" character varying(190),
    "hidden" boolean DEFAULT false NOT NULL,
    CONSTRAINT "UQE_role_org_id_name" UNIQUE ("org_id", "name"),
    CONSTRAINT "UQE_role_uid" UNIQUE ("uid"),
    CONSTRAINT "role_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_role_org_id" ON "public"."role" USING btree ("org_id");

TRUNCATE "role";

DROP TABLE IF EXISTS "secrets";
DROP SEQUENCE IF EXISTS secrets_id_seq;
CREATE SEQUENCE secrets_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."secrets" (
    "id" integer DEFAULT nextval('secrets_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "namespace" character varying(255) NOT NULL,
    "type" character varying(255) NOT NULL,
    "value" text,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    CONSTRAINT "secrets_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "secrets";

DROP TABLE IF EXISTS "seed_assignment";
CREATE TABLE "public"."seed_assignment" (
    "builtin_role" character varying(190) NOT NULL,
    "role_name" character varying(190) NOT NULL,
    CONSTRAINT "UQE_seed_assignment_builtin_role_role_name" UNIQUE ("builtin_role", "role_name")
) WITH (oids = false);

TRUNCATE "seed_assignment";

DROP TABLE IF EXISTS "server_lock";
DROP SEQUENCE IF EXISTS server_lock_id_seq;
CREATE SEQUENCE server_lock_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;

CREATE TABLE "public"."server_lock" (
    "id" integer DEFAULT nextval('server_lock_id_seq') NOT NULL,
    "operation_uid" character varying(100) NOT NULL,
    "version" bigint NOT NULL,
    "last_execution" bigint NOT NULL,
    CONSTRAINT "UQE_server_lock_operation_uid" UNIQUE ("operation_uid"),
    CONSTRAINT "server_lock_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "server_lock";
INSERT INTO "server_lock" ("id", "operation_uid", "version", "last_execution") VALUES
(1,	'cleanup expired auth tokens',	1,	1658940558);

DROP TABLE IF EXISTS "session";
CREATE TABLE "public"."session" (
    "key" character(16) NOT NULL,
    "data" bytea NOT NULL,
    "expiry" integer NOT NULL,
    CONSTRAINT "session_pkey" PRIMARY KEY ("key")
) WITH (oids = false);

TRUNCATE "session";

DROP TABLE IF EXISTS "short_url";
DROP SEQUENCE IF EXISTS short_url_id_seq;
CREATE SEQUENCE short_url_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."short_url" (
    "id" integer DEFAULT nextval('short_url_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "uid" character varying(40) NOT NULL,
    "path" text NOT NULL,
    "created_by" integer NOT NULL,
    "created_at" integer NOT NULL,
    "last_seen_at" integer,
    CONSTRAINT "UQE_short_url_org_id_uid" UNIQUE ("org_id", "uid"),
    CONSTRAINT "short_url_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "short_url";

DROP TABLE IF EXISTS "star";
DROP SEQUENCE IF EXISTS star_id_seq;
CREATE SEQUENCE star_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."star" (
    "id" integer DEFAULT nextval('star_id_seq') NOT NULL,
    "user_id" bigint NOT NULL,
    "dashboard_id" bigint NOT NULL,
    CONSTRAINT "UQE_star_user_id_dashboard_id" UNIQUE ("user_id", "dashboard_id"),
    CONSTRAINT "star_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "star";

DROP TABLE IF EXISTS "tag";
DROP SEQUENCE IF EXISTS tag_id_seq;
CREATE SEQUENCE tag_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."tag" (
    "id" integer DEFAULT nextval('tag_id_seq') NOT NULL,
    "key" character varying(100) NOT NULL,
    "value" character varying(100) NOT NULL,
    CONSTRAINT "UQE_tag_key_value" UNIQUE ("key", "value"),
    CONSTRAINT "tag_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "tag";

DROP TABLE IF EXISTS "team";
DROP SEQUENCE IF EXISTS team_id_seq;
CREATE SEQUENCE team_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."team" (
    "id" integer DEFAULT nextval('team_id_seq') NOT NULL,
    "name" character varying(190) NOT NULL,
    "org_id" bigint NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "email" character varying(190),
    CONSTRAINT "UQE_team_org_id_name" UNIQUE ("org_id", "name"),
    CONSTRAINT "team_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_team_org_id" ON "public"."team" USING btree ("org_id");

TRUNCATE "team";

DROP TABLE IF EXISTS "team_member";
DROP SEQUENCE IF EXISTS team_member_id_seq;
CREATE SEQUENCE team_member_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."team_member" (
    "id" integer DEFAULT nextval('team_member_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "team_id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "external" boolean,
    "permission" smallint,
    CONSTRAINT "UQE_team_member_org_id_team_id_user_id" UNIQUE ("org_id", "team_id", "user_id"),
    CONSTRAINT "team_member_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_team_member_org_id" ON "public"."team_member" USING btree ("org_id");

CREATE INDEX "IDX_team_member_team_id" ON "public"."team_member" USING btree ("team_id");

TRUNCATE "team_member";

DROP TABLE IF EXISTS "team_role";
DROP SEQUENCE IF EXISTS team_role_id_seq;
CREATE SEQUENCE team_role_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."team_role" (
    "id" integer DEFAULT nextval('team_role_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "team_id" bigint NOT NULL,
    "role_id" bigint NOT NULL,
    "created" timestamp NOT NULL,
    CONSTRAINT "UQE_team_role_org_id_team_id_role_id" UNIQUE ("org_id", "team_id", "role_id"),
    CONSTRAINT "team_role_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_team_role_org_id" ON "public"."team_role" USING btree ("org_id");

CREATE INDEX "IDX_team_role_team_id" ON "public"."team_role" USING btree ("team_id");

TRUNCATE "team_role";

DROP TABLE IF EXISTS "temp_user";
DROP SEQUENCE IF EXISTS temp_user_id_seq1;
CREATE SEQUENCE temp_user_id_seq1 INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."temp_user" (
    "id" integer DEFAULT nextval('temp_user_id_seq1') NOT NULL,
    "org_id" bigint NOT NULL,
    "version" integer NOT NULL,
    "email" character varying(190) NOT NULL,
    "name" character varying(255),
    "role" character varying(20),
    "code" character varying(190) NOT NULL,
    "status" character varying(20) NOT NULL,
    "invited_by_user_id" bigint,
    "email_sent" boolean NOT NULL,
    "email_sent_on" timestamp,
    "remote_addr" character varying(255),
    "created" integer DEFAULT '0' NOT NULL,
    "updated" integer DEFAULT '0' NOT NULL,
    CONSTRAINT "temp_user_pkey1" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_temp_user_code" ON "public"."temp_user" USING btree ("code");

CREATE INDEX "IDX_temp_user_email" ON "public"."temp_user" USING btree ("email");

CREATE INDEX "IDX_temp_user_org_id" ON "public"."temp_user" USING btree ("org_id");

CREATE INDEX "IDX_temp_user_status" ON "public"."temp_user" USING btree ("status");

TRUNCATE "temp_user";

DROP TABLE IF EXISTS "test_data";
DROP SEQUENCE IF EXISTS test_data_id_seq;
CREATE SEQUENCE test_data_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."test_data" (
    "id" integer DEFAULT nextval('test_data_id_seq') NOT NULL,
    "metric1" character varying(20),
    "metric2" character varying(150),
    "value_big_int" bigint,
    "value_double" double precision,
    "value_float" real,
    "value_int" integer,
    "time_epoch" bigint NOT NULL,
    "time_date_time" timestamp NOT NULL,
    "time_time_stamp" timestamp NOT NULL,
    CONSTRAINT "test_data_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

TRUNCATE "test_data";

DROP TABLE IF EXISTS "user";
DROP SEQUENCE IF EXISTS user_id_seq1;
CREATE SEQUENCE user_id_seq1 INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;

CREATE TABLE "public"."user" (
    "id" integer DEFAULT nextval('user_id_seq1') NOT NULL,
    "version" integer NOT NULL,
    "login" character varying(190) NOT NULL,
    "email" character varying(190) NOT NULL,
    "name" character varying(255),
    "password" character varying(255),
    "salt" character varying(50),
    "rands" character varying(50),
    "company" character varying(255),
    "org_id" bigint NOT NULL,
    "is_admin" boolean NOT NULL,
    "email_verified" boolean,
    "theme" character varying(255),
    "created" timestamp NOT NULL,
    "updated" timestamp NOT NULL,
    "help_flags1" bigint DEFAULT '0' NOT NULL,
    "last_seen_at" timestamp,
    "is_disabled" boolean DEFAULT false NOT NULL,
    "is_service_account" boolean DEFAULT false,
    CONSTRAINT "UQE_user_email" UNIQUE ("email"),
    CONSTRAINT "UQE_user_login" UNIQUE ("login"),
    CONSTRAINT "user_pkey1" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_user_login_email" ON "public"."user" USING btree ("login", "email");

TRUNCATE "user";
INSERT INTO "user" ("id", "version", "login", "email", "name", "password", "salt", "rands", "company", "org_id", "is_admin", "email_verified", "theme", "created", "updated", "help_flags1", "last_seen_at", "is_disabled", "is_service_account") VALUES
(1,	0,	'admin',	'admin@localhost',	'',	'0fed4784aeefca392a3e8f3b3d1e8c76827abf9ff304ba6893878896e57db43d0bb949d905a280024941e750d4619a138472',	'IqT4eoD7MB',	'lsQiAegnfv',	'',	1,	'1',	'0',	'',	'2022-07-27 16:49:18',	'2022-07-27 16:49:18',	0,	'2012-07-27 16:49:18',	'0',	'0');

DROP TABLE IF EXISTS "user_auth";
DROP SEQUENCE IF EXISTS user_auth_id_seq;
CREATE SEQUENCE user_auth_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."user_auth" (
    "id" integer DEFAULT nextval('user_auth_id_seq') NOT NULL,
    "user_id" bigint NOT NULL,
    "auth_module" character varying(190) NOT NULL,
    "auth_id" character varying(190) NOT NULL,
    "created" timestamp NOT NULL,
    "o_auth_access_token" text,
    "o_auth_refresh_token" text,
    "o_auth_token_type" text,
    "o_auth_expiry" timestamp,
    "o_auth_id_token" text,
    CONSTRAINT "user_auth_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_user_auth_auth_module_auth_id" ON "public"."user_auth" USING btree ("auth_module", "auth_id");

CREATE INDEX "IDX_user_auth_user_id" ON "public"."user_auth" USING btree ("user_id");

TRUNCATE "user_auth";

DROP TABLE IF EXISTS "user_auth_token";
DROP SEQUENCE IF EXISTS user_auth_token_id_seq;
CREATE SEQUENCE user_auth_token_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."user_auth_token" (
    "id" integer DEFAULT nextval('user_auth_token_id_seq') NOT NULL,
    "user_id" bigint NOT NULL,
    "auth_token" character varying(100) NOT NULL,
    "prev_auth_token" character varying(100) NOT NULL,
    "user_agent" character varying(255) NOT NULL,
    "client_ip" character varying(255) NOT NULL,
    "auth_token_seen" boolean NOT NULL,
    "seen_at" integer,
    "rotated_at" integer NOT NULL,
    "created_at" integer NOT NULL,
    "updated_at" integer NOT NULL,
    "revoked_at" integer,
    CONSTRAINT "UQE_user_auth_token_auth_token" UNIQUE ("auth_token"),
    CONSTRAINT "UQE_user_auth_token_prev_auth_token" UNIQUE ("prev_auth_token"),
    CONSTRAINT "user_auth_token_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_user_auth_token_user_id" ON "public"."user_auth_token" USING btree ("user_id");

TRUNCATE "user_auth_token";

DROP TABLE IF EXISTS "user_role";
DROP SEQUENCE IF EXISTS user_role_id_seq;
CREATE SEQUENCE user_role_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."user_role" (
    "id" integer DEFAULT nextval('user_role_id_seq') NOT NULL,
    "org_id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "role_id" bigint NOT NULL,
    "created" timestamp NOT NULL,
    CONSTRAINT "UQE_user_role_org_id_user_id_role_id" UNIQUE ("org_id", "user_id", "role_id"),
    CONSTRAINT "user_role_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_user_role_org_id" ON "public"."user_role" USING btree ("org_id");

CREATE INDEX "IDX_user_role_user_id" ON "public"."user_role" USING btree ("user_id");

TRUNCATE "user_role";

-- 2022-07-27 16:49:55.211906+00
