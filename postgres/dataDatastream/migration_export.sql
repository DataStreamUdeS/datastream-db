-- Active: 1742397105088@@127.0.0.1@5432@cogesaf_db
COPY(
    SELECT DISTINCT 
        st."NO_STATION" AS "nostation",
        co."NAD83_LATITUDE" AS "nad83_latitude",
        co."NAD83_LONGITUDE" AS "nad83_longitude",
        st."DESC_STAT" AS "description",
        'Lac' AS "type"
    FROM public."STATION" AS st LEFT JOIN public."COORDONNEES" AS co ON st."NO_STATION" = co."NO_STATION"
    )
    TO '/tmp/stations.csv' (format csv, delimiter ';');
CREATE TABLE fournisseurs AS 
    SELECT DISTINCT 
        st."PROPRIETAIRE" AS "nom"
    FROM public."STATION" AS st;
ALTER TABLE public."fournisseurs" ADD "FournisseurID" SERIAL;
COPY(SELECT DISTINCT "nom" FROM public."fournisseurs")
    TO '/tmp/fournisseurs.csv' (format csv, delimiter ';');
COPY(
    SELECT DISTINCT 
        st."NO_STATION" AS "NoStation",
        fn."FournisseurID" AS "FournisseurID"
    FROM public."STATION" AS st INNER JOIN public."fournisseurs" AS fn ON st."NO_STATION" = fn."nom"
    )
    TO '/tmp/stationsfournisseurs.csv' (format csv, delimiter ';');
CREATE TABLE responsables AS
    SELECT DISTINCT 
        -- À VOIR MANQUE PT DES INFO À MIGRER
        pr."NOM_RESPONSB" AS "nom"
    FROM public."PROJET" AS pr WHERE pr."NOM_RESPONSB" IS NOT NULL;
ALTER TABLE public."responsables" ADD "responsableid" SERIAL;
COPY(
    SELECT DISTINCT "nom" FROM public."responsables"
    )
    TO '/tmp/responsables.csv' (format csv, delimiter ';');
COPY(
    SELECT DISTINCT
        pr."NO_PROJET" AS "NoProjet", 
        pr."NOM_PROJET" AS "NomProjet", 
        re."responsableid" AS "ResponsableID", 
        pr."DESC_SOMMAIRE" AS "Description",
        pr."BUT" AS "Objectif",
        pr."DESC_PROTOCL" AS "Protocole"
    FROM public."PROJET" AS pr LEFT JOIN public."responsables" AS re ON pr."NOM_RESPONSB" = re."nom"
    )
    TO '/tmp/projets.csv' (format csv, delimiter ';');
CREATE TABLE releves AS
    SELECT DISTINCT 
        re."NO_STATION" AS "NoStation",
        re."NO_PROJET" AS "NoProjet",
        to_timestamp(concat(re."DATE_PRELEVM", ' ', re."HRE_PRELEVM"), 'YYYY-MM-DD HH24:MI') AS "TimeStamp",--::timestamp without time zone at time zone 'Etc/UTC'
        re."IND_COMMENT" AS "Description",
        NULL AS "Pluviometrie"
    FROM public."RELEVE" AS re;
ALTER TABLE public."releves" ADD "ReleveID" SERIAL;
COPY(
    SELECT DISTINCT
        re."ReleveID",
        re."NoStation",
        re."NoProjet",
        re."Pluviometrie",
        re."TimeStamp",
        re."Description"
        FROM public.releves AS re
    )
    TO '/tmp/releves.csv' (format csv, delimiter ';');

CREATE TABLE TypesMesures (
    TypeMesureID INT,
    TypeName TEXT, 
    TypeDescription TEXT);

CREATE TABLE Symboles
(
    SymboleID SERIAL PRIMARY KEY,
    TypeMesureID INT,
    SymboleName TEXT,
    SymboleDescription TEXT,
    Units TEXT
);

INSERT INTO TypesMesures (TypeMesureID, TypeName)
    VALUES
    (0, NULL),
    (1,'Oxygene'),
    (2,'Température'),
    (3,'Niveau_Profondeur'),
    (4,'Conductivite_Mineralisation'),
    (5,'Azote'),
    (6,'Phosphore'),
    (7,'Metaux'),
    (8,'Ions'),
    (9,'Carbone'),
    (10,'Bactéries'),
    (11,'Phytoplancton'),
    (12,'Cyanobacterie'),
    (13,'Solide_Matiere'),
    (14,'Particule_Visibilite'),
    (15,'Autre');

