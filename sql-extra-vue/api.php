<?php
/**
 * sql-extra/api.php
 * Minimal REST API — MariaDB + PHP 8.1+
 *
 * GET  api.php?resource=tasks
 *      → all active tasks (sorted)
 *
 * GET  api.php?resource=progress&session=<uuid>
 *      → progress rows for this session
 *
 * POST api.php
 *      body: { resource:"progress", session:"<uuid>", task_id:1, solved:true, user_sql:"..." }
 *      → upserts progress, returns updated row
 */

declare(strict_types=1);

// ── Config ────────────────────────────────────────────────────
// Set these via environment variables or a local config file
// that is NOT committed to version control.
$cfg = [
    'host'   => getenv('DB_HOST') ?: 'localhost',
    'port'   => (int)(getenv('DB_PORT') ?: 3306),
    'dbname' => getenv('DB_NAME') ?: 'jkingma_lernarchiv',
    'user'   => getenv('DB_USER') ?: 'jkingma_lernarchiv',
    'pass'   => getenv('DB_PASS') ?: '87ak#mR31',
    'charset'=> 'utf8mb4',
];

// ── Headers ───────────────────────────────────────────────────
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// ── Bootstrap ─────────────────────────────────────────────────
function jsonOut(mixed $data, int $status = 200): never
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function jsonError(string $message, int $status = 400): never
{
    jsonOut(['error' => $message], $status);
}

// ── DB connection (lazy singleton) ────────────────────────────
function db(array $cfg): PDO
{
    static $pdo = null;
    if ($pdo === null) {
        $dsn = "mysql:host={$cfg['host']};port={$cfg['port']};dbname={$cfg['dbname']};charset={$cfg['charset']}";
        $pdo = new PDO($dsn, $cfg['user'], $cfg['pass'], [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    }
    return $pdo;
}

// ── UUID validation ────────────────────────────────────────────
function isValidUuid(string $s): bool
{
    return (bool) preg_match(
        '/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i',
        $s
    );
}

// ── Routing ───────────────────────────────────────────────────
$method   = $_SERVER['REQUEST_METHOD'];
$resource = '';

if ($method === 'GET') {
    $resource = $_GET['resource'] ?? '';
} elseif ($method === 'POST') {
    $body     = json_decode(file_get_contents('php://input'), true) ?? [];
    $resource = $body['resource'] ?? '';
}

try {
    $pdo = db($cfg);

    // ════════════════════════════════════════
    // GET tasks
    // ════════════════════════════════════════
    if ($method === 'GET' && $resource === 'tasks') {
        $stmt = $pdo->query(
            'SELECT id, sort_order, title, difficulty, diff_label,
                    description, output_cols, keywords, hint, solution, check_regex
             FROM   sql_tasks
             WHERE  active = 1
             ORDER  BY sort_order ASC'
        );
        $rows = $stmt->fetchAll();

        // Decode JSON columns
        foreach ($rows as &$row) {
            $row['output_cols'] = json_decode($row['output_cols'], true);
            $row['keywords']    = json_decode($row['keywords'],    true);
            $row['check_regex'] = json_decode($row['check_regex'], true);
            $row['id']          = (int) $row['id'];
            $row['sort_order']  = (int) $row['sort_order'];
        }
        unset($row);

        jsonOut(['data' => $rows]);
    }

    // ════════════════════════════════════════
    // GET progress
    // ════════════════════════════════════════
    if ($method === 'GET' && $resource === 'progress') {
        $session = trim($_GET['session'] ?? '');
        if (!isValidUuid($session)) {
            jsonError('Invalid session token.');
        }

        $stmt = $pdo->prepare(
            'SELECT task_id, solved, user_sql, attempts, solved_at
             FROM   sql_progress
             WHERE  session_token = ?'
        );
        $stmt->execute([$session]);
        $rows = $stmt->fetchAll();

        // Normalise types
        foreach ($rows as &$row) {
            $row['task_id']  = (int)  $row['task_id'];
            $row['solved']   = (bool) $row['solved'];
            $row['attempts'] = (int)  $row['attempts'];
        }
        unset($row);

        jsonOut(['data' => $rows]);
    }

    // ════════════════════════════════════════
    // POST progress  (upsert)
    // ════════════════════════════════════════
    if ($method === 'POST' && $resource === 'progress') {
        $session = trim($body['session'] ?? '');
        $taskId  = filter_var($body['task_id'] ?? null, FILTER_VALIDATE_INT);
        $solved  = isset($body['solved']) ? (bool) $body['solved'] : false;
        $userSql = mb_substr((string)($body['user_sql'] ?? ''), 0, 8000);

        if (!isValidUuid($session))    jsonError('Invalid session token.');
        if ($taskId === false || $taskId < 1) jsonError('Invalid task_id.');

        // Verify task exists
        $check = $pdo->prepare('SELECT id FROM sql_tasks WHERE id = ? AND active = 1');
        $check->execute([$taskId]);
        if (!$check->fetch()) jsonError('Task not found.', 404);

        // Upsert
        $pdo->prepare(
            'INSERT INTO sql_progress (session_token, task_id, solved, user_sql, attempts, solved_at)
             VALUES (?, ?, ?, ?, 1, ?)
             ON DUPLICATE KEY UPDATE
               solved    = IF(VALUES(solved) = 1, 1, solved),
               user_sql  = VALUES(user_sql),
               attempts  = attempts + 1,
               solved_at = IF(VALUES(solved) = 1 AND solved_at IS NULL, NOW(), solved_at)'
        )->execute([
            $session,
            $taskId,
            $solved ? 1 : 0,
            $userSql ?: null,
            $solved ? date('Y-m-d H:i:s') : null,
        ]);

        // Return fresh row
        $fetch = $pdo->prepare(
            'SELECT task_id, solved, user_sql, attempts, solved_at
             FROM   sql_progress
             WHERE  session_token = ? AND task_id = ?'
        );
        $fetch->execute([$session, $taskId]);
        $row = $fetch->fetch();
        $row['task_id']  = (int)  $row['task_id'];
        $row['solved']   = (bool) $row['solved'];
        $row['attempts'] = (int)  $row['attempts'];

        jsonOut(['data' => $row]);
    }

    // ── Fallthrough ───────────────────────────────────────────
    jsonError('Unknown resource or method.', 404);

} catch (PDOException $e) {
    // Don't leak DB details in production
    error_log('[sql-extra/api.php] DB error: ' . $e->getMessage());
    jsonError('Database error. Please try again later.', 500);
} catch (Throwable $e) {
    error_log('[sql-extra/api.php] Error: ' . $e->getMessage());
    jsonError('Unexpected error.', 500);
}
