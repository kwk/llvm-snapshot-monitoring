INSERT INTO buildbot_build_logs (
        builder_builderid,
        builder_description,
        builder_masterids,
        builder_name,
        builder_tags,
        build_buildid,
        build_buildrequestid,
        build_complete,
        build_masterid,
        build_number,
        build_results,
        build_workerid,
        build_state_string,
        build_properties,
        build_complete_at,
        build_started_at,
        buildbot_instance
    ) VALUES 
(137, 'null', ARRAY[1]::integer[], 'publish-lnt-sphinx-docs', ARRAY['doc']::text[], 177865, 485659, true, 1, 1, 2, 86, '', '{}', to_timestamp(1607978113), to_timestamp(1607978111), 'buildbot'), 
(137, 'null', ARRAY[1]::integer[], 'publish-lnt-sphinx-docs', ARRAY['doc']::text[], 182644, 502478, true, 1, 2, 2, 86, '', '{}', to_timestamp(1608082898), to_timestamp(1608082896), 'buildbot')

        ON CONFLICT ON CONSTRAINT buildbot_build_logs_pkey
        DO UPDATE SET
            builder_description=excluded.builder_description,
            builder_masterids=excluded.builder_masterids,
            builder_name=excluded.builder_name,
            builder_tags=excluded.builder_tags,
            build_complete=excluded.build_complete,
            build_masterid=excluded.build_masterid,
            build_number=excluded.build_number,
            build_results=excluded.build_results,
            build_workerid=excluded.build_workerid,
            build_state_string=excluded.build_state_string,
            build_properties=excluded.build_properties,
            build_complete_at=excluded.build_complete_at,
            buildbot_instance=excluded.buildbot_instance
        ;
    
