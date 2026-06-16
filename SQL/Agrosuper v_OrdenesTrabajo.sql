CREATE VIEW albi.v_OrdenesTrabajoAgrosuper AS
SELECT * FROM albi.AgrosuperDashboards
WHERE OperacionPadreId IS NULL