CREATE FUNCTION func_liststation
    RETURNS TABLE("nom" TEXT, "long" FLOAT, "lat" FLOAT, "no" TEXT)

CREATE VIEW view_listStations AS
    SELECT
        st."nostation" AS "nostation",
        st."nad83_latitude" AS "lat",
        st."nad83_longitude" AS "long"
    FROM public."Stations" AS st