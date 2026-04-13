SECRET_KEY = "kg0iGT1eCnnfAh24WoMNVJPPAy8CT9uG1sJcyPwsk0JC42S7YNyV01ID"

FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True,
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

# Tema claro global
THEME_OVERRIDE = {"algorithm": "light"}

GUEST_ROLE_NAME = "Admin"
GUEST_TOKEN_JWT_SECRET = "D4_ukNX9kBgso0cyGycd0PcpPXtTg4wZH3Evx3mPw8H-6oXcFS64pqVJ"
GUEST_TOKEN_JWT_EXP_SECONDS = 3600
