CREATE DATABASE IF NOT EXISTS BUEIROS_URBANOS_CARATINGA
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE BUEIROS_URBANOS_CARATINGA;

DROP VIEW IF EXISTS vw_alertas_criticos;
DROP VIEW IF EXISTS vw_metricas_por_bairro;
DROP VIEW IF EXISTS vw_leitura_atual_bueiro;

DROP TABLE IF EXISTS leitura_sensor;
DROP TABLE IF EXISTS bueiro;
DROP TABLE IF EXISTS tipo_sensor;
DROP TABLE IF EXISTS bairro;

CREATE TABLE bairro (
    id_bairro SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    zona VARCHAR(40) NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_bairro_nome UNIQUE (nome)
) ENGINE=InnoDB;

CREATE TABLE bueiro (
    id_bueiro INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_bairro SMALLINT UNSIGNED NOT NULL,
    codigo_patrimonial VARCHAR(30) NOT NULL,
    latitude DECIMAL(9, 6) NOT NULL,
    longitude DECIMAL(9, 6) NOT NULL,
    logradouro VARCHAR(140) NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    instalado_em DATE NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_bueiro_codigo UNIQUE (codigo_patrimonial),
    CONSTRAINT ck_bueiro_latitude CHECK (latitude BETWEEN -90.000000 AND 90.000000),
    CONSTRAINT ck_bueiro_longitude CHECK (longitude BETWEEN -180.000000 AND 180.000000),
    CONSTRAINT fk_bueiro_bairro
        FOREIGN KEY (id_bairro) REFERENCES bairro(id_bairro)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tipo_sensor (
    id_tipo_sensor TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL,
    nome VARCHAR(80) NOT NULL,
    unidade VARCHAR(12) NOT NULL,
    valor_minimo DECIMAL(8, 2) NOT NULL DEFAULT 0.00,
    valor_maximo DECIMAL(8, 2) NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_tipo_sensor_codigo UNIQUE (codigo),
    CONSTRAINT ck_tipo_sensor_faixa CHECK (valor_maximo IS NULL OR valor_maximo >= valor_minimo)
) ENGINE=InnoDB;

CREATE TABLE leitura_sensor (
    id_leitura BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_bueiro INT UNSIGNED NOT NULL,
    id_tipo_sensor TINYINT UNSIGNED NOT NULL,
    valor DECIMAL(8, 2) NOT NULL,
    coletado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    recebido_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_leitura_bueiro
        FOREIGN KEY (id_bueiro) REFERENCES bueiro(id_bueiro)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_leitura_tipo_sensor
        FOREIGN KEY (id_tipo_sensor) REFERENCES tipo_sensor(id_tipo_sensor)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT ck_leitura_valor CHECK (valor >= 0.00),
    INDEX ix_leitura_bueiro_tipo_tempo (id_bueiro, id_tipo_sensor, coletado_em DESC),
    INDEX ix_leitura_tipo_tempo (id_tipo_sensor, coletado_em DESC),
    INDEX ix_leitura_tempo (coletado_em DESC)
) ENGINE=InnoDB;

INSERT INTO bairro (nome, zona) VALUES
    ('Centro', 'Central'),
    ('Santa Cruz', 'Norte'),
    ('Santa Zita', 'Leste'),
    ('Dario Grossi', 'Oeste'),
    ('Limoeiro', 'Sul'),
    ('Aparecida', 'Norte');

INSERT INTO tipo_sensor (codigo, nome, unidade, valor_minimo, valor_maximo) VALUES
    ('OBSTRUCAO', 'Percentual de obstrucao', '%', 0.00, 100.00),
    ('PLUVIOMETRICO', 'Indice pluviometrico', 'mm', 0.00, NULL),
    ('VAZAO', 'Volume de vazao', 'L/s', 0.00, NULL);

INSERT INTO bueiro (id_bairro, codigo_patrimonial, latitude, longitude, logradouro, instalado_em) VALUES
    (1, 'BUE-CEN-001', -19.789120, -42.139820, 'Rua Coronel Pedro Martins', '2025-03-10'),
    (1, 'BUE-CEN-002', -19.790410, -42.137940, 'Avenida Catarina Cimini', '2025-03-10'),
    (2, 'BUE-SCR-001', -19.783250, -42.146300, 'Rua Santa Cruz', '2025-04-02'),
    (3, 'BUE-STZ-001', -19.795600, -42.133210, 'Rua Santa Zita', '2025-04-15'),
    (4, 'BUE-DGR-001', -19.801020, -42.151010, 'Avenida Dario Grossi', '2025-05-07'),
    (5, 'BUE-LIM-001', -19.807820, -42.143700, 'Rua do Limoeiro', '2025-05-22'),
    (6, 'BUE-APA-001', -19.779440, -42.140930, 'Rua Aparecida', '2025-06-01');

INSERT INTO leitura_sensor (id_bueiro, id_tipo_sensor, valor, coletado_em) VALUES
    (1, 1, 86.50, NOW(3) - INTERVAL 6 MINUTE), (1, 2, 38.40, NOW(3) - INTERVAL 6 MINUTE), (1, 3, 244.80, NOW(3) - INTERVAL 6 MINUTE),
    (2, 1, 72.10, NOW(3) - INTERVAL 5 MINUTE), (2, 2, 35.20, NOW(3) - INTERVAL 5 MINUTE), (2, 3, 218.10, NOW(3) - INTERVAL 5 MINUTE),
    (3, 1, 91.80, NOW(3) - INTERVAL 4 MINUTE), (3, 2, 42.00, NOW(3) - INTERVAL 4 MINUTE), (3, 3, 301.60, NOW(3) - INTERVAL 4 MINUTE),
    (4, 1, 64.30, NOW(3) - INTERVAL 3 MINUTE), (4, 2, 31.70, NOW(3) - INTERVAL 3 MINUTE), (4, 3, 179.40, NOW(3) - INTERVAL 3 MINUTE),
    (5, 1, 48.00, NOW(3) - INTERVAL 2 MINUTE), (5, 2, 22.30, NOW(3) - INTERVAL 2 MINUTE), (5, 3, 132.90, NOW(3) - INTERVAL 2 MINUTE),
    (6, 1, 55.40, NOW(3) - INTERVAL 1 MINUTE), (6, 2, 25.60, NOW(3) - INTERVAL 1 MINUTE), (6, 3, 158.20, NOW(3) - INTERVAL 1 MINUTE),
    (7, 1, 82.20, NOW(3)), (7, 2, 29.10, NOW(3)), (7, 3, 205.50, NOW(3));

CREATE OR REPLACE VIEW vw_leitura_atual_bueiro AS
SELECT
    b.id_bueiro,
    b.codigo_patrimonial,
    ba.nome AS bairro,
    b.latitude,
    b.longitude,
    MAX(CASE WHEN ts.codigo = 'OBSTRUCAO' THEN ls.valor END) AS obstrucao_percentual,
    MAX(CASE WHEN ts.codigo = 'PLUVIOMETRICO' THEN ls.valor END) AS indice_pluviometrico_mm,
    MAX(CASE WHEN ts.codigo = 'VAZAO' THEN ls.valor END) AS vazao_litros_segundo,
    MAX(ls.coletado_em) AS ultima_coleta,
    CASE
        WHEN MAX(CASE WHEN ts.codigo = 'OBSTRUCAO' THEN ls.valor END) >= 80.00
          OR (
              MAX(CASE WHEN ts.codigo = 'PLUVIOMETRICO' THEN ls.valor END) >= 35.00
              AND MAX(CASE WHEN ts.codigo = 'VAZAO' THEN ls.valor END) >= 240.00
          ) THEN 'Critico'
        WHEN MAX(CASE WHEN ts.codigo = 'OBSTRUCAO' THEN ls.valor END) >= 60.00
          OR MAX(CASE WHEN ts.codigo = 'PLUVIOMETRICO' THEN ls.valor END) >= 25.00 THEN 'Atencao'
        ELSE 'Normal'
    END AS status_operacional
FROM bueiro b
JOIN bairro ba ON ba.id_bairro = b.id_bairro
LEFT JOIN (
    SELECT l1.*
    FROM leitura_sensor l1
    JOIN (
        SELECT id_bueiro, id_tipo_sensor, MAX(coletado_em) AS ultima_coleta
        FROM leitura_sensor
        GROUP BY id_bueiro, id_tipo_sensor
    ) ult
        ON ult.id_bueiro = l1.id_bueiro
       AND ult.id_tipo_sensor = l1.id_tipo_sensor
       AND ult.ultima_coleta = l1.coletado_em
) ls ON ls.id_bueiro = b.id_bueiro
LEFT JOIN tipo_sensor ts ON ts.id_tipo_sensor = ls.id_tipo_sensor
WHERE b.ativo = TRUE
GROUP BY b.id_bueiro, b.codigo_patrimonial, ba.nome, b.latitude, b.longitude;

CREATE OR REPLACE VIEW vw_metricas_por_bairro AS
SELECT
    bairro,
    COUNT(*) AS total_bueiros,
    SUM(CASE WHEN status_operacional COLLATE utf8mb4_unicode_ci = 'Critico' COLLATE utf8mb4_unicode_ci THEN 1 ELSE 0 END) AS bueiros_criticos,
    ROUND(AVG(obstrucao_percentual), 2) AS media_obstrucao_percentual,
    ROUND(AVG(indice_pluviometrico_mm), 2) AS media_pluviometrica_mm,
    ROUND(AVG(vazao_litros_segundo), 2) AS media_vazao_litros_segundo
FROM vw_leitura_atual_bueiro
GROUP BY bairro;

CREATE OR REPLACE VIEW vw_alertas_criticos AS
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
WHERE status_operacional COLLATE utf8mb4_unicode_ci = 'Critico' COLLATE utf8mb4_unicode_ci;
