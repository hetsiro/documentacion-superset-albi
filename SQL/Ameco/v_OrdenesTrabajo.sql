CREATE VIEW albi.v_OrdenesTrabajo AS
SELECT * FROM albi.AmecoDashboards
WHERE OperacionPadreId IS NULL