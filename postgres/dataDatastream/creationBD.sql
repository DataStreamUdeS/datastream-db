CREATE OR REPLACE PROCEDURE createMesureTable(_MesureName VARCHAR(50))
    LANGUAGE plpgsql AS
    $func$
    DECLARE
        metaName VARCHAR(50);
        mesureName VARCHAR(50);
    BEGIN
        metaName := 'Metadata_' || _MesureName;
        mesureName := 'Mesure_' || _MesureName;
        EXECUTE format('
            CREATE TABLE %I (
            MetadataID SERIAL PRIMARY KEY,
            DateUpdated TIMESTAMP,
            DataSource VARCHAR,
            MeasuringDevice VARCHAR,
            Method VARCHAR,
            Comments VARCHAR,
            DetectableLimit VARCHAR,
            IDLaboAnalysis VARCHAR
        )', metaName);
        EXECUTE format('
            CREATE TABLE %I (
            ID SERIAL PRIMARY KEY,
            NoProjet TEXT,
            ReleveID INT,
            Timestamp TIMESTAMP,
            MetadataID INT, 
            SymboleID INT,
            Value FLOAT
        )', mesureName);
        EXECUTE format('
            ALTER TABlE %I
            ADD CONSTRAINT %I
            FOREIGN KEY (ReleveID)
            REFERENCES Releves(ReleveID)', mesureName, concat('fk_', mesureName, '_ReleveID'));
        EXECUTE format('
            ALTER TABlE %I
            ADD CONSTRAINT %I
            FOREIGN KEY (NoProjet)
            REFERENCES Projets(NoProjet)', mesureName, concat('fk_', mesureName, '_NoProjet'));
        EXECUTE format('
            ALTER TABlE %I
            ADD CONSTRAINT %I
            FOREIGN KEY (MetaDataID)
            REFERENCES %I(MetaDataID)', mesureName, concat('fk_', mesureName, '_MetaData'), metaName);
        EXECUTE format('
            ALTER TABlE %I
            ADD CONSTRAINT %I
            FOREIGN KEY (SymboleID)
            REFERENCES Symboles(SymboleID)', mesureName, concat('fk_', mesureName, '_SymboleID'));
        EXECUTE format('
            ALTER TABLE %I
            ADD CONSTRAINT %I
            FOREIGN KEY (ID)
            REFERENCES Mesures(MesureID)', mesureName, concat('fk_', mesureName, '_MesureID'));
    END
$func$;


CREATE TABLE Fournisseurs(
    FournisseurID SERIAL PRIMARY KEY,
    Nom TEXT,
    Acronyme TEXT,
    AncienNom TEXT
);
CREATE TABLE StationsFournisseurs(
    NoStation TEXT,
    FournisseurID INT,
    NomStation TEXT,
    AncienNom TEXT,
    PRIMARY KEY(NoStation, FournisseurID)
);
CREATE TABLE StationDoublons(
    NoStation1 TEXT,
    NoStation2 TEXT,
    Doublon BOOLEAN,
    PRIMARY KEY(NoStation1, NoStation2)
);
CREATE TYPE TypePluvio AS ENUM ('oui', 'non');
CREATE TABLE Releves(
    ReleveID SERIAL PRIMARY KEY,
    NoStation TEXT,
    NoProjet TEXT,
    TimeStamp TIMESTAMPTZ,
    Description TEXT,
    Pluviometrie TypePluvio
);
CREATE TABLE Projets(
    NoProjet TEXT PRIMARY KEY,
    NomProjet TEXT,
    ResponsableID INT,
    Description TEXT,
    Objectif TEXT,
    Protocole TEXT
);
CREATE TABLE ProjetsStations(
    NoProjet TEXT,
    NoStation TEXT,
    PRIMARY KEY(NoProjet, NoStation)
);
CREATE TABLE Responsables(
    ResponsableID SERIAL PRIMARY KEY,
    Nom TEXT,
    Societe TEXT,
    Couriel TEXT,
    Telephone TEXT
);
CREATE TYPE TypeStation AS ENUM ('Lac', 'Tributaire');
CREATE TABLE Stations(
    NoStation TEXT PRIMARY KEY,
    NAD83_Latitude FLOAT,
    NAD83_Longitude FLOAT,
    DateCreation TIMESTAMPTZ,
    Description TEXT,
    Type TypeStation NOT NULL,
    IDBassinVersant INT
);

CREATE TABLE BassinVersant(
    IDBassinVersant SERIAL PRIMARY KEY,
    Nom TEXT,
    Niveau INT,
    Superficie FLOAT,
    Description TEXT
);
CREATE TABLE Symboles(
    SymboleID SERIAL PRIMARY KEY,
    TypeMesureID INT,
    SymboleName TEXT,
    SymboleDescription TEXT,
    Units TEXT
);
CREATE TABLE Mesures(
    MesureID INT PRIMARY KEY,
    TypeMesureID INT
);
CREATE TABLE TypesMesures(
    TypeMesureID INT PRIMARY KEY,
    TypeName TEXT,
    TypeDescription TEXT
);
ALTER TABLE Mesures
    ADD CONSTRAINT fk_Mesure_TypeMesure
    FOREIGN KEY (TypeMesureID)
    REFERENCES TypesMesures(TypeMesureID);
ALTER TABLE Symboles
    ADD CONSTRAINT fk_Symbole_MesureTypeID
    FOREIGN KEY (TypeMesureID)
    REFERENCES TypesMesures(TypeMesureID);
ALTER TABLE ProjetsStations
    ADD CONSTRAINT fk_ProjetStation_ProjetID
    FOREIGN KEY (NoProjet)
    REFERENCES Projets(NoProjet);
ALTER TABLE ProjetsStations
    ADD CONSTRAINT fk_ProjetStation_StationID
    FOREIGN KEY (NoStation)
    REFERENCES Stations(NoStation);
ALTER TABLE Projets
    ADD CONSTRAINT fk_Projets_ResponsableID
    FOREIGN KEY (ResponsableID)
    REFERENCES Responsables(ResponsableID);
ALTER TABLE StationsFournisseurs
    ADD CONSTRAINT fk_StationsFournisseurs_FournisseurID
    FOREIGN KEY (FournisseurID)
    REFERENCES Fournisseurs(FournisseurID);
ALTER TABLE StationsFournisseurs
    ADD CONSTRAINT fk_StationsFournisseurs_NoStation
    FOREIGN KEY (NoStation)
    REFERENCES Stations(NoStation);
ALTER TABLE Releves
    ADD CONSTRAINT fk_Mesures_NoStation
    FOREIGN KEY (NoStation)
    REFERENCES Stations(NoStation);
ALTER TABLE Releves
    ADD CONSTRAINT fk_Releves_NoProjet
    FOREIGN KEY (NoProjet)
    REFERENCES Projets(NoProjet);

ALTER TABLE Stations
    ADD CONSTRAINT fk_BassinVersant_StationID
    FOREIGN KEY (IDBassinVersant)
    REFERENCES BassinVersant(IDBassinVersant);

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

DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT TypeName
        FROM TypesMesures
        WHERE TypeName IS NOT NULL
    LOOP
        -- Crée la requête pour chaque table
        CALL createMesureTable(rec.TypeName);
    END LOOP;
END;
$$;

CALL createMesureTable('TEST');