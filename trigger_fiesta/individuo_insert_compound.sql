-- ####### Punto a, b #######
CREATE OR REPLACE TRIGGER individuo_insert_compound
    FOR INSERT
    ON INDIVIDUO
    COMPOUND TRIGGER
    TYPE padres_type IS TABLE OF INDIVIDUO.PADRE%TYPE
        INDEX BY BINARY_INTEGER;
    padres padres_type;

    BEFORE EACH ROW IS
    BEGIN
        -- Punta a
        :NEW.NRO_HIJOS := 0;
        -- Punta b
        -- identifica los insert que tienen padre
        -- y los agrega a una lista
        IF (:NEW.PADRE IS NOT NULL) THEN
            padres(padres.COUNT + 1) := :NEW.PADRE;
        END IF;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        FOR p IN 1..padres.COUNT
            LOOP
                -- recorre la lista de padres e incrementa nro_hijos
                UPDATE INDIVIDUO SET NRO_HIJOS = NRO_HIJOS + 1 WHERE CODIGO = padres(p);
            END LOOP;
    END AFTER STATEMENT;
END individuo_insert_compound;