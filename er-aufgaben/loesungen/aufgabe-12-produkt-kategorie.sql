-- Musterlösung: Aufgabe 12 – Produkt & Kategorie
-- Schwierigkeit: Basis | 2 Entitäten | 1:n

CREATE TABLE kategorie (
  kategorie_id  INT          NOT NULL AUTO_INCREMENT,
  bezeichnung   VARCHAR(100) NOT NULL,
  PRIMARY KEY (kategorie_id)
);

CREATE TABLE produkt (
  produkt_id    INT          NOT NULL AUTO_INCREMENT,
  name          VARCHAR(100) NOT NULL,
  preis         DECIMAL(10,2) NOT NULL,
  lagerbestand  INT          NOT NULL DEFAULT 0,
  ablaufdatum   DATE,
  verfuegbar    BOOLEAN      NOT NULL DEFAULT TRUE,
  kategorie_id  INT          NOT NULL,
  PRIMARY KEY (produkt_id),
  FOREIGN KEY (kategorie_id) REFERENCES kategorie(kategorie_id)
);
