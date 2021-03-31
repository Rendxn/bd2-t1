CREATE TABLE cerdo
(
    cod       NUMBER(8) PRIMARY KEY,
    nombre    VARCHAR(20) NOT NULL,
    pesokilos NUMBER(8)   NOT NULL CHECK (pesokilos > 0)
);

CREATE TABLE camion
(
    idcamion             NUMBER(8) PRIMARY KEY,
    maximacapacidadkilos NUMBER(8) NOT NULL CHECK (maximacapacidadkilos > 0)
);

INSERT ALL
    into cerdo (cod, nombre, pesokilos)
values (2, 'Ana Criado', 3)
into cerdo (cod, nombre, pesokilos)
values (4, 'Dua Lipa', 3)
into cerdo (cod, nombre, pesokilos)
values (8, 'Saffron', 3)
into cerdo (cod, nombre, pesokilos)
values (11, 'Ava Max', 3)
into cerdo (cod, nombre, pesokilos)
values (15, 'Esthero', 8)
select *
from dual;

INSERT ALL
    INTO camion(idcamion, maximacapacidadkilos)
values (13, 10)
INTO camion(idcamion, maximacapacidadkilos)
values (38, 7)
INTO camion(idcamion, maximacapacidadkilos)
values (22, 8)
select *
from dual;

commit;