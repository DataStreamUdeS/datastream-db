CREATE OR REPLACE PROCEDURE createMesureTable (_MesureName VARCHAR(50))
    LANGUAGE plpgsql AS
    $func$
    DECLARE
        metaName VARCHAR(50);
        mesureName VARCHAR(50);
    BEGIN
        metaName := 'Metadata' || _MesureName;
        mesureName := 'Mesure' || _MesureName;
        EXECUTE format('
            CREATE TABLE %I (
            MetadataID INT PRIMARY KEY,
            DateUodated TIMESTAMP,
            DataSource VARCHAR,
            MeasuringDevice VARCHAR,
            Methode VARCHAR,
            Comments VARCHAR,
            DetectableLimit VARCHAR
        )', metaName);
        EXECUTE format('
            CREATE TABLE %I (
            ID INT PRIMARY KEY,
            NoProjet INT,
            ReleveID INT,
            Timestamp TIMESTAMP,
            PositionID INT,
            MetadataID INT, 
            SymboleID INT,
            Value FLOAT
        )', mesureName);
        EXECUTE format('
            ALTER TABlE %I
            ADD CONSTRAINT fk_releveID
            FOREIGN KEY (ReleveID)
            REFERENCES Releves(ReleveID)', mesureName);
        EXECUTE format('
            ALTER TABlE %I
            ADD CONSTRAINT fk_noProjet
            FOREIGN KEY (NoProjet)
            REFERENCES Projets(NoProjet)', mesureName);
        EXECUTE format('
            ALTER TABlE %I
            ADD CONSTRAINT fk_metaDataID
            FOREIGN KEY (MetaDataID)
            REFERENCES %I(MetaDataID)', mesureName, metaName);
        EXECUTE format('
            ALTER TABlE %I
            ADD CONSTRAINT fk_symboleID
            FOREIGN KEY (SymboleID)
            REFERENCES Symboles(SymboleID)', mesureName);
    END
    
    $func$;

CREATE TABLE Fournisseurs(
    FournisseurID INT PRIMARY KEY,
    Nom TEXT,
    Acronyme TEXT,
    AncienNom TEXT
);

CREATE TABLE StationsFournisseurs(
    FournisseurID INT,
    NoStation TEXT,
    NomStation TEXT,
    AncienNom TEXT,
    PRIMARY KEY(NoStation, NomStation)
);

CREATE TYPE TypePluvio AS ENUM ('oui', 'non');

CREATE TABLE Releves(
    ReleveID INT PRIMARY KEY,
    NoStation TEXT,
    NoProjet INT,
    Pluviometrie TypePluvio,
    TimeStamp TIMESTAMPTZ,
    Description TEXT
);

CREATE TABLE Projets(
    NoProjet INT PRIMARY KEY,
    NomProjet TEXT,
    ResponsableID INT,
    Descritpion TEXT,
    Objectif TEXT,
    Protocole TEXT
);

CREATE TABLE ProjetsStations(
    NoProjet INT,
    NoStation TEXT,
    PRIMARY KEY(NoProjet, NoStation)
);

CREATE TABLE Responsables(
    ResponsableID INT PRIMARY KEY,
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
    Type TypeStation NOT NULL
);

CREATE TABLE Symboles(
    SymboleID INT PRIMARY KEY,
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
    FOREIGN KEY (NoProjet)
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

