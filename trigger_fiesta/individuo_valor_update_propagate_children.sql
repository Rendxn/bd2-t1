-- Punto e

CREATE OR REPLACE TRIGGER valor_update_propagate_children
    FOR UPDATE OF VALOR
    ON INDIVIDUO
COMPOUND TRIGGER

    TYPE padre_valor_type IS record (
        padre_id   INDIVIDUO.padre%TYPE,
        valor_restante   INDIVIDUO.valor%TYPE
    );

    TYPE padre_valor_list_type IS TABLE OF padre_valor_type
        INDEX BY BINARY_INTEGER;
     padre_valor padre_valor_list_type;

    recursion_level auxiliary.valor%type;

    before statement is begin
        -- Store level of recursion.
        select valor into recursion_level from AUXILIARY where nombre = 'valor_update_level';
    end before statement;

    before each row is begin
        -- If level of recursion is under 1, it means that this row update
        -- was called from outside the trigger.
        -- Therefore, all rules apply:
        --      - Increment must be greater than 5
        --      - Only increments 2.
        --      - Increment rest to first child.
        if (recursion_level < 1) then
            IF (:NEW.VALOR - :OLD.VALOR < 0) THEN
                -- Decrement normally.
                :new.valor := :new.valor;
            ELSIF (:NEW.VALOR - :OLD.VALOR < 5) THEN
                raise_application_error(-20001, 'El incremento debe ser de al menos 5 unidades.');
            ELSE
                -- If the affected row has kids (NRO_HIJOS is greather than 0)
                -- Then it stores the `codigo` of this row and the rest of the increment
                -- that will be added to his first child (hijo)
                IF (:OLD.NRO_HIJOS > 0) THEN
                    padre_valor(padre_valor.count + 1).padre_id := :OLD.CODIGO;
                    padre_valor(padre_valor.count ).valor_restante := :NEW.VALOR - :OLD.VALOR - 2;
                END IF;
                -- Only increments by 2 the updated row.
                :new.valor := :old.valor + 2;
            END IF;
        end if;
    end before each row;

    after statement is
    begin
        -- If level of recursion is under 1, it means that this row update
        -- was called from outside the trigger.
        -- Therefore, we must add the remaining increment to his first child.
        if (recursion_level < 1) then
            -- Update the level of recursion
            update AUXILIARY set VALOR = VALOR + 1 where NOMBRE = 'valor_update_level';
            for p in 1..padre_valor.COUNT
                loop
                    -- Update first child's `valor` column.
                    update INDIVIDUO set valor = valor + padre_valor(p).valor_restante where PADRE = padre_valor(p).padre_id AND ROWNUM = 1;
                end loop;
            -- Reset the level of recursion
            update AUXILIARY set VALOR = 0 where NOMBRE = 'valor_update_level';
        end if;
    end after statement;

END valor_update_propagate_children;