-- Active: 1742397105088@@127.0.0.1@5432@datastream_db

CREATE EXTENSION postgres_fdw;
CREATE SERVER link_cogesaf_db_s FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'postgresql_datastream', port '5432', dbname 'cogesaf_db');
GRANT USAGE ON FOREIGN SERVER link_cogesaf_db_s TO postgres;
CREATE USER MAPPING FOR postgres SERVER link_cogesaf_db_s OPTIONS (user 'postgres');
CREATE SCHEMA link_cogesaf_db;
IMPORT FOREIGN SCHEMA public FROM SERVER link_cogesaf_db_s INTO link_cogesaf_db;
INSERT INTO public."stations" ("nostation", "nad83_latitude", "nad83_longitude", "description", "type")
SELECT DISTINCT st."NO_STATION", co."NAD83_LATITUDE", co."NAD83_LONGITUDE", st."DESC_STAT", 'Lac' 
FROM link_cogesaf_db."STATION" AS st INNER JOIN link_cogesaf_db."COORDONNEES" AS co ON st."NO_STATION" = co."NO_STATION";
INSERT INTO public."fournisseurs" ("nom")
SELECT DISTINCT st."PROPRIETAIRE"
FROM link_cogesaf_db."STATION" AS st;
INSERT INTO public."stationsfournisseurs" ("nostation", "fournisseurid")
SELECT DISTINCT st."NO_STATION", fn."fournisseurid"
FROM link_cogesaf_db."STATION" AS st INNER JOIN public.fournisseurs AS fn ON st."NO_STATION" = fn."nom";
INSERT INTO public."responsables" ("nom")
SELECT DISTINCT pr."NOM_RESPONSB"
FROM link_cogesaf_db."PROJET" as pr;
-- INSERT INTO public."projets" ("noprojet", "nomprojet", "reponsableid", "description", "objectif", "protocole")
-- SELECT
-- FROM link_cogesaf_db