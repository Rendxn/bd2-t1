-- ###### Punto f

CREATE OR REPLACE TRIGGER codigo_update_cascade
    FOR UPDATE OF CODIGO
    ON INDIVIDUO
    COMPOUND TRIGGER

    TYPE individuo_type IS TABLE OF individuo%rowtype
        INDEX BY binary_integer;

    originales individuo_type;

    TYPE new_old_record_type IS record (
        old_codigo individuo.codigo%type,
        new_codigo individuo.codigo%type
    );

    TYPE new_old_list_type IS TABLE OF new_old_record_type
        INDEX BY binary_integer;

    new_old new_old_list_type;

    --

    BEFORE STATEMENT IS
    BEGIN
        SELECT *
        BULK COLLECT
        INTO originales
        FROM INDIVIDUO;

        UPDATE individuo
        SET padre = NULL
        WHERE CODIGO is not null;
    end before statement;

    BEFORE EACH ROW IS
    BEGIN
        new_old(:old.codigo).new_codigo := :NEW.CODIGO;
        new_old(:old.codigo).old_codigo := :OLD.CODIGO;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        FOR p IN 1..originales.COUNT
            LOOP
                if (new_old.exists(originales(p).PADRE)) then
                    if (originales(p).padre is not null and originales(p).padre = new_old(originales(p).PADRE).old_codigo) then
                        UPDATE INDIVIDUO SET PADRE = new_old(originales(p).PADRE).new_codigo where CODIGO = originales(p).CODIGO;
                    end if;
                else
                    UPDATE INDIVIDUO SET PADRE = originales(p).padre where CODIGO = originales(p).CODIGO;
                end if;
            END LOOP;
    end AFTER STATEMENT;

END codigo_update_cascade;