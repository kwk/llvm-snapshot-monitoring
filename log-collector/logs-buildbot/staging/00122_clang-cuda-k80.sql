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
(122, 'null', ARRAY[2]::integer[], 'clang-cuda-k80', ARRAY['clang']::text[], 42243, 639911, true, 2, 1, 0, 56, '', '{}', to_timestamp(1616450244), to_timestamp(1616449974), 'staging'), 
(122, 'null', ARRAY[2]::integer[], 'clang-cuda-k80', ARRAY['clang']::text[], 42250, 640485, true, 2, 2, 0, 56, '', '{}', to_timestamp(1616450286), to_timestamp(1616450243), 'staging'), 
(122, 'null', ARRAY[2]::integer[], 'clang-cuda-k80', ARRAY['clang']::text[], 42253, 640553, true, 2, 3, 5, 56, '', '{}', to_timestamp(1616450297), to_timestamp(1616450291), 'staging')

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
    
