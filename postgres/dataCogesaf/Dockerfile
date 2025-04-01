FROM postgres:17.2
FROM postgis/postgis:latest
RUN apt-get update && apt-get  install -y postgresql-17-postgis-3  
RUN apt-get update && apt-get install -y dos2unix
COPY /pg_convergence.tar /home
COPY /init_cogesaf.sh /docker-entrypoint-initdb.d/init_cogesaf.sh
RUN dos2unix /docker-entrypoint-initdb.d/init_cogesaf.sh
RUN chmod +x /docker-entrypoint-initdb.d/init_cogesaf.sh