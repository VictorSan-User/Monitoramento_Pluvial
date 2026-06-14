create DATABASE BUEIROS_URBANOS_CARATINGA;

use BUEIROS_URBANOS_CARATINGA;

CREATE TABLE BUEIRO (
    id_bueiro INT AUTO_INCREMENT PRIMARY KEY,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    bairro VARCHAR(100) NOT NULL
);
-- Sensor Sedmentos e lixos
CREATE TABLE SENS_SED_LIXOS (
    id_sens_sed_lix INT AUTO_INCREMENT PRIMARY KEY,
    id_bueiro INT NOT NULL,
    
    valor_capturado DECIMAL(5, 2) NOT NULL CHECK (valor_capturado BETWEEN 0.00 AND 100.00),
    
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_bueiro) REFERENCES BUEIRO(id_bueiro) ON DELETE CASCADE
);
-- Sensor Pluviométrico
CREATE TABLE SENS_IND_PLUV (
    id_indice_pluv INT AUTO_INCREMENT PRIMARY KEY,
    id_bueiro INT NOT NULL,
    valor_capturado DECIMAL(5, 2) NOT NULL CHECK (valor_capturado >= 0.00),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_bueiro) REFERENCES BUEIRO(id_bueiro) ON DELETE CASCADE
);

-- Sensor Vazão Galerias
CREATE TABLE SENS_VASAO_GAL (
    id_volume_vas INT AUTO_INCREMENT PRIMARY KEY,
    id_bueiro INT NOT NULL,
    valor_capturado DECIMAL(7, 2) NOT NULL CHECK (valor_capturado >= 0.00),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_bueiro) REFERENCES BUEIRO(id_bueiro) ON DELETE CASCADE
);
