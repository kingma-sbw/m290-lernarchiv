-- Musterlösung: Aufgabe 1 – Bibliothek
-- Schwierigkeit: Einfach | 3 Entitäten | 1:n + Beziehungstabelle

CREATE TABLE mitglied (
  mitglied_id   INT          NOT NULL AUTO_INCREMENT,
  vorname       VARCHAR(50)  NOT NULL,
  nachname      VARCHAR(50)  NOT NULL,
  adresse       VARCHAR(255),
  PRIMARY KEY (mitglied_id)
);

CREATE TABLE buch (
  buch_id       INT          NOT NULL AUTO_INCREMENT,
  titel         VARCHAR(255) NOT NULL,
  isbn          VARCHAR(20)  NOT NULL,
  autor         VARCHAR(100) NOT NULL,
  PRIMARY KEY (buch_id)
);

-- Beziehungstabelle: ein Mitglied kann viele Bücher ausleihen (n:m über Zeit)
CREATE TABLE ausleihe (
  ausleihe_id    INT          NOT NULL AUTO_INCREMENT,
  mitglied_id    INT          NOT NULL,
  buch_id        INT          NOT NULL,
  ausleihdatum   DATE         NOT NULL,
  rueckgabedatum DATE,
  PRIMARY KEY (ausleihe_id),
  FOREIGN KEY (mitglied_id) REFERENCES mitglied(mitglied_id),
  FOREIGN KEY (buch_id)     REFERENCES buch(buch_id)
);
