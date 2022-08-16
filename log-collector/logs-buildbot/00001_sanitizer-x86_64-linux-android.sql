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
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 13257, 226034, true, 2, 1, 4, 3, '', '{}', to_timestamp(1611823152), to_timestamp(1611822816)), 
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 13258, 227149, true, 2, 2, 4, 3, '', '{}', to_timestamp(1611823300), to_timestamp(1611823162)), 
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 13266, 227393, true, 2, 3, 4, 3, '', '{}', to_timestamp(1611823812), to_timestamp(1611823522)), 
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 30188, 455002, true, 2, 6, 5, 3, '', '{}', to_timestamp(1614378882), to_timestamp(1614378851)), 
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 30176, 451209, true, 2, 4, 2, 3, '', '{}', to_timestamp(1614377831), to_timestamp(1614376416)), 
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 30191, 454959, true, 2, 8, 2, 3, '', '{}', to_timestamp(1614379309), to_timestamp(1614378934)), 
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 30179, 454959, true, 2, 5, 5, 3, '', '{}', to_timestamp(1614378852), to_timestamp(1614377831)), 
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 30189, 454959, true, 2, 7, 5, 3, '', '{}', to_timestamp(1614378934), to_timestamp(1614378881)), 
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 30204, 455232, true, 2, 10, 2, 3, '', '{}', to_timestamp(1614381352), to_timestamp(1614381343)), 
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 30192, 455219, true, 2, 9, 0, 3, '', '{}', to_timestamp(1614381343), to_timestamp(1614379309)), 
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 30205, 455245, true, 2, 11, 0, 3, '', '{}', to_timestamp(1614383379), to_timestamp(1614381351)), 
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 30243, 455707, true, 2, 13, 5, 3, '', '{}', to_timestamp(1614386116), to_timestamp(1614385411)), 
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 30226, 455610, true, 2, 12, 0, 3, '', '{}', to_timestamp(1614385412), to_timestamp(1614383379)), 
(1, 'null', ARRAY[2]::integer[], 'sanitizer-x86_64-linux-android', ARRAY['sanitizer']::text[], 378103, 455707, true, 2, 14, 5, 178, '', '{}', to_timestamp(1660241799), to_timestamp(1660241721))

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
    
