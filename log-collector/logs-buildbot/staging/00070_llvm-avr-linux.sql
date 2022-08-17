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
(70, 'null', ARRAY[2]::integer[], 'llvm-avr-linux', ARRAY['clang']::text[], 35427, 551734, true, 2, 1, 0, 42, '', '{}', to_timestamp(1615436130), to_timestamp(1615431710), 'staging'), 
(70, 'null', ARRAY[2]::integer[], 'llvm-avr-linux', ARRAY['clang']::text[], 35465, 551859, true, 2, 2, 5, 42, '', '{}', to_timestamp(1615437534), to_timestamp(1615436129), 'staging')

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
    
