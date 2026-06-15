<?php
require_once __DIR__ . '/env.php';

load_env(__DIR__ . '/../.env');

$host = getenv('DB_HOST') ?: 'localhost';
$port = getenv('DB_PORT') ?: '3306';
$dbname = getenv('DB_NAME') ?: 'BUEIROS_URBANOS_CARATINGA';
$usuario = getenv('DB_USER') ?: 'matheus';
$password = getenv('DB_PASSWORD') ?: 'matheus';

try {
    $dsn = "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4";
    $pdo = new PDO($dsn, $usuario, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'erro' => 'Erro de conexao ao banco de dados.',
        'detalhe' => $e->getMessage(),
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
