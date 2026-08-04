TRUNCATE TABLE albi.DemomineriaDashboards

INSERT INTO albi.DemomineriaDashboards
SELECT
    ot.id                               AS OrdenTrabajoId,
    ot.fechaInicio                      AS OrdenTrabajoFechaInicio,
    emp.nombre                          AS OrdenTrabajoEmpresa,
    estot.id                            AS EstadoOrdenTrabajoId,
    estot.nombre                        AS EstadoOrdenTrabajo,
    ope.id                              AS OperacionId,
    ope.descripcion                     AS OperacionDescripcion,
    ope.duracionMinSTD                  AS OperacionTiempoEstandar,
    ope.duracionReal                    AS OperacionTiempoDuracionReal,
    ISNULL(ope.tiempoPerdidoMin, 0)     AS OperacionTiempoPerdido,
    ope.fechaFin                        AS OperacionFechaFin,
    ope.fechaResolucion                 AS OperacionFechaResolucion,
    ope.ubicacion                       AS OperacionUbicacion,
    ope.recursos                        AS OperacionRecursos,
    ope.dependencia                     AS OperacionDependencia,
    ope.orden                           AS OperacionOrden,
    ope.direccion                       AS OperacionDireccion,
    ope.duracionTraslado                AS OperacionTiempoTraslado,
    ope.procesoOperacionId              AS OperacionProcesoId,
    CASE WHEN ope.id = (SELECT MIN(o2.id) FROM albi.operacion o2 WHERE o2.ordenTrabajoId = ot.id) THEN NULL ELSE (SELECT MIN(o2.id) FROM albi.operacion o2 WHERE o2.ordenTrabajoId = ot.id) END AS OperacionPadreId,
    ope.fechaAsignacion                 AS OperacionFechaAsignacion,
    ope.fechaDetenidoInicio             AS OperacionFechaDetenidoInicio,
    ope.fechaDetenidoFin                AS OperacionFechaDetenidoFin,
    ISNULL(operesol.fechainicioTareaReal, ISNULL(ope.fechaInicioTareaReal, ope.fechaInicio)) AS OperacionFechaInicio,
    tipotarea.id                        AS TipoTareaId,
    tipotarea.nombre                    AS TipoTarea,
    subtipotar.id                       AS SubTipoTareaId,
    subtipotar.nombre                   AS SubTipoTarea,
    n3.id                               AS Nivel3Id,
    n3.nombre                           AS Nivel3,
    n4.id                               AS Nivel4Id,
    n4.nombre                           AS Nivel4,
    neg.nombre                          AS OrdenTrabajoNegocio,
    tipoOperacion.id                    AS TipoOperacionId,
    tipoOperacion.nombre                AS TipoOperacion,
    espec.id                            AS EspecialidadId,
    espec.nombre                        AS Especialidad,
    estadoOperacion.id                  AS EstadoOperacionId,
    estadoOperacion.nombre              AS EstadoOperacion,
    grupo.id                            AS GrupoResolutorOperacionId,
    grupo.nombre                        AS GrupoResolutorOperacion,
    resolutor.personaId                 AS ResolutorPersonaId,
    pers.nombre                         AS OperacionResolutor,
    ISNULL(turno.nombre, 'Sin asignar') AS OperacionResolutorTurno,
    cargo.nombre                        AS OperacionResolutorCargo,
    perfil.id                           AS ResolutorPerfilId,
    perfil.nombre                       AS ResolutorPerfil,
    sitio.id                            AS SitioOperacionId,
    sitio.nombre                        AS SitioOperacion,
    zona.id                             AS ZonaOperacionId,
    zona.nombre                         AS ZonaOperacion,
    prioridad.id                        AS PrioridadOperacionId,
    prioridad.nombre                    AS PrioridadOperacion,
    operesol.tiempoEspera               AS OperacionResolucionTiempoEspera,
    operesol.duracionEjecucion          AS OperacionResolucionTiempoEjecucion,
    operesol.tiempoResolucionBruto      AS OperacionResolucionTiempoBruto,
    operesol.tiempoTrasladoDeclarado    AS OperacionResolucionTiempoTraslado,
    operesol.tiemposAdministrativos     AS OperacionResolucionTiemposAdministrativos,
    operesol.esPreparacionDocumentacion AS OperacionResolucionEsPreparacionDoc,
    operesol.esObtencionAutorizaciones  AS OperacionResolucionEsObtencionAutorizaciones,
    operesol.esObtencionPermisosES      AS OperacionResolucionEsObtencionPermisos,
    operesol.latitud                    AS OperacionResolucionLatitud,
    operesol.longitud                   AS OperacionResolucionLongitud,
    operesol.fechaResolucion            AS OperacionResolucionFecha,
    activo.id                           AS ActivoId,
    activo.nombre                       AS Activo,
    activo.codigo                       AS ActivoCodigo,
    proceso.id                          AS ProcesoId,
    proceso.nombre                      AS Proceso,
    solicitante.nombre                  AS OrdenTrabajoSolicitante,
    responsable.nombre                  AS OrdenTrabajoResponsable,
    recinto.id                          AS RecintoId,
    recinto.nombre                      AS Recinto,
    ot.descripcion                      AS OrdenTrabajoDescripcion,
    ot.fechaFin                         AS OrdenTrabajoFechaFin,
    ot.fechaInicioReal                  AS OrdenTrabajoFechaInicioReal,
    ot.fechaFinReal                     AS OrdenTrabajoFechaFinReal,
    ot.tiempoResolucionBruto            AS OrdenTrabajoTiempoResolucionBruto,
    ot.duracion                         AS OrdenTrabajoDuracion,
    ot.fechaCreacion                    AS OrdenTrabajoFechaCreacion,
    ot.ubicacion                        AS OrdenTrabajoUbicacion,
    ot.nochero                          AS OrdenTrabajoNochero,
    ot.planId                           AS OrdenTrabajoPlanId,
    CASE WHEN ot.planId IS NULL THEN 'Correctivo' ELSE 'Preventivo' END AS OrdenTrabajoPlan,
    (ISNULL((SELECT COUNT(DISTINCT oc.personaId)
             FROM albi.operacionColaboradores oc
             WHERE oc.operacionId = ope.id), 0)
     + CASE WHEN ope.resolutorId IS NULL THEN 0 ELSE 1 END) AS OperacionCantidadInvolucrados,
    -- Duracion del catalogo de la OT: es la que usa la web (SP dashboard01v3) para el
    -- esfuerzo estandar. OJO: distinta de ot.duracion -> las OT sin catalogo valen 0.
    ISNULL(cat.duracion, 0)             AS OrdenTrabajoCatalogoDuracion,
    -- Fecha de inicio PROGRAMADA de la operacion (la que filtra el SP dashboard01v3).
    -- Distinta de OperacionFechaInicio, que es la fecha de inicio REAL.
    ope.fechaInicio                     AS OperacionFechaInicioProgramada

