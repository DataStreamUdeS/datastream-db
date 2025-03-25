#!/bin/sh
set -e
echo "Waiting for PostgreSQL to start..."
until pg_isready -U postgres; do
    sleep 2
done
echo "PostgreSQL is ready. Restoring database..."
pg_restore -U postgres -d cogesaf_db "/home/pg_convergence.tar"
echo "Creating database datastream_db..."
psql -U "$POSTGRES_USER" -d datastream_db -c "CREATE DATABASE datastream_db;"
psql -U "$POSTGRES_USER" -d datastream_db -f /docker-entrypoint-initdb.d/creationBD.sql
# psql -U "$POSTGRES_USER" -d datastream_db -f /docker-entrypoint-initdb.d/migration.sql
