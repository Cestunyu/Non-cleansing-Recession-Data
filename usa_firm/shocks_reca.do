cd "/Users/yuun/Documents/Research_Projects/data_task_2.20/"
clear all
set matsize 11000
set maxvar 5000

use tempfile/usa_firm/temporary/portfolio_2000.dta,clear
mkmat xi*, matrix(ximat)

forval y=2000/2014 {
	append using  tempfile/usa_firm/temporary/f_`y'.dta
}


egen pair_id=group(country_ind col_country)
tsset pair year
egen col_country_year=group(col_country year)

glevelsof row_country, local(country)

glevelsof row_ind, local(industry)

foreach c of local country {
	
	quietly {
		foreach i of local industry {
		cap gen F`c'=F
		replace F`c'=. if row_country=="`c'"
		replace F`c'=. if row_ind=="`i'"
		cap gen lnf=log(F`c')
		bys pair_id: gen dlog_f=d.lnf
		reghdfe dlog_f , absorb( buyer`c'`i'=col_country_year)
		drop dlog lnf
		drop F`c'
		}
	}

	di "`c'"
}



save tempfile/usa_firm/F_shocks_lco_lso,replace



forval y=2001/2014 {
	preserve
	keep if year==`y'
	gcollapse (firstnm) buyer*, by(col_country)

	mkmat buyer*, mat(etamat)
	mat eta`y'_mat=hadamard(ximat,etamat')
	svmat eta`y'_mat
	egen eta`y'=rowtotal(eta`y'_mat*)
	drop eta`y'_mat* buyer* 
	gen n=_n
	greshape long eta, i(n) j(year)
	save tempfile/usa_firm/F_shocks_lco_lso_`y',replace
	restore
}



clear
forval y=2001/2014 {
	append using tempfile/usa_firm/F_shocks_lco_lso_`y'
	drop col_country
}

save tempfile/industry/demand_shocks_lco_lso,replace

use tempfile/usa_firm/temporary/portfolio_2000.dta,clear

keep country_ind row_country row_ind
gen n=_n

merge 1:m n using tempfile/industry/demand_shocks_lco_lso, nogen
drop n
ren eta shock
save tempfile/usa_firm/demand_shocks_lco_lso,replace


/*

levelsof row_country, local(country)
levelsof row_ind, local(industry)
foreach c of local country {
	foreach i of local industry {

		qui bys col_country year: egen step`c'`i'=mean(buyer`c'`i')
		qui replace buyer`c'`i'=step`c'`i'
		drop step`c'`i'
	
	}
	di "`c'"
}


gen buyer=.

levelsof row_country, local(country)
levelsof row_ind, local(industry)

foreach c of local country {
		foreach i of local industry {
		qui replace buyer=buyer`c'`i' if country_ind=="`c'`i'"
		drop buyer`c'`i'
	}
	di "`c'"
}


save tempfile\industry\robustness\F_shocks_lco_lso,replace


****** test of exogeneity
clear all


use tempfile\industry\portfolio,clear
egen id=group(country_ind year)
reshape long xi_, i(id) j(col_country) string
merge 1:1 row_country row_ind col_country year using tempfile\industry\robustness\F_shocks_lco_lso, nogen

xtset pair year


gen f_buyer=f.buyer


egen ind_year=group(country_ind year)
encode row_country, gen(country_code)
reghdfe xi_ f_buyer, absorb(ind_year) cluster(country_code)

eststo orthogonality_test

esttab orthogonality_test using output\orthogonality_test.tex ,  label se  s(N r2, label(N " $ R^2 $ ") ) replace  r2  star(* 0.10 ** 0.05 *** 0.01)

