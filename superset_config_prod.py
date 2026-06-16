import os

SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY", "kg0iGT1eCnnfAh24WoMNVJPPAy8CT9uG1sJcyPwsk0JC42S7YNyV01ID")

# Base de datos de metadata — PostgreSQL Azure (persiste entre reinicios)
SQLALCHEMY_DATABASE_URI = "postgresql+psycopg2://supersetadmin:Boe.,2026@superset-pg-6021.postgres.database.azure.com:5432/superset"

FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True,
    "ENABLE_TEMPLATE_PROCESSING": True,
}

TALISMAN_ENABLED = False
CONTENT_SECURITY_POLICY_WARNING = False

# Cuando migres a HTTPS, reactivar Talisman con:
# TALISMAN_ENABLED = True
# TALISMAN_CONFIG = {
#     "content_security_policy": {
#         "frame-ancestors": [
#             "'self'",
#             "https://centinela.albibot.cl",
#             "https://dev.albibot.cl",
#             "http://localhost:4200",
#         ]
#     },
#     "force_https": False,
# }

# Permitir iframes
HTTP_HEADERS = {"X-Frame-Options": "ALLOWALL"}

# Cookies de sesión sin requerir HTTPS
SESSION_COOKIE_SECURE = False
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = "Lax"

WTF_CSRF_ENABLED = False

# Dashboard público — permite iframe directo sin login
PUBLIC_ROLE_LIKE = "Gamma"
AUTH_ROLE_PUBLIC = "Public"

# Tema claro global
THEME_OVERRIDE = {"algorithm": "light"}

GUEST_ROLE_NAME = "Admin"
GUEST_TOKEN_JWT_SECRET = "D4_ukNX9kBgso0cyGycd0PcpPXtTg4wZH3Evx3mPw8H-6oXcFS64pqVJ"
GUEST_TOKEN_JWT_EXP_SECONDS = 3600
