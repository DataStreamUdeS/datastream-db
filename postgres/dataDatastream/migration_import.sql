-- Active: 1742397105088@@127.0.0.1@5432@datastream_db

COPY public."stations" ("nostation", "nad83_latitude", "nad83_longitude", "description", "type")
FROM '/tmp/stations.csv' (format csv, delimiter ';');
COPY public."fournisseurs" ("nom")
FROM '/tmp/fournisseurs.csv' (format csv, delimiter ';');
COPY public."stationsfournisseurs" ("nostation", "fournisseurid", "anciennom")
FROM '/tmp/stationsfournisseurs.csv' (format csv, delimiter ';');
COPY public."responsables" ("nom")
FROM '/tmp/responsables.csv' (format csv, delimiter ';');
COPY public."projets" ("noprojet", "nomprojet", "responsableid", "description", "objectif", "protocole")
FROM '/tmp/projets.csv' (format csv, delimiter ';');
COPY public."releves" ("releveid", "nostation", "noprojet", "pluviometrie", "timestamp", "description")
FROM '/tmp/releves.csv' (format csv, delimiter ';');
COPY public."mesures" ("mesureid", "typemesureid")
FROM '/tmp/mesures.csv' (format csv, delimiter ';');

DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT TypeName
        FROM TypesMesures
        WHERE TypeName IS NOT NULL
    LOOP
        -- Export MetaData
        EXECUTE format($f$
            COPY public.%I ("metadataid", "dateupdated", "datasource", "measuringdevice", "method", 
                "comments", "detectablelimit", "idlaboanalysis")
            FROM %L (format csv, delimiter ';');
        $f$, concat('Metadata_', rec.TypeName), concat('/tmp/MetaData_', rec.TypeName, '.csv'));

        -- Export Mesures
        EXECUTE format($f$
            COPY public.%I ("id", "noprojet", "releveid", "timestamp", "metadataid",
                "symboleid", "value")
            FROM %L (format csv, delimiter ';');
        $f$, concat('Mesure_', rec.TypeName), concat('/tmp/Mesures_', rec.TypeName, '.csv'));
    END LOOP;
END;
$$;