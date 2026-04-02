# Superset Local con SQL Server

Guia paso a paso para instalar Apache Superset en Docker con soporte para Microsoft SQL Server.

---

## Requisitos previos

1. **Docker Desktop** instalado y corriendo
   - Descarga: https://www.docker.com/products/docker-desktop/
   - Despues de instalar, **reiniciar la PC**
   - Abrir Docker Desktop y esperar a que diga "Docker is running" (icono verde)

---

## Estructura de archivos

Crear una carpeta `C:\superset` con estos 3 archivos:

```
C:\superset\
  ├── Dockerfile
  ├── docker-compose.yml
  └── superset_config.py
```

---

## Archivo 1: Dockerfile

Este archivo define la imagen de Superset con el driver de SQL Server (pymssql).

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

**Que hace cada linea:**
- `FROM apache/superset:latest` — Usa la imagen oficial de Superset como base
- `USER root` — Cambia a usuario root para poder instalar paquetes
- `apt-get install python3-pip` — Instala pip (gestor de paquetes de Python)
- `pip install pymssql` — Instala el driver de SQL Server
- `cp -r ...` — Copia pymssql al virtual environment de Superset (porque pip lo instala en otra ruta)
- `USER superset` — Vuelve al usuario normal por seguridad

---

## Archivo 2: docker-compose.yml

Este archivo define los 3 servicios necesarios: Superset, PostgreSQL (base de datos interna) y Redis (cache).

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

volumes:
  db_data:
```

**Que hace cada servicio:**
- `redis` — Cache para hacer Superset mas rapido
- `db` — PostgreSQL donde Superset guarda sus datos internos (usuarios, dashboards, configuracion)
- `superset` — La aplicacion web de Superset

**Variables de entorno importantes:**
- `DATABASE_URL` — Conexion a PostgreSQL (base de datos INTERNA de Superset, NO tu SQL Server)
- `REDIS_URL` — Conexion a Redis
- `SUPERSET_SECRET_KEY` — Clave secreta para encriptar sesiones (puedes cambiarla por cualquier texto largo)

**Nota:** La linea `version: "3.8"` puede dar una advertencia. Es cosmetic y no afecta nada.

---

## Archivo 3: superset_config.py

Configuracion personalizada de Superset.

```python
SECRET_KEY = "MiClaveSecretaSuperSegura2024xyz"

FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True,
    "EMBEDDED_SUPERSET": True,
}

HTTP_HEADERS = {"X-Frame-Options": "ALLOWALL"}

TALISMAN_ENABLED = False
WTF_CSRF_ENABLED = False

OVERRIDE_HTTP_HEADERS = {"X-Frame-Options": "ALLOWALL"}

# BABEL_DEFAULT_LOCALE = "es"  # Descomentar para activar español

THEME_OVERRIDE = {"algorithm": "light"}
```

**Que hace cada configuracion:**
- `SECRET_KEY` — Clave secreta (debe ser igual a la del docker-compose.yml)
- `ENABLE_TEMPLATE_PROCESSING` — Habilita plantillas Jinja en las consultas SQL (ej: `{{ from_dttm }}`)
- `EMBEDDED_SUPERSET` — Permite embeber dashboards en otras aplicaciones
- `HTTP_HEADERS / OVERRIDE_HTTP_HEADERS` — Permite que Superset se muestre dentro de un iframe
- `TALISMAN_ENABLED = False` — Desactiva proteccion HTTPS (solo para desarrollo local)
- `WTF_CSRF_ENABLED = False` — Desactiva proteccion CSRF (solo para desarrollo local)
- `BABEL_DEFAULT_LOCALE` — Idioma de la interfaz (descomentar para español)
- `THEME_OVERRIDE` — Fuerza el tema claro (fondo blanco)

**IMPORTANTE:** `TALISMAN_ENABLED = False` y `WTF_CSRF_ENABLED = False` son solo para desarrollo local. En produccion (Azure) hay que configurarlos correctamente.

---

## Pasos de instalacion

### Paso 1: Crear la carpeta y archivos

```bash
mkdir C:\superset
```

Crear los 3 archivos dentro de `C:\superset` con el contenido de arriba.

### Paso 2: Construir y levantar los contenedores

Abrir CMD o PowerShell y ejecutar:

```bash
cd C:\superset
docker compose up -d --build
```

Esto descarga las imagenes, construye el Superset con pymssql, y levanta los 3 servicios.
La primera vez tarda varios minutos.

### Paso 3: Inicializar la base de datos

Esperar ~30 segundos despues del paso 2 y ejecutar:

```bash
docker compose exec superset superset db upgrade
```

Este comando tarda 1-2 minutos. Esperar a que termine.

### Paso 4: Crear el usuario administrador

```bash
docker compose exec superset superset fab create-admin --username admin --firstname Admin --lastname Admin --email admin@admin.com --password admin
```

### Paso 5: Inicializar Superset

```bash
docker compose exec superset superset init
```

### Paso 6: Abrir Superset

Abrir en el navegador: **http://localhost:8088**

- Usuario: `admin`
- Contraseña: `admin`

---

## Conectar SQL Server

1. En Superset: **Settings** > **Database Connections** > **+ Database**
2. Seleccionar **Other**
3. En SQLAlchemy URI pegar:

```
mssql+pymssql://usuario:contraseña@servidor:puerto/basededatos
```

Ejemplo:
```
mssql+pymssql://sa:MiPassword@54.244.218.18:1433/AmecoHubIntegracion
```

4. Click en **Test Connection** para verificar
5. Click en **Connect**

---

## Importar un dashboard exportado

Si tienes un archivo `.zip` exportado desde otro Superset:

1. **IMPORTANTE:** Primero crea la conexion a la base de datos manualmente (paso anterior) con el **mismo nombre** que tenia en el Superset original (ej: `DEV-CENTINELA`)
2. Ve a **Dashboards** > icono de importar (flecha hacia arriba)
3. Selecciona el archivo `.zip`
4. En el campo de password, pon la **contraseña de SQL Server** (la del usuario `sa`), NO la de Superset
5. Click en **Import**

---

## Embeber dashboard en otra aplicacion

### Opcion 1: iframe (simple)

En tu HTML/Angular/React:

```html
<iframe
  src="http://localhost:8088/superset/dashboard/1/?standalone=2"
  width="100%"
  style="border: none; height: 100vh;">
