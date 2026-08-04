// Genera docs/referencia/calculos-charts.html desde summary.json
const fs = require('fs');
const path = require('path');
const S = JSON.parse(fs.readFileSync(path.join(__dirname, 'calculos_data', 'summary.json'), 'utf8'));

const VIZ = {
  big_number_total: 'Big number', table: 'Tabla', gauge_chart: 'Gauge',
  echarts_timeseries_bar: 'Barras', echarts_timeseries_line: 'Línea',
  pie: 'Torta', echarts_area: 'Área'
};

// [clave, título de la sección, intro, cliente (grupo del menú), nombre corto en el menú]
const SECTIONS = [
  ['centinela_gestion', '3. Centinela — Indicadores de Gestión',
   'Los tiempos replican los SP de AlbiWeb: declarados por <code>OrdenTrabajoFechaFinReal</code> con OT Resuelta/Cerrada (= <code>dashboard01KPI01v2</code>); esfuerzo estándar por fecha programada (= <code>dashboard01v3.kpi00</code>).',
   'Centinela', 'Indicadores de Gestión'],
  ['centinela_operacionales', '4. Centinela — Indicadores Operacionales',
   'Conteos de OTs/operaciones por fecha programada (<code>OrdenTrabajoFechaInicio</code>) y asistencia del día.',
   'Centinela', 'Indicadores Operacionales'],
  ['ameco_gestion', '5. Ameco — Indicadores de Gestión',
   'A diferencia de Centinela, Ameco filtra por <code>OrdenTrabajoFechaCreacion</code> (alineado a AmecoWeb, que trabaja por fecha de creación).',
   'Ameco', 'Indicadores de Gestión'],
  ['ameco_operacionales', '6. Ameco — Indicadores Operacionales',
   'Conteos por <code>OrdenTrabajoFechaCreacion</code> y asistencia del día.',
   'Ameco', 'Indicadores Operacionales']
];

