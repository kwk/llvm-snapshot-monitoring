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
(46, 'null', ARRAY[]::integer[], 'sanitizer-x86_64-linux-bootstrap', ARRAY['sanitizer']::text[], 101473, 1099361, true, 2, 1, 2, 22, '', '{}', to_timestamp(1621322042), to_timestamp(1621315099), 'staging'), 
(46, 'null', ARRAY[]::integer[], 'sanitizer-x86_64-linux-bootstrap', ARRAY['sanitizer']::text[], 101561, 1104125, true, 2, 3, 0, 22, '', '{}', to_timestamp(1621335534), to_timestamp(1621328679), 'staging'), 
(46, 'null', ARRAY[]::integer[], 'sanitizer-x86_64-linux-bootstrap', ARRAY['sanitizer']::text[], 101518, 1103671, true, 2, 2, 0, 22, '', '{}', to_timestamp(1621328679), to_timestamp(1621322041), 'staging'), 
(46, 'null', ARRAY[]::integer[], 'sanitizer-x86_64-linux-bootstrap', ARRAY['sanitizer']::text[], 101623, 1104971, true, 2, 4, 0, 22, '', '{}', to_timestamp(1621342504), to_timestamp(1621335534), 'staging'), 
(46, 'null', ARRAY[]::integer[], 'sanitizer-x86_64-linux-bootstrap', ARRAY['sanitizer']::text[], 101702, 1105936, true, 2, 5, 0, 22, '', '{}', to_timestamp(1621349491), to_timestamp(1621342504), 'staging'), 
(46, 'null', ARRAY[]::integer[], 'sanitizer-x86_64-linux-bootstrap', ARRAY['sanitizer']::text[], 101781, 1106707, true, 2, 7, 0, 22, '', '{}', to_timestamp(1621363340), to_timestamp(1621356470), 'staging'), 
(46, 'null', ARRAY[]::integer[], 'sanitizer-x86_64-linux-bootstrap', ARRAY['sanitizer']::text[], 101745, 1106505, true, 2, 6, 0, 22, '', '{}', to_timestamp(1621356452), to_timestamp(1621349490), 'staging'), 
(46, 'null', ARRAY[]::integer[], 'sanitizer-x86_64-linux-bootstrap', ARRAY['sanitizer']::text[], 101896, 1108399, true, 2, 8, 0, 22, '', '{}', to_timestamp(1621370065), to_timestamp(1621363339), 'staging'), 
(46, 'null', ARRAY[]::integer[], 'sanitizer-x86_64-linux-bootstrap', ARRAY['sanitizer']::text[], 101960, 1109632, true, 2, 9, 0, 22, '', '{}', to_timestamp(1621376556), to_timestamp(1621370065), 'staging'), 
(46, 'null', ARRAY[]::integer[], 'sanitizer-x86_64-linux-bootstrap', ARRAY['sanitizer']::text[], 102041, 1109995, true, 2, 10, 0, 22, '', '{}', to_timestamp(1621383052), to_timestamp(1621376555), 'staging'), 
(46, 'null', ARRAY[]::integer[], 'sanitizer-x86_64-linux-bootstrap', ARRAY['sanitizer']::text[], 102129, 1112261, true, 2, 11, 0, 22, '', '{}', to_timestamp(1621389022), to_timestamp(1621383052), 'staging'), 
(46, 'null', ARRAY[]::integer[], 'sanitizer-x86_64-linux-bootstrap', ARRAY['sanitizer']::text[], 102169, 1112897, true, 2, 12, 5, 22, '', '{}', to_timestamp(1621399624), to_timestamp(1621389239), 'staging')

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
    
