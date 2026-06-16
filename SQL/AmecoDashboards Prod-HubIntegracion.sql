USE AmecoHubIntegracion;
GO

-- =============================================
-- PASO 1: Crear la tabla si no existe
-- Solo se ejecuta la primera vez
-- =============================================
IF OBJECT_ID('AmecoHubIntegracion.dbo.AmecoDashboards') IS NULL
BEGIN
    SELECT TOP 0 *
    INTO AmecoHubIntegracion.dbo.AmecoDashboards
    FROM (
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
            ope.operacionPadreId                AS OperacionPadreId,
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
            ot.ganttId                          AS OrdenTrabajoPlanId,
            CASE WHEN ot.ganttId IS NULL THEN 'Correctivo' ELSE 'Preventivo' END AS OrdenTrabajoPlan,
            tipoAct.id                          AS TipoActividadId,
            tipoAct.nombreReal                  AS TipoActividad
        FROM        Ameco.albi.ordenTrabajo           AS ot
        INNER JOIN  Ameco.albi.empresa                AS emp              ON ot.empresaId                 = emp.id
        LEFT JOIN   Ameco.albi.operacion              AS ope              ON ot.id                        = ope.ordenTrabajoId
        LEFT JOIN   Ameco.albi.operacionResolucion    AS operesol         ON ope.id                       = operesol.operacionId
        LEFT JOIN   Ameco.albi.especialidad           AS espec            ON ope.especialidadId           = espec.id
        LEFT JOIN   Ameco.albi.negocio                AS neg              ON ot.negocioId                 = neg.id
        LEFT JOIN   Ameco.albi.tipoOperacion          AS tipoOperacion    ON tipoOperacion.id             = ope.tipoOperacionId
        LEFT JOIN   Ameco.albi.nivel3                 AS n3               ON ot.nivel3Id                  = n3.id
        LEFT JOIN   Ameco.albi.nivel4                 AS n4               ON ot.nivel4Id                  = n4.id
        LEFT JOIN   Ameco.albi.estadoOt               AS estot            ON ot.estadoOtId                = estot.id
        LEFT JOIN   Ameco.albi.estadoOperacion        AS estadoOperacion  ON estadoOperacion.id           = ope.estadoOperacionId
        LEFT JOIN   Ameco.albi.tipoTarea              AS tipotarea        ON tipotarea.id                 = ot.tipoTareaId
        LEFT JOIN   Ameco.albi.subtipoTarea           AS subtipotar       ON ot.subtipoTareaId            = subtipotar.id
        LEFT JOIN   Ameco.albi.prioridad              AS prioridad        ON prioridad.id                 = ope.prioridadId
        LEFT JOIN   Ameco.albi.grupoResolutor         AS grupo            ON ope.grupoResolutorId         = grupo.id
        LEFT JOIN   Ameco.albi.resolutor              AS resolutor        ON ope.resolutorId              = resolutor.personaId
        LEFT JOIN   Ameco.albi.persona                AS pers             ON resolutor.personaId          = pers.id
        LEFT JOIN   Ameco.albi.perfil                 AS perfil           ON perfil.id                    = resolutor.perfilId
        LEFT JOIN   Ameco.albi.sitio                  AS sitio            ON ope.sitioId                  = sitio.id
        LEFT JOIN   Ameco.albi.zona                   AS zona             ON zona.id                      = sitio.zonaId
        LEFT JOIN   Ameco.albi.turno                  AS turno            ON turno.id                     = resolutor.turnoId
        LEFT JOIN   Ameco.albi.cargoResolutor         AS cargo            ON cargo.id                     = resolutor.cargoResolutorId
        LEFT JOIN   Ameco.albi.activo                 AS activo           ON activo.id                    = ot.activoId
        LEFT JOIN   Ameco.albi.proceso                AS proceso          ON proceso.id                   = ot.procesoId
        LEFT JOIN   Ameco.albi.persona                AS solicitante      ON solicitante.id               = ot.solicitanteId
        LEFT JOIN   Ameco.albi.persona                AS responsable      ON responsable.id               = ot.responsableId
        LEFT JOIN   Ameco.albi.recinto                AS recinto          ON recinto.id                   = activo.recintoId
        LEFT JOIN   Ameco.albi.ordenTrabajoAdicionales AS otadic          ON otadic.ordenTrabajoId        = ot.id
        LEFT JOIN   Ameco.albi.tipoActividad           AS tipoAct         ON tipoAct.id                   = otadic.tipoActividadId
        WHERE 1 = 0
    ) AS t
    PRINT 'Tabla creada por primera vez'
