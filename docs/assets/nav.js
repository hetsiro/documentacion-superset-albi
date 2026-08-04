/* ============================================================
   Menú lateral compartido — FUENTE ÚNICA de la navegación común.
   Editar la lista ITEMS de este archivo actualiza el menú de
   TODAS las páginas que lo incluyen.

   Uso:
     <script src="assets/nav.js"    data-base="."></script>   (docs/index.html)
     <script src="../assets/nav.js" data-base=".."></script>  (docs/<carpeta>/*.html)

   Si la página ya tiene un <nav class="docs-nav"> con items propios
   (ej. filtros por grupo/tipo del diccionario), el menú común se
   inserta ARRIBA de esos items y no se toca nada más. Si no existe,
   se crea el <nav> completo.
   ============================================================ */
(function () {
  var script = document.currentScript;
  var base = (script && script.dataset.base) || '.';

  /* Items comunes. href relativo a la raíz de docs/. */
  var ITEMS = [
    { section: 'Guía' },
    { label: 'Guía operativa Centinela', href: 'index.html' },

    { section: 'Diccionario de datos' },
    { label: 'Centinela', href: 'diccionario/centinela.html' },
    { label: 'Ameco', href: 'diccionario/ameco.html' },

    { section: 'Referencia' },
    { label: 'Cálculos de los charts', href: 'referencia/calculos-charts.html' },
    { label: 'Limitaciones de Superset', href: 'referencia/limitaciones-superset.html' }
  ];

  var LOGO = '<div class="nav-logo"><h1>Superset Docs</h1><p>Centinela · Albi</p></div>';

  /* CSS del sidebar. Solo hace falta en páginas que no lo traen (index.html);
     en las demás coincide con el suyo, así que no genera conflicto. */
  var CSS = [
    ':root{--sidebar-w:260px;--accent:#818cf8;--accent-light:rgba(129,140,248,.1);',
    '--text:#e2e8f0;--muted:#94a3b8;--border:#334155;--bg:#0f172a;--bg-surface:#1e293b;',
    '--success:#34d399;--warning:#fbbf24;--danger:#f87171}',
    'nav.docs-nav{width:var(--sidebar-w);background:var(--bg-surface);',
    'border-right:1px solid var(--border);position:fixed;top:0;left:0;bottom:0;',
    'overflow-y:auto;padding:24px 0;z-index:100;',
    "font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif}",
    'nav.docs-nav .nav-logo{padding:0 20px 20px;border-bottom:1px solid var(--border);margin-bottom:16px}',
    'nav.docs-nav .nav-logo h1{font-size:15px;font-weight:700;color:var(--accent);margin:0}',
    'nav.docs-nav .nav-logo p{font-size:11px;color:var(--muted);margin:2px 0 0}',
    'nav.docs-nav .nav-section{padding:4px 20px;font-size:10px;font-weight:700;color:var(--muted);',
    'text-transform:uppercase;letter-spacing:.08em;margin:16px 0 4px}',
    'nav.docs-nav a{display:block;padding:7px 20px;font-size:13px;color:var(--muted);',
    'text-decoration:none;border-left:3px solid transparent;transition:all .15s}',
    'nav.docs-nav a:hover{color:var(--accent);background:var(--accent-light)}',
    'nav.docs-nav a.active{color:var(--accent);border-left-color:var(--accent);',
    'background:var(--accent-light);font-weight:600}',
    'nav.docs-nav a.sub{padding-left:34px;font-size:12px}',
    'nav.docs-nav::-webkit-scrollbar{width:6px}',
    'nav.docs-nav::-webkit-scrollbar-track{background:transparent}',
    'nav.docs-nav::-webkit-scrollbar-thumb{background:var(--border);border-radius:3px}',
    '@media(max-width:768px){nav.docs-nav{display:none}}'
  ].join('');

  /* Marca el item activo comparando el nombre de archivo. */
  var file = location.pathname.split('/').pop() || 'index.html';
  var dir = location.pathname.split('/').slice(-2, -1)[0] || '';

  function isActive(href) {
    var parts = href.split('/');
    var hFile = parts.pop();
    var hDir = parts.pop() || '';
    return hFile === file && hDir === dir;
  }

  function render(items) {
    return items.map(function (it) {
      if (it.section) return '<div class="nav-section">' + it.section + '</div>';
      var href = it.href.charAt(0) === '#' ? it.href : base + '/' + it.href;
      var cls = ['nav-link'];
      if (it.sub) cls.push('sub');
      if (isActive(it.href)) cls.push('active');
      return '<a href="' + href + '" class="' + cls.join(' ') + '">' + it.label + '</a>';
    }).join('');
  }

  function mount() {
    var style = document.createElement('style');
    style.textContent = CSS;
    document.head.appendChild(style);

    var nav = document.querySelector('nav.docs-nav');
    var common = LOGO + render(ITEMS);

    if (nav) {
      // La página trae items propios: el menú común va arriba.
      nav.insertAdjacentHTML('afterbegin', common);
    } else {
      nav = document.createElement('nav');
      nav.className = 'docs-nav';
      nav.innerHTML = common;
      document.body.insertBefore(nav, document.body.firstChild);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', mount);
  } else {
    mount();
  }
})();
