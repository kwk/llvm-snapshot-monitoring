#!/bin/bash

set -e

get_all_builders() {
    local file_path=all_builders_${BUILDBOT_INSTANCE}.json
    local refresh_cache=${1:-false}
    if [ "$refresh_cache" == "true" ]; then
        rm -f $file_path
    fi
    if [ ! -f $file_path ]; then
        curl -Ls ${API_URL_BASE}/builders > $file_path
    fi
    echo $file_path
}
export -f get_all_builders

# Returns the SQL lines of values for a given builder index in the array of
# builders.
builder_values() {
    local builder_idx=$1

    cat $(get_all_builders) | jq -r --arg builder_idx $builder_idx $'
        .builders[($builder_idx | tonumber)] | [(
            .builderid,
            ("\'" + (.description | tostring) + "\'"),
            "ARRAY[" + (.masterids | join(", ")) + "]::integer[]",
            ("\'" + (.name| tostring) + "\'"),
            "ARRAY[" + (
                .tags 
                | map("\'" + . + "\'") 
                | join(", ")
            ) + "]::text[]"
        )] | join(", ")'
}
export -f builder_values

# I'm not sure if the index a builder has in the array of builders is the same
# as its id but we're translating it anyways just to be on the safe side.
builder_idx_to_id() {
    local builder_idx=$1
    cat $(get_all_builders) | jq -r --arg builder_idx $builder_idx $'
        .builders[($builder_idx | tonumber)].builderid
    '
}
export -f builder_idx_to_id

builder_idx_to_name() {
    local builder_idx=$1
    cat $(get_all_builders) | jq -r --arg builder_idx $builder_idx $'
        .builders[($builder_idx | tonumber)].name
    '
}
export -f builder_idx_to_name

dowork() {
    builder_idx=$1
    # if [[ "$builder_idx" == "1" ]]; then
    #     # echo "EXITING because we wanna"
    #     exit 0
    # fi
    # builder_idx=223
    builder_values=$(builder_values $builder_idx)
    builder_id=$(builder_idx_to_id $builder_idx)
    builder_name=$(builder_idx_to_name $builder_idx)
    log_file_base=logs-buildbot/${BUILDBOT_INSTANCE}/$(printf "%05d" $builder_id)_$builder_name
    json_file=$log_file_base.json
    sql_file=$log_file_base.sql

    echo -n "Processing $builder_name ($builder_id/$count_builders)..JSON..."

    # The dollar sign below is important; otherwise you cannot contain single quotes.
    curl -Ls ${API_URL_BASE}/builders/$builder_id/builds > $json_file
   
    if [[ ! -f $json_file ]] || [[ "$(cat $json_file | jq '.meta.total')" == "0" ]]; then
        echo "No logs for $builder_name"
        return 0
    fi

    echo "SQL"
    cat $json_file | jq -r --arg builder_values "$builder_values" --arg buildbot_instance "$BUILDBOT_INSTANCE" $'
    ("INSERT INTO buildbot_build_logs (
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
    ) VALUES ")
    ,
    (
        [
            "(" +
            
            (
                (
                    .builds[] | [
                        ([
                            $builder_values,
                            .buildid,
                            .buildrequestid,
                            .complete,
                            .masterid,
                            .number,
                            .results,
                            .workerid
                        ] | map(.|tostring) | join(", ")),
                        "\'\'",
                        "\'"+(.properties | tostring)+"\'",
                        ([.complete_at, .started_at] | map("to_timestamp("+(.|tostring)+")") | join(", ")),
                        "\'"+($buildbot_instance | tostring)+"\'"
                    ]
                ) | join(", ")
            ) 
            + ")"
        ] | join(", \n")
    ),
    ("
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
    ")
    ' \
    > $sql_file
}
export -f dowork

main() {
    # possible values: staging or buildbot (for production)
    export BUILDBOT_INSTANCE=${BUILDBOT_INSTANCE:-staging}
    export API_URL_BASE=https://lab.llvm.org/${BUILDBOT_INSTANCE}/api/v2

    # Ensure the builders file exists before all the parallel workers start.
    all_builders_file=$(get_all_builders true)

    export count_builders=$(cat $all_builders_file | jq '.meta.total')

    seq 0 1 $((count_builders - 1)) | parallel -j$(nproc) --eta dowork {}
}

main
