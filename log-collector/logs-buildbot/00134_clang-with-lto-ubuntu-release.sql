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
        build_started_at
    ) VALUES 
(134, 'null', ARRAY[2]::integer[], 'clang-with-lto-ubuntu-release', ARRAY['clang', 'lld', 'LTO', 'release']::text[], 96387, 979881, true, 2, 1, 6, 52, '', '{}', to_timestamp(1620754978), to_timestamp(1620754928)), 
(134, 'null', ARRAY[2]::integer[], 'clang-with-lto-ubuntu-release', ARRAY['clang', 'lld', 'LTO', 'release']::text[], 96388, 1036379, true, 2, 2, 6, 52, '', '{}', to_timestamp(1620755243), to_timestamp(1620754977)), 
(134, 'null', ARRAY[2]::integer[], 'clang-with-lto-ubuntu-release', ARRAY['clang', 'lld', 'LTO', 'release']::text[], 97464, 1046383, true, 2, 3, 2, 52, '', '{}', to_timestamp(1620817976), to_timestamp(1620817529)), 
(134, 'null', ARRAY[2]::integer[], 'clang-with-lto-ubuntu-release', ARRAY['clang', 'lld', 'LTO', 'release']::text[], 98333, 1054618, true, 2, 4, 6, 52, '', '{}', to_timestamp(1620926893), to_timestamp(1620903291))

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
            build_complete_at=excluded.build_complete_at
        ;
    
