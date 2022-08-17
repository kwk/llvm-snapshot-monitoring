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
(86, 'null', ARRAY[2]::integer[], 'clang-cuda-p4', ARRAY['clang']::text[], 28290, 426422, true, 2, 8, 2, 73, '', '{}', to_timestamp(1614112325), to_timestamp(1614112270), 'staging'), 
(86, 'null', ARRAY[2]::integer[], 'clang-cuda-p4', ARRAY['clang']::text[], 28282, 426357, true, 2, 7, 2, 73, '', '{}', to_timestamp(1614111739), to_timestamp(1614111672), 'staging'), 
(86, 'null', ARRAY[2]::integer[], 'clang-cuda-p4', ARRAY['clang']::text[], 28274, 426260, true, 2, 6, 2, 73, '', '{}', to_timestamp(1614110890), to_timestamp(1614110792), 'staging'), 
(86, 'null', ARRAY[2]::integer[], 'clang-cuda-p4', ARRAY['clang']::text[], 28258, 426018, true, 2, 3, 2, 73, '', '{}', to_timestamp(1614109367), to_timestamp(1614109268), 'staging'), 
(86, 'null', ARRAY[2]::integer[], 'clang-cuda-p4', ARRAY['clang']::text[], 28251, 421139, true, 2, 1, 2, 73, '', '{}', to_timestamp(1614109152), to_timestamp(1614109049), 'staging'), 
(86, 'null', ARRAY[2]::integer[], 'clang-cuda-p4', ARRAY['clang']::text[], 28252, 425868, true, 2, 2, 2, 73, '', '{}', to_timestamp(1614109186), to_timestamp(1614109151), 'staging'), 
(86, 'null', ARRAY[2]::integer[], 'clang-cuda-p4', ARRAY['clang']::text[], 28262, 426029, true, 2, 4, 2, 73, '', '{}', to_timestamp(1614109589), to_timestamp(1614109518), 'staging'), 
(86, 'null', ARRAY[2]::integer[], 'clang-cuda-p4', ARRAY['clang']::text[], 28267, 426238, true, 2, 5, 2, 73, '', '{}', to_timestamp(1614110556), to_timestamp(1614110257), 'staging'), 
(86, 'null', ARRAY[2]::integer[], 'clang-cuda-p4', ARRAY['clang']::text[], 28296, 426606, true, 2, 10, 2, 73, '', '{}', to_timestamp(1614112834), to_timestamp(1614112745), 'staging'), 
(86, 'null', ARRAY[2]::integer[], 'clang-cuda-p4', ARRAY['clang']::text[], 28293, 426575, true, 2, 9, 0, 73, '', '{}', to_timestamp(1614112469), to_timestamp(1614112390), 'staging'), 
(86, 'null', ARRAY[2]::integer[], 'clang-cuda-p4', ARRAY['clang']::text[], 28304, 426684, true, 2, 11, 2, 73, '', '{}', to_timestamp(1614113792), to_timestamp(1614113709), 'staging'), 
(86, 'null', ARRAY[2]::integer[], 'clang-cuda-p4', ARRAY['clang']::text[], 28308, 426722, true, 2, 12, 0, 73, '', '{}', to_timestamp(1614114429), to_timestamp(1614114152), 'staging')

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
    
