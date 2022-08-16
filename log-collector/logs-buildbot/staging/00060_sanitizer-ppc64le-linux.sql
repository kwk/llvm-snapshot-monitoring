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
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 333976, 4628577, true, 2, 1, 0, 48, '', '{}', to_timestamp(1656427009), to_timestamp(1656421032)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 334162, 4631115, true, 2, 2, 0, 48, '', '{}', to_timestamp(1656431471), to_timestamp(1656427031)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 334310, 4631305, true, 2, 3, 0, 48, '', '{}', to_timestamp(1656435772), to_timestamp(1656431470)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 334478, 4632010, true, 2, 4, 0, 48, '', '{}', to_timestamp(1656441213), to_timestamp(1656435778)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 334643, 4632550, true, 2, 5, 0, 48, '', '{}', to_timestamp(1656446120), to_timestamp(1656441213)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 334789, 4633325, true, 2, 6, 0, 48, '', '{}', to_timestamp(1656450117), to_timestamp(1656446125)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 334871, 4633894, true, 2, 7, 0, 48, '', '{}', to_timestamp(1656455693), to_timestamp(1656450343)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 335012, 4633989, true, 2, 8, 0, 48, '', '{}', to_timestamp(1656460825), to_timestamp(1656455872)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 335166, 4636041, true, 2, 9, 5, 48, '', '{}', to_timestamp(1656464669), to_timestamp(1656460825)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 335317, 4636041, true, 2, 10, 0, 48, '', '{}', to_timestamp(1656469389), to_timestamp(1656464754)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 335469, 4636480, true, 2, 11, 5, 48, '', '{}', to_timestamp(1656486655), to_timestamp(1656469389)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 335574, 4636480, true, 2, 12, 0, 48, '', '{}', to_timestamp(1656491050), to_timestamp(1656486736)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 335640, 4639175, true, 2, 13, 0, 48, '', '{}', to_timestamp(1656495845), to_timestamp(1656491050)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 335793, 4639566, true, 2, 14, 0, 48, '', '{}', to_timestamp(1656501036), to_timestamp(1656495845)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 335940, 4641075, true, 2, 15, 0, 48, '', '{}', to_timestamp(1656506474), to_timestamp(1656501144)), 
(60, 'null', ARRAY[2]::integer[], 'sanitizer-ppc64le-linux', ARRAY['sanitizer', 'ppc', 'ppc64le']::text[], 336123, 4641901, true, 2, 16, 5, 48, '', '{}', to_timestamp(1656510252), to_timestamp(1656506477))

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
    
