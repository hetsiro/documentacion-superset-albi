import os

SECRET_KEY = "MiClaveSecretaSuperSegura2024xyz"

# Metadata DB — Postgres del compose (servicio `db`), persiste en el volumen db_data.
# Sin esto Superset cae a una SQLite efimera que se pierde al recrear el contenedor.
SQLALCHEMY_DATABASE_URI = os.environ.get(
    "DATABASE_URL", "postgresql+psycopg2://superset:superset@db/superset"
)

FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True,
    "EMBEDDED_SUPERSET": True,
}

# Guest Token para embebido seguro
GUEST_ROLE_NAME = "Public"
GUEST_TOKEN_JWT_SECRET = "MiClaveGuestToken2024xyz"
GUEST_TOKEN_JWT_ALGO = "HS256"
GUEST_TOKEN_HEADER_NAME = "X-GuestToken"
GUEST_TOKEN_JWT_EXP_SECONDS = 3600  # 1 hora

HTTP_HEADERS = {"X-Frame-Options": "ALLOWALL"}

TALISMAN_ENABLED = False
WTF_CSRF_ENABLED = False

OVERRIDE_HTTP_HEADERS = {"X-Frame-Options": "ALLOWALL"}

BABEL_DEFAULT_LOCALE = "es"

# Idiomas disponibles en el selector de la UI
LANGUAGES = {
    "es": {"flag": "es", "name": "Español"},
    "en": {"flag": "us", "name": "English"},
}

# Formato numérico con coma decimal (estilo español/latinoamérica)
D3_FORMAT = {
    "decimal":   ",",
    "thousands": ".",
    "grouping":  [3],
    "currency":  ["$", ""],
}

THEME_OVERRIDE = {"algorithm": "light"}

# Paleta semáforo para gauges (rojo / amarillo / verde por % de uso)
EXTRA_CATEGORICAL_COLOR_SCHEMES = [
    {
        "id": "semaforo",
        "label": "Semaforo",
        "isDefault": False,
        "colors": ["#DC3545", "#FFC107", "#28A745"],
    }
]

# Cache en memoria (SimpleCache) — no requiere servicios externos
CACHE_CONFIG = {
    'CACHE_TYPE': 'SimpleCache',
    'CACHE_DEFAULT_TIMEOUT': 3600,
    'CACHE_KEY_PREFIX': 'superset_',
}

DATA_CACHE_CONFIG = {
    'CACHE_TYPE': 'SimpleCache',
    'CACHE_DEFAULT_TIMEOUT': 3600,
    'CACHE_KEY_PREFIX': 'superset_data_',
}