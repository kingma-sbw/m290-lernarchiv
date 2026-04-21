## MariaDB DCL (Data Control Language) – Benutzerverwaltung und Rechte

### 1) Benutzer erstellen und identifizieren

Ein Benutzer wird mit `CREATE USER` angelegt. Die eindeutige Identifikation erfolgt über **Benutzername und Herkunfts-Host** im Format `'user'@'host'`:
```sql
CREATE USER 'max'@'localhost' IDENTIFIED BY 'sicheres_passwort';
CREATE USER 'max'@'%' IDENTIFIED BY 'passwort';  -- % erlaubt Zugriff von jedem Host
```

### 2) Verfügbare Rechte (Auswahl)

| Privileg | Bedeutung |
|----------|-----------|
| `ALL PRIVILEGES` | Alle Rechte auf einer Ebene (außer `GRANT OPTION`) |
| `SELECT` | Daten lesen |
| `INSERT` | Daten einfügen |
| `UPDATE` | Daten ändern |
| `DELETE` | Daten löschen |
| `CREATE` | Datenbanken/Tabellen anlegen |
| `DROP` | Objekte löschen |
| `GRANT OPTION` | Rechte an andere weitergeben |

### 3) Zugriff auf Datenbanken, Tabellen und Spalten

Die `GRANT`-Syntax folgt diesem Muster:
```sql
GRANT privilegien ON ebene TO 'user'@'host';
```

**Ebenen und Beispiele:**
- **Datenbank-Ebene:** `ON datenbank.*` → alle Tabellen der DB
- **Tabellen-Ebene:** `ON datenbank.tabelle` → nur diese Tabelle
- **Spalten-Ebene:** `SELECT(spalte1, spalte2) ON tabelle` → nur bestimmte Spalten

Nach Änderungen empfiehlt sich `FLUSH PRIVILEGES;`. Mit `REVOKE` werden Rechte entzogen.

---

## Abschlussaufgabe: Zwei Benutzer für eine Datenbank

```sql
-- 1) Benutzer mit Lese- und Schreibrechten (SELECT, INSERT, UPDATE, DELETE)
CREATE USER 'redakteur'@'localhost' IDENTIFIED BY 'lesen_schreiben123';
GRANT SELECT, INSERT, UPDATE, DELETE ON meinedatenbank.* TO 'redakteur'@'localhost';

-- 2) Benutzer mit NUR Schreibrechten (INSERT + UPDATE, ohne SELECT)
CREATE USER 'schreiber'@'localhost' IDENTIFIED BY 'nur_schreiben456';
GRANT INSERT, UPDATE ON meinedatenbank.* TO 'schreiber'@'localhost';

-- Änderungen aktivieren
FLUSH PRIVILEGES;
```

Der zweite Benutzer (`schreiber`) kann Daten **einfügen und ändern**, aber keine Daten **lesen** (`SELECT` wurde bewusst nicht erteilt).