// ── Descripción breve por chart (clave: nombre sin prefijo de cliente) ──
const DESC = {
  'Administrativo': 'Horas-hombre administrativas declaradas de OTs terminadas: minutos × involucrados ÷ 60.',
  'Administrativo Declarado': 'Horas-hombre administrativas declaradas de OTs terminadas: minutos × involucrados ÷ 60.',
  'Capacidad Instalada (hs)': 'Horas disponibles del período: ResolutoresActivos × JornadaLaboralHoras × días del rango. Los dos valores viven en ConfiguracionDashboard (editables desde la web).',
  'Esfuerzo Declarado': 'Horas-hombre de ejecución declaradas por los técnicos en OTs terminadas: minutos × involucrados ÷ 60.',
  'Esfuerzo Estándar': null, // por cliente (ver overrides)
  'Esfuerzo Industria': 'Horas-hombre según la duración “de industria” del catálogo de la OT (catalogo.duracionIndustria × involucrados).',
  'Espera Declarado': 'Horas-hombre de espera declaradas en OTs terminadas: minutos × involucrados ÷ 60.',
  'Perdido Declarado': 'Horas de tiempo perdido declarado en OTs terminadas. Modelo nuevo: el valor ya viene sumado por todo el equipo, por eso NO se multiplica por involucrados.',
  'Traslado Declarado': 'Horas-hombre de traslado declaradas en OTs terminadas: minutos × involucrados ÷ 60.',
  'Total Declarado (hs)': 'Suma de los 4 tiempos declarados (ejecución + espera + traslado + administrativo) × involucrados ÷ 60, en OTs terminadas.',
  'Gauge Cumplimiento SLA': null, // por cliente
  'Gauge Tasa Finalización OT': '% de OTs del período que quedaron Resueltas o Cerradas.',
  'Gauge Tasa Finalización Operaciones': '% de operaciones del período en estado Resuelta.',
  'Gauge Uso de Jornada': 'Tiempo declarado total ÷ (resolutores-día con actividad × 720 min) × 100. Indicador heurístico: asume jornadas de 12 h y no usa la Capacidad Instalada.',
  'Motivos de tiempo perdido': 'Horas perdidas por resolutor y motivo, desde la vista v_TiempoPerdidoPorResolutor (unifica modelo nuevo por técnico y modelo antiguo replicado a los involucrados; cuadra con albi.retornaTiempo(ot, 2)).',
  'Operaciones por Especialidad': 'Por especialidad: operaciones ingresadas, resueltas y su % de finalización.',
  'Operaciones por Subsistemas': 'Por tipo/subtipo de tarea: operaciones ingresadas, resueltas y % de finalización.',
  'Operaciones por Zona': null, // difiere: tabla en gestión, barras en operacionales
  'OTs por Especialidad': 'Por especialidad: OTs ingresadas, terminadas (Resuelta/Cerrada) y % de finalización. Una fila por OT (vista de OTs).',
  'OTs por Sistemas': 'Por tipo de tarea (sistema): OTs ingresadas, terminadas y % de finalización.',
  'OTs por Subsistemas': 'Por subtipo de tarea (subsistema): OTs ingresadas, terminadas y % de finalización.',
  'OTs por Zona': 'Por zona: OTs ingresadas, terminadas y % de finalización.',
  'Resolutores Activos': 'Valor configurado de resolutores activos (ConfiguracionDashboard, editable desde la web).',
  'Selector Especialidad': 'Tabla-selector para filtrar el dashboard por especialidad; muestra esfuerzos de referencia.',
  'Selector Zona': 'Tabla-selector para filtrar el dashboard por zona; muestra esfuerzos de referencia (sin multiplicar por involucrados).',
  'SLA por Sistemas': 'Por tipo de tarea: OTs en plazo (terminó antes de su fecha comprometida), fuera de plazo, sin cerrar, % de cumplimiento y días promedio de atraso.',
  'SLA por Subsistemas': 'Por subtipo de tarea: OTs en plazo, fuera de plazo, sin cerrar, % de cumplimiento y días promedio de atraso.',
  'Tiempos por Especialidad': 'Tiempos declarados en horas-hombre (× involucrados) desglosados por columna.',
  'Tiempos por Resolutor': 'Tiempos declarados en horas-hombre (× involucrados) por resolutor.',
  'Tiempos por Zona': 'Tiempos declarados en horas-hombre (× involucrados).',
  'Estado de OTs': 'Cantidad de OTs por estado (barras).',
  'Operaciones Resueltas': 'Total de operaciones en estado Resuelta en el período.',
  'Ops Backlog por especialidad': null, // por cliente
  'Ops pendientes por especialidad': 'Operaciones aún no resueltas (Abierta, Por Abrir, Asignada, Detenida, Agendada) por especialidad.',
  'Ops resueltas por especialidad': 'Operaciones resueltas por especialidad.',
  'OTs Backlog': null, // por cliente
  'OTs Creadas': 'Total de OTs del período (según la fecha del filtro).',
  'OTs Resueltas': 'Total de OTs Resueltas o Cerradas en el período.',
  'Personal Presente Hoy': 'Resolutores activos con marca de ENTRADA hoy, por turno (dataset de asistencia).',
  'Supervisores Presente Hoy': 'Supervisores activos con marca de ENTRADA hoy, por turno.',
  'Ranking carga de trabajo': 'Operaciones asignadas por resolutor (mayor a menor).',
  'Tasa de Cumplimiento': '% de OTs terminadas dentro de su fecha comprometida (FechaFinReal ≤ FechaFin), sobre OTs Resueltas/Cerradas.',
  'Tasa de Finalizacion': '% de OTs del período que quedaron Resueltas o Cerradas.',
  'Tendencia de OTs': 'Serie diaria: OTs totales vs OTs terminadas.',
  'Tiempo Prom. Resolucion': null, // por cliente
  'Tiempos OT en HH': null, // por cliente
  'Tiempos reportados por persona': 'Tiempos declarados por persona (estándar, ejecución, traslado, espera, administrativo) en horas-hombre.'
};

