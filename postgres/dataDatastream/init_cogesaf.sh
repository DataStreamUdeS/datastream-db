#!/bin/sh
# set -e
sed -i 's/^local\s\+all\s\+all\s\+trust$/local   all   postgres   trust/' /var/lib/postgresql/data/pg_hba.conf
echo "Waiting for PostgreSQL to start..."
until pg_isready -U postgres; do
    echo "Waiting for Postgres"
    sleep 2
done
echo "PostgreSQL is ready. Restoring database..."
psql -U "$POSTGRES_USER" -d datastream_db -c "CREATE DATABASE cogesaf_db;"
psql -U "$POSTGRES_USER" -d datastream_db -c "CREATE ROLE admin_convergence;"
pg_restore -U postgres -d cogesaf_db "/home/pg_convergence.tar" & restore_pid=$!
wait $restore_pid
echo "Database restoration completed."
echo "Restarting Postgres"
pg_ctl restart
echo "Waiting for cogesaf_db to be available..."
until psql -U "$POSTGRES_USER" -d cogesaf_db -c "SELECT 1;" > /dev/null 2>&1; do
    echo "Waiting for cogesaf_db..."
    sleep 2
done
echo "Creating database datastream_db..."
psql -U "$POSTGRES_USER" -d datastream_db -c "CREATE DATABASE datastream_db;"
touch /tmp/stations.csv
touch /tmp/fournisseurs.csv
touch /tmp/stationsfournisseurs.csv
touch /tmp/responsables.csv
touch /tmp/projets.csv
psql -U "$POSTGRES_USER" -d datastream_db -f /home/creationBD.sql
psql -U "$POSTGRES_USER" -d cogesaf_db -f /home/migration_export.sql
psql -U "$POSTGRES_USER" -d datastream_db -f /home/migration_import.sql