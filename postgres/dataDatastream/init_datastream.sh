#!/bin/bash
set -e

echo "Waiting for PostgreSQL to start..."
until  pg_isready -U "$POSTGRES_USER"; do
  sleep 1
done
echo "PostgreSQL is ready. Restoring database..."

if psql -U "$POSTGRES_USER" -d datastream_db -tc "SELECT 1 FROM pg_database WHERE datname = 'datastream_db';" | grep -q 1; then
  echo "Database datastream_db already exists. Skipping creation."
else
  echo "Creating database datastream_db..."
  psql -U "$POSTGRES_USER" -d datastream_db -c "CREATE DATABASE datastream_db;"
  psql -U "$POSTGRES_USER" -d datastream_db -f /docker-entrypoint-initdb.d/creationBD.sql
  psql -U "$POSTGRES_USER" -d datastream_db -f /docker-entrypoint-initdb.d/populate.sql
fi