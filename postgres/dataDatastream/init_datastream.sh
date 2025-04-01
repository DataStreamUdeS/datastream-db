#!/bin/sh
# set -e
echo "INIT DATASTREAM"
sed -i 's/^local\s\+all\s\+all\s\+trust$/local   all   postgres   trust/' /var/lib/postgresql/data/pg_hba.conf
echo "Waiting for PostgreSQL to start..."
until pg_isready -U postgres; do
    echo "Waiting for Postgres"
    sleep 2
done
echo "Waiting for cogesaf_db to be available..."
until psql -U "$POSTGRES_USER" -h postgresql_cogesaf -d cogesaf_db -c "SELECT 1;" > /dev/null 2>&1; do
    echo "Waiting for cogesaf_db..."
    sleep 2
done
echo "Creating database datastream_db..."
psql -U "$POSTGRES_USER" -d datastream_db -c "CREATE DATABASE datastream_db;"
psql -U "$POSTGRES_USER" -d datastream_db -f /home/creationBD.sql
psql -U "$POSTGRES_USER" -d datastream_db -f /home/migration.sql 