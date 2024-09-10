#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER postgres;
    CREATE DATABASE nextclouddb;
    GRANT ALL PRIVILEGES ON DATABASE nextclouddb TO postgres;
EOSQL