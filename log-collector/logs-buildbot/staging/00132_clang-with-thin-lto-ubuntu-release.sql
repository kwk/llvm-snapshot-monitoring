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
(132, 'null', ARRAY[2]::integer[], 'clang-with-thin-lto-ubuntu-release', ARRAY['clang', 'lld', 'LTO', 'release']::text[], 189181, 979880, true, 2, 1, 6, 2, '', '{}', to_timestamp(1634148323), to_timestamp(1634146534), 'staging'), 
(132, 'null', ARRAY[2]::integer[], 'clang-with-thin-lto-ubuntu-release', ARRAY['clang', 'lld', 'LTO', 'release']::text[], 189198, 1420327, true, 2, 2, 6, 2, '', '{}', to_timestamp(1634148410), to_timestamp(1634148323), 'staging'), 
(132, 'null', ARRAY[2]::integer[], 'clang-with-thin-lto-ubuntu-release', ARRAY['clang', 'lld', 'LTO', 'release']::text[], 189199, 1926326, true, 2, 3, 6, 2, '', '{}', to_timestamp(1634148423), to_timestamp(1634148410), 'staging'), 
(132, 'null', ARRAY[2]::integer[], 'clang-with-thin-lto-ubuntu-release', ARRAY['clang', 'lld', 'LTO', 'release']::text[], 189748, 2262821, true, 2, 4, 2, 2, '', '{}', to_timestamp(1634377158), to_timestamp(1634361506), 'staging'), 
(132, 'null', ARRAY[2]::integer[], 'clang-with-thin-lto-ubuntu-release', ARRAY['clang', 'lld', 'LTO', 'release']::text[], 191040, 2288643, true, 2, 5, 2, 2, '', '{}', to_timestamp(1634630624), to_timestamp(1634615786), 'staging'), 
(132, 'null', ARRAY[2]::integer[], 'clang-with-thin-lto-ubuntu-release', ARRAY['clang', 'lld', 'LTO', 'release']::text[], 192216, 2304419, true, 2, 6, 2, 2, '', '{}', to_timestamp(1634811396), to_timestamp(1634797607), 'staging'), 
(132, 'null', ARRAY[2]::integer[], 'clang-with-thin-lto-ubuntu-release', ARRAY['clang', 'lld', 'LTO', 'release']::text[], 192706, 2312177, true, 2, 7, 2, 2, '', '{}', to_timestamp(1634874792), to_timestamp(1634859575), 'staging'), 
(132, 'null', ARRAY[2]::integer[], 'clang-with-thin-lto-ubuntu-release', ARRAY['clang', 'lld', 'LTO', 'release']::text[], 192866, 2315235, true, 2, 8, 2, 2, '', '{}', to_timestamp(1634902736), to_timestamp(1634889247), 'staging')

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
    
