-- Musterlösung: Aufgabe 4 – Online-Shop
-- Schwierigkeit: Mittel | 5 Entitäten | n:m mit Bestellposition

CREATE TABLE kategorie (
  kategorie_id  INT          NOT NULL AUTO_INCREMENT,
  name          VARCHAR(100) NOT NULL,
  PRIMARY KEY (kategorie_id)
);

CREATE TABLE produkt (
  produkt_id    INT          NOT NULL AUTO_INCREMENT,
  name          VARCHAR(255) NOT NULL,
  preis         DECIMAL(10,2) NOT NULL,
  lagerbestand  INT          NOT NULL DEFAULT 0,
  kategorie_id  INT          NOT NULL,
  PRIMARY KEY (produkt_id),
  FOREIGN KEY (kategorie_id) REFERENCES kategorie(kategorie_id)
);

CREATE TABLE kunde (
  kunde_id      INT          NOT NULL AUTO_INCREMENT,
  vorname       VARCHAR(50)  NOT NULL,
  nachname      VARCHAR(50)  NOT NULL,
  email         VARCHAR(100) NOT NULL,
  passwort_hash VARCHAR(255) NOT NULL,
  lieferadresse VARCHAR(255),
  PRIMARY KEY (kunde_id)
);

CREATE TABLE bestellung (
  bestellung_id INT          NOT NULL AUTO_INCREMENT,
  kunde_id      INT          NOT NULL,
  bestelldatum  DATE         NOT NULL,
  status        VARCHAR(20)  NOT NULL DEFAULT 'offen',  -- offen | versendet | geliefert
  PRIMARY KEY (bestellung_id),
  FOREIGN KEY (kunde_id) REFERENCES kunde(kunde_id)
);

-- n:m Auflösung: Bestellung ↔ Produkt
CREATE TABLE bestellposition (
  position_id   INT          NOT NULL AUTO_INCREMENT,
  bestellung_id INT          NOT NULL,
  produkt_id    INT          NOT NULL,
  menge         INT          NOT NULL DEFAULT 1,
  einzelpreis   DECIMAL(10,2) NOT NULL,   -- Preis zum Bestellzeitpunkt
  PRIMARY KEY (position_id),
  FOREIGN KEY (bestellung_id) REFERENCES bestellung(bestellung_id),
  FOREIGN KEY (produkt_id)    REFERENCES produkt(produkt_id)
);