</iframe>
```

**Parametros de standalone:**
- `standalone=1` — Oculta la barra de navegacion
- `standalone=2` — Oculta el titulo (muestra filtros)
- `standalone=3` — Oculta navegacion + titulo

**Nota:** El usuario debe estar logueado en Superset en el mismo navegador.

### Opcion 2: Embedded SDK (avanzado, sin login)

1. Instalar el paquete:
```bash
npm install @superset-ui/embedded-sdk
```

2. Habilitar embedding en el dashboard: click en **...** > **Embed dashboard** > agregar dominio permitido > **Enable embedding**

3. Copiar el UUID del dashboard

4. Usar en el frontend:
```typescript
import { embedDashboard } from '@superset-ui/embedded-sdk';

embedDashboard({
  id: 'uuid-del-dashboard',
  supersetDomain: 'http://localhost:8088',
  mountPoint: document.getElementById('superset-container'),
  fetchGuestToken: () => fetchGuestTokenFromBackend(),
  dashboardUiConfig: {
    hideTitle: true,
    hideChartControls: true,
    filters: { visible: true }
  }
});
```

---

## Comandos utiles

| Comando | Que hace |
|---------|----------|
| `docker compose up -d` | Levantar todos los servicios |
| `docker compose down` | Detener todos los servicios |
| `docker compose restart superset` | Reiniciar solo Superset |
| `docker compose logs superset --tail=50` | Ver los ultimos 50 logs |
| `docker compose up -d --build` | Reconstruir imagen y levantar |
| `docker compose build --no-cache superset` | Reconstruir sin cache |
| `docker compose exec superset superset db upgrade` | Actualizar base de datos interna |
| `docker compose exec superset superset init` | Inicializar permisos y roles |

---

## Verificar que pymssql esta instalado

```bash
docker compose exec superset python -c "import pymssql; print(pymssql.__version__)"
```

Debe mostrar: `2.3.13`

---

## Solucion de problemas

### "Refusing to start due to insecure SECRET_KEY"
La SECRET_KEY no esta configurada. Verificar que `superset_config.py` tiene la clave y que esta montado correctamente en docker-compose.yml.

### "ModuleNotFoundError: No module named 'pymssql'"
El driver no se instalo correctamente. Reconstruir: `docker compose build --no-cache superset` y luego `docker compose up -d`.

### "Internal server error" al abrir Superset
Se perdio el usuario admin. Ejecutar los pasos 3, 4 y 5 de nuevo.

### "DB engine Error 'username'"
La conexion de la base de datos tiene credenciales genericas. Ir a Settings > Database Connections, editar la conexion y poner la URI con usuario y contraseña reales.

### "Refused to display in a frame because X-Frame-Options"
La configuracion de TALISMAN o HTTP_HEADERS no se aplico. Verificar que `superset_config.py` tiene `TALISMAN_ENABLED = False` y reiniciar: `docker compose restart superset`.

### Pantalla negra al abrir Superset
Probar en modo incognito o en otro navegador. Limpiar cache del navegador.

---

## Para produccion (Azure)

Este setup es para **desarrollo local**. Para produccion:

1. Cambiar `SECRET_KEY` por una clave segura y aleatoria
2. Activar `TALISMAN_ENABLED = True` con configuracion de HTTPS
3. Activar `WTF_CSRF_ENABLED = True`
4. Cambiar contraseñas de PostgreSQL
5. Configurar HTTPS/SSL
6. Usar el Embedded SDK con Guest Token en vez de iframe simple
