DECLARE
    -- Similar to 0/1 knapsack
    TYPE number_row IS TABLE OF NUMERIC -- table of number(8)
        INDEX BY BINARY_INTEGER;
    TYPE matrix IS TABLE OF number_row -- table of peso
        INDEX BY BINARY_INTEGER;
    weights          matrix;

    TYPE trucks_type IS TABLE OF CAMION%rowtype;
    trucks           trucks_type;

    TYPE pigs_type IS TABLE OF CERDO%rowtype;
    pigs             pigs_type;
    available_pigs   pigs_type;
    requested_weight NUMBER;
    remaining_weight NUMBER;
    max_weight       NUMBER;
    aux              NUMBER;
    truck_weights    number_row;
    pigs_str         VARCHAR2(2000);
    truck_str        VARCHAR2(2000);
    w                NUMBER;
    res              NUMBER;

BEGIN
    -- User input
    requested_weight := : requested_weight;
    remaining_weight := requested_weight;
    -- Get all trucks ordered by max weight.
    select *
        bulk collect
    into trucks
    from camion
    order by MAXIMACAPACIDADKILOS desc;
    -- Get all pigs.
    select *
        bulk collect
    into pigs
    from cerdo;

    available_pigs := pigs;

    if(trucks.COUNT = 0) then
        raise_application_error(-20001, 'La tabla CAMION está vacía.');
    end if;

    if(pigs.COUNT = 0) then
        raise_application_error(-20001, 'La tabla CERDO está vacía.');
    end if;

    -- For each truck, there's a Knapsack problem
    for t in 1..trucks.count
        loop
            -- Min between the max capacity of the truck and the remaining requested weight.
            select least(trucks(t).MAXIMACAPACIDADKILOS, remaining_weight) into max_weight from dual;
            -- p is the index of the pig.
            pigs_str := null;
            for p in 0..pigs.count
                loop
                    -- wt is the current weight in the matrix.
                    for wt in 0..max_weight
                        loop
                            -- Knapsack. See: https://youtu.be/xCbYmUPvc2Q?t=548
                            if (p = 0 or wt = 0) then
                                weights(p)(wt) := 0;
                            elsif (pigs(p).PESOKILOS <= wt and available_pigs.exists(p)) then
                                -- Gets the max/greatest between the current possible weight
                                -- and the max weight with one less pig.
                                if (pigs(p).PESOKILOS + weights(p - 1)(wt - pigs(p).PESOKILOS) >
                                    weights(p - 1)(wt)) then
                                    weights(p)(wt) := pigs(p).PESOKILOS + weights(p - 1)(wt - pigs(p).PESOKILOS);
                                else
                                    weights(p)(wt) := weights(p - 1)(wt);
                                end if;
                            else
                                weights(p)(wt) := weights(p - 1)(wt);
                            end if;
                            -- DBMS_OUTPUT.PUT_LINE('Weight: ' || wt || ', Pigs: ' || p || ': ' || weights(p)(wt));
                        end loop;
                end loop;

            -- If at the last cell and it equals 0
            -- it means no pig could fit in the truck
            -- so there is no solution for this truck.
            if weights(pigs.count)(max_weight) = 0 then
                -- If this happens for the first truck
                -- it means no pigs were sent in previous
                -- trucks.
                if (t = 1) then
                    DBMS_OUTPUT.PUT_LINE('El pedido no se puede satisfacer');
                end if;
                -- Exit anyway if nothing fits in truck.
                exit;
            end if;

            -- Stores the weight that is put in the truck i
            truck_weights(t) := weights(pigs.count)(max_weight);
            w := max_weight;
            res := truck_weights(t);

            for i in REVERSE 1 .. pigs.count LOOP
                if (res <= 0) then
                    exit;
                    -- either the result comes from the
                    -- top (K[i-1][w]) or from (val[i-1]
                    -- + K[i-1] [w-wt[i-1]]) as in Knapsack
                    -- table. If it comes from the latter
                    -- one/ it means the item is included.
                END IF;
                if (res = weights(i - 1)(w)) then
                    CONTINUE;
                else
                     -- This item is included.
                    if (pigs_str is null) then
                        pigs_str := pigs(i).COD || ' (' || pigs(i).NOMBRE ||
                                                        ') ' ||
                                                        pigs(i).PESOKILOS || 'kg';
                    else
                        pigs_str := pigs_str || ', ' || pigs(i).COD || ' (' || pigs(i).NOMBRE ||
                                                        ') ' ||
                                                        pigs(i).PESOKILOS || 'kg';
                    end if;

                    available_pigs.delete(i);

                    -- Since this weight is included
                    -- its value is deducted
                    res := res - pigs(i).PESOKILOS;
                    w := w - pigs(i).PESOKILOS;
                END IF;
            END LOOP;

            -- Prints header only for the first truck.
            if (t = 1) then
                DBMS_OUTPUT.PUT_LINE('Informe para Mi Cerdito.');
                DBMS_OUTPUT.PUT_LINE('-----');
            end if;

            -- Building output for the truck.
            truck_str := '' || truck_weights(t) || 'kg.';
            aux := trucks(t).MAXIMACAPACIDADKILOS - truck_weights(t);
            truck_str := truck_str || ' Capacidad no usada del camión: ' || aux || 'kg';

            -- Report for this truck.
            DBMS_OUTPUT.PUT_LINE('Camión: ' || trucks(t).IDCAMION);
            DBMS_OUTPUT.PUT_LINE('Lista cerdos: ' || pigs_str);
            DBMS_OUTPUT.PUT_LINE('Total peso cerdos: ' || truck_str);
            --

            -- Update the remaining weight.
            remaining_weight := remaining_weight - truck_weights(t);
            -- trucks.delete(t);
        end loop;
    aux := requested_weight - remaining_weight;

    -- Prints footer if there is at least 1 sold pig.
    if (truck_weights.count > 0) then
        DBMS_OUTPUT.PUT_LINE('-----');
        DBMS_OUTPUT.PUT_LINE('Total Peso solicitado: ' || requested_weight || ' kg. Peso real enviado: ' || aux
            || 'kg. Peso no satisfecho: ' || remaining_weight ||
                             'kg.');
    end if;
END;
