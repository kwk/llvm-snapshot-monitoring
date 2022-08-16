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
(224, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-ubsan', ARRAY['sanitizer']::text[], 378491, 5075168, true, 2, 1, 2, 4, '', '{}', to_timestamp(1660299935), to_timestamp(1660293710)), 
(224, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-ubsan', ARRAY['sanitizer']::text[], 378738, 5078395, true, 2, 2, 2, 4, '', '{}', to_timestamp(1660329787), to_timestamp(1660323496)), 
(224, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-ubsan', ARRAY['sanitizer']::text[], 378813, 5101032, true, 2, 3, 2, 4, '', '{}', to_timestamp(1660597190), to_timestamp(1660591729)), 
(224, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-ubsan', ARRAY['sanitizer']::text[], 379174, 5107133, true, 2, 4, 0, 4, '', '{}', to_timestamp(1660629222), to_timestamp(1660622220)), 
(224, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-ubsan', ARRAY['sanitizer']::text[], 379294, 5107861, true, 2, 5, 0, 4, '', '{}', to_timestamp(1660642902), to_timestamp(1660636952)), 
(224, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-ubsan', ARRAY['sanitizer']::text[], 379555, 5110044, true, 2, 6, 2, 4, '', '{}', to_timestamp(1660663919), to_timestamp(1660658658)), 
(224, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-ubsan', ARRAY['sanitizer']::text[], 379801, 5112510, true, 2, 7, 2, 4, '', '{}', to_timestamp(1660684541), to_timestamp(1660678200))

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
    
