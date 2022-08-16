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
(218, 'null', ARRAY[2]::integer[], 'clang-ppc64le-linux-test-suite', ARRAY['clang', 'ppc', 'ppc64le']::text[], 356637, 4732041, true, 2, 1, 0, 175, '', '{}', to_timestamp(1657292779), to_timestamp(1657291031)), 
(218, 'null', ARRAY[2]::integer[], 'clang-ppc64le-linux-test-suite', ARRAY['clang', 'ppc', 'ppc64le']::text[], 356681, 4733424, true, 2, 3, 0, 175, '', '{}', to_timestamp(1657293630), to_timestamp(1657293030)), 
(218, 'null', ARRAY[2]::integer[], 'clang-ppc64le-linux-test-suite', ARRAY['clang', 'ppc', 'ppc64le']::text[], 356671, 4733424, true, 2, 2, 5, 175, '', '{}', to_timestamp(1657292985), to_timestamp(1657292778)), 
(218, 'null', ARRAY[2]::integer[], 'clang-ppc64le-linux-test-suite', ARRAY['clang', 'ppc', 'ppc64le']::text[], 356715, 4733976, true, 2, 4, 0, 175, '', '{}', to_timestamp(1657295799), to_timestamp(1657293881)), 
(218, 'null', ARRAY[2]::integer[], 'clang-ppc64le-linux-test-suite', ARRAY['clang', 'ppc', 'ppc64le']::text[], 356757, 4735284, true, 2, 5, 0, 175, '', '{}', to_timestamp(1657297229), to_timestamp(1657296501)), 
(218, 'null', ARRAY[2]::integer[], 'clang-ppc64le-linux-test-suite', ARRAY['clang', 'ppc', 'ppc64le']::text[], 356776, 4735462, true, 2, 6, 0, 175, '', '{}', to_timestamp(1657299076), to_timestamp(1657298354)), 
(218, 'null', ARRAY[2]::integer[], 'clang-ppc64le-linux-test-suite', ARRAY['clang', 'ppc', 'ppc64le']::text[], 356791, 4735610, true, 2, 7, 0, 175, '', '{}', to_timestamp(1657299877), to_timestamp(1657299207))

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
    
