FROM postgres:17.2
RUN apt-get update && apt-get install -y dos2unix
COPY /creationBD.sql /docker-entrypoint-initdb.d
COPY /migration.sql /docker-entrypoint-initdb.d
COPY /pg_convergence.tar /home
COPY /init_cogesaf.sh /docker-entrypoint-initdb.d/init.sh
RUN dos2unix /docker-entrypoint-initdb.d/init.sh
RUN chmod +x /docker-entrypoint-initdb.d/init.sh
# COPY /init_datastream.sh /docker-entrypoint-initdb.d/init.sh
# RUN chmod +x /docker-entrypoint-initdb.d/init.sh