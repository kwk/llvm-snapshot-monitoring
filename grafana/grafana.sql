-- Adminer 4.8.1 PostgreSQL 14.4 (Debian 14.4-1.pgdg110+1) dump

\connect "grafana";

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
',	'v1',	1658939315,	'1',	1,	'8c409350c88d78d2ee938448449e628d');

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


DROP TABLE IF EXISTS "cache_data";
CREATE TABLE "public"."cache_data" (
    "cache_key" character varying(168) NOT NULL,
    "data" bytea NOT NULL,
    "expires" integer NOT NULL,
    "created_at" integer NOT NULL,
    CONSTRAINT "UQE_cache_data_cache_key" UNIQUE ("cache_key"),
    CONSTRAINT "cache_data_pkey" PRIMARY KEY ("cache_key")
) WITH (oids = false);


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


DROP TABLE IF EXISTS "file_meta";
CREATE TABLE "public"."file_meta" (
    "path_hash" character varying(64) NOT NULL,
    "key" character varying(191) NOT NULL,
    "value" character varying(1024) NOT NULL,
    CONSTRAINT "UQE_file_meta_path_hash_key" UNIQUE ("path_hash", "key")
) WITH (oids = false);


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

INSERT INTO "org" ("id", "version", "name", "address1", "address2", "city", "state", "zip_code", "country", "billing_email", "created", "updated") VALUES
(1,	0,	'Main Org.',	'',	'',	'',	'',	'',	'',	NULL,	'2022-07-27 16:28:35',	'2022-07-27 16:28:35');

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

INSERT INTO "org_user" ("id", "org_id", "user_id", "role", "created", "updated") VALUES
(1,	1,	1,	'Admin',	'2022-07-27 16:28:35',	'2022-07-27 16:28:35');

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


DROP TABLE IF EXISTS "seed_assignment";
CREATE TABLE "public"."seed_assignment" (
    "builtin_role" character varying(190) NOT NULL,
    "role_name" character varying(190) NOT NULL,
    CONSTRAINT "UQE_seed_assignment_builtin_role_role_name" UNIQUE ("builtin_role", "role_name")
) WITH (oids = false);


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

INSERT INTO "server_lock" ("id", "operation_uid", "version", "last_execution") VALUES
(1,	'cleanup expired auth tokens',	1,	1658939315);

DROP TABLE IF EXISTS "session";
CREATE TABLE "public"."session" (
    "key" character(16) NOT NULL,
    "data" bytea NOT NULL,
    "expiry" integer NOT NULL,
    CONSTRAINT "session_pkey" PRIMARY KEY ("key")
) WITH (oids = false);


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

INSERT INTO "user" ("id", "version", "login", "email", "name", "password", "salt", "rands", "company", "org_id", "is_admin", "email_verified", "theme", "created", "updated", "help_flags1", "last_seen_at", "is_disabled", "is_service_account") VALUES
(1,	0,	'admin',	'admin@localhost',	'',	'3f4dda5c18bcb0f0e2e34eafca1823cc51776349ef73163be540ace45d8327e935deedc55d33c31b123b08484f58cbd69f74',	'Xt2huvAW5D',	'oviLxnTZWI',	'',	1,	'1',	'0',	'',	'2022-07-27 16:28:35',	'2022-07-27 16:28:35',	0,	'2012-07-27 16:28:35',	'0',	'0');

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


-- 2022-07-27 16:29:49.776633+00
