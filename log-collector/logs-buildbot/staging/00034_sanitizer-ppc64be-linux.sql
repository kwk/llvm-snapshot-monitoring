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
(34, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64be-linux', ARRAY['sanitizer', 'ppc']::text[], 364251, 4843753, true, 2, 1, 2, 64, '', '{}', to_timestamp(1658267060), to_timestamp(1658257743), 'staging'), 
(34, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64be-linux', ARRAY['sanitizer', 'ppc']::text[], 364363, 4845999, true, 2, 2, 0, 64, '', '{}', to_timestamp(1658275724), to_timestamp(1658267078), 'staging'), 
(34, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64be-linux', ARRAY['sanitizer', 'ppc']::text[], 364457, 4846977, true, 2, 3, 0, 64, '', '{}', to_timestamp(1658283983), to_timestamp(1658275723), 'staging'), 
(34, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64be-linux', ARRAY['sanitizer', 'ppc']::text[], 364526, 4848567, true, 2, 4, 0, 64, '', '{}', to_timestamp(1658292888), to_timestamp(1658283983), 'staging'), 
(34, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64be-linux', ARRAY['sanitizer', 'ppc']::text[], 364631, 4848975, true, 2, 5, 0, 64, '', '{}', to_timestamp(1658299674), to_timestamp(1658292888), 'staging'), 
(34, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64be-linux', ARRAY['sanitizer', 'ppc']::text[], 364665, 4850412, true, 2, 6, 2, 64, '', '{}', to_timestamp(1658308248), to_timestamp(1658299674), 'staging'), 
(34, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64be-linux', ARRAY['sanitizer', 'ppc']::text[], 364802, 4850941, true, 2, 7, 0, 64, '', '{}', to_timestamp(1658316991), to_timestamp(1658308247), 'staging'), 
(34, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64be-linux', ARRAY['sanitizer', 'ppc']::text[], 364923, 4853436, true, 2, 8, 5, 64, '', '{}', to_timestamp(1658322919), to_timestamp(1658316991), 'staging')

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
    
