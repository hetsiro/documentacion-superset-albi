USE AmecoHubIntegracion;
GO

-- =============================================
-- PASO 1: Crear la tabla si no existe
-- =============================================
IF OBJECT_ID('AmecoHubIntegracion.dbo.AmecoAsistencia') IS NULL
BEGIN
    SELECT TOP 0 *
    INTO AmecoHubIntegracion.dbo.AmecoAsistencia
    FROM (
        SELECT
            a.id                        AS AsistenciaId,
            a.personaId                 AS PersonaId,
            p.nombre                    AS Persona,
            pf.id                       AS PerfilId,
            pf.nombre                   AS Perfil,
            t.id                        AS TurnoId,
            t.nombre                    AS Turno,
            t.horaInicio                AS TurnoHoraInicio,
            t.horaFin                   AS TurnoHoraFin,
            r.especialidadId            AS EspecialidadId,
            esp.nombre                  AS Especialidad,
            r.zonaId                    AS ZonaId,
            z.nombre                    AS Zona,
            r.activo                    AS ResolutorActivo,
            a.tipo                      AS AsistenciaTipo,
            a.fechaHora                 AS AsistenciaFechaHora,
            CAST(a.fechaHora AS DATE)   AS AsistenciaFecha,
            a.latitud                   AS AsistenciaLatitud,
            a.longitud                  AS AsistenciaLongitud,
            a.estado                    AS AsistenciaEstado
        FROM        Ameco.albi.asistencia     AS a
        JOIN        Ameco.albi.persona        AS p    ON p.id     = a.personaId
        JOIN        Ameco.albi.resolutor      AS r    ON r.personaId = a.personaId
        LEFT JOIN   Ameco.albi.perfil         AS pf   ON pf.id    = r.perfilId
        LEFT JOIN   Ameco.albi.turno          AS t    ON t.id     = r.turnoId
        LEFT JOIN   Ameco.albi.especialidad   AS esp  ON esp.id   = r.especialidadId
        LEFT JOIN   Ameco.albi.zona           AS z    ON z.id     = r.zonaId
        WHERE 1 = 0
    ) AS t
    PRINT 'Tabla AmecoAsistencia creada'
END

-- =============================================
-- PASO 2: Actualizar los datos
-- =============================================
TRUNCATE TABLE AmecoHubIntegracion.dbo.AmecoAsistencia

INSERT INTO AmecoHubIntegracion.dbo.AmecoAsistencia
SELECT
    a.id                        AS AsistenciaId,
    a.personaId                 AS PersonaId,
    p.nombre                    AS Persona,
    pf.id                       AS PerfilId,
    pf.nombre                   AS Perfil,
    t.id                        AS TurnoId,
    t.nombre                    AS Turno,
    t.horaInicio                AS TurnoHoraInicio,
    t.horaFin                   AS TurnoHoraFin,
    r.especialidadId            AS EspecialidadId,
    esp.nombre                  AS Especialidad,
    r.zonaId                    AS ZonaId,
    z.nombre                    AS Zona,
    r.activo                    AS ResolutorActivo,
    a.tipo                      AS AsistenciaTipo,
    a.fechaHora                 AS AsistenciaFechaHora,
    CAST(a.fechaHora AS DATE)   AS AsistenciaFecha,
    a.latitud                   AS AsistenciaLatitud,
    a.longitud                  AS AsistenciaLongitud,
    a.estado                    AS AsistenciaEstado
FROM        Ameco.albi.asistencia     AS a
JOIN        Ameco.albi.persona        AS p    ON p.id     = a.personaId
JOIN        Ameco.albi.resolutor      AS r    ON r.personaId = a.personaId
LEFT JOIN   Ameco.albi.perfil         AS pf   ON pf.id    = r.perfilId
LEFT JOIN   Ameco.albi.turno          AS t    ON t.id     = r.turnoId
LEFT JOIN   Ameco.albi.especialidad   AS esp  ON esp.id   = r.especialidadId
LEFT JOIN   Ameco.albi.zona           AS z    ON z.id     = r.zonaId
WHERE a.fechaHora >= DATEADD(month, -6, GETDATE())