FROM        albi.ordenTrabajo           AS ot
INNER JOIN  albi.empresa                AS emp              ON ot.empresaId                 = emp.id
LEFT JOIN   albi.operacion              AS ope              ON ot.id                        = ope.ordenTrabajoId
LEFT JOIN   albi.operacionResolucion    AS operesol         ON ope.id                       = operesol.operacionId
LEFT JOIN   albi.catalogo               AS cat              ON cat.id                       = ot.catalogoId
LEFT JOIN   albi.especialidad           AS espec            ON ope.especialidadId           = espec.id
LEFT JOIN   albi.negocio                AS neg              ON ot.negocioId                 = neg.id
LEFT JOIN   albi.tipoOperacion          AS tipoOperacion    ON tipoOperacion.id             = ope.tipoOperacionId
LEFT JOIN   albi.nivel3                 AS n3               ON ot.nivel3Id                  = n3.id
LEFT JOIN   albi.nivel4                 AS n4               ON ot.nivel4Id                  = n4.id
LEFT JOIN   albi.estadoOt               AS estot            ON ot.estadoOtId                = estot.id
LEFT JOIN   albi.estadoOperacion        AS estadoOperacion  ON estadoOperacion.id           = ope.estadoOperacionId
LEFT JOIN   albi.tipoTarea              AS tipotarea        ON tipotarea.id                 = ot.tipoTareaId
LEFT JOIN   albi.subtipoTarea           AS subtipotar       ON ot.subtipoTareaId            = subtipotar.id
LEFT JOIN   albi.prioridad              AS prioridad        ON prioridad.id                 = ope.prioridadId
LEFT JOIN   albi.grupoResolutor         AS grupo            ON ope.grupoResolutorId         = grupo.id
LEFT JOIN   albi.resolutor              AS resolutor        ON ope.resolutorId              = resolutor.personaId
LEFT JOIN   albi.persona                AS pers             ON resolutor.personaId          = pers.id
LEFT JOIN   albi.perfil                 AS perfil           ON perfil.id                    = resolutor.perfilId
LEFT JOIN   albi.sitio                  AS sitio            ON ope.sitioId                  = sitio.id
LEFT JOIN   albi.zona                   AS zona             ON zona.id                      = sitio.zonaId
LEFT JOIN   albi.turno                  AS turno            ON turno.id                     = resolutor.turnoId
LEFT JOIN   albi.cargoResolutor         AS cargo            ON cargo.id                     = resolutor.cargoResolutorId
LEFT JOIN   albi.activo                 AS activo           ON activo.id                    = ot.activoId
LEFT JOIN   albi.proceso                AS proceso          ON proceso.id                   = ot.procesoId
LEFT JOIN   albi.persona                AS solicitante      ON solicitante.id               = ot.solicitanteId
LEFT JOIN   albi.persona                AS responsable      ON responsable.id               = ot.responsableId
LEFT JOIN   albi.recinto                AS recinto          ON recinto.id                   = activo.recintoId
WHERE ot.fechaInicio >= DATEADD(month, -6, GETDATE())

