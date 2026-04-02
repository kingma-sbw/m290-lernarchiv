-- Musterlösung: Aufgabe 11 – Person
-- Schwierigkeit: Basis | 1 Entität

CREATE TABLE person (
  person_id   INT            NOT NULL AUTO_INCREMENT,
  vorname     VARCHAR(50)    NOT NULL,
  nachname    VARCHAR(50)    NOT NULL,
  geburtsdatum DATE          NOT NULL,
  email       VARCHAR(100)   NOT NULL,
  groesse     DECIMAL(5,2),                   -- cm, z.B. 172.50
  aktiv       BOOLEAN        NOT NULL DEFAULT TRUE,
  PRIMARY KEY (person_id)
);
