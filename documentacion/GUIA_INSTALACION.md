# Guía de Instalación de Apache Superset con Docker Compose (Windows)

## Requisitos

- Docker Desktop instalado (https://www.docker.com/products/docker-desktop/)
- Docker Desktop abierto y corriendo (ícono verde)
- SQL Server Management Studio (SSMS)
- Acceso al servidor SQL productivo

---

## Paso 1: Crear la carpeta del proyecto

```bash
mkdir C:\superset
cd C:\superset
```

---

## Paso 2: Crear los archivos de configuración

### Archivo 1: superset_config.py

```python
SECRET_KEY = "MiClaveSecretaSuperSegura2024xyz"

FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True,  # Habilita Jinja en queries
    "EMBEDDED_SUPERSET": True,
}

HTTP_HEADERS = {"X-Frame-Options": "ALLOWALL"}
TALISMAN_ENABLED = False
WTF_CSRF_ENABLED = False
OVERRIDE_HTTP_HEADERS = {"X-Frame-Options": "ALLOWALL"}

# BABEL_DEFAULT_LOCALE = "es"  # Descomentar para español

# Cache (1 hora, sincronizado con el job de actualización)
CACHE_CONFIG = {
    'CACHE_TYPE': 'RedisCache',
    'CACHE_DEFAULT_TIMEOUT': 3600,
    'CACHE_KEY_PREFIX': 'superset_',
    'CACHE_REDIS_URL': 'redis://redis:6379/0'
}

DATA_CACHE_CONFIG = {
    'CACHE_TYPE': 'RedisCache',
    'CACHE_DEFAULT_TIMEOUT': 3600,
    'CACHE_KEY_PREFIX': 'superset_data_',
    'CACHE_REDIS_URL': 'redis://redis:6379/0'
}
```

### Archivo 2: Dockerfile

```dockerfile
FROM apache/superset:latest

USER root
RUN apt-get update && apt-get install -y python3-pip && \
    pip install pymssql && \
    cp -r /usr/local/lib/python3.10/site-packages/pymssql /app/.venv/lib/python3.10/site-packages/ && \
    cp -r /usr/local/lib/python3.10/site-packages/pymssql.libs /app/.venv/lib/python3.10/site-packages/ && \
    cp -r /usr/local/lib/python3.10/site-packages/pymssql-2.3.13.dist-info /app/.venv/lib/python3.10/site-packages/
USER superset
```

### Archivo 3: docker-compose.yml

```yaml
version: "3.8"

services:
  redis:
    image: redis:7
    restart: unless-stopped

  db:
    image: postgres:15
    restart: unless-stopped
    environment:
      POSTGRES_USER: superset
      POSTGRES_PASSWORD: superset
      POSTGRES_DB: superset
    volumes:
      - db_data:/var/lib/postgresql/data

  sqlserver:
    image: mcr.microsoft.com/mssql/server:2019-latest
    restart: unless-stopped
    ports:
      - "1434:1433"
    environment:
      SA_PASSWORD: "AmecoSQL2024!"
      ACCEPT_EULA: "Y"
      MSSQL_PID: "Developer"
      MSSQL_AGENT_ENABLED: "true"
    volumes:
      - sqlserver_data:/var/opt/mssql

  superset:
    build: .
    image: superset-local
    restart: unless-stopped
    ports:
      - "8088:8088"
    environment:
      DATABASE_URL: postgresql+psycopg2://superset:superset@db/superset
      REDIS_URL: redis://redis:6379/0
      SUPERSET_SECRET_KEY: MiClaveSecretaSuperSegura2024xyz
    volumes:
      - ./superset_config.py:/app/pythonpath/superset_config.py
    depends_on:
      - redis
      - db
      - sqlserver

volumes:
  db_data:
  sqlserver_data:
```

---

## Paso 3: Construir y levantar los servicios

```bash
cd C:\superset
docker compose up -d --build
```

Esperar unos minutos a que descargue todo y construya la imagen.

---

## Paso 4: Crear la base de datos y el usuario admin

Ejecutar los 3 comandos uno por uno esperando que cada uno termine:

```bash
docker compose exec superset superset db upgrade
```

```bash
docker compose exec superset superset fab create-admin --username admin --firstname Admin --lastname Admin --email admin@admin.com --password admin
```

```bash
docker compose exec superset superset init
```

---

## Paso 5: Configurar SQL Server Docker

Conectarse desde SSMS a `localhost,1434` con usuario `sa` y password `AmecoSQL2024!`

```sql
-- Crear la base de datos
CREATE DATABASE AmecoHubIntegracion;

-- Habilitar consultas distribuidas
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
```

---

## Paso 6: Crear Linked Server al servidor productivo

Desde SSMS conectado a `localhost,1434`:

```sql
EXEC sp_addlinkedserver
    @server = 'AMECO_DEV',
    @srvproduct = '',
    @provider = 'SQLNCLI',
    @datasrc = '54.244.218.18'

EXEC sp_addlinkedsrvlogin
    @rmtsrvname = 'AMECO_DEV',
    @useself = 'FALSE',
    @rmtuser = 'sa',
    @rmtpassword = 'TuPasswordAqui'
```

Verificar que funciona:
```sql
SELECT * FROM OPENQUERY(AMECO_DEV, 'SELECT @@SERVERNAME')
```

---

## Paso 7: Crear el Job de actualización (cada 1 hora)

En SSMS conectado a `localhost,1434`:

1. Expandir **Agente SQL Server → Jobs**
2. Click derecho → **Nuevo Job**
3. **General** → Nombre: `Actualizar AmecoDashboards`
4. **Pasos** → **Nuevo paso**:
   - Nombre: `TRUNCATE e INSERT`
   - Base de datos: `AmecoHubIntegracion`
   - Comando: pegar el script de `job_actualizacion.sql`
5. **Programaciones** → **Nueva**:
   - Tipo: Periódica
   - Frecuencia: Diaria
   - Frecuencia diaria: Cada 1 hora
   - Hora inicio: `00:00:00` / Hora fin: `23:59:59`

---

## Paso 8: Conectar Superset al SQL Server Docker

1. Abrir Superset en http://localhost:8088
   - Usuario: `admin` / Contraseña: `admin`
2. **Settings → Database Connections → + Database**
3. Seleccionar **Microsoft SQL Server**
4. En SQLAlchemy URI pegar:

```
mssql+pymssql://sa:AmecoSQL2024!@sqlserver:1433/AmecoHubIntegracion
```

> Usar `sqlserver:1433` (nombre del servicio Docker), NO `localhost:1434`

5. Click en **Test Connection** → **Connect**

---

## Paso 9: Crear el Dataset en Superset

1. **Data → Datasets → + Dataset**
2. Seleccionar la conexión de SQL Server
3. Seleccionar la tabla `AmecoDashboards`
4. Click en **Add**

---

## Agregar o eliminar columnas del dataset

**Agregar columna nueva:**
```sql
-- En SSMS (localhost,1434)
ALTER TABLE AmecoHubIntegracion.dbo.AmecoDashboards
ADD NuevaColumna VARCHAR(100)
```
Luego en Superset → Dataset → **Sync columns from source**

**Eliminar columna o cambio estructural:**
```sql
DROP TABLE IF EXISTS AmecoHubIntegracion.dbo.AmecoDashboards
```
Ejecutar el job manualmente y reimportar el dataset en Superset.

---

## Ver historial del Job

```sql
SELECT
    j.name                          AS JobNombre,
    h.run_date                      AS FechaEjecucion,
    h.run_time                      AS HoraEjecucion,
    CASE h.run_status
        WHEN 0 THEN 'Falló'
        WHEN 1 THEN 'Exitoso'
        WHEN 3 THEN 'Cancelado'
    END                             AS Estado,
    h.message                       AS MensajeError
FROM msdb.dbo.sysjobs j
INNER JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
WHERE j.name = 'Actualizar AmecoDashboards'
ORDER BY h.run_date DESC, h.run_time DESC
```

---

## Comandos útiles

| Comando | Qué hace |
|---------|----------|
| `docker compose up -d` | Levantar los servicios |
| `docker compose down` | Detener los servicios |
| `docker compose restart superset` | Reiniciar solo Superset |
| `docker compose logs superset --tail=50` | Ver los últimos 50 logs |
| `docker compose up -d --build` | Reconstruir y levantar |
| `docker compose build --no-cache superset` | Reconstruir sin caché |
| `docker stats` | Ver uso de recursos en tiempo real |

---

## Notas importantes

- Los datos de dashboards y gráficos se guardan en PostgreSQL (volumen `db_data`), no se pierden al reiniciar.
- Si reconstruís la imagen con `--build`, debés volver a ejecutar los comandos del Paso 4.
- Para evitar perder el admin al reconstruir, no uses `--build` a menos que cambies el Dockerfile.
- La `SECRET_KEY` puede ser cualquier texto largo. Si la cambiás, las sesiones se cierran pero no se pierde data.
- El caché de 3600 segundos está sincronizado con el job que corre cada 1 hora.
- Superset se conecta al SQL Server Docker usando `sqlserver:1433` (red interna Docker), no `localhost:1434`.

---

## Arquitectura

```
SQL Server productivo (54.244.218.18)
    ↑ Linked Server (AMECO_DEV)
SQL Server Docker (sqlserver:1433)
    → Job cada 1 hora: TRUNCATE + INSERT
    → Tabla: AmecoHubIntegracion.dbo.AmecoDashboards
        ↑ misma red Docker (instantáneo)
Apache Superset (localhost:8088)
```

---

## Migración a Azure (pendiente)

Cuando se migre a Azure, los cambios principales serán:

| Local | Azure |
|---|---|
| SQL Server Docker | Azure SQL Database |
| Superset Docker local | Azure Container Apps |
| Job SQL Agent | Azure Data Factory |
| `localhost:8088` | URL pública de Azure |