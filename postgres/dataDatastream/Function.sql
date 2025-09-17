-- Active: 1742397105088@@127.0.0.1@5432@datastream_db

-- Fonctions Station ----------------------------------------
-- Liste des station
CREATE VIEW view_listStations AS
    SELECT
        st."nostation" AS "nostation",
        st."nad83_latitude" AS "lat",
        st."nad83_longitude" AS "long"
    FROM public."stations" AS st;

-- Identification de station
CREATE OR REPLACE FUNCTION fn_get_nostation(
        _lat FLOAT,
        _long FLOAT
    )
    RETURNS TEXT 
    AS 
    $$
    DECLARE
        _noStation TEXT;
    BEGIN
        CREATE TABLE temp_fn_get_nostation AS(
            SELECT s."nostation"
            FROM Station AS s
            WHERE s."nad83_latitude" = _lat AND s."nad83_longitude" = _longl);
        ASSERT (SELECT COUNT(*) FROM temp_fn_get_nostation) = 1,
            'Expected 1 station, got ' || (SELECT COUNT(*) FROM temp_fn_get_nostation)::text;
        SELECT * INTO _noStation FROM temp_fn_get_responsableid LIMIT 1;
        DROP TABLE temp_fn_get_nostation;
        RETURN _noStation;
    END;
$$ LANGUAGE plpgsql;
-- Insertion de station
CREATE OR REPLACE FUNCTION fn_insert_station
(
    _NoStation TEXT,
    _nad83_lat FLOAT,
    _nad83_long FLOAT,
    _dateCreation TIMESTAMP DEFAULT NULL,
    _description TEXT DEFAULT NULL,
    _type TypeStation DEFAULT NULL,
    _idBassinVersant INT DEFAULT NULL
    )
    RETURNS void 
    AS 
    $$
    BEGIN
        INSERT INTO public."Stations" (
            "NoStation",
            "NAD83_Latitude",
            "NAD83_Longitude",
            "DateCreation",
            "Description",
            "Type",
            "IDBassinVersant"
            ) 
        VALUES (
            _NoStation,
            _nad83_lat,
            _nad83_long,
            _dateCreation,
            _description,
            _type,
            _idBassinVersant
            );
    END;
$$ LANGUAGE plpgsql;

-- MISSING DÉTECTION DOUBLONS

-- Fonctions Responsable -------------------------------
-- Identification de responsable
CREATE OR REPLACE FUNCTION fn_get_responsableid(
        _nomResponsable VARCHAR DEFAULT NULL, 
        _societe VARCHAR DEFAULT NULL, 
        _couriel VARCHAR DEFAULT NULL, 
        _telephone VARCHAR DEFAULT NULL,
        _matching_nomResponsable INT DEFAULT 0
    )
    RETURNS INT 
    AS 
    $$
    DECLARE
        _responsableid INT;
    BEGIN
        CREATE TABLE temp_fn_get_responsableid AS(
        SELECT r."responsableid"
        FROM public."responsables" AS r
        WHERE 
            ((r."nom" = _nomResponsable AND _matching_nomResponsable = 0)
                OR (LOWER(r."nom") LIKE lower('%' || _nomResponsable || '%') AND _matching_nomResponsable = 1)
                OR _nomResponsable IS NULL)
            AND (r."societe" = _societe OR _societe IS NULL)
            AND (r."couriel" = _couriel OR  _couriel IS NULL)
            AND (r."telephone" = _telephone OR _telephone IS NULL));
        ASSERT (SELECT COUNT(*) FROM temp_fn_get_responsableid) = 1,
            'Expected 1 responsable, got ' || (SELECT COUNT(*) FROM temp_fn_get_responsableid)::text;
        SELECT * INTO _responsableid FROM temp_fn_get_responsableid LIMIT 1;
        DROP TABLE temp_fn_get_responsableid;
        RETURN _responsableid;
    END;
$$ LANGUAGE plpgsql;

-- Insertion de responsable
CREATE OR REPLACE FUNCTION fn_insert_responsables
(
        _Nom TEXT,
        _Societe TEXT DEFAULT NULL,
        _Couriel TEXT DEFAULT NULL,
        _Telephone TEXT DEFAULT NULL
    )
    RETURNS void 
    AS 
    $$
    BEGIN
        INSERT INTO public."responsables" (
            "responsableID",
            "nom",
            "societe",
            "couriel",
            "telephone"
        ) 
        VALUES (
            _Nom,
            _Societe,
            _Couriel,
            _Telephone
        );
    END;
$$ LANGUAGE plpgsql;


