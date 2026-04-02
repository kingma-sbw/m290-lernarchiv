-- Musterlösung: Aufgabe 8 – Streaming-Plattform
-- Schwierigkeit: Schwer | 12 Entitäten | Spezialisierung (Film/Serie)

CREATE TABLE produktionsfirma (
  firma_id      INT          NOT NULL AUTO_INCREMENT,
  name          VARCHAR(255) NOT NULL,
  land          VARCHAR(50),
  PRIMARY KEY (firma_id)
);

CREATE TABLE genre (
  genre_id      INT          NOT NULL AUTO_INCREMENT,
  bezeichnung   VARCHAR(50)  NOT NULL,
  PRIMARY KEY (genre_id)
);

-- Basisentität für alle Inhalte
CREATE TABLE inhalt (
  inhalt_id     INT          NOT NULL AUTO_INCREMENT,
  titel         VARCHAR(255) NOT NULL,
  erscheinungsjahr INT,
  altersfreigabe INT,        -- z.B. 0, 6, 12, 16, 18
  typ           VARCHAR(10)  NOT NULL,  -- 'film' | 'serie'
  firma_id      INT,
  PRIMARY KEY (inhalt_id),
  FOREIGN KEY (firma_id) REFERENCES produktionsfirma(firma_id)
);

-- n:m: Inhalt ↔ Genre
CREATE TABLE inhalt_genre (
  inhalt_id     INT NOT NULL,
  genre_id      INT NOT NULL,
  PRIMARY KEY (inhalt_id, genre_id),
  FOREIGN KEY (inhalt_id) REFERENCES inhalt(inhalt_id),
  FOREIGN KEY (genre_id)  REFERENCES genre(genre_id)
);

-- Spezialisierung: Film
CREATE TABLE film (
  inhalt_id     INT NOT NULL,
  dauer_min     INT,
  PRIMARY KEY (inhalt_id),
  FOREIGN KEY (inhalt_id) REFERENCES inhalt(inhalt_id)
);

-- Spezialisierung: Serie → Staffel → Episode
CREATE TABLE staffel (
  staffel_id    INT NOT NULL AUTO_INCREMENT,
  inhalt_id     INT NOT NULL,   -- Bezug zur Serie (inhalt.typ='serie')
  staffelnummer INT NOT NULL,
  PRIMARY KEY (staffel_id),
  FOREIGN KEY (inhalt_id) REFERENCES inhalt(inhalt_id)
);

CREATE TABLE episode (
  episode_id    INT          NOT NULL AUTO_INCREMENT,
  staffel_id    INT          NOT NULL,
  episodennummer INT         NOT NULL,
  titel         VARCHAR(255),
  dauer_min     INT,
  PRIMARY KEY (episode_id),
  FOREIGN KEY (staffel_id) REFERENCES staffel(staffel_id)
);

CREATE TABLE abo (
  abo_id        INT          NOT NULL AUTO_INCREMENT,
  bezeichnung   VARCHAR(20)  NOT NULL,   -- Basic, Premium
  preis_monat   DECIMAL(6,2) NOT NULL,
  PRIMARY KEY (abo_id)
);

CREATE TABLE nutzer (
  nutzer_id     INT          NOT NULL AUTO_INCREMENT,
  email         VARCHAR(100) NOT NULL,
  passwort_hash VARCHAR(255) NOT NULL,
  abo_id        INT,
  PRIMARY KEY (nutzer_id),
  FOREIGN KEY (abo_id) REFERENCES abo(abo_id)
);

CREATE TABLE profil (
  profil_id     INT          NOT NULL AUTO_INCREMENT,
  nutzer_id     INT          NOT NULL,
  name          VARCHAR(50)  NOT NULL,
  PRIMARY KEY (profil_id),
  FOREIGN KEY (nutzer_id) REFERENCES nutzer(nutzer_id)
);

-- Wiedergabeverlauf (Profil sieht Inhalt)
CREATE TABLE verlauf (
  verlauf_id    INT          NOT NULL AUTO_INCREMENT,
  profil_id     INT          NOT NULL,
  inhalt_id     INT          NOT NULL,
  zeitstempel   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  fortschritt   INT          NOT NULL DEFAULT 0,   -- Sekunden
  PRIMARY KEY (verlauf_id),
  FOREIGN KEY (profil_id) REFERENCES profil(profil_id),
  FOREIGN KEY (inhalt_id) REFERENCES inhalt(inhalt_id)
);

-- Bewertung
CREATE TABLE bewertung (
  profil_id     INT NOT NULL,
  inhalt_id     INT NOT NULL,
  sterne        INT NOT NULL,   -- 1–5
  PRIMARY KEY (profil_id, inhalt_id),
  FOREIGN KEY (profil_id) REFERENCES profil(profil_id),
  FOREIGN KEY (inhalt_id) REFERENCES inhalt(inhalt_id)
);

-- Watchlist
CREATE TABLE watchlist (
  profil_id     INT NOT NULL,
  inhalt_id     INT NOT NULL,
  hinzugefuegt  DATE,
  PRIMARY KEY (profil_id, inhalt_id),
  FOREIGN KEY (profil_id) REFERENCES profil(profil_id),
  FOREIGN KEY (inhalt_id) REFERENCES inhalt(inhalt_id)
);
