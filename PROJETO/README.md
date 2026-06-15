# Monitoramento Pluvial Urbano

Sistema para monitorar bueiros urbanos com leituras de obstrucao, indice pluviometrico e vazao.

## Estrutura

- `database/db.sql`: DDL MySQL normalizado, dados iniciais e views analiticas.
- `docs/modelagem_banco.md`: DER, dicionario de dados, normalizacao e algebra relacional.
- `api/`: endpoints PHP que retornam JSON.
- `ingestao_simulada.py`: simulador de ingestao continua.
- `views/`: dashboard, lista de sensores, alertas e relatorios.
- `js/`: consumo da API e renderizacao dos graficos/tabelas.

## Banco de Dados

Execute o script em um servidor MySQL/MariaDB:

```sql
SOURCE C:/Users/Matheus/Desktop/to n/Monitoramento_Pluvial/PROJETO/database/db.sql;
```

Ou importe `database/db.sql` pelo phpMyAdmin.

Configure a conexao no arquivo `.env`:

```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=BUEIROS_URBANOS_CARATINGA
DB_USER=root
DB_PASSWORD=''
```

O PHP carrega esse arquivo automaticamente antes de chamar `getenv()`. O simulador Python tambem le o mesmo `.env`.

## Ingestao Simulada

```powershell
cd "C:\Users\Matheus\Desktop\to n\Monitoramento_Pluvial\PROJETO"
python -m pip install -r requirements.txt
python ingestao_simulada.py --intervalo 10
```

Para inserir apenas dois lotes de teste:

```powershell
python ingestao_simulada.py --lotes 2 --intervalo 1
```

## API e Dashboard

Inicie o servidor PHP local:

```powershell
cd "C:\Users\Matheus\Desktop\to n\Monitoramento_Pluvial\PROJETO"
php -S localhost:8000
```

Acesse:

- Dashboard: `http://localhost:8000/views/index.html`
- Sensores: `http://localhost:8000/views/listaSensores.html`
- Alertas: `http://localhost:8000/views/alerts.html`
- Relatorios: `http://localhost:8000/views/relatorios.html`

Endpoints:

- `GET /api/dashboard.php`
- `GET /api/sensores.php`
- `GET /api/sensores.php?q=Centro`
- `GET /api/alertas.php`
