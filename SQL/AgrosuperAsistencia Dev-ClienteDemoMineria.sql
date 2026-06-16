USE ClienteDemoMineria;
GO

-- =============================================
-- PASO 1: Crear la tabla si no existe
-- =============================================
IF OBJECT_ID('ClienteDemoMineria.albi.AgrosuperAsistencia') IS NULL
BEGIN
    SELECT TOP 0 *
    INTO ClienteDemoMineria.albi.AgrosuperAsistencia
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
        FROM        ClienteDemoMineria.albi.asistencia     AS a
        JOIN        ClienteDemoMineria.albi.persona        AS p    ON p.id     = a.personaId
        JOIN        ClienteDemoMineria.albi.resolutor      AS r    ON r.personaId = a.personaId
        LEFT JOIN   ClienteDemoMineria.albi.perfil         AS pf   ON pf.id    = r.perfilId
        LEFT JOIN   ClienteDemoMineria.albi.turno          AS t    ON t.id     = r.turnoId
        LEFT JOIN   ClienteDemoMineria.albi.especialidad   AS esp  ON esp.id   = r.especialidadId
        LEFT JOIN   ClienteDemoMineria.albi.zona           AS z    ON z.id     = r.zonaId
        WHERE 1 = 0
    ) AS t
    PRINT 'Tabla AgrosuperAsistencia creada'
END

-- =============================================
-- PASO 2: Actualizar los datos
-- =============================================
TRUNCATE TABLE ClienteDemoMineria.albi.AgrosuperAsistencia

INSERT INTO ClienteDemoMineria.albi.AgrosuperAsistencia
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
FROM        ClienteDemoMineria.albi.asistencia     AS a
JOIN        ClienteDemoMineria.albi.persona        AS p    ON p.id     = a.personaId
JOIN        ClienteDemoMineria.albi.resolutor      AS r    ON r.personaId = a.personaId
LEFT JOIN   ClienteDemoMineria.albi.perfil         AS pf   ON pf.id    = r.perfilId
LEFT JOIN   ClienteDemoMineria.albi.turno          AS t    ON t.id     = r.turnoId
LEFT JOIN   ClienteDemoMineria.albi.especialidad   AS esp  ON esp.id   = r.especialidadId
LEFT JOIN   ClienteDemoMineria.albi.zona           AS z    ON z.id     = r.zonaId
WHERE a.fechaHora >= DATEADD(month, -6, GETDATE())
