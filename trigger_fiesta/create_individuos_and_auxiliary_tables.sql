CREATE TABLE individuo(
codigo NUMBER(8) PRIMARY KEY,
nombre VARCHAR2(20) NOT NULL,
valor NUMBER(8) NOT NULL CHECK (valor > 0),
padre NUMBER(8) REFERENCES individuo, -- código del padre del individuo
nro_hijos NUMBER(8) NOT NULL CHECK (nro_hijos >=0),
CHECK(padre <> codigo)
);

-- AUXILIARY TABLE

CREATE TABLE auxiliary(
 nombre VARCHAR2(20) PRIMARY KEY,
 valor NUMBER(8)
);

-- Populate with auxiliary value
insert into auxiliary (nombre, valor) values ('valor_update_level', 0);
commit;