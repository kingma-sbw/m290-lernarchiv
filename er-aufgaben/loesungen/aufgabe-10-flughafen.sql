-- Musterlösung: Aufgabe 10 – Flughafen-System
-- Schwierigkeit: Experte | 13 Entitäten

CREATE TABLE airline (
  airline_id     INT          NOT NULL AUTO_INCREMENT,
  name           VARCHAR(255) NOT NULL,
  iata_code      VARCHAR(3)   NOT NULL,
  land           VARCHAR(50),
  PRIMARY KEY (airline_id)
);

CREATE TABLE flugzeugtyp (
  typ_id         INT          NOT NULL AUTO_INCREMENT,
  bezeichnung    VARCHAR(100) NOT NULL,   -- z.B. Boeing 737-800
  sitzplaetze    INT          NOT NULL,
  PRIMARY KEY (typ_id)
);

CREATE TABLE flugzeug (
  flugzeug_id    INT          NOT NULL AUTO_INCREMENT,
  kennzeichen    VARCHAR(20)  NOT NULL,
  typ_id         INT          NOT NULL,
  airline_id     INT          NOT NULL,
  PRIMARY KEY (flugzeug_id),
  FOREIGN KEY (typ_id)    REFERENCES flugzeugtyp(typ_id),
  FOREIGN KEY (airline_id) REFERENCES airline(airline_id)
);

CREATE TABLE terminal (
  terminal_id    INT          NOT NULL AUTO_INCREMENT,
  bezeichnung    VARCHAR(10)  NOT NULL,
  PRIMARY KEY (terminal_id)
);

CREATE TABLE gate (
  gate_id        INT          NOT NULL AUTO_INCREMENT,
  bezeichnung    VARCHAR(10)  NOT NULL,
  terminal_id    INT          NOT NULL,
  PRIMARY KEY (gate_id),
  FOREIGN KEY (terminal_id) REFERENCES terminal(terminal_id)
);

CREATE TABLE flug (
  flug_id        INT          NOT NULL AUTO_INCREMENT,
  flugnummer     VARCHAR(10)  NOT NULL,
  airline_id     INT          NOT NULL,
  flugzeug_id    INT,
  herkunft       VARCHAR(10)  NOT NULL,  -- IATA Flughafencode
  ziel           VARCHAR(10)  NOT NULL,
  abflugzeit     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ankunftzeit    TIMESTAMP    NULL DEFAULT NULL,
  gate_id        INT,
  status         VARCHAR(20)  NOT NULL DEFAULT 'geplant',
  PRIMARY KEY (flug_id),
  FOREIGN KEY (airline_id)  REFERENCES airline(airline_id),
  FOREIGN KEY (flugzeug_id) REFERENCES flugzeug(flugzeug_id),
  FOREIGN KEY (gate_id)     REFERENCES gate(gate_id)
);

CREATE TABLE statusprotokoll (
  protokoll_id   INT          NOT NULL AUTO_INCREMENT,
  flug_id        INT          NOT NULL,
  zeitpunkt      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  status         VARCHAR(20)  NOT NULL,
  verzoegerung   INT,                   -- Minuten
  PRIMARY KEY (protokoll_id),
  FOREIGN KEY (flug_id) REFERENCES flug(flug_id)
);

CREATE TABLE passagier (
  passagier_id   INT          NOT NULL AUTO_INCREMENT,
  vorname        VARCHAR(50)  NOT NULL,
  nachname       VARCHAR(50)  NOT NULL,
  passnummer     VARCHAR(20)  NOT NULL,
  nationalitaet  VARCHAR(50),
  PRIMARY KEY (passagier_id)
);

CREATE TABLE buchung (
  buchung_id     INT          NOT NULL AUTO_INCREMENT,
  passagier_id   INT          NOT NULL,
  flug_id        INT          NOT NULL,
  sitzklasse     VARCHAR(20)  NOT NULL,  -- Economy, Business, First
  sitzplatznummer VARCHAR(5),
  buchungsdatum  DATE         NOT NULL,
  preis          DECIMAL(10,2),
  PRIMARY KEY (buchung_id),
  FOREIGN KEY (passagier_id) REFERENCES passagier(passagier_id),
  FOREIGN KEY (flug_id)      REFERENCES flug(flug_id)
);

CREATE TABLE gepaeck (
  gepaeck_id     INT          NOT NULL AUTO_INCREMENT,
  buchung_id     INT          NOT NULL,
  gewicht_kg     DECIMAL(5,2),
  tracking_code  VARCHAR(50)  NOT NULL,
  status         VARCHAR(30)  NOT NULL DEFAULT 'eingecheckt',
  PRIMARY KEY (gepaeck_id),
  FOREIGN KEY (buchung_id) REFERENCES buchung(buchung_id)
);

CREATE TABLE crew_mitglied (
  crew_id        INT          NOT NULL AUTO_INCREMENT,
  vorname        VARCHAR(50)  NOT NULL,
  nachname       VARCHAR(50)  NOT NULL,
  lizenz         VARCHAR(50),
  airline_id     INT,
  PRIMARY KEY (crew_id),
  FOREIGN KEY (airline_id) REFERENCES airline(airline_id)
);

-- Crew-Zuteilung zu Flügen (n:m mit Rolle)
CREATE TABLE crew_zuteilung (
  crew_id        INT NOT NULL,
  flug_id        INT NOT NULL,
  rolle          VARCHAR(30) NOT NULL,  -- Kapitän | Copilot | Kabine
  PRIMARY KEY (crew_id, flug_id),
  FOREIGN KEY (crew_id) REFERENCES crew_mitglied(crew_id),
  FOREIGN KEY (flug_id) REFERENCES flug(flug_id)
);
