-- Musterlösung: Aufgabe 2 – Tierarztpraxis
-- Schwierigkeit: Einfach | 4 Entitäten

CREATE TABLE besitzer (
  besitzer_id   INT          NOT NULL AUTO_INCREMENT,
  vorname       VARCHAR(50)  NOT NULL,
  nachname      VARCHAR(50)  NOT NULL,
  telefon       VARCHAR(20),
  email         VARCHAR(100),
  PRIMARY KEY (besitzer_id)
);

-- 1 Besitzer : n Tiere
CREATE TABLE tier (
  tier_id       INT          NOT NULL AUTO_INCREMENT,
  name          VARCHAR(50)  NOT NULL,
  art           VARCHAR(50)  NOT NULL,   -- z.B. Hund, Katze
  geburtsdatum  DATE,
  besitzer_id   INT          NOT NULL,
  PRIMARY KEY (tier_id),
  FOREIGN KEY (besitzer_id) REFERENCES besitzer(besitzer_id)
);

CREATE TABLE tierarzt (
  tierarzt_id   INT          NOT NULL AUTO_INCREMENT,
  vorname       VARCHAR(50)  NOT NULL,
  nachname      VARCHAR(50)  NOT NULL,
  PRIMARY KEY (tierarzt_id)
);

-- Behandlung verknüpft Tier und Tierarzt (n:m aufgelöst)
CREATE TABLE behandlung (
  behandlung_id INT          NOT NULL AUTO_INCREMENT,
  tier_id       INT          NOT NULL,
  tierarzt_id   INT          NOT NULL,
  datum         DATE         NOT NULL,
  diagnose      TEXT,
  PRIMARY KEY (behandlung_id),
  FOREIGN KEY (tier_id)     REFERENCES tier(tier_id),
  FOREIGN KEY (tierarzt_id) REFERENCES tierarzt(tierarzt_id)
);
