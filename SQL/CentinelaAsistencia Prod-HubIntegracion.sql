SELECT TOP 0 *
    INTO HubIntegracion.albi.CentinelaAsistencia
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
        FROM        albi.asistencia     AS a
        JOIN        albi.persona        AS p    ON p.id     = a.personaId
        JOIN        albi.resolutor      AS r    ON r.personaId = a.personaId
        LEFT JOIN   albi.perfil         AS pf   ON pf.id    = r.perfilId
        LEFT JOIN   albi.turno          AS t    ON t.id     = r.turnoId
        LEFT JOIN   albi.especialidad   AS esp  ON esp.id   = r.especialidadId
        LEFT JOIN   albi.zona           AS z    ON z.id     = r.zonaId
        WHERE 1 = 0
    ) AS t

-- =============================================
-- PASO 2: Actualizar los datos
-- =============================================
TRUNCATE TABLE HubIntegracion.albi.CentinelaAsistencia

INSERT INTO HubIntegracion.albi.CentinelaAsistencia
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
FROM        albi.asistencia     AS a
JOIN        albi.persona        AS p    ON p.id     = a.personaId
JOIN        albi.resolutor      AS r    ON r.personaId = a.personaId
LEFT JOIN   albi.perfil         AS pf   ON pf.id    = r.perfilId
LEFT JOIN   albi.turno          AS t    ON t.id     = r.turnoId
LEFT JOIN   albi.especialidad   AS esp  ON esp.id   = r.especialidadId
LEFT JOIN   albi.zona           AS z    ON z.id     = r.zonaId
WHERE a.fechaHora >= DATEADD(month, -6, GETDATE())
