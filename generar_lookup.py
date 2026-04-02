"""
generar_lookup.py
-----------------
Consulta AmecoDashboards y genera lookup_data.json
con los valores de cada campo de catálogo (ID + nombre).

NO necesitás Python instalado en Windows.
Usá el archivo generar_lookup.bat que hace todo automáticamente:

    generar_lookup.bat     ← doble click o ejecutar en CMD desde C:\superset

El script detecta automáticamente si corre dentro o fuera de Docker.
El archivo JSON es cargado por diccionario.html al abrir la página.
"""

import json
import os
import sys
from datetime import datetime

# ── Conexión — se adapta automáticamente a Docker o a Windows host ────────────
IN_DOCKER = os.path.exists("/.dockerenv")

HOST     = "sqlserver" if IN_DOCKER else "localhost"
PORT     = 1433         if IN_DOCKER else 1434
USER     = "sa"
PASSWORD = "AmecoSQL2024!"
DATABASE = "AmecoHubIntegracion"

# Ruta de salida: genera un .js (no .json) para que funcione con file:// sin servidor
# Dentro de Docker escribe en /tmp, el .bat lo copia al host
OUT_PATH = "/tmp/lookup_data.js" if IN_DOCKER else os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "documentacion", "lookup_data.js"
)

# ── Catálogos a extraer ───────────────────────────────────────────────────────
# (etiqueta, col_id en AmecoDashboards, col_valor en AmecoDashboards, tabla_catalogo, col_id_cat, col_valor_cat)
# tabla_catalogo = tabla real en AMECO_DEV para traer TODOS los valores (incluso sin datos)
# Si tabla_catalogo es None, se usa el método anterior (DISTINCT desde AmecoDashboards)
LINKED = "AMECO_DEV.Ameco.albi"  # Prefijo del linked server

LOOKUPS = [
    ("Estado OT",             "EstadoOrdenTrabajoId",       "EstadoOrdenTrabajo",         "estadoOt",              "id", "nombre"),
    ("Tipo Tarea",            "TipoTareaId",                "TipoTarea",                  "tipoTarea",             "id", "nombre"),
    ("Sub Tipo Tarea",        "SubTipoTareaId",             "SubTipoTarea",               "subtipoTarea",          "id", "nombre"),
    ("Nivel 3",               "Nivel3Id",                   "Nivel3",                     "nivel3",                "id", "nombre"),
    ("Nivel 4",               "Nivel4Id",                   "Nivel4",                     "nivel4",                "id", "nombre"),
    ("Tipo Operación",        "TipoOperacionId",            "TipoOperacion",              "tipoOperacion",         "id", "nombre"),
    ("Especialidad",          "EspecialidadId",              "Especialidad",               "especialidad",          "id", "nombre"),
    ("Estado Operación",      "EstadoOperacionId",           "EstadoOperacion",            "estadoOperacion",       "id", "nombre"),
    ("Motivo Detención",      "MotivoDetencionId",           "MotivoDetencion",            "motivo",                "id", "valor"),
    ("Motivo No Ejecución",   "MotivoNoEjecucionId",         "MotivoNoEjecucion",          "motivo",                "id", "valor"),
    ("Grupo Resolutor",       "GrupoResolutorOperacionId",   "GrupoResolutorOperacion",    "grupoResolutor",        "id", "nombre"),
    ("Sitio",                 "SitioOperacionId",            "SitioOperacion",             "sitio",                 "id", "nombre"),
    ("Zona",                  "ZonaOperacionId",             "ZonaOperacion",              "zona",                  "id", "nombre"),
    ("Prioridad",             "PrioridadOperacionId",        "PrioridadOperacion",         "prioridad",             "id", "nombre"),
    ("Proceso",               "ProcesoId",                   "Proceso",                    "proceso",               "id", "nombre"),
    ("Plan",                  "OrdenTrabajoPlanId",          "OrdenTrabajoPlanNombre",     "plan",                  "id", "nombre"),
    ("Estado Instalación",    "EstadoInstalacionId",         "EstadoInstalacion",          "estadoInstalacion",     "id", "nombre"),
    ("Recinto",               "RecintoId",                   "Recinto",                    "recinto",               "id", "nombre"),
    ("Motivo Detención Tipo", "MotivoDetencionId",           "MotivoDetencionTipo",        None,                    None, None),  # sin tabla catalogo directa
    ("Tipo Actividad",        "TipoActividadId",             "TipoActividad",              "tipoActividad",         "id", "nombreReal"),
]

