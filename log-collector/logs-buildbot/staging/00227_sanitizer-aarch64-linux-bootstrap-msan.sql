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
(227, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-msan', ARRAY['sanitizer']::text[], 378257, 5073650, true, 2, 1, 2, 4, '', '{}', to_timestamp(1660277055), to_timestamp(1660268372)), 
(227, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-msan', ARRAY['sanitizer']::text[], 378386, 5075171, true, 2, 2, 2, 4, '', '{}', to_timestamp(1660293710), to_timestamp(1660285254)), 
(227, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-msan', ARRAY['sanitizer']::text[], 378729, 5078420, true, 2, 4, 0, 4, '', '{}', to_timestamp(1660323489), to_timestamp(1660323485)), 
(227, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-msan', ARRAY['sanitizer']::text[], 378663, 5078420, true, 2, 3, 5, 4, '', '{}', to_timestamp(1660322282), to_timestamp(1660315074)), 
(227, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-msan', ARRAY['sanitizer']::text[], 378812, 5101037, true, 2, 5, 0, 4, '', '{}', to_timestamp(1660591729), to_timestamp(1660591725)), 
(227, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-msan', ARRAY['sanitizer']::text[], 379173, 5107136, true, 2, 6, 0, 4, '', '{}', to_timestamp(1660622221), to_timestamp(1660622217)), 
(227, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-msan', ARRAY['sanitizer']::text[], 379293, 5107896, true, 2, 7, 0, 4, '', '{}', to_timestamp(1660636953), to_timestamp(1660636949)), 
(227, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-msan', ARRAY['sanitizer']::text[], 379353, 5108493, true, 2, 8, 0, 4, '', '{}', to_timestamp(1660643649), to_timestamp(1660643643)), 
(227, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-msan', ARRAY['sanitizer']::text[], 379554, 5110063, true, 2, 9, 0, 4, '', '{}', to_timestamp(1660658658), to_timestamp(1660658655)), 
(227, 'null', ARRAY[2]::integer[], 'sanitizer-aarch64-linux-bootstrap-msan', ARRAY['sanitizer']::text[], 379800, 5112513, true, 2, 10, 0, 4, '', '{}', to_timestamp(1660678200), to_timestamp(1660678196))

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
    