-- Fonciton Projets ---------------------------------------
CREATE OR REPLACE FUNCTION fn_get_projet(
        _NomProjet TEXT,
        _ResponsableID INT DEFAULT NULL,
        _Description TEXT DEFAULT NULL,
        _Objectif TEXT DEFAULT NULL,
        _Protocole TEXT DEFAULT NULL,
        _matching_nomResponsable INT DEFAULT 0

    )
    RETURNS TEXT 
    AS 
    $$
    DECLARE
        _NoProjet TEXT;
    BEGIN
        CREATE TABLE temp_fn_get_projet AS(
            SELECT "noprojet"
            FROM public."projet" AS p  
            WHERE ((p."nomprojet" = _NomProjet AND _matching_nomResponsable = 0)
                OR (p."nomprojet" LIKE '%' || _NomProjet || '%' AND _matching_nomResponsable = 1))
                AND (p."responsableid" = _ResponsableID OR _ResponsableID IS NULL)
                AND (p."description" = _Description OR _Description IS NULL)
                AND (p."objectif" = _Objectif OR _Objectif IS NULL)
                AND (p."protocole" = _Protocole OR _Protocole IS NULL));
        ASSERT (SELECT COUNT(*) FROM temp_fn_get_projet) = 1,
            'Expected 1 station, got ' || (SELECT COUNT(*) FROM temp_fn_get_projet)::text;
        SELECT * INTO _NoProjet FROM temp_fn_get_projet LIMIT 1;
        DROP TABLE temp_fn_get_projet;
        RETURN _NoProjet;
    END;
$$ LANGUAGE plpgsql;

-- Insertion de projet
CREATE OR REPLACE FUNCTION fn_insert_projet
(
    _noProjet VARCHAR, 
    _nomProjet VARCHAR,
    _responsableid INT,
    _description VARCHAR    
    )
    RETURNS void 
    AS 
    $$
    BEGIN
        INSERT INTO public."projets" (
            "noProjet", 
            "description", 
            "dateDebut", 
            "dateFin"
            ) 
        VALUES (
            _noProjet, 
            _description, 
            _dateDebut, 
            _dateFin
            );
    END;
$$ LANGUAGE plpgsql;

-- Fonctions mesures -------------------------
-- Insert de mesures

CREATE OR REPLACE FUNCTION fn_insert_mesure(
        _symbole VARCHAR, 
        _noProjet VARCHAR, 
        _ReleveID INT,
        _Timestamp TIMESTAMP,
        _SymboleID INT,
        _Value FLOAT,
        _DateUpdated TIMESTAMP DEFAULT NULL,
        _DataSource VARCHAR DEFAULT NULL,
        _MeasuringDevice VARCHAR DEFAULT NULL,
        _Method VARCHAR DEFAULT NULL,
        _Comments VARCHAR DEFAULT NULL,
        _DetectableLimit VARCHAR DEFAULT NULL,
        _IDLaboAnalysis VARCHAR DEFAULT NULL
        )
    RETURNS void 
    AS 
    $$
    DECLARE
        _typename TEXT;
        _tablename_mesure TEXT;
        _tablename_meta TEXT;
    BEGIN
        SELECT tm."typename"
        INTO _typename
        FROM 
            public."symboles" AS s
            INNER JOIN public."typesmesures" AS tm 
                ON s."typemesureid" = tm."typemesureid"
        WHERE s."symbolename" = _symbole
        LIMIT 1;

        _tablename_mesure := lower(concat('mesure_', _typename));
        _tablename_meta := lower(concat('meta_', _typename));

        EXECUTE format('_metadataid := INSERT INTO public.%I 
            (
                "DateUpdated",
                "DataSource",
                "MeasuringDevice", 
                "Method", 
                "Method", 
                "Comments",
                "DetectableLimit",
                "IDLaboAnalysis"
            ) 
            VALUES 
            (
                _DateUpdated, 
                _DataSource, 
                _MeasuringDevice, 
                _Method,
                _Comments,
                _DetectableLimit,
                _IDLaboAnalysis
            )
            RETURNING "MetadataID"', _tablename_meta);

        EXECUTE format('INSERT INTO public.%I 
            (
                "noProjet",
                "ReleveID",
                "Timestamp", 
                "MetadataID", 
                "SymboleID", 
                "Value"
             ) 
            VALUES
             (
                _noProjet,
                _ReleveID,
                _Timestamp,
                _metadataid,
                _SymboleID,
                _Value
             )', _tablename_mesure);
    END;
$$ LANGUAGE plpgsql;;

-- Liste des mesures
DO 
$$
DECLARE
    _sql TEXT;
BEGIN
    SELECT string_agg(format('SELECT *, %L AS source_table FROM public.%I', table_name, table_name), E'\nUNION ALL\n')
    INTO _sql
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name LIKE 'Mesure\_%' ESCAPE '\';

    _sql := 'CREATE OR REPLACE VIEW mesure_all AS ' || _sql;

    EXECUTE _sql;
END;
$$;