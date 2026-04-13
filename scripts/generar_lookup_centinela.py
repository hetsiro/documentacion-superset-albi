"""
generar_lookup.py
-----------------
Consulta CentinelaDashboards y genera lookup_data_centinela.js
con los valores de cada campo de catálogo (ID + nombre).

NO necesitás Python instalado en Windows.
Usá el archivo generar_lookup.bat que hace todo automáticamente:

    generar_lookup_centinela.bat

El script detecta automáticamente si corre dentro o fuera de Docker.
El archivo JSON es cargado por diccionario.html al abrir la página.
"""

import json
import os
import sys
from datetime import datetime

# ── Conexión directa a PROD ───────────────────────────────────────────────────
HOST     = "52.41.60.163"
PORT     = 1433
USER     = "cfuentealba"
PASSWORD = ""  # Se pide por consola si está vacío

# BD de datasets (HubIntegracion) — para contar usos
DB_DATASETS = "HubIntegracion"
DS_SCHEMA   = "albi"
DS_TABLE    = "CentinelaDashboards"

# BD de catálogos (Albi) — para traer todos los valores
DB_CATALOG  = "Albi"
CAT_SCHEMA  = "albi"

# Ruta de salida
OUT_PATH = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "..", "docs", "lookup_data_centinela.js"
)

LOOKUPS = [
    ("Estado OT",             "EstadoOrdenTrabajoId",       "EstadoOrdenTrabajo",         "estadoOt",              "id", "nombre"),
    ("Tipo Tarea",            "TipoTareaId",                "TipoTarea",                  "tipoTarea",             "id", "nombre"),
    ("Sub Tipo Tarea",        "SubTipoTareaId",             "SubTipoTarea",               "subtipoTarea",          "id", "nombre"),
    ("Nivel 3",               "Nivel3Id",                   "Nivel3",                     "nivel3",                "id", "nombre"),
    ("Nivel 4",               "Nivel4Id",                   "Nivel4",                     "nivel4",                "id", "nombre"),
    ("Tipo Operacion",        "TipoOperacionId",            "TipoOperacion",              "tipoOperacion",         "id", "nombre"),
    ("Especialidad",          "EspecialidadId",              "Especialidad",               "especialidad",          "id", "nombre"),
    ("Estado Operacion",      "EstadoOperacionId",           "EstadoOperacion",            "estadoOperacion",       "id", "nombre"),
    ("Grupo Resolutor",       "GrupoResolutorOperacionId",   "GrupoResolutorOperacion",    "grupoResolutor",        "id", "nombre"),
    ("Sitio",                 "SitioOperacionId",            "SitioOperacion",             "sitio",                 "id", "nombre"),
    ("Zona",                  "ZonaOperacionId",             "ZonaOperacion",              "zona",                  "id", "nombre"),
    ("Prioridad",             "PrioridadOperacionId",        "PrioridadOperacion",         "prioridad",             "id", "nombre"),
    ("Proceso",               "ProcesoId",                   "Proceso",                    "proceso",               "id", "nombre"),
    ("Recinto",               "RecintoId",                   "Recinto",                    "recinto",               "id", "nombre"),
    ("Perfil Resolutor",      "ResolutorPerfilId",            "ResolutorPerfil",            "perfil",                "id", "nombre"),
    ("Plan",                  "OrdenTrabajoPlanId",           "OrdenTrabajoPlan",           None,                    None, None),
]

# Catálogos de Asistencia — se consultan desde CentinelaAsistencia (DISTINCT)
LOOKUPS_ASISTENCIA = [
    ("Asistencia Tipo",       "AsistenciaTipo",              "AsistenciaTipo"),
    ("Asistencia Estado",     "AsistenciaEstado",            "AsistenciaEstado"),
]
TABLA_ASISTENCIA = "albi.CentinelaAsistencia"

