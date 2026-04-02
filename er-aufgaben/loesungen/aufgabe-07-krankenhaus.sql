-- Musterlösung: Aufgabe 7 – Krankenhaus
-- Schwierigkeit: Schwer | 7 Entitäten

CREATE TABLE fachgebiet (
  fachgebiet_id INT          NOT NULL AUTO_INCREMENT,
  bezeichnung   VARCHAR(100) NOT NULL,
  PRIMARY KEY (fachgebiet_id)
);

CREATE TABLE station (
  station_id    INT          NOT NULL AUTO_INCREMENT,
  name          VARCHAR(100) NOT NULL,
  abteilung     VARCHAR(100),
  kapazitaet    INT          NOT NULL,
  PRIMARY KEY (station_id)
);

-- Arzt kann Stationsleiter sein (Selbstreferenz via station.leiter_id)
CREATE TABLE arzt (
  arzt_id       INT          NOT NULL AUTO_INCREMENT,
  vorname       VARCHAR(50)  NOT NULL,
  nachname      VARCHAR(50)  NOT NULL,
  fachgebiet_id INT,
  PRIMARY KEY (arzt_id),
  FOREIGN KEY (fachgebiet_id) REFERENCES fachgebiet(fachgebiet_id)
);

-- Stationsleiter ist ein Arzt (nullable FK)
ALTER TABLE station ADD COLUMN leiter_id INT,
  ADD FOREIGN KEY (leiter_id) REFERENCES arzt(arzt_id);

CREATE TABLE patient (
  patient_id    INT          NOT NULL AUTO_INCREMENT,
  vorname       VARCHAR(50)  NOT NULL,
  nachname      VARCHAR(50)  NOT NULL,
  geburtsdatum  DATE,
  aufnahme      DATE         NOT NULL,
  entlassung    DATE,
  station_id    INT,
  PRIMARY KEY (patient_id),
  FOREIGN KEY (station_id) REFERENCES station(station_id)
);

-- n:m: Patient ↔ Arzt (Behandlung)
CREATE TABLE behandlung (
  behandlung_id INT          NOT NULL AUTO_INCREMENT,
  patient_id    INT          NOT NULL,
  arzt_id       INT          NOT NULL,
  datum         DATE         NOT NULL,
  diagnose      TEXT,
  PRIMARY KEY (behandlung_id),
  FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
  FOREIGN KEY (arzt_id)    REFERENCES arzt(arzt_id)
);

CREATE TABLE medikament (
  medikament_id INT          NOT NULL AUTO_INCREMENT,
  name          VARCHAR(255) NOT NULL,
  atc_code      VARCHAR(10),
  einheit       VARCHAR(20)  NOT NULL,   -- mg, ml, Tabletten
  PRIMARY KEY (medikament_id)
);

-- Verschreibung: Patient – Medikament – Arzt
CREATE TABLE verschreibung (
  verschreibung_id INT         NOT NULL AUTO_INCREMENT,
  patient_id       INT         NOT NULL,
  medikament_id    INT         NOT NULL,
  arzt_id          INT         NOT NULL,
  dosierung        VARCHAR(50),
  datum            DATE        NOT NULL,
  PRIMARY KEY (verschreibung_id),
  FOREIGN KEY (patient_id)    REFERENCES patient(patient_id),
  FOREIGN KEY (medikament_id) REFERENCES medikament(medikament_id),
  FOREIGN KEY (arzt_id)       REFERENCES arzt(arzt_id)
);
