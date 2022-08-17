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
(149, 'null', ARRAY[]::integer[], 'flang-aarch64-ubuntu-out-of-tree-new-driver', ARRAY['flang']::text[], 39967, 624130, true, 2, 1, 2, 98, '', '{}', to_timestamp(1616223967), to_timestamp(1616223643), 'staging'), 
(149, 'null', ARRAY[]::integer[], 'flang-aarch64-ubuntu-out-of-tree-new-driver', ARRAY['flang']::text[], 40211, 625204, true, 2, 2, 2, 98, '', '{}', to_timestamp(1616262136), to_timestamp(1616262127), 'staging')

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
    
