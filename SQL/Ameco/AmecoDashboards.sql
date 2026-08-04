TRUNCATE TABLE albi.AmecoDashboards

INSERT INTO albi.AmecoDashboards
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
    tipoAct.nombreReal                  AS TipoActividad,
    (ISNULL((SELECT COUNT(DISTINCT oc.personaId)
             FROM albi.operacionColaboradores oc
             WHERE oc.operacionId = ope.id), 0)
     + CASE WHEN ope.resolutorId IS NULL THEN 0 ELSE 1 END) AS OperacionCantidadInvolucrados,
    cat.duracionIndustria               AS OrdenTrabajoDuracionIndustria

FROM        albi.ordenTrabajo           AS ot
INNER JOIN  albi.empresa                AS emp              ON ot.empresaId                 = emp.id
LEFT JOIN   albi.operacion              AS ope              ON ot.id                        = ope.ordenTrabajoId
LEFT JOIN   albi.operacionResolucion    AS operesol         ON ope.id                       = operesol.operacionId
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
LEFT JOIN   albi.ordenTrabajoAdicionales AS otadic          ON otadic.ordenTrabajoId        = ot.id
LEFT JOIN   albi.tipoActividad           AS tipoAct         ON tipoAct.id                   = otadic.tipoActividadId
LEFT JOIN   albi.catalogo                AS cat              ON cat.id                       = ot.catalogoId
WHERE ot.fechaCreacion >= DATEADD(month, -6, GETDATE())

/*
BEGIN
    CREATE TABLE albi.AmecoDashboards
    (
        OrdenTrabajoId                                INT            NULL,
        OrdenTrabajoFechaInicio                       DATETIME       NULL,
        OrdenTrabajoEmpresa                           VARCHAR(50)    NULL,
        EstadoOrdenTrabajoId                          INT            NULL,
        EstadoOrdenTrabajo                            VARCHAR(50)    NULL,
        OperacionId                                   INT            NULL,
        OperacionDescripcion                          VARCHAR(MAX)   NULL,
        OperacionTiempoEstandar                       INT            NULL,
        OperacionTiempoDuracionReal                   INT            NULL,
        OperacionTiempoPerdido                        INT            NULL,
        OperacionFechaFin                             DATETIME       NULL,
        OperacionFechaResolucion                      DATETIME       NULL,
        OperacionUbicacion                            VARCHAR(MAX)   NULL,
        OperacionRecursos                             INT            NULL,
        OperacionDependencia                          VARCHAR(100)   NULL,
        OperacionOrden                                INT            NULL,
        OperacionDireccion                            VARCHAR(200)   NULL,
        OperacionTiempoTraslado                       INT            NULL,
        OperacionProcesoId                            INT            NULL,
        OperacionPadreId                              INT            NULL,
        OperacionFechaAsignacion                      DATETIME       NULL,
        OperacionFechaDetenidoInicio                  DATETIME       NULL,
        OperacionFechaDetenidoFin                     DATETIME       NULL,
        OperacionFechaInicio                          DATETIME       NULL,
        TipoTareaId                                   INT            NULL,
        TipoTarea                                     VARCHAR(50)    NULL,
        SubTipoTareaId                                INT            NULL,
        SubTipoTarea                                  VARCHAR(50)    NULL,
        Nivel3Id                                      INT            NULL,
        Nivel3                                        VARCHAR(200)   NULL,
        Nivel4Id                                      INT            NULL,
        Nivel4                                        VARCHAR(200)   NULL,
        OrdenTrabajoNegocio                           VARCHAR(50)    NULL,
        TipoOperacionId                               INT            NULL,
        TipoOperacion                                 VARCHAR(100)   NULL,
        EspecialidadId                                INT            NULL,
        Especialidad                                  VARCHAR(50)    NULL,
        EstadoOperacionId                             INT            NULL,
        EstadoOperacion                               VARCHAR(100)   NULL,
        GrupoResolutorOperacionId                     INT            NULL,
        GrupoResolutorOperacion                       VARCHAR(50)    NULL,
        ResolutorPersonaId                            INT            NULL,
        OperacionResolutor                            VARCHAR(150)   NULL,
        OperacionResolutorTurno                       VARCHAR(50)    NULL,
        OperacionResolutorCargo                       VARCHAR(50)    NULL,
        ResolutorPerfilId                             INT            NULL,
        ResolutorPerfil                               VARCHAR(100)   NULL,
        SitioOperacionId                              INT            NULL,
        SitioOperacion                                VARCHAR(50)    NULL,
        ZonaOperacionId                               INT            NULL,
        ZonaOperacion                                 VARCHAR(50)    NULL,
        PrioridadOperacionId                          INT            NULL,
        PrioridadOperacion                            VARCHAR(50)    NULL,
        OperacionResolucionTiempoEspera               INT            NULL,
        OperacionResolucionTiempoEjecucion            INT            NULL,
        OperacionResolucionTiempoBruto                INT            NULL,
        OperacionResolucionTiempoTraslado             INT            NULL,
        OperacionResolucionTiemposAdministrativos     INT            NULL,
        OperacionResolucionEsPreparacionDoc           BIT            NULL,
        OperacionResolucionEsObtencionAutorizaciones  BIT            NULL,
        OperacionResolucionEsObtencionPermisos        BIT            NULL,
        OperacionResolucionLatitud                    VARCHAR(20)    NULL,
        OperacionResolucionLongitud                   VARCHAR(20)    NULL,
        OperacionResolucionFecha                      DATETIME       NULL,
        ActivoId                                      INT            NULL,
        Activo                                        VARCHAR(50)    NULL,
        ActivoCodigo                                  VARCHAR(50)    NULL,
        ProcesoId                                     INT            NULL,
        Proceso                                       VARCHAR(50)    NULL,
        OrdenTrabajoSolicitante                       VARCHAR(150)   NULL,
        OrdenTrabajoResponsable                       VARCHAR(150)   NULL,
        RecintoId                                     INT            NULL,
        Recinto                                       VARCHAR(50)    NULL,
        OrdenTrabajoDescripcion                       VARCHAR(MAX)   NULL,
        OrdenTrabajoFechaFin                          DATETIME       NULL,
        OrdenTrabajoFechaInicioReal                   DATETIME       NULL,
        OrdenTrabajoFechaFinReal                      DATETIME       NULL,
        OrdenTrabajoTiempoResolucionBruto             INT            NULL,
        OrdenTrabajoDuracion                          INT            NULL,
        OrdenTrabajoFechaCreacion                     DATETIME       NULL,
        OrdenTrabajoUbicacion                         VARCHAR(MAX)   NULL,
        OrdenTrabajoNochero                           BIT            NULL,
        OrdenTrabajoPlanId                            INT            NULL,
        OrdenTrabajoPlan                              VARCHAR(10)    NULL,
        TipoActividadId                               INT            NULL,
        TipoActividad                                 VARCHAR(50)    NULL,
        OperacionCantidadInvolucrados                 INT            NULL,
        OrdenTrabajoDuracionIndustria                 INT            NULL
    );
END
GO
*/