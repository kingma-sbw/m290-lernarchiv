-- Musterlösung: Aufgabe 9 – Lieferketten-Management
-- Schwierigkeit: Experte | 12 Entitäten | Stückliste (BOM)

CREATE TABLE lieferant (
  lieferant_id     INT          NOT NULL AUTO_INCREMENT,
  name             VARCHAR(255) NOT NULL,
  land             VARCHAR(50),
  bewertung        DECIMAL(3,1),           -- 1.0–5.0
  zertifizierungen VARCHAR(255),
  PRIMARY KEY (lieferant_id)
);

CREATE TABLE material (
  material_id      INT          NOT NULL AUTO_INCREMENT,
  bezeichnung      VARCHAR(255) NOT NULL,
  einheit          VARCHAR(20)  NOT NULL,  -- kg, Stück, Liter
  mindestbestand   INT          NOT NULL DEFAULT 0,
  lieferant_id     INT,
  PRIMARY KEY (material_id),
  FOREIGN KEY (lieferant_id) REFERENCES lieferant(lieferant_id)
);

CREATE TABLE produkt (
  produkt_id       INT          NOT NULL AUTO_INCREMENT,
  bezeichnung      VARCHAR(255) NOT NULL,
  artikelnummer    VARCHAR(50)  NOT NULL,
  verkaufspreis    DECIMAL(10,2),
  PRIMARY KEY (produkt_id)
);

-- Stückliste: Produkt besteht aus Materialien (n:m mit Menge)
CREATE TABLE stueckliste (
  produkt_id       INT          NOT NULL,
  material_id      INT          NOT NULL,
  menge            DECIMAL(10,3) NOT NULL,
  PRIMARY KEY (produkt_id, material_id),
  FOREIGN KEY (produkt_id)  REFERENCES produkt(produkt_id),
  FOREIGN KEY (material_id) REFERENCES material(material_id)
);

CREATE TABLE lager (
  lager_id         INT          NOT NULL AUTO_INCREMENT,
  name             VARCHAR(100) NOT NULL,
  standort         VARCHAR(255),
  kapazitaet       INT,
  PRIMARY KEY (lager_id)
);

CREATE TABLE lagerposition (
  position_id      INT          NOT NULL AUTO_INCREMENT,
  lager_id         INT          NOT NULL,
  material_id      INT,
  produkt_id       INT,
  bestand          DECIMAL(10,3) NOT NULL DEFAULT 0,
  PRIMARY KEY (position_id),
  FOREIGN KEY (lager_id)    REFERENCES lager(lager_id),
  FOREIGN KEY (material_id) REFERENCES material(material_id),
  FOREIGN KEY (produkt_id)  REFERENCES produkt(produkt_id)
);

CREATE TABLE einkaufsbestellung (
  bestellung_id    INT          NOT NULL AUTO_INCREMENT,
  lieferant_id     INT          NOT NULL,
  bestelldatum     DATE         NOT NULL,
  lieferdatum      DATE,
  status           VARCHAR(20)  NOT NULL DEFAULT 'offen',
  material_id      INT          NOT NULL,
  menge            DECIMAL(10,3) NOT NULL,
  einzelpreis      DECIMAL(10,2),
  PRIMARY KEY (bestellung_id),
  FOREIGN KEY (lieferant_id) REFERENCES lieferant(lieferant_id),
  FOREIGN KEY (material_id)  REFERENCES material(material_id)
);

CREATE TABLE kundenauftrag (
  auftrag_id       INT          NOT NULL AUTO_INCREMENT,
  kundennr         VARCHAR(50)  NOT NULL,
  auftragsdatum    DATE         NOT NULL,
  lieferdatum      DATE,
  status           VARCHAR(20)  NOT NULL DEFAULT 'offen',
  produkt_id       INT          NOT NULL,
  menge            INT          NOT NULL,
  PRIMARY KEY (auftrag_id),
  FOREIGN KEY (produkt_id) REFERENCES produkt(produkt_id)
);

CREATE TABLE mitarbeiter (
  mitarbeiter_id   INT          NOT NULL AUTO_INCREMENT,
  vorname          VARCHAR(50)  NOT NULL,
  nachname         VARCHAR(50)  NOT NULL,
  rolle            VARCHAR(100),
  PRIMARY KEY (mitarbeiter_id)
);

CREATE TABLE maschine (
  maschine_id      INT          NOT NULL AUTO_INCREMENT,
  bezeichnung      VARCHAR(100) NOT NULL,
  kapazitaet_std   DECIMAL(5,2),
  PRIMARY KEY (maschine_id)
);

CREATE TABLE produktionsauftrag (
  pa_id            INT          NOT NULL AUTO_INCREMENT,
  produkt_id       INT          NOT NULL,
  maschine_id      INT,
  mitarbeiter_id   INT,
  startdatum       DATE,
  enddatum         DATE,
  menge            INT          NOT NULL,
  status           VARCHAR(20)  NOT NULL DEFAULT 'geplant',
  PRIMARY KEY (pa_id),
  FOREIGN KEY (produkt_id)    REFERENCES produkt(produkt_id),
  FOREIGN KEY (maschine_id)   REFERENCES maschine(maschine_id),
  FOREIGN KEY (mitarbeiter_id) REFERENCES mitarbeiter(mitarbeiter_id)
);

CREATE TABLE qualitaetspruefung (
  pruefung_id      INT          NOT NULL AUTO_INCREMENT,
  pa_id            INT          NOT NULL,
  datum            DATE         NOT NULL,
  pruefprotokoll   TEXT,
  ergebnis         VARCHAR(20)  NOT NULL,   -- bestanden | nicht_bestanden
  mitarbeiter_id   INT,
  PRIMARY KEY (pruefung_id),
  FOREIGN KEY (pa_id)          REFERENCES produktionsauftrag(pa_id),
  FOREIGN KEY (mitarbeiter_id) REFERENCES mitarbeiter(mitarbeiter_id)
);
