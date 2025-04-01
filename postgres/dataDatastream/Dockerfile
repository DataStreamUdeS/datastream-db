FROM postgres:17.2
FROM postgis/postgis:latest
RUN apt-get update && apt-get  install -y postgresql-17-postgis-3  
RUN apt-get update && apt-get install -y dos2unix
COPY /creationBD.sql /home
COPY /migration.sql /home
COPY /init_datastream.sh /docker-entrypoint-initdb.d/init_datastream.sh
RUN dos2unix /docker-entrypoint-initdb.d/init_datastream.sh
RUN chmod +x /docker-entrypoint-initdb.d/init_datastream.sh
# RUN sed -i 's/^local\s\+all\s\+all\s\+trust$/local   all   postgres   trust/' /var/lib/postgresql/data/pg_hba.conf
# COPY /init_datastream.sh /docker-entrypoint-initdb.d/init.sh
# RUN chmod +x /docker-entrypoint-initdb.d/init.sh