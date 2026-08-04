/* ============================================================
   Regenera docs/referencia/calculos-charts.html desde Superset.

   Uso:  node scripts/calculos_fetch.js
   o bien: doble clic en scripts/Actualizar-calculos-charts.bat

   NO necesita dashboards exportados: lee las definiciones de los
   charts en vivo desde la API de Superset.

   Pasos:
     1. login en la API
     2. baja los charts de los 4 dashboards -> calculos_data/dash_*.json
     3. los resume (calculos_extract.js)    -> calculos_data/summary.json
     4. genera el HTML (calculos_render.js) -> docs/referencia/calculos-charts.html

   Las descripciones en prosa de cada chart están en calculos_render.js
   (constantes DESC / DESC_OVR / NOTA). Si agregas un chart nuevo,
   agrega ahí su texto y vuelve a correr esto.
   ============================================================ */
const fs = require('fs');
const path = require('path');

const URL_BASE = process.env.SUPERSET_URL || 'https://reporting.boe-hub.com';
const USER = process.env.SUPERSET_USER || 'api_service';
const PASS = process.env.SUPERSET_PASS || 'Boe_2026';

// id del dashboard en Superset -> nombre de la sección en el documento
const DASHBOARDS = [
  [37, 'centinela_gestion'],
  [38, 'centinela_operacionales'],
  [23, 'ameco_gestion'],
  [24, 'ameco_operacionales']
];

const DATA_DIR = path.join(__dirname, 'calculos_data');

async function main() {
  fs.mkdirSync(DATA_DIR, { recursive: true });

  console.log(`[1/4] Login en ${URL_BASE}`);
  const loginRes = await fetch(`${URL_BASE}/api/v1/security/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username: USER, password: PASS, provider: 'db', refresh: false })
  });
  if (!loginRes.ok) throw new Error(`login HTTP ${loginRes.status}`);
  const { access_token: token } = await loginRes.json();
  if (!token) throw new Error('la API no devolvió access_token');

  console.log('[2/4] Descargando charts');
  for (const [id, name] of DASHBOARDS) {
    const res = await fetch(`${URL_BASE}/api/v1/dashboard/${id}/charts`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    if (!res.ok) throw new Error(`dashboard ${id}: HTTP ${res.status}`);
    const body = await res.text();
    fs.writeFileSync(path.join(DATA_DIR, `dash_${name}.json`), body);
    const n = (body.match(/"slice_name"/g) || []).length;
    console.log(`      ${name}: ${n} charts`);
  }

  console.log('[3/4] Resumiendo definiciones');
  require('./calculos_extract.js');

  console.log('[4/4] Generando página');
  require('./calculos_render.js');
}

main().catch(err => {
  console.error('\nERROR:', err.message);
  process.exit(1);
});