INSERT INTO Symboles (SymboleName, TypeMesureID)
    VALUES 
    ('OXYGÈNE DISSOUT',1),
    ('PROFONDEUR MAXIMALE',3),
    ('SODIUM',8),
    ('MAGNÉSIUM',8),
    ('CARBONE ORGANIQUE DISSOUS',9),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - PLOMB',7),
    ('null',0),
    ('MÉTAL TRACE DISSOUS, SERINGUE - URANIUM',7),
    ('MÉTAL TRACE DISSOUS, SERINGUE - CADMIUM',7),
    ('CONDUCTIVITÉ',4),
    ('MÉTAL TRACE DISSOUS, SERINGUE - BÉRYLLIUM',7),
    ('SOLIDES EN SUSPENSION (FILTRÉ À 45 µ)',13),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - BORE',7),
    ('PHOSPHORE TOTAL Faible concentration',6),
    ('Iron',6),
    ('TEMPÉRATURE SURFACE',2),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - ANTIMOINE',7),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - VANADIUM',7),
    ('PROFONDEUR DE L''ÉCHANTILLONNAGE',3),
    ('MÉTAL TRACE DISSOUS, SERINGUE - MOLYBDÈNE',7),
    ('PHOSPHORE TOTAL EN SUSPENSION',6),
    ('PHOSPHORE TOTAL DISSOUS (FILTRÉ À 45 µ)',6),
    ('ALCALINITÉ TOTALE',4),
    ('MÉTAL TRACE DISSOUS, SERINGUE - VANADIUM',7),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - URANIUM',7),
    ('Chloride',8),
    ('CYANOBACTÉRIES',12),
    ('AZOTE AMMONIACAL (NON FILTRÉ)',5),
    ('MÉTAL TRACE DISSOUS, SERINGUE - NICKEL',7),
    ('MICROCYSTINES',12),
    ('COLIFORMES THERMOTOLÉRANTS (FÉCAUX) - DÉNOMBREMENT',10),
    ('NITRATES ET NITRITES (NON FILTRÉ)',5),
    ('FOND',3),
    ('DURETÉ',4),
    ('ESCHERICHIA COLI (MILIEU M-TEC MODIFIÉ)',10),
    ('AZOTE TOTAL FILTRÉ',5),
    ('NITRATES ET NITRITES (FILTRÉ À 45 µ)',5),
    ('PHOSPHORE TOTAL DISSOUS PERSULFATE (FILTRÉ 1,2 µm)',6),
    ('SESTON - POIDS SEC',13),
    ('AZOTE TOTAL (NON FILTRÉ)',5),
    ('PHOSPHORE TOTAL DISSOUS',6),
    ('TEMPÉRATURE FOND',2),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - ARSENIC',7),
    ('CHLOROPHYLLE A',11),
    ('MÉTAL TRACE DISSOUS, SERINGUE - COBALT',7),
    ('ORTHOPHOSPHATES',15),
    ('AZOTE TOTAL (FILTRÉ 1,2 µm)',5),
    ('TEMPÉRATURE',2),
    ('MÉTAL TRACE DISSOUS, SERINGUE - ANTIMOINE',7),
    ('Nitrogen, Total - Persulfate',5),
    ('AZOTE AMMONIACAL (FILTRÉ 1,2 µm)',5),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - ALUMINIUM',7),
    ('CALCIUM',8),
    ('MÉTAL TRACE DISSOUS, SERINGUE - ALUMINIUM',7),
    ('PHOSPHORE TOTAL',6),
    ('NITRATES ET NITRITES (FILTRÉ 1,2 µm)',5),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - FER',7),
    ('NITRATES ET NITRITES',5),
    ('TRANSPARENCE',14),
    ('FLUORURES',8),
    ('PHOSPHORE DISSOUS PERSULFATE (FILTRÉ 1,2 µm)',6),
    ('MÉTAL TRACE DISSOUS, SERINGUE - SÉLÉNIUM',7),
    ('CLOSTRIDIUM PERFRINGENS - DÉNOMBREMENT',10),
    ('PHOSPHORE DISSOUS PERSULFATE (FILTRÉ OU NON)',6),
    ('PHOSPHORE BIODISPONIBLE',6),
    ('MÉTAL TRACE DISSOUS, SERINGUE - MANGANÈSE',7),
    ('OXYGÈNE DISSOUT EN PROFONDEUR',1),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - CADMIUM',7),
    ('SOLIDES EN SUSPENSION (FILTRÉ 1,2 µm)',13),
    ('Depth',3),
    ('pH',4),
    ('MÉTAL TRACE DISSOUS, SERINGUE - BORE',7),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - ARGENT',7),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - COBALT',7),
    ('CHLOROPHYLLE A ACTIVE - FILTRÉ SOLUBLE',11),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - NICKEL',7),
    ('Chloride- Filtered',8),
    ('MÉTAL TRACE DISSOUS, SERINGUE - ZINC',7),
    ('Alkalinity',4),
    ('COULEUR',14),
    ('AZOTE AMMONIACAL',5),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - STRONTIUM',7),
    ('CARBONE ORGANIQUE DISSOUS (FILTRÉ)',9),
    ('NITRATES',5),
    ('Total Calculated Hardness',4),
    ('PHÉOPHYTINE A',11),
    ('PHOSPHORE TOTAL PERSULFATE',6),
    ('Chlorophyll-a - Fluorometric',11),
    ('Arsenic',15),
    ('MÉTAL TRACE DISSOUS, SERINGUE - BARYUM',7),
    ('CARBONE INORGANIQUE DISSOUS',9),
    ('MÉTAL TRACE DISSOUS, SERINGUE - STRONTIUM',7),
    ('ESCHERICHIA COLI (MILIEU MFC-BCIG)',10),
    ('MÉTAL TRACE DISSOUS, SERINGUE - ARGENT',7),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - CUIVRE',7),
    ('POTASSIUM',8),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - ZINC',7),
    ('TEMPÉRATURE FOSSE',2),
    ('Manganese',7),
    ('SM 2130 B',15),
    ('MÉTHANE',15),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - SÉLÉNIUM',7),
    ('AZOTE AMMONIACAL (FILTRÉ À 45 µ)',5),
    ('MÉTAL TRACE DISSOUS, SERINGUE - CHROME',7),
    ('TURBIDITÉ',14),
    ('MÉTAL TRACE DISSOUS, SERINGUE - FER',7),
    ('CARBONE ORGANIQUE TOTAL',9),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - BÉRYLLIUM',7),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - CHROME',7),
    ('NITRITES (FILTRÉ À 45 µ)',5),
    ('OXYGÈNE DISSOUS',1),
    ('COLIFORMES FÉCAUX - DÉPISTAGE',10),
    ('MÉTAL TRACE DISSOUS, SERINGUE - PLOMB',7),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - MANGANÈSE',7),
    ('PHOSPHORE TOTAL EN TRACE',6),
    ('PHYCOCYANINE',11),
    ('MÉTAL TRACE DISSOUS, SERINGUE - ARSENIC',7),
    ('CHLORURES',8),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - BARYUM',7),
    ('Secchi Clarity',14),
    ('AZOTE TOTAL FILTRÉ (FILTRÉ À 45 µ)',5),
    ('Phosphorus - Digested',6),
    ('MÉTAL TRACE DISSOUS, SERINGUE - CUIVRE',7),
    ('Phosphorus - Filtered/Digested',6),
    ('NIVEAU D''EAU',3),
    ('CHLOROPHYLLE A-Fond',11),
    ('OXYGÈNE DISSOUT SURFACE',1),
    ('MÉTAL TRACE EXTRACTIBLE TOTAL - MOLYBDÈNE',7),
    ('SATURATION EN OXYGÈNE DISSOUS',1),
    ('NITRITES',5),
    ('PHÉOPHYTINE',11),
    ('SOLIDES EN SUSPENSION',13),
    ('SOLIDES DISSOUS TOTAL',13),
    ('SATURATION OXYGÈNE',1);