END

-- =============================================
-- PASO 2: Actualizar los datos
-- Se ejecuta cada 1 hora sin DROP
-- =============================================
TRUNCATE TABLE AmecoHubIntegracion.dbo.AmecoDashboards

INSERT INTO AmecoHubIntegracion.dbo.AmecoDashboards
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
    ope.operacionPadreId                AS OperacionPadreId,
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
    ot.ganttId                          AS OrdenTrabajoPlanId,
    CASE WHEN ot.ganttId IS NULL THEN 'Correctivo' ELSE 'Preventivo' END AS OrdenTrabajoPlan,
    tipoAct.id                          AS TipoActividadId,
    tipoAct.nombreReal                  AS TipoActividad

FROM        Ameco.albi.ordenTrabajo           AS ot
INNER JOIN  Ameco.albi.empresa                AS emp              ON ot.empresaId                 = emp.id
LEFT JOIN   Ameco.albi.operacion              AS ope              ON ot.id                        = ope.ordenTrabajoId
LEFT JOIN   Ameco.albi.operacionResolucion    AS operesol         ON ope.id                       = operesol.operacionId
LEFT JOIN   Ameco.albi.especialidad           AS espec            ON ope.especialidadId           = espec.id
LEFT JOIN   Ameco.albi.negocio                AS neg              ON ot.negocioId                 = neg.id
LEFT JOIN   Ameco.albi.tipoOperacion          AS tipoOperacion    ON tipoOperacion.id             = ope.tipoOperacionId
LEFT JOIN   Ameco.albi.nivel3                 AS n3               ON ot.nivel3Id                  = n3.id
LEFT JOIN   Ameco.albi.nivel4                 AS n4               ON ot.nivel4Id                  = n4.id
LEFT JOIN   Ameco.albi.estadoOt               AS estot            ON ot.estadoOtId                = estot.id
LEFT JOIN   Ameco.albi.estadoOperacion        AS estadoOperacion  ON estadoOperacion.id           = ope.estadoOperacionId
LEFT JOIN   Ameco.albi.tipoTarea              AS tipotarea        ON tipotarea.id                 = ot.tipoTareaId
LEFT JOIN   Ameco.albi.subtipoTarea           AS subtipotar       ON ot.subtipoTareaId            = subtipotar.id
LEFT JOIN   Ameco.albi.prioridad              AS prioridad        ON prioridad.id                 = ope.prioridadId
LEFT JOIN   Ameco.albi.grupoResolutor         AS grupo            ON ope.grupoResolutorId         = grupo.id
LEFT JOIN   Ameco.albi.resolutor              AS resolutor        ON ope.resolutorId              = resolutor.personaId
LEFT JOIN   Ameco.albi.persona                AS pers             ON resolutor.personaId          = pers.id
LEFT JOIN   Ameco.albi.perfil                 AS perfil           ON perfil.id                    = resolutor.perfilId
LEFT JOIN   Ameco.albi.sitio                  AS sitio            ON ope.sitioId                  = sitio.id
LEFT JOIN   Ameco.albi.zona                   AS zona             ON zona.id                      = sitio.zonaId
LEFT JOIN   Ameco.albi.turno                  AS turno            ON turno.id                     = resolutor.turnoId
LEFT JOIN   Ameco.albi.cargoResolutor         AS cargo            ON cargo.id                     = resolutor.cargoResolutorId
LEFT JOIN   Ameco.albi.activo                 AS activo           ON activo.id                    = ot.activoId
LEFT JOIN   Ameco.albi.proceso                AS proceso          ON proceso.id                   = ot.procesoId
LEFT JOIN   Ameco.albi.persona                AS solicitante      ON solicitante.id               = ot.solicitanteId
LEFT JOIN   Ameco.albi.persona                AS responsable      ON responsable.id               = ot.responsableId
LEFT JOIN   Ameco.albi.recinto                AS recinto          ON recinto.id                   = activo.recintoId
LEFT JOIN   Ameco.albi.ordenTrabajoAdicionales AS otadic          ON otadic.ordenTrabajoId        = ot.id
LEFT JOIN   Ameco.albi.tipoActividad           AS tipoAct         ON tipoAct.id                   = otadic.tipoActividadId
WHERE ot.fechaInicio >= DATEADD(month, -6, GETDATE())