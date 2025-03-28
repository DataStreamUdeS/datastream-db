FROM postgres:17.2
FROM postgis/postgis:latest
RUN apt-get update && apt-get  install -y postgresql-17-postgis-3  
RUN apt-get update && apt-get install -y dos2unix
# COPY /creationBD.sql /docker-entrypoint-initdb.d
# COPY /migration.sql /docker-entrypoint-initdb.d
COPY /creationBD.sql /home
COPY /migration.sql /home
COPY /pg_convergence.tar /home
COPY /init_cogesaf.sh /docker-entrypoint-initdb.d/init.sh
RUN dos2unix /docker-entrypoint-initdb.d/init.sh
RUN chmod +x /docker-entrypoint-initdb.d/init.sh
# RUN sed -i 's/^local\s\+all\s\+all\s\+trust$/local   all   postgres   trust/' /var/lib/postgresql/data/pg_hba.conf
# COPY /init_datastream.sh /docker-entrypoint-initdb.d/init.sh
# RUN chmod +x /docker-entrypoint-initdb.d/init.sh