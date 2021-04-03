-- ####### Punto c, d #######

CREATE OR REPLACE TRIGGER individuo_delete_compound
    FOR DELETE
    ON INDIVIDUO
    COMPOUND TRIGGER

    TYPE padres_type IS TABLE OF INDIVIDUO.PADRE%TYPE
        INDEX BY BINARY_INTEGER;
    padres padres_type;

    padres_to_delete padres_type;

    TYPE individuo_type IS TABLE OF individuo%rowtype
        INDEX BY binary_integer;

    originales individuo_type;

    BEFORE STATEMENT IS
    BEGIN
        -- Trae todos los datos de individuo
        select * bulk collect into originales from INDIVIDUO where codigo in (select CODIGO from INDIVIDUO);
        -- Hace todos los padres null
        update INDIVIDUO set PADRE = null where CODIGO is not null;
    end before statement;

    BEFORE EACH ROW IS
    BEGIN
        -- Determina los individuos que van a ser eliminados y tienen padre
        -- y los agrega a una lista
        FOR i in originales.FIRST .. originales.LAST
            LOOP
                IF (originales(i).CODIGO = :OLD.CODIGO) THEN
                    padres(padres.COUNT + 1) := originales(i).PADRE;
                    EXIT;
                end if;
            end loop;
        -- Determina cuales son los que de verdad deberían ser NULL
        -- Y los agrega una lista.
        for i in originales.first .. originales.last
            loop
                IF (originales(i).PADRE = :OLD.CODIGO) THEN
                    padres_to_delete(i) := :OLD.CODIGO;
                else
                    padres_to_delete(i) := null;
                end if;
            end loop;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        -- Recorre la lista de padres que deben reducir su nro_hijos
        for p in 1..padres.COUNT
            loop
                IF (padres(p) IS NOT NULL) THEN
                    UPDATE individuo
                    SET nro_hijos = nro_hijos - 1
                    WHERE CODIGO = padres(p);
                end if;
            end loop;
        -- Recorre todos los individuos y "recupera" los valores de padre, dependiendo de si
        -- este se está eliminando o no.
        FOR p IN originales.FIRST .. originales.LAST
            LOOP
                if (padres_to_delete(p) is null) then
                    UPDATE INDIVIDUO SET PADRE = originales(p).PADRE where CODIGO = originales(p).CODIGO;
                end if;
            END LOOP;
    END AFTER STATEMENT;
END individuo_delete_compound;