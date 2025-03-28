*local dir "C:/Users/alessandro/OneDrive - Istituto Universitario Europeo/GBC and GVC/data/wiot_stata_16"
// local dir "G:/GVC"
local dir "/Users/yuun/Documents/Research_Projects/data_task_2.20/"
cd "`dir'"
clear

// reghdfe, compile
// ftools, compile


cap mkdir "`dir'/tempfile"
cap mkdir "`dir'/tempfile/usa_firm/inventories"

forval y=2000/2014 {

	use tempfile/usa_firm/wiot_`y'_reclassified.dta,clear
	keep row_country year country_ind row_ind v*57 v*58 v*59 
	drop if row_country=="ZZZ"
	levelsof row_country, local(country)
	foreach c of local country {
		egen F_`c'=rowtotal(v`c'*)
	}
	drop v*
	reshape long F_, i(country_ind) j(col_country) string
	save tempfile/usa_firm/temporary/f_`y',replace
}


clear 
forval y=2000/2014 {
	append using tempfile/usa_firm/temporary/f_`y'
}

ren F F


egen pair_id=group(country_ind col_country)
tsset pair year

gen lnf=log(F)
bys pair_id: gen dlog_f=d.lnf

egen col_country_year=group(col_country year)
reghdfe dlog_f , absorb( buyer=col_country_year )


save tempfile/usa_firm/industry/F_shocks,replace


