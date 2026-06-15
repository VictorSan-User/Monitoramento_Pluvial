import argparse
import os
import random
import time
from datetime import datetime
from pathlib import Path

try:
    import mysql.connector
except ImportError as exc:
    raise SystemExit(
        "Instale a dependencia antes de executar: python -m pip install mysql-connector-python"
    ) from exc


def carregar_env():
    env_path = Path(__file__).with_name(".env")
    if not env_path.is_file():
        return

    for raw_line in env_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue

        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip().strip("\"'"))


carregar_env()


DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "database": os.getenv("DB_NAME", "BUEIROS_URBANOS_CARATINGA"),
    "user": os.getenv("DB_USER", "matheus"),
    "password": os.getenv("DB_PASSWORD", "matheus"),
}

TIPOS = {
    "OBSTRUCAO": {"min": 20.0, "max": 96.0},
    "PLUVIOMETRICO": {"min": 0.0, "max": 55.0},
    "VAZAO": {"min": 60.0, "max": 340.0},
}


def conectar():
    return mysql.connector.connect(**DB_CONFIG)


def carregar_referencias(conn):
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id_bueiro FROM bueiro WHERE ativo = TRUE ORDER BY id_bueiro")
    bueiros = [row["id_bueiro"] for row in cursor.fetchall()]

    cursor.execute("SELECT id_tipo_sensor, codigo FROM tipo_sensor ORDER BY id_tipo_sensor")
    tipos = {row["codigo"]: row["id_tipo_sensor"] for row in cursor.fetchall()}
    cursor.close()

    if not bueiros:
        raise RuntimeError("Nenhum bueiro ativo encontrado. Execute database/db.sql primeiro.")

    faltantes = sorted(set(TIPOS) - set(tipos))
    if faltantes:
        raise RuntimeError(f"Tipos de sensor ausentes no banco: {', '.join(faltantes)}")

    return bueiros, tipos


def gerar_valor(codigo_tipo):
    faixa = TIPOS[codigo_tipo]
    valor = random.uniform(faixa["min"], faixa["max"])

    if codigo_tipo == "OBSTRUCAO" and random.random() < 0.18:
        valor = random.uniform(80.0, 100.0)

    if codigo_tipo == "PLUVIOMETRICO" and random.random() < 0.20:
        valor = random.uniform(35.0, 70.0)

    return round(valor, 2)


def inserir_lote(conn, bueiros, tipos):
    cursor = conn.cursor()
    registros = []
    agora = datetime.now()

    for id_bueiro in bueiros:
        for codigo, id_tipo_sensor in tipos.items():
            registros.append((id_bueiro, id_tipo_sensor, gerar_valor(codigo), agora))

    cursor.executemany(
        """
        INSERT INTO leitura_sensor (id_bueiro, id_tipo_sensor, valor, coletado_em)
        VALUES (%s, %s, %s, %s)
        """,
        registros,
    )
    conn.commit()
    cursor.close()
    return len(registros)


def main():
    parser = argparse.ArgumentParser(description="Simula ingestao continua de leituras dos bueiros.")
    parser.add_argument("--intervalo", type=float, default=10.0, help="Segundos entre lotes.")
    parser.add_argument("--lotes", type=int, default=0, help="Quantidade de lotes. Use 0 para rodar continuamente.")
    args = parser.parse_args()

    conn = conectar()
    try:
        bueiros, tipos = carregar_referencias(conn)
        lote = 0

        while args.lotes == 0 or lote < args.lotes:
            total = inserir_lote(conn, bueiros, tipos)
            lote += 1
            print(f"[{datetime.now():%Y-%m-%d %H:%M:%S}] lote {lote}: {total} leituras inseridas")

            if args.lotes and lote >= args.lotes:
                break

            time.sleep(args.intervalo)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
