<?php
declare(strict_types=1);

require_once __DIR__ . '/common.php';

try {
    $resumo = fetch_one($pdo, "
        SELECT
            COUNT(*) AS total_bueiros,
            SUM(CASE WHEN status_operacional COLLATE utf8mb4_unicode_ci = 'Critico' COLLATE utf8mb4_unicode_ci THEN 1 ELSE 0 END) AS bueiros_criticos,
            ROUND(AVG(indice_pluviometrico_mm), 2) AS pluviometrico_medio,
            ROUND(AVG(vazao_litros_segundo), 2) AS vazao_media,
            ROUND(AVG(obstrucao_percentual), 2) AS obstrucao_media
        FROM vw_leitura_atual_bueiro
    ");

    $porBairro = fetch_all($pdo, "
        SELECT
            bairro,
            COUNT(*) AS total_bueiros,
            SUM(CASE WHEN status_operacional COLLATE utf8mb4_unicode_ci = 'Critico' COLLATE utf8mb4_unicode_ci THEN 1 ELSE 0 END) AS bueiros_criticos,
            ROUND(AVG(obstrucao_percentual), 2) AS media_obstrucao_percentual,
            ROUND(AVG(indice_pluviometrico_mm), 2) AS media_pluviometrica_mm,
            ROUND(AVG(vazao_litros_segundo), 2) AS media_vazao_litros_segundo
        FROM vw_leitura_atual_bueiro
        GROUP BY bairro
        ORDER BY bairro
    ");

    $serieTemporal = fetch_all($pdo, "
        SELECT
            DATE_FORMAT(ls.coletado_em, '%Y-%m-%d %H:%i') AS janela,
            DATE_FORMAT(MIN(ls.coletado_em), '%H:%i') AS horario,
            ROUND(AVG(CASE WHEN ts.codigo COLLATE utf8mb4_unicode_ci = 'PLUVIOMETRICO' COLLATE utf8mb4_unicode_ci THEN ls.valor END), 2) AS chuva,
            ROUND(AVG(CASE WHEN ts.codigo COLLATE utf8mb4_unicode_ci = 'VAZAO' COLLATE utf8mb4_unicode_ci THEN ls.valor END), 2) AS vazao
        FROM leitura_sensor ls
        JOIN tipo_sensor ts ON ts.id_tipo_sensor = ls.id_tipo_sensor
        WHERE ls.coletado_em >= NOW() - INTERVAL 12 HOUR
          AND ts.codigo COLLATE utf8mb4_unicode_ci IN ('PLUVIOMETRICO' COLLATE utf8mb4_unicode_ci, 'VAZAO' COLLATE utf8mb4_unicode_ci)
        GROUP BY DATE_FORMAT(ls.coletado_em, '%Y-%m-%d %H:%i')
        ORDER BY MIN(ls.coletado_em)
        LIMIT 60
    ");

    json_response([
        'resumo' => [
            'total_bueiros' => (int)($resumo['total_bueiros'] ?? 0),
            'bueiros_criticos' => (int)($resumo['bueiros_criticos'] ?? 0),
            'pluviometrico_medio' => (float)($resumo['pluviometrico_medio'] ?? 0),
            'vazao_media' => (float)($resumo['vazao_media'] ?? 0),
            'obstrucao_media' => (float)($resumo['obstrucao_media'] ?? 0),
        ],
        'por_bairro' => $porBairro,
        'serie_temporal' => $serieTemporal,
    ]);
} catch (Throwable $e) {
    json_response(['erro' => 'Falha ao carregar dashboard.', 'detalhe' => $e->getMessage()], 500);
}
