import { readFileSync, readdirSync } from "fs";

const dirs = [
  "C:/Albi/superset/exports/15-06-2026/_work/centinela-gestion/dashboard_export_20260615T221734/charts",
];

for (const dir of dirs) {
  for (const f of readdirSync(dir).sort()) {
    if (!f.endsWith(".yaml")) continue;
    const raw = readFileSync(`${dir}/${f}`, "utf8");
    const m = raw.match(/query_context: '([\s\S]*?)'\r?\ncache_timeout:/);
    if (!m) {
      console.log("·· (sin query_context):", f);
      continue;
    }
    let fd;
    try {
      fd = JSON.parse(m[1].replace(/''/g, "'")).form_data ?? {};
    } catch (e) {
      console.log("·· (JSON fail):", f, e.message);
      continue;
    }
    const metrics = fd.metrics ?? (fd.metric ? [fd.metric] : []);
    const groupby = fd.groupby ?? fd.columns ?? [];
    console.log(`\n### ${fd.viz_type} — ${f}`);
    if (groupby.length)
      console.log(
        "   groupby:",
        groupby.map((g) => (typeof g === "string" ? g : g?.label ?? g?.column_name)).join(", "),
      );
    for (const mt of metrics) {
      if (typeof mt === "string") {
        console.log("   •", mt);
      } else if (mt.sqlExpression) {
        console.log(`   • ${mt.label}: ${mt.sqlExpression.replace(/\s+/g, " ").trim()}`);
      } else {
        console.log(`   • ${mt.label ?? ""}: ${mt.aggregate}(${mt.column?.column_name})`);
      }
    }
  }
}
