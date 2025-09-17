-- Active: 1742397105088@@127.0.0.1@5432@datastream_db

-- fn_insert_mesure
SELECT fn_insert_mesure('Temperature', 'P001', 1, '2023-01-01 00:00:00', 1, 1, 23.5) ;

-- fn_get_responsableid
SELECT fn_get_responsableid('Catherine Frizzle', NULL, NULL, NULL, 1);
SELECT fn_get_responsableid('Catherine Frizzle', NULL, NULL, NULL, 0);
SELECT fn_get_responsableid('Catherine Frizzle, COGESAF', NULL, NULL, NULL, 1);

CREATE OR REPLACE FUNCTION fn_get_table(
        _in TYPE
    )
    RETURNS TYPE 
    AS 
    $$
    DECLARE
        _return TYPE;
    BEGIN
        CREATE TABLE temp_fn_get_TABLE AS(
            SELECT 
            FROM  AS 
            WHERE );
        ASSERT (SELECT COUNT(*) FROM temp_fn_get_TABLE) = 1,
            'Expected 1 station, got ' || (SELECT COUNT(*) FROM temp_fn_get_TABLE)::text;
        SELECT * INTO _return FROM temp_fn_get_TABLE LIMIT 1;
        DROP TABLE temp_fn_get_TABLE;
        RETURN _return;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_insert_projet
(
    _val TYPE
    )
    RETURNS void 
    AS 
    $$
    BEGIN
        INSERT INTO public."TABLE" (
            "cHAMPS"
            ) 
        VALUES (
            _VAL
            );
    END;
$$ LANGUAGE plpgsql;