// Overrides por sección (clave: 'seccion|nombre')
const DESC_OVR = {
  'centinela_gestion|Esfuerzo Estándar': 'Horas “de catálogo” de lo resuelto: duración del catálogo de la OT × nº de operaciones resueltas ÷ 60. Replica kpi00.esfuerzoEstandar de AlbiWeb: universo por fecha programada de la operación, sin multiplicar por involucrados.',
  'ameco_gestion|Esfuerzo Estándar': 'Horas-hombre estándar: duracionMinSTD de la operación × involucrados ÷ 60, en OTs terminadas.',
  'centinela_gestion|Gauge Cumplimiento SLA': '% de OTs que terminaron dentro de su fecha comprometida (FechaFinReal ≤ FechaFin).',
  'ameco_gestion|Gauge Cumplimiento SLA': '% de OTs que terminaron dentro de 8 días desde su creación (SLA de 8 días).',
  'centinela_operacionales|OTs Backlog': 'OTs Abiertas con 3 o más días desde su creación.',
  'ameco_operacionales|OTs Backlog': 'OTs cuyo TipoActividad es “Backlog”.',
  'ameco_operacionales|Ops Backlog por especialidad': 'Operaciones de OTs con TipoActividad “Backlog”, por especialidad.',
  'centinela_operacionales|Ops Backlog por especialidad': 'Operaciones por especialidad. OJO: no tiene filtro propio de backlog (depende de los filtros del dashboard).',
  'centinela_operacionales|Tiempo Prom. Resolucion': 'Promedio del tiempo de resolución bruto por OT (campo OrdenTrabajoTiempoResolucionBruto) en horas. Replica el promedioResolucion de AlbiWeb.',
  'ameco_operacionales|Tiempo Prom. Resolucion': 'Horas de ejecución declaradas ÷ nº de OTs distintas (promedio por OT).',
  'centinela_operacionales|Tiempos OT en HH': 'Total de los 4 tiempos declarados en horas-hombre (× involucrados) de OTs terminadas. Equivale al “Tiempo total” del modal de AlbiWeb.',
  'ameco_operacionales|Tiempos OT en HH': 'Total de los 4 tiempos declarados ÷ 60 (sin involucrados), sobre la vista de OTs (solo primera operación de cada OT).',
  'centinela_operacionales|Operaciones por Zona': 'Cantidad de operaciones por zona (barras).',
  'centinela_gestion|Operaciones por Zona': 'Por zona: operaciones ingresadas, resueltas y % de finalización.',
  'ameco_operacionales|Operaciones por Zona': 'Cantidad de operaciones por zona (barras).',
  'ameco_gestion|Operaciones por Zona': 'Por zona: operaciones ingresadas, resueltas y % de finalización.'
};

// Notas de advertencia por chart
const NOTA = {
  'centinela_gestion|Tiempos por Zona': 'La dimensión configurada es <code>OperacionResolutor</code>, no la zona — la tabla agrupa por resolutor pese al nombre.',
  'ameco_gestion|Tiempos por Especialidad': 'La dimensión configurada es <code>OperacionResolutor</code>, no la especialidad — la tabla agrupa por resolutor pese al nombre.',
  'ameco_gestion|Tiempos por Zona': 'La dimensión configurada es <code>OperacionResolutor</code>, no la zona — la tabla agrupa por resolutor pese al nombre.',
  'ameco_gestion|Selector Zona': 'Bug: la métrica “Esfuerzo Estándar (hs)” usa <code>OperacionResolucionTiempoEjecucion</code> (quedó igual al Declarado). Debería usar <code>OperacionTiempoEstandar</code>.',
  'ameco_operacionales|Tiempos reportados por persona': 'Bug: la métrica “Esfuerzo Estándar (hrs)” usa <code>OperacionResolucionTiempoEjecucion</code> (igual al Declarado). En Centinela ya está corregido con <code>OperacionTiempoEstandar</code>.',
  'centinela_operacionales|Tiempo Prom. Resolucion': 'La fecha del rango es <code>OperacionFechaInicio</code> (inicio real); para calzar 100% con la web correspondería <code>OperacionFechaInicioProgramada</code>.',
  'centinela_gestion|Esfuerzo Estándar': 'Las OT sin catálogo aportan 0 (igual que la web). Requiere las columnas <code>OrdenTrabajoCatalogoDuracion</code> y <code>OperacionFechaInicioProgramada</code> del ETL.',
  'centinela_operacionales|Tasa de Cumplimiento': 'El label interno de la métrica quedó “[Ameco] | Tasa de Cumplimiento” (solo cosmético).'
};

