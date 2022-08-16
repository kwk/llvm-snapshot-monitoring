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
(35, 'null', ARRAY[2]::integer[], 'clang-ppc64be-linux-multistage', ARRAY['clang', 'ppc']::text[], 364248, 4843739, true, 2, 1, 2, 92, '', '{}', to_timestamp(1658264218), to_timestamp(1658257368)), 
(35, 'null', ARRAY[2]::integer[], 'clang-ppc64be-linux-multistage', ARRAY['clang', 'ppc']::text[], 364319, 4845422, true, 2, 2, 0, 92, '', '{}', to_timestamp(1658270817), to_timestamp(1658264218)), 
(35, 'null', ARRAY[2]::integer[], 'clang-ppc64be-linux-multistage', ARRAY['clang', 'ppc']::text[], 364405, 4846848, true, 2, 3, 0, 92, '', '{}', to_timestamp(1658275308), to_timestamp(1658270816)), 
(35, 'null', ARRAY[2]::integer[], 'clang-ppc64be-linux-multistage', ARRAY['clang', 'ppc']::text[], 364451, 4846995, true, 2, 4, 0, 92, '', '{}', to_timestamp(1658281242), to_timestamp(1658275308)), 
(35, 'null', ARRAY[2]::integer[], 'clang-ppc64be-linux-multistage', ARRAY['clang', 'ppc']::text[], 364506, 4848362, true, 2, 5, 0, 92, '', '{}', to_timestamp(1658286384), to_timestamp(1658281242)), 
(35, 'null', ARRAY[2]::integer[], 'clang-ppc64be-linux-multistage', ARRAY['clang', 'ppc']::text[], 364630, 4850186, true, 2, 7, 0, 92, '', '{}', to_timestamp(1658297113), to_timestamp(1658292870)), 
(35, 'null', ARRAY[2]::integer[], 'clang-ppc64be-linux-multistage', ARRAY['clang', 'ppc']::text[], 364555, 4848491, true, 2, 6, 0, 92, '', '{}', to_timestamp(1658292870), to_timestamp(1658286384)), 
(35, 'null', ARRAY[2]::integer[], 'clang-ppc64be-linux-multistage', ARRAY['clang', 'ppc']::text[], 364655, 4850371, true, 2, 8, 0, 92, '', '{}', to_timestamp(1658301996), to_timestamp(1658298072)), 
(35, 'null', ARRAY[2]::integer[], 'clang-ppc64be-linux-multistage', ARRAY['clang', 'ppc']::text[], 364693, 4850481, true, 2, 9, 0, 92, '', '{}', to_timestamp(1658306363), to_timestamp(1658301996)), 
(35, 'null', ARRAY[2]::integer[], 'clang-ppc64be-linux-multistage', ARRAY['clang', 'ppc']::text[], 364772, 4850943, true, 2, 10, 0, 92, '', '{}', to_timestamp(1658313242), to_timestamp(1658306363)), 
(35, 'null', ARRAY[2]::integer[], 'clang-ppc64be-linux-multistage', ARRAY['clang', 'ppc']::text[], 364870, 4852727, true, 2, 11, 0, 92, '', '{}', to_timestamp(1658318286), to_timestamp(1658313242)), 
(35, 'null', ARRAY[2]::integer[], 'clang-ppc64be-linux-multistage', ARRAY['clang', 'ppc']::text[], 364930, 4853458, true, 2, 12, 0, 92, '', '{}', to_timestamp(1658322640), to_timestamp(1658318286)), 
(35, 'null', ARRAY[2]::integer[], 'clang-ppc64be-linux-multistage', ARRAY['clang', 'ppc']::text[], 365008, 4854218, true, 2, 13, 5, 92, '', '{}', to_timestamp(1658322955), to_timestamp(1658322639))

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
    
