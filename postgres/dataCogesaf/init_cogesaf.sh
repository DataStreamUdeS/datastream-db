#!/bin/sh
# set -e
echo "INIT COGESAF"
echo "Waiting for PostgreSQL to start..."
until pg_isready -U postgres; do
    echo "Waiting for Postgres"
    sleep 2
done
echo "PostgreSQL is ready. Restoring database..."
psql -U "$POSTGRES_USER" -d cogesaf_db -c "CREATE DATABASE cogesaf_db;"
psql -U "$POSTGRES_USER" -d cogesaf_db -c "CREATE ROLE admin_convergence;"
pg_restore -U postgres -d cogesaf_db "/home/pg_convergence.tar" & restore_pid=$!
wait $restore_pid
echo "Database restoration completed."