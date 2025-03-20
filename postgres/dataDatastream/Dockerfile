FROM postgres:17.2
COPY /creationBD.sql /docker-entrypoint-initdb.d
COPY /PopulateBD.sql /docker-entrypoint-initdb.d
COPY /pg_convergence.tar /home
COPY /init_cogesaf.sh /docker-entrypoint-initdb.d/init.sh
RUN chmod +x /docker-entrypoint-initdb.d/init.sh
# COPY /init_datastream.sh /docker-entrypoint-initdb.d/init.sh
# RUN chmod +x /docker-entrypoint-initdb.d/init.sh