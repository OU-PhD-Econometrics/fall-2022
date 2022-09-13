version 17

webuse nlsw88
drop if mi(occupation)
recode occupation (8 9 10 11 12 13 = 7)
gen white = race==1
mlogit occupation age white collgrad, base(7)