// Extrae por chart: nombre, tipo, dataset, métricas, filtros, fecha, dimensiones.
const fs = require('fs');
const path = require('path');
const DIR = path.join(__dirname, 'calculos_data');

const DATASETS = {
  34: 'AmecoDashboards', 35: 'v_OrdenesTrabajoAmeco', 36: 'AmecoAsistencia',
  37: 'CentinelaDashboards', 38: 'v_OrdenesTrabajoCentinela', 39: 'CentinelaAsistencia',
  66: 'ConfiguracionDashboard (Ameco)', 67: 'v_TiempoPerdidoPorResolutor', 68: 'ConfiguracionDashboard (Albi)',
  59: 'DemomineriaDashboards', 60: 'v_OrdenesTrabajoDemomineria', 61: 'DemomineriaAsistencia',
  63: 'AmecoDashboards (ALBICORP)', 64: 'v_OrdenesTrabajo (ALBICORP)', 65: 'AmecoAsistencia (ALBICORP)'
};

function metricText(m) {
  if (m == null) return null;
  if (typeof m === 'string') return m;                       // métrica guardada (ej. count)
  if (m.expressionType === 'SQL') return (m.sqlExpression || '').trim();
  if (m.expressionType === 'SIMPLE') {
    return `${m.aggregate}(${m.column ? m.column.column_name : ''})`;
  }
  if (m.aggregate) return `${m.aggregate}(${m.column ? m.column.column_name : '*'})`;
  return JSON.stringify(m);
}

function metricLabel(m) {
  if (m == null) return null;
  if (typeof m === 'string') return m;
  if (m.hasCustomLabel && m.label) return m.label;
  return null;
}

function filterText(f) {
  const subj = f.subject || (f.col || '');
  const op = f.operator || f.op || '';
  let comp = f.comparator;
  if (op === 'TEMPORAL_RANGE') return { temporal: subj };
  if (f.expressionType === 'SQL' && f.sqlExpression) return { text: `SQL: ${f.sqlExpression.trim()}` };
  if (Array.isArray(comp)) comp = `(${comp.join(', ')})`;
  if (comp === undefined || comp === null) comp = '';
  return { text: `${subj} ${op} ${comp}`.trim() };
}

const out = {};
for (const f of fs.readdirSync(DIR).filter(f => f.startsWith('dash_') && f.endsWith('.json'))) {
  const key = f.replace('dash_', '').replace('.json', '');
  const data = JSON.parse(fs.readFileSync(path.join(DIR, f), 'utf8'));
  const charts = [];
  for (const c of data.result || []) {
    const fd = typeof c.form_data === 'string' ? JSON.parse(c.form_data) : (c.form_data || {});
    const dsId = parseInt(String(fd.datasource || '').split('__')[0], 10);

    // métricas: metric | metrics | percent_metrics | secondary metrics de gauges etc.
    const rawMetrics = []
      .concat(fd.metric || [])
      .concat(fd.metrics || [])
      .concat(fd.percent_metrics || [])
      .concat(fd.metric_2 || []);
    const metrics = rawMetrics.map(m => ({ label: metricLabel(m), sql: metricText(m) }))
      .filter(m => m.sql);

    const filters = [];
    let temporal = null;
    for (const fl of fd.adhoc_filters || []) {
      const r = filterText(fl);
      if (r.temporal) temporal = r.temporal;
      else if (r.text) filters.push(r.text);
    }

    const dims = []
      .concat(fd.groupby || [])
      .concat(fd.x_axis ? [`x: ${typeof fd.x_axis === 'string' ? fd.x_axis : '(custom)'}`] : [])
      .concat(fd.all_columns || [])
      .map(d => (typeof d === 'string' ? d : (d.label || d.sqlExpression || '?')));

    charts.push({
      id: c.id,
      name: c.slice_name,
      viz: fd.viz_type || c.viz_type,
      dataset: DATASETS[dsId] || `dataset ${dsId}`,
      metrics,
      filters,
      temporal,
      dims,
      subheader: fd.subheader || null,
      rowLimit: fd.row_limit || null,
      sortBy: null
    });
  }
  charts.sort((a, b) => a.name.localeCompare(b.name, 'es'));
  out[key] = charts;
}

fs.writeFileSync(path.join(DIR, 'summary.json'), JSON.stringify(out, null, 2));

// resumen compacto
for (const [k, charts] of Object.entries(out)) {
  console.log('      ' + k + ': ' + charts.length + ' charts resumidos');
}
