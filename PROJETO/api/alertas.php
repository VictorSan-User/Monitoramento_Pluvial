<?php
declare(strict_types=1);

require_once __DIR__ . '/common.php';

try {
    $alertas = fetch_all($pdo, "
        SELECT
            id_bueiro,
            codigo_patrimonial,
            bairro,
            obstrucao_percentual,
            indice_pluviometrico_mm,
            vazao_litros_segundo,
            ultima_coleta,
            status_operacional
        FROM vw_leitura_atual_bueiro
        WHERE status_operacional COLLATE utf8mb4_unicode_ci = 'Critico' COLLATE utf8mb4_unicode_ci
        ORDER BY obstrucao_percentual DESC, indice_pluviometrico_mm DESC
    ");

    json_response(['alertas' => $alertas, 'total' => count($alertas)]);
} catch (Throwable $e) {
    json_response(['erro' => 'Falha ao carregar alertas.', 'detalhe' => $e->getMessage()], 500);
}
