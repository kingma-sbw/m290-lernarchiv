-- Musterlösung: Aufgabe 3 – Schulverwaltung
-- Schwierigkeit: Einfach | 4 Tabellen (inkl. n:m Unterricht)

CREATE TABLE lehrperson (
  lehrperson_id INT          NOT NULL AUTO_INCREMENT,
  vorname       VARCHAR(50)  NOT NULL,
  nachname      VARCHAR(50)  NOT NULL,
  faecher       VARCHAR(255),
  PRIMARY KEY (lehrperson_id)
);

-- Klasse hat genau 1 Klassenlehrperson (1:n)
CREATE TABLE klasse (
  klasse_id     INT          NOT NULL AUTO_INCREMENT,
  bezeichnung   VARCHAR(20)  NOT NULL,   -- z.B. INF22a
  raum          VARCHAR(20),
  schuljahr     VARCHAR(9),              -- z.B. 2024/2025
  klassenlp_id  INT          NOT NULL,   -- Klassenlehrperson
  PRIMARY KEY (klasse_id),
  FOREIGN KEY (klassenlp_id) REFERENCES lehrperson(lehrperson_id)
);

-- Schüler*in gehört genau 1 Klasse
CREATE TABLE schueler (
  schueler_id   INT          NOT NULL AUTO_INCREMENT,
  vorname       VARCHAR(50)  NOT NULL,
  nachname      VARCHAR(50)  NOT NULL,
  geburtsdatum  DATE,
  lehrjahr      INT,
  klasse_id     INT          NOT NULL,
  PRIMARY KEY (schueler_id),
  FOREIGN KEY (klasse_id) REFERENCES klasse(klasse_id)
);

-- Lehrperson unterrichtet mehrere Klassen (n:m)
CREATE TABLE unterricht (
  lehrperson_id INT NOT NULL,
  klasse_id     INT NOT NULL,
  fach          VARCHAR(50),
  PRIMARY KEY (lehrperson_id, klasse_id),
  FOREIGN KEY (lehrperson_id) REFERENCES lehrperson(lehrperson_id),
  FOREIGN KEY (klasse_id)     REFERENCES klasse(klasse_id)
);
