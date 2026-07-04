CREATE VIEW albi.v_OrdenesDemomineria AS
SELECT * FROM albi.DemomineriaDashboards
WHERE OperacionPadreId IS NULL