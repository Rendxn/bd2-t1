-- 3,Rozalie,572,1,1
-- 1,Kristin,741,,2
-- 1,Kristin,741,,1
delete from INDIVIDUO where codigo = 3;
commit;

-- 1,Kristin,741,,2
-- 3,Rozalie,572,1,1
-- 3,Rozalie,572,null,1
delete from INDIVIDUO where codigo = 1;
commit;