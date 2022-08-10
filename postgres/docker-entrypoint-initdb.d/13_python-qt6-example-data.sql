INSERT INTO copr_build_logs (
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
) VALUES 
('@kdesig', 'python-qt6', 'thunderbirdtr', 'python-qt6', 'https://download.copr.fedorainfracloud.org/results/@kdesig/python-qt6/srpm-builds/04200339/python-qt6-6.2.3-1.fc35.src.rpm', '6.2.3-1.fc35', 'python-qt6', 'succeeded', 'https://download.copr.fedorainfracloud.org/results/@kdesig/python-qt6', 4200339, to_timestamp(1649808972), to_timestamp(1649803664), to_timestamp(1649803622), false, ARRAY['fedora-rawhide-x86_64', 'fedora-36-x86_64', 'fedora-rawhide-aarch64', 'fedora-36-aarch64']), 
('@kdesig', 'python-qt6', 'thunderbirdtr', 'python-pyqt6-sip', 'https://download.copr.fedorainfracloud.org/results/@kdesig/python-qt6/srpm-builds/04200338/python-pyqt6-sip-13.3.0-1.fc35.src.rpm', '13.3.0-1.fc35', 'python-qt6', 'succeeded', 'https://download.copr.fedorainfracloud.org/results/@kdesig/python-qt6', 4200338, to_timestamp(1649804303), to_timestamp(1649803642), to_timestamp(1649803595), false, ARRAY['fedora-rawhide-x86_64', 'fedora-36-x86_64', 'fedora-rawhide-aarch64', 'fedora-36-aarch64']), 
('@kdesig', 'python-qt6', 'thunderbirdtr', 'python-qt6', 'https://download.copr.fedorainfracloud.org/results/@kdesig/python-qt6/srpm-builds/04199264/python-qt6-6.2.3-1.fc35.src.rpm', '6.2.3-1.fc35', 'python-qt6', 'succeeded', 'https://download.copr.fedorainfracloud.org/results/@kdesig/python-qt6', 4199264, to_timestamp(1649802694), to_timestamp(1649797473), to_timestamp(1649796495), false, ARRAY['fedora-rawhide-x86_64', 'fedora-36-x86_64', 'fedora-rawhide-aarch64', 'fedora-36-aarch64'])

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