def main():
    try:
        import pymssql
    except ImportError:
        print("❌  pymssql no instalado. Ejecutá: pip install pymssql")
        sys.exit(1)

    modo = "Docker (sqlserver:1433)" if IN_DOCKER else f"Windows host ({HOST},{PORT})"
    print(f"Modo: {modo}")
    print(f"Conectando a {HOST},{PORT} / {DATABASE}...")
    try:
        conn = pymssql.connect(
            server=HOST, port=PORT,
            user=USER, password=PASSWORD,
            database=DATABASE, charset="UTF-8"
        )
    except Exception as e:
        print(f"❌  No se pudo conectar: {e}")
        print("    Verificá que los contenedores Docker estén corriendo (docker compose up -d)")
        sys.exit(1)

    cursor = conn.cursor()
    result = {}
    total_valores = 0

    for label, col_id, col_valor, tabla_cat, col_id_cat, col_valor_cat in LOOKUPS:
        try:
            if tabla_cat is not None:
                # Consultar tabla de catálogo real (todos los valores, incluso sin datos)
                query = f"""
                    SELECT {col_id_cat}, {col_valor_cat}
                    FROM {LINKED}.{tabla_cat}
                    ORDER BY {col_valor_cat}
                """
                source = f"{LINKED}.{tabla_cat}"
            else:
                # Fallback: DISTINCT desde AmecoDashboards
                query = f"""
                    SELECT DISTINCT {col_id}, {col_valor}
                    FROM dbo.AmecoDashboards
                    WHERE {col_id} IS NOT NULL AND {col_valor} IS NOT NULL
                    ORDER BY {col_valor}
                """
                source = "AmecoDashboards (DISTINCT)"

            cursor.execute(query)
            rows = cursor.fetchall()

            # Calcular usos por valor desde AmecoDashboards
            usos_por_valor = {}
            try:
                usos_query = f"""
                    SELECT {col_id}, COUNT(*) AS usos
                    FROM dbo.AmecoDashboards
                    WHERE {col_id} IS NOT NULL
                    GROUP BY {col_id}
                """
                cursor.execute(usos_query)
                for r in cursor.fetchall():
                    usos_por_valor[r[0]] = r[1]
            except Exception:
                pass  # si falla, usos queda vacío

            result[label] = {
                "idCol":    col_id,
                "valorCol": col_valor,
                "valores":  [{"id": r[0], "valor": str(r[1]), "usos": usos_por_valor.get(r[0], 0)} for r in rows]
            }
            count = len(rows)
            total_valores += count
            con_datos = sum(1 for r in rows if usos_por_valor.get(r[0], 0) > 0)
            print(f"  ✔  {label:<25} {count:>4} valores ({con_datos} con datos)  ← {source}")
        except Exception as e:
            print(f"  ⚠  {label:<25} error: {e}")
            result[label] = {"idCol": col_id, "valorCol": col_valor, "valores": [], "error": str(e)}

    # ── Usos: COUNT(col) por cada columna de AmecoDashboards ─────────────────
    print("\n  Calculando usos por columna...")
    usos = {}
    total_ots = 0
    total_operaciones = 0
    try:
        # Obtener nombres de columnas desde INFORMATION_SCHEMA
        cursor.execute("""
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'AmecoDashboards'
            ORDER BY ORDINAL_POSITION
        """)
        columnas = [row[0] for row in cursor.fetchall()]

        # Construir SELECT con COUNT(col) para cada columna en bloques de 50
        # para evitar queries demasiado largas
        BLOQUE = 50
        for i in range(0, len(columnas), BLOQUE):
            bloque_cols = columnas[i:i+BLOQUE]
            partes = [f"COUNT([{c}]) AS [{c}]" for c in bloque_cols]
            q = f"SELECT {', '.join(partes)} FROM dbo.AmecoDashboards"
            cursor.execute(q)
            row = cursor.fetchone()
            if row:
                for j, col in enumerate(bloque_cols):
                    usos[col] = row[j]

        print(f"  ✔  Usos calculados para {len(usos)} columnas")

        # Totales OT y Operaciones
        cursor.execute("""
            SELECT
                COUNT(DISTINCT OrdenTrabajoId) AS total_ots,
                COUNT(DISTINCT OperacionId)    AS total_operaciones
            FROM dbo.AmecoDashboards
        """)
        row = cursor.fetchone()
        if row:
            total_ots, total_operaciones = row[0], row[1]
            print(f"  ✔  Total OTs: {total_ots:,}  |  Total Operaciones: {total_operaciones:,}")
    except Exception as e:
        print(f"  ⚠  Error calculando usos: {e}")

    conn.close()

    output = {
        "_meta": {
            "generado": datetime.now().isoformat(timespec="seconds"),
            "tabla":    f"{DATABASE}.dbo.AmecoDashboards",
            "total_valores": total_valores,
            "catalogos": len(result),
            "total_ots": total_ots,
            "total_operaciones": total_operaciones,
            "usos": usos,
        },
        "catalogos": result
    }

    # Generar como .js con window.LOOKUP_DATA para que funcione con file:// sin servidor HTTP
    js_content = "window.LOOKUP_DATA = " + json.dumps(output, ensure_ascii=False, indent=2) + ";\n"
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        f.write(js_content)

    print(f"\n✅  Generado: {OUT_PATH}")
    print(f"   {len(result)} catálogos  ·  {total_valores} valores en total")
    if IN_DOCKER:
        print(f"   El .bat copiará el archivo a documentacion\\lookup_data.js automáticamente.")
    else:
        print(f"   Abrí diccionario.html y recargá la página para ver los datos.")

if __name__ == "__main__":
    main()
