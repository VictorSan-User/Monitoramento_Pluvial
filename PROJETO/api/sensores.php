<?php
declare(strict_types=1);

require_once __DIR__ . '/common.php';

try {
    $busca = trim((string)($_GET['q'] ?? ''));
    $params = [];
    $where = '';

    if ($busca !== '') {
        $where = "WHERE codigo_patrimonial LIKE :codigo_patrimonial OR bairro LIKE :busca OR CAST(id_bueiro AS CHAR) = :id_busca";
        $params = [
            ':codigo_patrimonial' =>'%' . $busca . '%',
            ':busca' => '%' . $busca . '%',
            ':id_busca' => ctype_digit($busca) ? $busca : '-1',
        ];
    }

    $sensores = fetch_all($pdo, "
        SELECT
            id_bueiro,
            codigo_patrimonial,
            bairro,
            latitude,
            longitude,
            obstrucao_percentual,
            indice_pluviometrico_mm,
            vazao_litros_segundo,
            ultima_coleta,
            status_operacional
        FROM vw_leitura_atual_bueiro
        $where
        ORDER BY
            CASE status_operacional COLLATE utf8mb4_unicode_ci
                WHEN 'Critico' COLLATE utf8mb4_unicode_ci THEN 1
                WHEN 'Atencao' COLLATE utf8mb4_unicode_ci THEN 2
                ELSE 3
            END,
            bairro,
            id_bueiro
    ", $params);

    json_response(['sensores' => $sensores]);
} catch (Throwable $e) {
    json_response(['erro' => 'Falha ao listar sensores.', 'detalhe' => $e->getMessage()], 500);
}
