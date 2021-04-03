-- 1,Kristin,741,,2
-- 1,Kristin,743,,2
-- Hijos de 1:
-- 2,Graehme,30,1,0
-- 2,Graehme,33,1,0
update INDIVIDUO set VALOR = VALOR + 5 where codigo = 1;
commit;

-- 2,Graehme,33,1,0
-- 2,Graehme,35,1,0
-- 2 No tiene hijos
-- 3,Rozalie,572,1,1
-- 3,Rozalie,574,1,1
-- Hijos de 3:
-- 4,Silvanus,120,3,1
-- 4,Silvanus,123,3,1
update INDIVIDUO set VALOR = VALOR + 5 where padre = 1;
commit;

-- 2,Graehme,35,1,0
-- 2,Graehme,5,1,0
-- 3,Rozalie,574,1,1
-- 3,Rozalie,544,1,1
update INDIVIDUO set VALOR = VALOR - 30 where padre = 1;
commit;

-- 1,Kristin,741,,2
-- 69420,Kristin,741,,2
-- 2,Graehme,30,69420,0
-- 3,Rozalie,572,69420,1
update INDIVIDUO set CODIGO = 69420 where codigo = 1;
commit;