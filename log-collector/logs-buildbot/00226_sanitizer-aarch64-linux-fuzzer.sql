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
(226, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-fuzzer', ARRAY['sanitizer']::text[], 378542, 5075170, true, 2, 1, 0, 4, '', '{}', to_timestamp(1660308521), to_timestamp(1660299935)), 
(226, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-fuzzer', ARRAY['sanitizer']::text[], 378749, 5078409, true, 2, 2, 0, 4, '', '{}', to_timestamp(1660329790), to_timestamp(1660329786)), 
(226, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-fuzzer', ARRAY['sanitizer']::text[], 378875, 5101036, true, 2, 3, 0, 4, '', '{}', to_timestamp(1660597294), to_timestamp(1660597290)), 
(226, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-fuzzer', ARRAY['sanitizer']::text[], 379221, 5107135, true, 2, 4, 0, 4, '', '{}', to_timestamp(1660629225), to_timestamp(1660629221)), 
(226, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-fuzzer', ARRAY['sanitizer']::text[], 379346, 5107884, true, 2, 5, 0, 4, '', '{}', to_timestamp(1660642906), to_timestamp(1660642902)), 
(226, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-fuzzer', ARRAY['sanitizer']::text[], 379655, 5110061, true, 2, 6, 0, 4, '', '{}', to_timestamp(1660663992), to_timestamp(1660663988)), 
(226, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-fuzzer', ARRAY['sanitizer']::text[], 379843, 5112512, true, 2, 7, 0, 4, '', '{}', to_timestamp(1660684546), to_timestamp(1660684541))

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
    
