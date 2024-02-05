CREATE TABLE Anbieter (
    UStID VARCHAR(11) NOT NULL,
    Name VARCHAR(80) NOT NULL,
    Website TEXT NOT NULL,
    Organisationsform TEXT,
    API_URL TEXT,
    Lizenz TEXT,
    PRIMARY KEY (UStID),
    CHECK (UStID LIKE 'DE_________' AND LENGTH(11)),
    CHECK (API_URL LIKE 'https://%' OR  API_URL LIKE 'http://%'),
    CHECK (Website LIKE 'https://%' OR  Website LIKE 'http://%')
);

CREATE TABLE Bundesland(
    Kuerzel CHAR NOT NULL,
    Name VARCHAR(80) UNIQUE NOT NULL,
    Aufsichtsbehoerde VARCHAR(255),
    PRIMARY KEY (Kuerzel),
    CHECK (Kuerzel LIKE 'DE-__' AND LENGTH(5))
);

CREATE TABLE Polygon(
    Kuerzel CHAR NOT NULL,
    Latitude FLOAT NOT NULL,
    Longitude FLOAT NOT NULL,
    PRIMARY KEY (Kuerzel, Latitude, Longitude),
    FOREIGN KEY (Longitude, Latitude) REFERENCES Koordinate (Longitude, Latitude),
    FOREIGN KEY (Kuerzel) REFERENCES Bundesland (Kuerzel)
);

CREATE TABLE Arbeitet_in(
    Kuerzel CHAR NOT NULL,
    UStID VARCHAR(11) NOT NULL,
    PRIMARY KEY (Kuerzel, UStID),
    FOREIGN KEY (Kuerzel) REFERENCES Bundesland (Kuerzel),
    FOREIGN KEY (UStID) REFERENCES Anbieter (UStID)
);

CREATE TABLE Koordinate(
    Latitude FLOAT NOT NULL,
    Longitude FLOAT NOT NULL,
    GeoHash VARCHAR(12) NOT NULL,
    EPSG_Code INTEGER DEFAULT 4326 NOT NULL,
    Kuerzel CHAR,
    PRIMARY KEY (Latitude, Longitude),
    FOREIGN KEY (Kuerzel) REFERENCES Bundesland (Kuerzel),
    CHECK (EPSG_Code == 4326),
    CHECK (LENGTH(GeoHash) <= 12),
    CHECK (Latitude >= -90 AND Latitude <= 90),
    CHECK (Longitude >= -180 AND Longitude <= 180)
);

CREATE TABLE Station (
    ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    Hoehe INTEGER,
    Latitude FLOAT NOT NULL,
    Longitude FLOAT NOT NULL,
    UStID VARCHAR(11) NOT NULL,
    FOREIGN KEY (Latitude, Longitude) REFERENCES Koordinate (Latitude, Longitude),
    FOREIGN KEY (UStID) REFERENCES Anbieter (UStID)
);

CREATE TABLE Verbunden_mit(
    StationA_ID INTEGER NOT NULL,
    StationB_ID INTEGER NOT NULL,
    Abstand FLOAT NOT NULL,
    PRIMARY KEY (StationA_ID, StationB_ID),
    FOREIGN KEY (StationA_ID) REFERENCES Station (ID),
    FOREIGN KEY (StationB_ID) REFERENCES Station (ID),
    CHECK (0 <= Abstand)
);

CREATE TABLE Messwert(
    Zeitpunkt DATE NOT NULL ,
    ID INTEGER NOT NULL,
    Einheit Varchar NOT NULL,
    Wert INTEGER NOT NULL,
    Art VARCHAR,
    Richtung INTEGER,
    hat_schatten BOOLEAN,
    Typ TEXT NOT NULL,
    PRIMARY KEY (Zeitpunkt, ID),
    FOREIGN KEY (ID) REFERENCES Station (ID),
    CHECK (Richtung >= 0 AND Richtung <= 360),
    CHECK (Typ LIKE 'Niederschlag' OR Typ LIKE 'Wind' OR Typ LIKE 'Sonne' OR Typ LIKE 'Temperatur' OR Typ LIKE 'Messwert'),
    CHECK ((Typ LIKE 'Niederschlag' AND Art IS NOT NULL AND Richtung IS NULL AND hat_schatten IS NULL) OR (Typ LIKE 'Wind' AND Richtung IS NOT NULL AND Art IS NULL AND hat_schatten IS NULL) OR (Typ LIKE 'Sonne' AND hat_schatten IS NOT NULL AND Art IS NULL AND Richtung IS NULL) OR (Typ LIKE 'Temperatur' AND Art IS NULL AND Richtung IS NULL AND hat_schatten IS NULL) OR (TYP LIKE 'Messwert' AND Art IS NULL AND Richtung IS NULL AND hat_schatten IS NULL))
);