/*
SELECT TOP 0
    ot.id                               AS OrdenTrabajoId,
    ot.fechaInicio                      AS OrdenTrabajoFechaInicio,
    emp.nombre                          AS OrdenTrabajoEmpresa,
    estot.id                            AS EstadoOrdenTrabajoId,
    estot.nombre                        AS EstadoOrdenTrabajo,
    ope.id                              AS OperacionId,
    ope.descripcion                     AS OperacionDescripcion,
    ope.duracionMinSTD                  AS OperacionTiempoEstandar,
    ope.duracionReal                    AS OperacionTiempoDuracionReal,
    ISNULL(ope.tiempoPerdidoMin, 0)     AS OperacionTiempoPerdido,
    ope.fechaFin                        AS OperacionFechaFin,
    ope.fechaResolucion                 AS OperacionFechaResolucion,
    ope.ubicacion                       AS OperacionUbicacion,
    ope.recursos                        AS OperacionRecursos,
    ope.dependencia                     AS OperacionDependencia,
    ope.orden                           AS OperacionOrden,
    ope.direccion                       AS OperacionDireccion,
    ope.duracionTraslado                AS OperacionTiempoTraslado,
    ope.procesoOperacionId              AS OperacionProcesoId,
    CASE WHEN ope.id = (SELECT MIN(o2.id) FROM albi.operacion o2 WHERE o2.ordenTrabajoId = ot.id) THEN NULL ELSE (SELECT MIN(o2.id) FROM albi.operacion o2 WHERE o2.ordenTrabajoId = ot.id) END AS OperacionPadreId,
    ope.fechaAsignacion                 AS OperacionFechaAsignacion,
    ope.fechaDetenidoInicio             AS OperacionFechaDetenidoInicio,
    ope.fechaDetenidoFin                AS OperacionFechaDetenidoFin,
    ISNULL(operesol.fechainicioTareaReal, ISNULL(ope.fechaInicioTareaReal, ope.fechaInicio)) AS OperacionFechaInicio,
    tipotarea.id                        AS TipoTareaId,
    tipotarea.nombre                    AS TipoTarea,
    subtipotar.id                       AS SubTipoTareaId,
    subtipotar.nombre                   AS SubTipoTarea,
    n3.id                               AS Nivel3Id,
    n3.nombre                           AS Nivel3,
    n4.id                               AS Nivel4Id,
    n4.nombre                           AS Nivel4,
    neg.nombre                          AS OrdenTrabajoNegocio,
    tipoOperacion.id                    AS TipoOperacionId,
    tipoOperacion.nombre                AS TipoOperacion,
    espec.id                            AS EspecialidadId,
    espec.nombre                        AS Especialidad,
    estadoOperacion.id                  AS EstadoOperacionId,
    estadoOperacion.nombre              AS EstadoOperacion,
    grupo.id                            AS GrupoResolutorOperacionId,
    grupo.nombre                        AS GrupoResolutorOperacion,
    resolutor.personaId                 AS ResolutorPersonaId,
    pers.nombre                         AS OperacionResolutor,
    ISNULL(turno.nombre, 'Sin asignar') AS OperacionResolutorTurno,
    cargo.nombre                        AS OperacionResolutorCargo,
    perfil.id                           AS ResolutorPerfilId,
    perfil.nombre                       AS ResolutorPerfil,
    sitio.id                            AS SitioOperacionId,
    sitio.nombre                        AS SitioOperacion,
    zona.id                             AS ZonaOperacionId,
    zona.nombre                         AS ZonaOperacion,
    prioridad.id                        AS PrioridadOperacionId,
    prioridad.nombre                    AS PrioridadOperacion,
    operesol.tiempoEspera               AS OperacionResolucionTiempoEspera,
    operesol.duracionEjecucion          AS OperacionResolucionTiempoEjecucion,
    operesol.tiempoResolucionBruto      AS OperacionResolucionTiempoBruto,
    operesol.tiempoTrasladoDeclarado    AS OperacionResolucionTiempoTraslado,
    operesol.tiemposAdministrativos     AS OperacionResolucionTiemposAdministrativos,
    operesol.esPreparacionDocumentacion AS OperacionResolucionEsPreparacionDoc,
    operesol.esObtencionAutorizaciones  AS OperacionResolucionEsObtencionAutorizaciones,
    operesol.esObtencionPermisosES      AS OperacionResolucionEsObtencionPermisos,
    operesol.latitud                    AS OperacionResolucionLatitud,
    operesol.longitud                   AS OperacionResolucionLongitud,
    operesol.fechaResolucion            AS OperacionResolucionFecha,
    activo.id                           AS ActivoId,
    activo.nombre                       AS Activo,
    activo.codigo                       AS ActivoCodigo,
    proceso.id                          AS ProcesoId,
    proceso.nombre                      AS Proceso,
    solicitante.nombre                  AS OrdenTrabajoSolicitante,
    responsable.nombre                  AS OrdenTrabajoResponsable,
    recinto.id                          AS RecintoId,
    recinto.nombre                      AS Recinto,
    ot.descripcion                      AS OrdenTrabajoDescripcion,
    ot.fechaFin                         AS OrdenTrabajoFechaFin,
    ot.fechaInicioReal                  AS OrdenTrabajoFechaInicioReal,
    ot.fechaFinReal                     AS OrdenTrabajoFechaFinReal,
    ot.tiempoResolucionBruto            AS OrdenTrabajoTiempoResolucionBruto,
    ot.duracion                         AS OrdenTrabajoDuracion,
    ot.fechaCreacion                    AS OrdenTrabajoFechaCreacion,
    ot.ubicacion                        AS OrdenTrabajoUbicacion,
    ot.nochero                          AS OrdenTrabajoNochero,
    ot.planId                           AS OrdenTrabajoPlanId,
    CASE WHEN ot.planId IS NULL THEN 'Correctivo' ELSE 'Preventivo' END AS OrdenTrabajoPlan,
    (ISNULL((SELECT COUNT(DISTINCT oc.personaId)
             FROM albi.operacionColaboradores oc
             WHERE oc.operacionId = ope.id), 0)
     + CASE WHEN ope.resolutorId IS NULL THEN 0 ELSE 1 END) AS OperacionCantidadInvolucrados,
    ISNULL(cat.duracion, 0)             AS OrdenTrabajoCatalogoDuracion,
    ope.fechaInicio                     AS OperacionFechaInicioProgramada
INTO albi.DemomineriaDashboards
FROM        albi.ordenTrabajo           AS ot
INNER JOIN  albi.empresa                AS emp              ON ot.empresaId                 = emp.id
LEFT JOIN   albi.operacion              AS ope              ON ot.id                        = ope.ordenTrabajoId
LEFT JOIN   albi.operacionResolucion    AS operesol         ON ope.id                       = operesol.operacionId
LEFT JOIN   albi.catalogo               AS cat              ON cat.id                       = ot.catalogoId
LEFT JOIN   albi.especialidad           AS espec            ON ope.especialidadId           = espec.id
LEFT JOIN   albi.negocio                AS neg              ON ot.negocioId                 = neg.id
LEFT JOIN   albi.tipoOperacion          AS tipoOperacion    ON tipoOperacion.id             = ope.tipoOperacionId
LEFT JOIN   albi.nivel3                 AS n3               ON ot.nivel3Id                  = n3.id
LEFT JOIN   albi.nivel4                 AS n4               ON ot.nivel4Id                  = n4.id
LEFT JOIN   albi.estadoOt               AS estot            ON ot.estadoOtId                = estot.id
LEFT JOIN   albi.estadoOperacion        AS estadoOperacion  ON estadoOperacion.id           = ope.estadoOperacionId
LEFT JOIN   albi.tipoTarea              AS tipotarea        ON tipotarea.id                 = ot.tipoTareaId
LEFT JOIN   albi.subtipoTarea           AS subtipotar       ON ot.subtipoTareaId            = subtipotar.id
LEFT JOIN   albi.prioridad              AS prioridad        ON prioridad.id                 = ope.prioridadId
LEFT JOIN   albi.grupoResolutor         AS grupo            ON ope.grupoResolutorId         = grupo.id
LEFT JOIN   albi.resolutor              AS resolutor        ON ope.resolutorId              = resolutor.personaId
LEFT JOIN   albi.persona                AS pers             ON resolutor.personaId          = pers.id
LEFT JOIN   albi.perfil                 AS perfil           ON perfil.id                    = resolutor.perfilId
LEFT JOIN   albi.sitio                  AS sitio            ON ope.sitioId                  = sitio.id
LEFT JOIN   albi.zona                   AS zona             ON zona.id                      = sitio.zonaId
LEFT JOIN   albi.turno                  AS turno            ON turno.id                     = resolutor.turnoId
LEFT JOIN   albi.cargoResolutor         AS cargo            ON cargo.id                     = resolutor.cargoResolutorId
LEFT JOIN   albi.activo                 AS activo           ON activo.id                    = ot.activoId
LEFT JOIN   albi.proceso                AS proceso          ON proceso.id                   = ot.procesoId
LEFT JOIN   albi.persona                AS solicitante      ON solicitante.id               = ot.solicitanteId
LEFT JOIN   albi.persona                AS responsable      ON responsable.id               = ot.responsableId
LEFT JOIN   albi.recinto                AS recinto          ON recinto.id                   = activo.recintoId
WHERE 1 = 0;
*/