CREATE TABLE all_Mesures_And_Metas AS
    SELECT DISTINCT
        row_number() OVER () AS "ID",
        ra."NO_PROJET" AS "NoProjet",
        r."ReleveID" AS "ReleveID",
        r."TimeStamp" AS "TimeStamp",
        row_number() OVER () AS "MetaDataID",
        s."symboleid" AS "SymboleID",
        ra."VALEUR" AS "Value",
        row_number() OVER () AS "_MetaDataID",
        r."TimeStamp" AS "DateUpdated",
        ra."FOURNISSEUR" AS "DataSource",
        NULL AS "MeasuringDevice",
        ra."NO_METHODE" AS "Method",
        p."REMARQUES" AS "Comments",
        p."LIMT_DETECT" AS "DetectableLimit",
        p."ID_LABO_ANALYSE" AS "IDLaboAnalysis"  
    FROM public."PARAMANA" AS p
        INNER JOIN public."RESLANAL_ACTIF" AS ra 
            ON ra."ID_LABO_ANALYSE" = p."ID_LABO_ANALYSE"
            AND ra."ABREV_PARAM" = p."ABREV_PARAM"
            AND ra."NO_METHODE" = p."NO_METHODE"
            AND ra."CODE_NATURE_PARAM" = p."CODE_NATURE_PARAM"
        INNER JOIN public."releves" AS r 
            ON ra."NO_PROJET" = r."NoProjet"
            AND ra."NO_STATION" = r."NoStation"
            AND to_timestamp(concat(ra."DATE_PRELEVM", ' ', ra."HRE_PRELEVM"), 'YYYY-MM-DD HH24:MI') = r."TimeStamp"
        INNER JOIN public."symboles" AS s 
            ON p."SYMBOLE_NOM" = s."symbolename"
        INNER JOIN public."typesmesures" AS tm 
            ON s."typemesureid" = tm."typemesureid";

