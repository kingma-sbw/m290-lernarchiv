-- ══════════════════════════════════════════════════════════════
--  sql_extra  ·  MariaDB setup
--  Run once:  mariadb -u USER -p DBNAME < setup.sql
-- ══════════════════════════════════════════════════════════════

-- ── Tasks ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sql_tasks (
  id           INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  sort_order   SMALLINT        NOT NULL DEFAULT 0,
  title        VARCHAR(120)    NOT NULL,
  difficulty   ENUM('easy','medium','hard') NOT NULL DEFAULT 'easy',
  diff_label   VARCHAR(30)     NOT NULL,
  description  TEXT            NOT NULL,
  output_cols  JSON            NOT NULL COMMENT 'array of expected column names',
  keywords     JSON            NOT NULL COMMENT 'array of keyword badges',
  hint         TEXT            NOT NULL,
  solution     TEXT            NOT NULL,
  check_regex  JSON            NOT NULL COMMENT 'array of regex strings, ALL must match',
  active       TINYINT(1)      NOT NULL DEFAULT 1,
  created_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_sort (sort_order, active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Student progress ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sql_progress (
  id           INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  session_token CHAR(36)       NOT NULL COMMENT 'UUID v4, generated client-side',
  task_id      INT UNSIGNED    NOT NULL,
  solved       TINYINT(1)      NOT NULL DEFAULT 0,
  user_sql     TEXT                     DEFAULT NULL,
  attempts     SMALLINT        NOT NULL DEFAULT 0,
  solved_at    DATETIME                 DEFAULT NULL,
  updated_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_session_task (session_token, task_id),
  KEY idx_session (session_token),
  CONSTRAINT fk_progress_task FOREIGN KEY (task_id) REFERENCES sql_tasks (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ══════════════════════════════════════════════════════════════
--  Seed: 10 tasks
-- ══════════════════════════════════════════════════════════════

INSERT INTO sql_tasks
  (sort_order, title, difficulty, diff_label, description, output_cols, keywords, hint, solution, check_regex)
VALUES

(1,
 'Einfache Auflistung',
 'easy', 'Einfach',
 'Liste alle Fächer (<strong>subject_name</strong>) sortiert nach Namen auf. Zeige zusätzlich die zugehörige <strong>teacher_id</strong> aus der Tabelle <strong>subject</strong>.',
 '["subject_name","teacher_id"]',
 '["SELECT","FROM","ORDER BY"]',
 'Nutze ORDER BY auf subject_name. Keine JOIN-Verknüpfung nötig – alle Daten kommen aus einer einzigen Tabelle.',
 'SELECT subject_name, teacher_id\nFROM   subject\nORDER BY subject_name ASC;',
 '["order\\\\s+by","subject","subject_name"]'
),

(2,
 'Aggregation: Fächer pro Lehrer',
 'easy', 'Einfach',
 'Ermittle für jeden Lehrer (<strong>teacher_id</strong>) in der Tabelle <strong>subject</strong>, wie viele Fächer er unterrichtet.',
 '["teacher_id","anzahl_faecher"]',
 '["COUNT","GROUP BY"]',
 'Verwende GROUP BY auf teacher_id und COUNT(*) oder COUNT(subject_id) als Aggregatfunktion.',
 'SELECT   teacher_id,\n         COUNT(*) AS anzahl_faecher\nFROM     subject\nWHERE    teacher_id IS NOT NULL\nGROUP BY teacher_id\nORDER BY anzahl_faecher DESC;',
 '["group\\\\s+by","count","teacher_id"]'
),

(3,
 'INNER JOIN: Fächer mit Lehrername',
 'easy', 'Einfach',
 'Zeige alle Fächer mit dem vollständigen Lehrernamen (<strong>first_part</strong>, <strong>last_part</strong>), basierend auf der direkten Verknüpfung <code>subject.teacher_id = teacher.teacher_id</code>.',
 '["subject_name","lehrer_name"]',
 '["INNER JOIN","CONCAT","ON"]',
 'Verbinde subject und teacher über INNER JOIN. Konkateniere first_part und last_part mit CONCAT().',
 'SELECT s.subject_name,\n       CONCAT(t.first_part, '' '', t.last_part) AS lehrer_name\nFROM   subject s\nINNER JOIN teacher t ON s.teacher_id = t.teacher_id\nORDER BY s.subject_name;',
 '["inner\\\\s+join|join","concat","teacher"]'
),

(4,
 'LEFT JOIN: Lehrer ohne Fach',
 'medium', 'Mittel',
 'Finde alle Lehrer, die <em>keinem</em> Fach in der Tabelle <strong>subject</strong> direkt zugeordnet sind.',
 '["teacher_id","first_part","last_part"]',
 '["LEFT JOIN","IS NULL"]',
 'Starte mit teacher als linker Tabelle und verknüpfe subject per LEFT JOIN. Filtere dann mit WHERE s.subject_id IS NULL.',
 'SELECT t.teacher_id,\n       t.first_part,\n       t.last_part\nFROM   teacher t\nLEFT JOIN subject s ON t.teacher_id = s.teacher_id\nWHERE  s.subject_id IS NULL\nORDER BY t.last_part;',
 '["left\\\\s+join","is\\\\s+null"]'
),

(5,
 'N:m-Beziehung: Drei Tabellen',
 'medium', 'Mittel',
 'Über die Tabelle <strong>subject_teacher</strong> (N:m) sollen alle Fächer mit den zugehörigen Lehrernamen ausgegeben werden. Ein Fach kann hier mehreren Lehrern zugeordnet sein.',
 '["subject_name","lehrer_name"]',
 '["JOIN ×2","subject_teacher"]',
 'Verknüpfe alle drei Tabellen mit zwei JOINs: subject → subject_teacher → teacher.',
 'SELECT s.subject_name,\n       CONCAT(t.first_part, '' '', t.last_part) AS lehrer_name\nFROM   subject         s\nINNER JOIN subject_teacher st ON s.subject_id  = st.subject_id\nINNER JOIN teacher         t  ON st.teacher_id = t.teacher_id\nORDER BY s.subject_name, t.last_part;',
 '["subject_teacher","join.*join|join"]'
),

(6,
 'Vergleich: direkte vs. N:m-Zuordnung',
 'hard', 'Komplex',
 'Erstelle eine Liste aller Fächer mit dem <strong>direkten</strong> Lehrer und allen <strong>zusätzlichen</strong> Lehrern aus subject_teacher (ohne den direkten).',
 '["subject_name","direkter_lehrer","zusätzliche_lehrer"]',
 '["GROUP_CONCAT","DISTINCT","LEFT JOIN ×3"]',
 'Nutze GROUP_CONCAT() für die N:m-Lehrer. Schliesse mit einer Bedingung den direkten Lehrer aus der N:m-Liste aus.',
 'SELECT   s.subject_name,\n         CONCAT(t_dir.first_part, '' '', t_dir.last_part) AS direkter_lehrer,\n         GROUP_CONCAT(\n           DISTINCT CONCAT(t_nm.first_part, '' '', t_nm.last_part)\n           ORDER BY t_nm.last_part\n           SEPARATOR '', ''\n         ) AS zusätzliche_lehrer\nFROM     subject s\nLEFT JOIN teacher         t_dir ON s.teacher_id   = t_dir.teacher_id\nLEFT JOIN subject_teacher st    ON s.subject_id    = st.subject_id\n                                AND st.teacher_id <> s.teacher_id\nLEFT JOIN teacher         t_nm  ON st.teacher_id   = t_nm.teacher_id\nGROUP BY s.subject_id, s.subject_name, direkter_lehrer\nORDER BY s.subject_name;',
 '["group_concat"]'
),

(7,
 'Lehrer ohne N:m-Zuordnung',
 'hard', 'Komplex',
 'Finde alle Lehrer, die in <strong>subject_teacher</strong> <em>nicht</em> vorkommen. Zeige auch, ob sie als direkter Lehrer in subject existieren (<em>ja/nein</em>).',
 '["teacher_id","first_part","last_part","direkter_lehrer"]',
 '["IF()","IS NULL","LEFT JOIN ×2"]',
 'Starte mit teacher, LEFT JOIN auf subject_teacher (filtere IS NULL), dann nochmals LEFT JOIN auf subject um ja/nein zu bestimmen.',
 'SELECT   t.teacher_id,\n         t.first_part,\n         t.last_part,\n         IF(s.subject_id IS NOT NULL, ''ja'', ''nein'') AS direkter_lehrer\nFROM     teacher t\nLEFT JOIN subject_teacher st ON t.teacher_id = st.teacher_id\nLEFT JOIN subject          s  ON t.teacher_id = s.teacher_id\nWHERE    st.teacher_id IS NULL\nORDER BY t.last_part;',
 '["subject_teacher","is\\\\s+null"]'
),

(8,
 'Widersprüchliche Zuordnungen',
 'hard', 'Komplex',
 'Finde Fälle, bei denen ein Lehrer in <strong>subject_teacher</strong> einem Fach zugeordnet ist, aber <em>nicht</em> dem direkten Lehrer in subject entspricht.',
 '["subject_name","teacher_id_aus_nm","lehrer_name","direkter_teacher_id_des_faches"]',
 '["<> (Ungleich)","INNER JOIN","Filterung im ON"]',
 'Verknüpfe subject mit subject_teacher und filtere mit st.teacher_id <> s.teacher_id direkt im ON.',
 'SELECT s.subject_name,\n       st.teacher_id                          AS teacher_id_aus_nm,\n       CONCAT(t.first_part, '' '', t.last_part) AS lehrer_name,\n       s.teacher_id                           AS direkter_teacher_id_des_faches\nFROM   subject         s\nINNER JOIN subject_teacher st ON s.subject_id  = st.subject_id\n                              AND st.teacher_id <> s.teacher_id\nINNER JOIN teacher         t  ON st.teacher_id = t.teacher_id\nORDER BY s.subject_name;',
 '["subject_teacher","<>|!="]'
),

(9,
 'Statistik: Anzahl Lehrer pro Fach',
 'hard', 'Komplex',
 'Erstelle für jedes Fach eine Statistik:<br>• Anzahl direkte Lehrer (0 oder 1)<br>• Anzahl Lehrer über subject_teacher<br>• Gesamtanzahl <em>einzigartiger</em> Lehrer',
 '["subject_name","anzahl_direkt","anzahl_nm","anzahl_gesamt_eindeutig"]',
 '["IF()","COUNT(DISTINCT)","CASE WHEN"]',
 'Nutze COUNT(DISTINCT …). Zähle direkte als 0/1 per IF(), N:m separat per LEFT JOIN auf subject_teacher.',
 'SELECT   s.subject_name,\n         IF(s.teacher_id IS NOT NULL, 1, 0)  AS anzahl_direkt,\n         COUNT(DISTINCT st.teacher_id)         AS anzahl_nm,\n         COUNT(DISTINCT CASE WHEN s.teacher_id IS NOT NULL THEN s.teacher_id ELSE NULL END)\n         + COUNT(DISTINCT st.teacher_id)\n         - COUNT(DISTINCT CASE WHEN st.teacher_id = s.teacher_id THEN st.teacher_id ELSE NULL END)\n                                               AS anzahl_gesamt_eindeutig\nFROM     subject s\nLEFT JOIN subject_teacher st ON s.subject_id = st.subject_id\nGROUP BY s.subject_id, s.subject_name, s.teacher_id\nORDER BY s.subject_name;',
 '["count.*distinct","group\\\\s+by"]'
),

(10,
 'Top 5: Größte Gesamtverantwortung',
 'hard', 'Komplex',
 'Ermittle den Lehrer, der über <em>beide</em> Zuordnungsarten an den meisten Fächern beteiligt ist. Top 5 absteigend sortiert.',
 '["teacher_id","lehrer_name","anzahl_faecher_gesamt"]',
 '["UNION ALL","Subquery","LIMIT"]',
 'Nutze UNION ALL, um beide Quellen zu kombinieren, danach GROUP BY und ORDER BY LIMIT 5.',
 'SELECT   teacher_id,\n         CONCAT(first_part, '' '', last_part) AS lehrer_name,\n         COUNT(*)                           AS anzahl_faecher_gesamt\nFROM (\n  SELECT t.teacher_id, t.first_part, t.last_part\n  FROM   subject s\n  INNER JOIN teacher t ON s.teacher_id = t.teacher_id\n  UNION ALL\n  SELECT t.teacher_id, t.first_part, t.last_part\n  FROM   subject_teacher st\n  INNER JOIN teacher t ON st.teacher_id = t.teacher_id\n) combined\nGROUP BY teacher_id, first_part, last_part\nORDER BY anzahl_faecher_gesamt DESC\nLIMIT 5;',
 '["union","limit"]'
);
