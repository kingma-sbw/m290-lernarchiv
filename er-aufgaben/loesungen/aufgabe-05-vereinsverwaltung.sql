-- Musterlösung: Aufgabe 5 – Vereinsverwaltung
-- Schwierigkeit: Mittel | 5 Tabellen | Selbstreferenz

CREATE TABLE mitglied (
  mitglied_id    INT          NOT NULL AUTO_INCREMENT,
  vorname        VARCHAR(50)  NOT NULL,
  nachname       VARCHAR(50)  NOT NULL,
  email          VARCHAR(100),
  eintrittsdatum DATE         NOT NULL,
  beitrag        DECIMAL(8,2) NOT NULL,
  PRIMARY KEY (mitglied_id)
);

-- Abteilungsleiter ist selbst ein Mitglied (Selbstreferenz, nullable)
CREATE TABLE abteilung (
  abteilung_id   INT          NOT NULL AUTO_INCREMENT,
  name           VARCHAR(100) NOT NULL,  -- z.B. Fussball, Tennis
  leiter_id      INT,                    -- FK auf mitglied
  PRIMARY KEY (abteilung_id),
  FOREIGN KEY (leiter_id) REFERENCES mitglied(mitglied_id)
);

-- n:m: Mitglied ↔ Abteilung
CREATE TABLE mitglied_abteilung (
  mitglied_id    INT NOT NULL,
  abteilung_id   INT NOT NULL,
  beitrittsdatum DATE,
  PRIMARY KEY (mitglied_id, abteilung_id),
  FOREIGN KEY (mitglied_id)  REFERENCES mitglied(mitglied_id),
  FOREIGN KEY (abteilung_id) REFERENCES abteilung(abteilung_id)
);

CREATE TABLE veranstaltung (
  veranstaltung_id INT          NOT NULL AUTO_INCREMENT,
  titel            VARCHAR(255) NOT NULL,
  datum            DATE         NOT NULL,
  ort              VARCHAR(255),
  max_teilnehmer   INT,
  abteilung_id     INT,
  PRIMARY KEY (veranstaltung_id),
  FOREIGN KEY (abteilung_id) REFERENCES abteilung(abteilung_id)
);

CREATE TABLE anmeldung (
  anmeldung_id     INT  NOT NULL AUTO_INCREMENT,
  mitglied_id      INT  NOT NULL,
  veranstaltung_id INT  NOT NULL,
  anmeldedatum     DATE NOT NULL,
  PRIMARY KEY (anmeldung_id),
  UNIQUE KEY uq_anmeldung (mitglied_id, veranstaltung_id),
  FOREIGN KEY (mitglied_id)      REFERENCES mitglied(mitglied_id),
  FOREIGN KEY (veranstaltung_id) REFERENCES veranstaltung(veranstaltung_id)
);