def main():
    try:
        import pymssql
    except ImportError:
        print("❌  pymssql no instalado. Ejecutá: pip install pymssql")
        sys.exit(1)

    pwd = PASSWORD
    if not pwd:
        import getpass
        pwd = getpass.getpass(f"Contraseña para {USER}@{HOST}: ")

    # Conexion a BD de catalogos (Albi)
    print(f"Conectando a {HOST}:{PORT} / {DB_CATALOG} (catalogos)...")
    try:
        conn_cat = pymssql.connect(
            server=HOST, port=PORT,
            user=USER, password=pwd,
            database=DB_CATALOG, charset="UTF-8"
        )
    except Exception as e:
        print(f"  No se pudo conectar a {DB_CATALOG}: {e}")
        sys.exit(1)

    # Conexion a BD de datasets (HubIntegracion)
    print(f"Conectando a {HOST}:{PORT} / {DB_DATASETS} (datasets)...")
    try:
        conn_ds = pymssql.connect(
            server=HOST, port=PORT,
            user=USER, password=pwd,
            database=DB_DATASETS, charset="UTF-8"
        )
    except Exception as e:
        print(f"  No se pudo conectar a {DB_DATASETS}: {e}")
        conn_cat.close()
        sys.exit(1)

    cur_cat = conn_cat.cursor()
    cur_ds = conn_ds.cursor()
    result = {}
    total_valores = 0

    for label, col_id, col_valor, tabla_cat, col_id_cat, col_valor_cat in LOOKUPS:
        try:
            if tabla_cat is not None:
                # Consultar tabla de catalogo en BD Albi
                query = f"""
                    SELECT {col_id_cat}, {col_valor_cat}
                    FROM {CAT_SCHEMA}.{tabla_cat}
                    ORDER BY {col_valor_cat}
                """
                cur_cat.execute(query)
                rows = cur_cat.fetchall()
                source = f"{DB_CATALOG}.{CAT_SCHEMA}.{tabla_cat}"
            else:
                # Fallback: DISTINCT desde CentinelaDashboards en HubIntegracion
                query = f"""
                    SELECT DISTINCT {col_id}, {col_valor}
                    FROM {DS_SCHEMA}.{DS_TABLE}
                    WHERE {col_id} IS NOT NULL AND {col_valor} IS NOT NULL
                    ORDER BY {col_valor}
                """
                cur_ds.execute(query)
                rows = cur_ds.fetchall()
                source = f"{DS_TABLE} (DISTINCT)"

            # Calcular usos por valor desde CentinelaDashboards
            usos_por_valor = {}
            try:
                usos_query = f"""
                    SELECT {col_id}, COUNT(*) AS usos
                    FROM {DS_SCHEMA}.{DS_TABLE}
                    WHERE {col_id} IS NOT NULL
                    GROUP BY {col_id}
                """
                cur_ds.execute(usos_query)
                for r in cur_ds.fetchall():
                    usos_por_valor[r[0]] = r[1]
            except Exception:
                pass

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

    # ── Catálogos de Asistencia (DISTINCT desde CentinelaAsistencia) ──────────
    print("\n  Catalogos de Asistencia...")
    for label, col_valor, col_valor_alias in LOOKUPS_ASISTENCIA:
        try:
            query = f"""
                SELECT DISTINCT {col_valor} AS id, {col_valor} AS valor
                FROM {TABLA_ASISTENCIA}
                WHERE {col_valor} IS NOT NULL
                ORDER BY {col_valor}
            """
            cur_ds.execute(query)
            rows = cur_ds.fetchall()

            usos_por_valor = {}
            try:
                usos_query = f"""
                    SELECT {col_valor}, COUNT(*) AS usos
                    FROM {TABLA_ASISTENCIA}
                    WHERE {col_valor} IS NOT NULL
                    GROUP BY {col_valor}
                """
                cur_ds.execute(usos_query)
                for r in cur_ds.fetchall():
                    usos_por_valor[r[0]] = r[1]
            except Exception:
                pass

            result[label] = {
                "idCol":    col_valor,
                "valorCol": col_valor,
                "valores":  [{"id": str(r[0]), "valor": str(r[1]), "usos": usos_por_valor.get(r[0], 0)} for r in rows]
            }
            count = len(rows)
            total_valores += count
            print(f"  {label:<25} {count:>4} valores  <- {TABLA_ASISTENCIA}")
        except Exception as e:
            print(f"  {label:<25} error: {e}")
            result[label] = {"idCol": col_valor, "valorCol": col_valor, "valores": [], "error": str(e)}

    # ── Usos: COUNT(col) por cada columna de CentinelaDashboards ──────────────
    print("\n  Calculando usos por columna...")
    usos = {}
    total_ots = 0
    total_operaciones = 0
    try:
        cur_ds.execute(f"""
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = '{DS_SCHEMA}' AND TABLE_NAME = '{DS_TABLE}'
            ORDER BY ORDINAL_POSITION
        """)
        columnas = [row[0] for row in cur_ds.fetchall()]

        BLOQUE = 50
        for i in range(0, len(columnas), BLOQUE):
            bloque_cols = columnas[i:i+BLOQUE]
            partes = [f"COUNT([{c}]) AS [{c}]" for c in bloque_cols]
            q = f"SELECT {', '.join(partes)} FROM {DS_SCHEMA}.{DS_TABLE}"
            cur_ds.execute(q)
            row = cur_ds.fetchone()
            if row:
                for j, col in enumerate(bloque_cols):
                    usos[col] = row[j]

        print(f"  Usos calculados para {len(usos)} columnas (CentinelaDashboards)")

        cur_ds.execute(f"""
            SELECT
                COUNT(DISTINCT OrdenTrabajoId) AS total_ots,
                COUNT(DISTINCT OperacionId)    AS total_operaciones
            FROM {DS_SCHEMA}.{DS_TABLE}
        """)
        row = cur_ds.fetchone()
        if row:
            total_ots, total_operaciones = row[0], row[1]
            print(f"  Total OTs: {total_ots:,}  |  Total Operaciones: {total_operaciones:,}")
    except Exception as e:
        print(f"  Error calculando usos (Dashboards): {e}")

    # ── Usos: COUNT(col) por cada columna de CentinelaAsistencia ─────────────
    total_asistencias = 0
    try:
        cur_ds.execute(f"""
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = '{DS_SCHEMA}' AND TABLE_NAME = 'CentinelaAsistencia'
            ORDER BY ORDINAL_POSITION
        """)
        columnas_asist = [row[0] for row in cur_ds.fetchall()]

        BLOQUE = 50
        for i in range(0, len(columnas_asist), BLOQUE):
            bloque_cols = columnas_asist[i:i+BLOQUE]
            partes = [f"COUNT([{c}]) AS [{c}]" for c in bloque_cols]
            q = f"SELECT {{', '.join(partes)}} FROM {TABLA_ASISTENCIA}"
            cur_ds.execute(f"SELECT {', '.join(partes)} FROM {TABLA_ASISTENCIA}")
            row = cur_ds.fetchone()
            if row:
                for j, col in enumerate(bloque_cols):
                    usos[col] = row[j]

        print(f"  Usos calculados para {len(columnas_asist)} columnas (CentinelaAsistencia)")

        cur_ds.execute(f"""
            SELECT COUNT(*) FROM {TABLA_ASISTENCIA}
        """)
        row = cur_ds.fetchone()
        if row:
            total_asistencias = row[0]
            print(f"  Total Asistencias: {total_asistencias:,}")
    except Exception as e:
        print(f"  Error calculando usos (Asistencia): {e}")

    conn_cat.close()
    conn_ds.close()

    output = {
        "_meta": {
            "generado": datetime.now().isoformat(timespec="seconds"),
            "tabla":    f"{DB_DATASETS}.{DS_SCHEMA}.{DS_TABLE}",
            "total_valores": total_valores,
            "catalogos": len(result),
            "total_ots": total_ots,
            "total_operaciones": total_operaciones,
            "total_asistencias": total_asistencias,
            "usos": usos,
        },
        "catalogos": result
    }

    # Generar como .js con window.LOOKUP_DATA para que funcione con file:// sin servidor HTTP
    js_content = "window.LOOKUP_DATA = " + json.dumps(output, ensure_ascii=False, indent=2) + ";\n"
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        f.write(js_content)

    print(f"\n  Generado: {OUT_PATH}")
    print(f"   {len(result)} catalogos  ·  {total_valores} valores en total")
    print(f"   Abri diccionario_centinela.html y recarga la pagina para ver los datos.")

if __name__ == "__main__":
    main()
