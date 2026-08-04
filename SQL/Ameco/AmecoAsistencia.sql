TRUNCATE TABLE albi.AmecoAsistencia

INSERT INTO albi.AmecoAsistencia
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

/*
BEGIN
    CREATE TABLE albi.AmecoAsistencia
    (
        AsistenciaId          INT            NULL,
        PersonaId             INT            NULL,
        Persona               VARCHAR(150)   NULL,
        PerfilId              INT            NULL,
        Perfil                VARCHAR(100)   NULL,
        TurnoId               INT            NULL,
        Turno                 VARCHAR(50)    NULL,
        TurnoHoraInicio       TIME           NULL,
        TurnoHoraFin          TIME           NULL,
        EspecialidadId        INT            NULL,
        Especialidad          VARCHAR(50)    NULL,
        ZonaId                INT            NULL,
        Zona                  VARCHAR(50)    NULL,
        ResolutorActivo       BIT            NULL,
        AsistenciaTipo        CHAR(1)        NULL,
        AsistenciaFechaHora   DATETIME       NULL,
        AsistenciaFecha       DATE           NULL,
        AsistenciaLatitud     VARCHAR(20)    NULL,
        AsistenciaLongitud    VARCHAR(20)    NULL,
        AsistenciaEstado      INT            NULL
    );
END
GO
*/