function esc(s) {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
function baseName(name) {
  return name.replace(/^\[(Ameco|Centinela)\]\s*\|\s*/, '').trim();
}
function slug(s) {
  return s.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}
// Normaliza el SQL guardado en Superset: saltos \r\n, tabs, espacios sobrantes
// al final, alineaciones raras (varios espacios seguidos) e indentación global.
function cleanSql(sql) {
  let lines = String(sql).replace(/\r\n?/g, '\n').replace(/\t/g, '  ').split('\n');
  lines = lines.map(l => {
    const m = l.match(/^( *)(.*?) *$/);
    return m[1] + m[2].replace(/ {2,}/g, ' ');
  });
  while (lines.length && !lines[0].trim()) lines.shift();
  while (lines.length && !lines[lines.length - 1].trim()) lines.pop();
  const indents = lines.filter(l => l.trim()).map(l => l.match(/^ */)[0].length);
  const min = indents.length ? Math.min(...indents) : 0;
  if (min > 0) lines = lines.map(l => l.slice(min));
  return lines.join('\n');
}

// Multilínea o línea larga -> bloque <pre> (un solo recuadro, legible).
// Expresión corta -> <code> en línea.
function sqlHtml(sql) {
  const clean = cleanSql(sql);
  if (clean.includes('\n') || clean.length > 80) {
    return { html: `<pre class="sql"><code>${esc(clean)}</code></pre>`, block: true };
  }
  return { html: `<code>${esc(clean)}</code>`, block: false };
}

let bodyHtml = '';
// El menú se agrupa por cliente: Centinela / Ameco, y dentro por dashboard.
const navGroups = new Map();

for (const [key, title, intro, client, short] of SECTIONS) {
  const charts = S[key] || [];
  const secId = 's-' + slug(title);
  const mt = title.match(/^(\d+)\.\s*(.*)$/);
  const navLinks = [];
  if (!navGroups.has(client)) navGroups.set(client, []);
  navGroups.get(client).push({ short, secId, links: navLinks, count: charts.length });
  const cl = slug(client);
  bodyHtml += `<section id="${secId}" data-client="${cl}"><h2><span class="num">${mt ? mt[1] : ''}</span>` +
              `${esc(mt ? mt[2] : title)}</h2><p>${intro}</p></section>\n`;

  let i = 0;
  const seen = {};
  for (const c of charts) {
    i++;
    const bn = baseName(c.name);
    let id = `${key.split('_').map(w => w[0]).join('')}-${slug(bn)}`;
    if (seen[id]) { id += '-' + (++seen[id]); } else seen[id] = 1;

    const desc = DESC_OVR[`${key}|${bn}`] || DESC[bn] || '';
    const nota = NOTA[`${key}|${bn}`];

    navLinks.push(`<a class="sub" href="#${id}">${esc(bn)}</a>`);

    let ficha = `<table class="ficha"><tbody>`;
    ficha += `<tr><th>Tipo</th><td>${VIZ[c.viz] || esc(c.viz)}</td></tr>`;
    ficha += `<tr><th>Dataset</th><td><code>${esc(c.dataset)}</code></td></tr>`;
    ficha += `<tr><th>Fecha del rango</th><td>${c.temporal ? '<code>' + esc(c.temporal) + '</code>' : '— (no le afecta el filtro de fecha)'}</td></tr>`;
    if (c.filters.length)
      ficha += `<tr><th>Filtros propios</th><td>${c.filters.map(f => '<code>' + esc(f) + '</code>').join('<br>')}</td></tr>`;
    if (c.dims.length)
      ficha += `<tr><th>Agrupado por</th><td>${c.dims.map(esc).join(', ')}</td></tr>`;
    ficha += `</tbody></table>`;

    let calc = '';
    if (c.metrics.length) {
      const norm = t => String(t || '').replace(/\s+/g, ' ').trim().toLowerCase();
      calc = `<h4>Cálculo</h4><ul class="calc">` + c.metrics.map(m => {
        const s = sqlHtml(m.sql);
        // si el label repite el nombre del chart, no aporta: se omite
        const redundante = norm(m.label) === norm(c.name);
        const label = m.label && !redundante ? `<strong>${esc(m.label)}</strong>` : '';
        // con bloque el label va arriba; en línea va con el "=" al medio
        return `<li>${label}${label && !s.block ? ' = ' : ''}${s.html}</li>`;
      }).join('') + `</ul>`;
    } else {
      calc = `<h4>Cálculo</h4><ul><li>Sin métricas: lista registros crudos de las columnas indicadas.</li></ul>`;
    }

    bodyHtml += `<section id="${id}" data-client="${cl}"><h3>${esc(c.name)}</h3>` +
      (desc ? `<p>${desc}</p>` : '') +
      ficha + calc +
      (nota ? `<div class="nota"><strong>Nota:</strong> ${nota}</div>` : '') +
      `</section>\n`;
  }
}

// ── Menú: un grupo colapsable por cliente, y dentro uno por dashboard.
//    Se abre solo el primer dashboard del primer cliente para no dejar
//    un sidebar de 90 items.
let navHtml = '';
let cardsHtml = '';
for (const [client, dashboards] of navGroups) {
  const cl = slug(client);
  const total = dashboards.reduce((n, d) => n + d.count, 0);

  navHtml += `<details class="nav-group" data-client="${cl}" open>` +
             `<summary>${esc(client)}</summary>\n`;
  let firstDash = true;
  for (const d of dashboards) {
    navHtml += `<details class="nav-sub"${firstDash ? ' open' : ''}><summary>${esc(d.short)}` +
               ` <span class="cnt">${d.count}</span></summary>\n` +
               `<a class="dash" href="#${d.secId}">Ver la sección completa</a>\n` +
               d.links.join('\n') + `\n</details>\n`;
    firstDash = false;
  }
  navHtml += `</details>\n`;

  cardsHtml += `<a class="client-card" href="#" data-pick="${cl}">` +
    `<h3>${esc(client)}</h3>` +
    `<p>${dashboards.map(d => esc(d.short)).join(' · ')}</p>` +
    `<div class="meta">${total} charts en ${dashboards.length} dashboards</div>` +
    `</a>\n`;
}


// ── Salida con el diseño de la documentación Superset ──
const now = 'agosto 2026';
const html = `<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Cálculos de los charts — Superset Centinela y Ameco</title>
<link rel="stylesheet" href="../assets/docs.css">
</head>
<body>
<script src="../assets/nav.js" data-base=".."></script>
<nav class="docs-nav">
<div class="nav-section">Charts por dashboard</div>
<a href="#s1">Cómo leer este documento</a>
${navHtml}</nav>

<main>
<div class="hero">
  <h1>Cálculos de los charts</h1>
  <p>Qué calcula cada chart de los dashboards de <strong>Centinela</strong> y <strong>Ameco</strong>: métrica SQL, filtros propios, columna de fecha y agrupación. Extraído de las definiciones reales en Superset · ${now}.</p>
</div>

<section id="s1"><h2><span class="num">1</span>Cómo leer este documento</h2>
<ul>
<li><strong>Grano de los datasets</strong>: <code>CentinelaDashboards</code> / <code>AmecoDashboards</code> tienen <strong>una fila por operación</strong> (con los datos de su OT repetidos); las vistas <code>v_OrdenesTrabajo*</code> dejan <strong>una fila por OT</strong>; <code>*Asistencia</code> una fila por marca; <code>ConfiguracionDashboard</code> es clave/valor.</li>
<li><strong>Involucrados</strong>: <code>OperacionCantidadInvolucrados</code> = resolutor (si tiene) + colaboradores de la operación. Multiplicar un tiempo por involucrados lo convierte en <strong>horas-hombre</strong>.</li>
<li><strong>Fecha del rango</strong>: la columna donde cae el filtro de fecha del dashboard. Cada ficha indica cuál usa.</li>
<li><strong>Filtros del dashboard</strong>: sobre los filtros propios de cada chart se aplican además los nativos del dashboard (Fecha, Tipo Plan, Negocio, Estado); se intersectan.</li>
<li><strong>Centinela vs Ameco</strong>: Centinela está alineado a los SP de AlbiWeb (fecha programada para conteos, <code>FechaFinReal</code> para tiempos declarados); Ameco filtra casi todo por fecha de creación, igual que AmecoWeb.</li>
</ul>
<div class="nota">
<strong>Esta página se genera automáticamente</strong> — no la edites a mano, se sobrescribe.
Para actualizarla después de cambiar un chart en Superset: <strong>doble clic en
<code>scripts\\Actualizar-calculos-charts.bat</code></strong> (equivale a
<code>node scripts/calculos_fetch.js</code>). Lee los charts en vivo desde la API de
Superset, así que <strong>no necesita dashboards exportados</strong>.
Los textos descriptivos de cada chart están en las constantes <code>DESC</code> /
<code>DESC_OVR</code> / <code>NOTA</code> de <code>scripts/calculos_render.js</code>:
si creas un chart nuevo, agrega ahí su descripción y vuelve a ejecutar.
</div>
</section>

<section id="s-elegir">
<h2><span class="num">2</span>Elige el cliente</h2>
<p>Cada cliente tiene sus propios dashboards y sus cálculos difieren. Elige uno para ver sus fichas;
puedes cambiar de cliente en cualquier momento volviendo a estas tarjetas.</p>
<div class="client-cards">
${cardsHtml}</div>
</section>

${bodyHtml}
</main>

<script>
/* Selector de cliente: muestra solo las secciones (y el menú) del cliente
   elegido. El filtrado real lo hace el CSS con body[data-client]. */
(function () {
  var cards = document.querySelectorAll('.client-card');

  function pick(c, scroll) {
    document.body.dataset.client = c;
    cards.forEach(function (a) {
      a.classList.toggle('active', a.dataset.pick === c);
    });
    if (scroll) {
      var first = document.querySelector('section[data-client="' + c + '"]');
      if (first) first.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }

  cards.forEach(function (a) {
    a.addEventListener('click', function (e) {
      e.preventDefault();
      pick(a.dataset.pick, true);
    });
  });

  /* Si se entra con un enlace directo a una ficha (#cg-...), se activa
     el cliente al que pertenece para que no quede oculta. */
  function fromHash() {
    if (!location.hash || location.hash === '#s1' || location.hash === '#s-elegir') return;
    var el = null;
    try { el = document.querySelector(location.hash); } catch (err) { return; }
    if (!el) return;
    var host = el.closest('[data-client]');
    if (host) {
      pick(host.dataset.client, false);
      el.scrollIntoView({ block: 'start' });
    }
  }

  window.addEventListener('hashchange', fromHash);
  fromHash();
})();
</script>
</body>
</html>
`;

const OUT = path.join(__dirname, '..', 'docs', 'referencia', 'calculos-charts.html');
fs.writeFileSync(OUT, html);
console.log('OK ->', OUT, Math.round(html.length / 1024) + 'KB');
