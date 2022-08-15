#!/bin/bash

INPUT=-
OUTPUT=/dev/stdout
if (($# >= 1)); then
    if (($# == 2)); then
        INPUT=$1
        OUTPUT=$2
    else
        echo "ERROR: Either use standard input/output or pass input and output files to $0." 1>&2
        exit 1;
    fi
fi

# The dollar sign below is important; otherwise you cannot contain single quotes.
jq -r $'
("INSERT INTO copr_build_logs (
    owner_name,
    project_name,
    submitter,
    source_package_name,
    source_package_url,
    source_package_version,
    project_dirname,
    state,
    repo_url,
    build_id,
    ended_on_ts,
    started_on_ts,
    submitted_on,
    is_background,
    chroots
) VALUES ")
,
([
    "(" +
    (
        (
            .items[] | [
                ([
                    .ownername,
                    .projectname,
                    .submitter,
                    .source_package.name,
                    .source_package.url,
                    .source_package.version,
                    .project_dirname,
                    .state,
                    .repo_url
                ] | map("\'" + . + "\'") | join(", ")),
                .id,
                ([.ended_on, .started_on, .submitted_on] | map("to_timestamp("+(.|tostring)+")") | join(", ")),
                .is_background,
                "ARRAY[" + (
                    .chroots 
                    | map("\'" + . + "\'") 
                    | join(", ") 
                ) + "]"
            ]) | join(", ")
        ) 
    + ")"
] | join(", \n")),
("
    ON CONFLICT ON CONSTRAINT copr_build_logs_pkey
    DO UPDATE SET
        submitter=excluded.submitter,
        source_package_name=excluded.source_package_name,
        source_package_url=excluded.source_package_url,
        source_package_version=excluded.source_package_version,
        project_dirname=excluded.project_dirname,
        state=excluded.state,
        repo_url=excluded.repo_url,
        ended_on_ts=excluded.ended_on_ts,
        started_on_ts=excluded.started_on_ts,
        submitted_on=excluded.submitted_on,
        is_background=excluded.is_background,
        chroots=excluded.chroots
    ;
")
' $INPUT > $OUTPUT
