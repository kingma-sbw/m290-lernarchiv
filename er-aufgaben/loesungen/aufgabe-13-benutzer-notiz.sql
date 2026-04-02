-- Musterlösung: Aufgabe 13 – Benutzer & Notiz
-- Schwierigkeit: Basis | 2 Entitäten | 1:n

CREATE TABLE benutzer (
  benutzer_id   INT          NOT NULL AUTO_INCREMENT,
  benutzername  VARCHAR(50)  NOT NULL,
  email         VARCHAR(100) NOT NULL,
  erstellt_am   DATE         NOT NULL,
  PRIMARY KEY (benutzer_id)
);

CREATE TABLE notiz (
  notiz_id      INT          NOT NULL AUTO_INCREMENT,
  titel         VARCHAR(100) NOT NULL,
  inhalt        TEXT,
  erstellt_am   DATE         NOT NULL,
  wichtig       BOOLEAN      NOT NULL DEFAULT FALSE,
  benutzer_id   INT          NOT NULL,
  PRIMARY KEY (notiz_id),
  FOREIGN KEY (benutzer_id) REFERENCES benutzer(benutzer_id)
);
