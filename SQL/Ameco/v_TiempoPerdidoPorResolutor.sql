/* ==========================================================================
   Vista unificada de tiempo perdido por resolutor/colaborador (modelo nuevo + viejo).
   Alineada al canon (docs/modelo-tiempos-colaboradores.md): la suma por OT debe
   cuadrar con albi.retornaTiempo(ot, 2).

   - NUEVO (equipo de trabajo): 1 fila por (operación, técnico, motivo), minutos reales.
   - VIEJO (por operación, sin equipo): el modelo no guarda tiempo por persona, así que se
     REPLICA el tiempoEspera declarado a cada involucrado -> 1 fila por (resolutor + cada
     colaborador). Suma = tiempoEspera x (1 + nº colaboradores) = horas-hombre (= retornaTiempo).
     Motivos = CSV motivoPerdidoIds + motivoPerdidoId (legacy), resueltos a texto y concatenados.

   Mismas 14 columnas en ambas ramas. motivoTipoId = 6 = catálogo de motivos de tiempo perdido.
   ========================================================================== */
CREATE OR ALTER VIEW albi.v_TiempoPerdidoPorResolutor AS

-- ===== Modelo NUEVO: desglose real por técnico del equipo de trabajo =====
SELECT  e.operacionId                 AS OperacionId,
        ot.id                         AS OrdenTrabajoId,
        e.resolutorId                 AS ResolutorId,
        p.nombre                      AS Resolutor,
        m.valor                       AS Motivo,
        ot.fechaCreacion              AS OrdenTrabajoFechaCreacion,
        neg.nombre                    AS OrdenTrabajoNegocio,
        estot.nombre                  AS EstadoOrdenTrabajo,
        eope.nombre                   AS EstadoOperacion,
        CASE WHEN ot.ganttId IS NULL THEN 'Correctivo' ELSE 'Preventivo' END AS OrdenTrabajoPlan,
        espec.nombre                  AS Especialidad,
        sitio.nombre                  AS SitioOperacion,
        zona.nombre                   AS ZonaOperacion,
        ISNULL(tp.minutos, 0)         AS MinutosPerdidos
FROM       albi.operacionEquipoTrabajoTiempoPerdido  tp
JOIN       albi.operacionEquipoTrabajo               e     ON e.id     = tp.operacionEquipoTrabajoId
LEFT JOIN  albi.persona                              p     ON p.id     = e.resolutorId
LEFT JOIN  albi.motivo                               m     ON m.id     = tp.motivoId AND m.motivoTipoId = 6
LEFT JOIN  albi.operacion                            ope   ON ope.id   = e.operacionId
LEFT JOIN  albi.ordenTrabajo                         ot    ON ot.id    = ope.ordenTrabajoId
LEFT JOIN  albi.negocio                              neg   ON neg.id   = ot.negocioId
LEFT JOIN  albi.estadoOt                             estot ON estot.id = ot.estadoOtId
LEFT JOIN  albi.estadoOperacion                      eope  ON eope.id  = ope.estadoOperacionId
LEFT JOIN  albi.especialidad                         espec ON espec.id = ope.especialidadId
LEFT JOIN  albi.sitio                                sitio ON sitio.id = ope.sitioId
LEFT JOIN  albi.zona                                 zona  ON zona.id  = sitio.zonaId

UNION ALL

-- ===== Modelo VIEJO: replicado a resolutor + colaboradores (horas-hombre) =====
SELECT  ope.id                        AS OperacionId,
        ot.id                         AS OrdenTrabajoId,
        inv.personaId                 AS ResolutorId,
        per.nombre                    AS Resolutor,
        mot.motivos                   AS Motivo,
        ot.fechaCreacion              AS OrdenTrabajoFechaCreacion,
        neg.nombre                    AS OrdenTrabajoNegocio,
        estot.nombre                  AS EstadoOrdenTrabajo,
        eope.nombre                   AS EstadoOperacion,
        CASE WHEN ot.ganttId IS NULL THEN 'Correctivo' ELSE 'Preventivo' END AS OrdenTrabajoPlan,
        espec.nombre                  AS Especialidad,
        sitio.nombre                  AS SitioOperacion,
        zona.nombre                   AS ZonaOperacion,
        ISNULL(oresol.tiempoEspera, 0) AS MinutosPerdidos
FROM       albi.operacionResolucion   oresol
JOIN       albi.operacion             ope   ON ope.id   = oresol.operacionId
-- involucrados: resolutor (1) + cada fila de colaboradores  => (1 + COUNT(*) colaboradores)
CROSS APPLY (
    SELECT ope.resolutorId AS personaId
    UNION ALL
    SELECT oc.personaId
    FROM   albi.operacionColaboradores oc
    WHERE  oc.operacionId = ope.id
) inv
LEFT JOIN  albi.persona               per   ON per.id   = inv.personaId
LEFT JOIN  albi.ordenTrabajo          ot    ON ot.id    = ope.ordenTrabajoId
LEFT JOIN  albi.negocio               neg   ON neg.id   = ot.negocioId
LEFT JOIN  albi.estadoOt              estot ON estot.id = ot.estadoOtId
LEFT JOIN  albi.estadoOperacion       eope  ON eope.id  = ope.estadoOperacionId
LEFT JOIN  albi.especialidad          espec ON espec.id = ope.especialidadId
LEFT JOIN  albi.sitio                 sitio ON sitio.id = ope.sitioId
LEFT JOIN  albi.zona                  zona  ON zona.id  = sitio.zonaId
OUTER APPLY (
    SELECT STRING_AGG(mm.valor, ', ') AS motivos
    FROM (
        SELECT DISTINCT TRY_CAST(LTRIM(RTRIM(s.value)) AS INT) AS motivoId
        FROM STRING_SPLIT(
                 CONCAT(ISNULL(oresol.motivoPerdidoIds, ''), ',',
                        ISNULL(CAST(oresol.motivoPerdidoId AS VARCHAR(20)), '')), ',') s
        WHERE TRY_CAST(LTRIM(RTRIM(s.value)) AS INT) IS NOT NULL
    ) ids
    JOIN albi.motivo mm ON mm.id = ids.motivoId AND mm.motivoTipoId = 6
) mot
WHERE  ISNULL(oresol.tiempoEspera, 0) > 0
  AND  NOT EXISTS (SELECT 1 FROM albi.operacionEquipoTrabajo eq WHERE eq.operacionId = oresol.operacionId);