COPY(
    SELECT DISTINCT 
        r."ID" AS "MesureID", 
        s."typemesureid" AS "TypeMesureID"
    FROM all_mesures_and_metas AS r 
        INNER JOIN symboles AS s ON r."SymboleID" = s."symboleid"
    )
    TO '/tmp/mesures.csv' (format csv, delimiter ';');

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
            COPY (
                SELECT 
                    r."MetaDataID" AS "MetaDataID",
                    r."DateUpdated" AS "DateUpdated",
                    r."DataSource" AS "DataSource",
                    r."MeasuringDevice" AS "MeasuringDevice",
                    r."Method" AS "Method",
                    r."Comments" AS "Comments",
                    r."DetectableLimit" AS "DetectableLimit",
                    r."IDLaboAnalysis" AS "IDLaboAnalysis"
                FROM all_mesures_and_metas AS r
                    INNER JOIN public.Symboles AS s ON r."SymboleID" = s."symboleid"
                    INNER JOIN public.TypesMesures AS t ON s."typemesureid" = t."typemesureid"
                WHERE t."typename" = %L
            )
            TO %L (FORMAT CSV, DELIMITER ';');
        $f$, rec.TypeName, concat('/tmp/MetaData_', rec.TypeName, '.csv'));

        -- Export Mesures
        EXECUTE format($f$
            COPY (
                SELECT 
                    r."ID" AS "ID", 
                    r."NoProjet" AS "NoProjet", 
                    r."ReleveID" AS "ReleveID", 
                    r."TimeStamp" AS "TimeStamp", 
                    r."MetaDataID" AS "MetaDataID", 
                    r."SymboleID" AS "SymboleID",
                    r."Value" AS "Value"
                FROM all_Mesures_And_Metas AS r
                    INNER JOIN public.Symboles AS s ON r."SymboleID" = s."symboleid"
                    INNER JOIN public.TypesMesures AS t ON s."typemesureid" = t."typemesureid"
                WHERE t."typename" = %L
            )
            TO %L (FORMAT CSV, DELIMITER ';');
        $f$, rec.TypeName, concat('/tmp/Mesures_', rec.TypeName, '.csv'));
    END LOOP;
END;
$$;


-- DO $$
-- DECLARE
--     rec RECORD;
-- BEGIN
--     FOR rec IN
--         SELECT TypeName
--         FROM TypesMesures
--         WHERE TypeName IS NOT NULL
--     LOOP
--         EXECUTE format('COPY(
--             SELECT 
--                 r."MetaDataID" AS "MetaDataID",
--                 r."DateUpdated" AS "DateUpdated",
--                 r."DataSource" AS "DataSource",
--                 r."MeasuringDevice" AS "MeasuringDevice",
--                 r."Method" AS "Method",
--                 r."Comments" AS "Comments",
--                 r."DetectableLimit" AS "DetectableLimit",
--                 r."IDLaboAnalysis" AS "IDLaboAnalysis"
--             FROM all_mesures_and_metas as r
--                 INNER JOIN public.Symboles AS s ON r."SymboleID" = s."symboleid"
--                 INNER JOIN public.TypesMesures AS t ON s."typemesureid" = t."typemesureid"
--             WHERE 
--                 t."typename" = ''%I'')
--         TO ''%I'' (format csv, delimiter '';'');', rec.TypeName, concat('/tmp/MetaData', rec.TypeName, '.csv'));

--         -- EXECUTE format('COPY(
--         --     SELECT 
--         --         r."ID" AS ID, 
--         --         r."NoProjet" AS "NoProjet", 
--         --         r."ReleveID" AS "ReleveID", 
--         --         r."TimeStamp" AS "TimeStamp", 
--         --         r."MetaDataID" AS "MetaDataID", 
--         --         r."SymboleID" AS "SymboleID",
--         --         r."Value" AS Value
--         --     FROM all_Mesures_And_Metas as r
--         --         INNER JOIN public.Symboles AS s ON r."SymboleID" = s."SymboleID"
--         --         INNER JOIN public.TypesMesures AS t ON s."TypeMesureID" = t."TypeMesureID"
--         --     WHERE 
--         --         t."TypeName" = %I)
--         -- TO %I', rec.TypeName, concat('/tmp/Mesures', rec.TypeName, '.csv'));
--     END LOOP;
-- END;
-- $$;