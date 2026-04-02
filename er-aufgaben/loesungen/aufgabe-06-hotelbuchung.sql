-- Musterlösung: Aufgabe 6 – Hotelbuchung
-- Schwierigkeit: Mittel | 5 Entitäten

CREATE TABLE zimmerkategorie (
  kategorie_id  INT          NOT NULL AUTO_INCREMENT,
  bezeichnung   VARCHAR(50)  NOT NULL,  -- Einzel, Doppel, Suite
  tagespreis    DECIMAL(8,2) NOT NULL,
  PRIMARY KEY (kategorie_id)
);

CREATE TABLE zimmer (
  zimmer_id     INT          NOT NULL AUTO_INCREMENT,
  zimmernummer  VARCHAR(10)  NOT NULL,
  etage         INT          NOT NULL,
  verfuegbar    BOOLEAN      NOT NULL DEFAULT TRUE,
  kategorie_id  INT          NOT NULL,
  PRIMARY KEY (zimmer_id),
  FOREIGN KEY (kategorie_id) REFERENCES zimmerkategorie(kategorie_id)
);

CREATE TABLE gast (
  gast_id       INT          NOT NULL AUTO_INCREMENT,
  vorname       VARCHAR(50)  NOT NULL,
  nachname      VARCHAR(50)  NOT NULL,
  email         VARCHAR(100),
  telefon       VARCHAR(20),
  nationalitaet VARCHAR(50),
  PRIMARY KEY (gast_id)
);

CREATE TABLE buchung (
  buchung_id    INT          NOT NULL AUTO_INCREMENT,
  gast_id       INT          NOT NULL,
  zimmer_id     INT          NOT NULL,
  checkin       DATE         NOT NULL,
  checkout      DATE         NOT NULL,
  gesamtpreis   DECIMAL(10,2),
  status        VARCHAR(20)  NOT NULL DEFAULT 'aktiv',  -- aktiv | storniert | abgeschlossen
  PRIMARY KEY (buchung_id),
  FOREIGN KEY (gast_id)   REFERENCES gast(gast_id),
  FOREIGN KEY (zimmer_id) REFERENCES zimmer(zimmer_id)
);

CREATE TABLE zusatzleistung (
  leistung_id   INT          NOT NULL AUTO_INCREMENT,
  bezeichnung   VARCHAR(100) NOT NULL,   -- Frühstück, Spa, Parking
  preis         DECIMAL(8,2) NOT NULL,
  PRIMARY KEY (leistung_id)
);

-- n:m: Buchung ↔ Zusatzleistung
CREATE TABLE buchung_leistung (
  buchung_id    INT NOT NULL,
  leistung_id   INT NOT NULL,
  PRIMARY KEY (buchung_id, leistung_id),
  FOREIGN KEY (buchung_id)  REFERENCES buchung(buchung_id),
  FOREIGN KEY (leistung_id) REFERENCES zusatzleistung(leistung_id)
);
