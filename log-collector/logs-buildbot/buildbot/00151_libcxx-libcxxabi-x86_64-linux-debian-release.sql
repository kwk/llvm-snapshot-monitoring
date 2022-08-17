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
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 522787, 1438586, true, 1, 4, 5, 53, '', '{}', to_timestamp(1619129795), to_timestamp(1619129410), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 522832, 1438586, true, 1, 5, 2, 53, '', '{}', to_timestamp(1619130570), to_timestamp(1619130147), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 647889, 1782298, true, 1, 6, 2, 53, '', '{}', to_timestamp(1622864675), to_timestamp(1622864314), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 657722, 1808912, true, 1, 7, 2, 53, '', '{}', to_timestamp(1623194581), to_timestamp(1623194234), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 680837, 1866237, true, 1, 8, 2, 53, '', '{}', to_timestamp(1623864616), to_timestamp(1623864283), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 682854, 1871317, true, 1, 9, 2, 53, '', '{}', to_timestamp(1623935183), to_timestamp(1623934845), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 695271, 1901049, true, 1, 10, 2, 53, '', '{}', to_timestamp(1624378607), to_timestamp(1624378186), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 695461, 1901939, true, 1, 11, 2, 53, '', '{}', to_timestamp(1624381140), to_timestamp(1624380921), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 695839, 1904246, true, 1, 12, 2, 53, '', '{}', to_timestamp(1624387528), to_timestamp(1624387308), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 696702, 1907348, true, 1, 14, 2, 53, '', '{}', to_timestamp(1624409174), to_timestamp(1624408935), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 696688, 1907346, true, 1, 13, 2, 53, '', '{}', to_timestamp(1624408935), to_timestamp(1624408590), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 802992, 2207529, true, 1, 15, 2, 53, '', '{}', to_timestamp(1627538877), to_timestamp(1627538594), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 812966, 2232840, true, 1, 16, 2, 53, '', '{}', to_timestamp(1627918913), to_timestamp(1627918588), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 834613, 2299091, true, 1, 17, 2, 53, '', '{}', to_timestamp(1628704341), to_timestamp(1628704118), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 364302, 974409, true, 1, 2, 2, 53, '', '{}', to_timestamp(1614135877), to_timestamp(1614135518), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 364415, 974801, true, 1, 3, 2, 53, '', '{}', to_timestamp(1614137915), to_timestamp(1614137668), 'buildbot'), 
(151, 'null', ARRAY[]::integer[], 'libcxx-libcxxabi-x86_64-linux-debian-release', ARRAY['libcxx', 'release']::text[], 358957, 957023, true, 1, 1, 2, 53, '', '{}', to_timestamp(1613986928), to_timestamp(1613986500), 'buildbot')

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
    
