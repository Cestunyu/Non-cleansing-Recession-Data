cd "/Users/yuun/Documents/Research_Projects/data_task_2.20/"

clear all
set matsize 11000
set maxvar 5000

use tempfile/usa_firm/temporary/portfolio_2000.dta,clear
mkmat xi*, matrix(ximat)

clear 

forval y=2000/2014 {
	append using  tempfile/usa_firm/temporary/f_`y'.dta
}





ren F F

encode col_country, gen(id)
collapse (sum) F, by(id year)

xtset id year

gen dlnf= d.F/l.F
keep id year dlnf
reshape wide dlnf, i(id) j(year)
mkmat dlnf*, matrix(etamat)


mat eta=ximat*etamat


drop *
svmat eta

gen row_country=_n

reshape long eta, i(row_country) j(year)
replace year=year+1999
ren row_country n
save tempfile/usa_firm/demand_shocks_no_shift_share, replace


use tempfile/usa_firm/temporary/portfolio_2000.dta,clear
drop xi_sum
keep country_ind row_country row_ind
gen n=_n

merge 1:m n using tempfile/usa_firm/demand_shocks_no_shift_share, nogen
drop n
ren eta eta_noss
save tempfile/usa_firm/demand_shocks_no_shift_share,replace
