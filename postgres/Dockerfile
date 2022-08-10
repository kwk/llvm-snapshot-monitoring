FROM postgres:14-bullseye

LABEL maintainer="LLVM Fedora Team"

ENV TIMESCALEDB_MAJOR 2
ENV TIMESCALEDB_VERSION 2.7.2
ENV POSTGRES_USER postgres

RUN apt-get update \
    && apt install -y --no-install-recommends ca-certificates gnupg postgresql-common apt-transport-https lsb-release wget \
    && /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y \
    && echo "deb https://packagecloud.io/timescale/timescaledb/debian/ bullseye main" > /etc/apt/sources.list.d/timescaledb.list \
    && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | apt-key add - \
    && apt update \
    && apt install -y --no-install-recommends timescaledb-2-postgresql-$PG_MAJOR \
    && rm -rf /var/lib/apt/lists/*

# RUN mkdir -p /docker-entrypoint-initdb.d
# COPY ./initdb-timescaledb.sh /docker-entrypoint-initdb.d/10_timescale.sh
COPY ./update-timescaledb.sh /usr/local/bin
