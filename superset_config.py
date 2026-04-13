SECRET_KEY = "MiClaveSecretaSuperSegura2024xyz"

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

BABEL_DEFAULT_LOCALE = "en"

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

# Cache
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