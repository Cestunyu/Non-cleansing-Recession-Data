
cd "/Users/yuun/Documents/Research_Projects/data_task_2.20/"
use tempfile/q_estimation_v3_no_estab.dta, clear


mkdir tempfile/usa_firm



gen merge_index = . 
gen new_description = .

tostring merge_index new_description, replace

replace merge_index = "72" if row_ind == 36
replace new_description = "Accommodation and food services" if row_ind == 36

replace merge_index = "56" if row_ind == 50 | row_ind == 26
replace new_description = "Administrative and support and waste management and remediation services" if row_ind == 50 | row_ind == 26

replace merge_index = "11" if inlist(row_ind, 1, 2, 3)
replace new_description = "Agriculture, forestry, fishing and hunting" if inlist(row_ind, 1, 2, 3)

replace merge_index = "71" if row_ind == 38
replace new_description = "Arts, entertainment, and recreation" if row_ind == 38

replace merge_index = "23" if row_ind == 27
replace new_description = "Construction" if row_ind == 27

replace merge_index = "61" if row_ind == 52
replace new_description = "Educational services" if row_ind == 52

replace merge_index = "52" if inlist(row_ind, 41, 42, 43)
replace new_description = "Finance and insurance" if inlist(row_ind, 41, 42, 43)

replace merge_index = "62" if row_ind == 53
replace new_description = "Health care and social assistance" if row_ind == 53

replace merge_index = "51" if inlist(row_ind, 40, 39, 37)
replace new_description = "Information" if inlist(row_ind, 40, 39, 37)

replace merge_index = "55" if row_ind == 45
replace new_description = "Management of companies and enterprises" if row_ind == 45

replace merge_index = "31-33" if inlist(row_ind, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22)
replace new_description = "Manufacturing" if inlist(row_ind, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22)

replace merge_index = "21" if row_ind == 4
replace new_description = "Mining, quarrying, and oil and gas extraction" if row_ind == 4

replace merge_index = "81" if row_ind == 54
replace new_description = "Other services (except public administration)" if row_ind == 54

replace merge_index = "54" if row_ind == 49
replace new_description = "Professional, scientific, and technical services" if row_ind == 49

replace merge_index = "53" if row_ind == 44
replace new_description = "Real estate and rental and leasing" if row_ind == 44

replace merge_index = "44-45" if row_ind == 30
replace new_description = "Retail trade" if row_ind == 30

replace merge_index = "48-49" if inlist(row_ind, 31, 32, 33, 34, 35)
replace new_description = "Transportation and warehousing" if inlist(row_ind, 31, 32, 33, 34, 35)

replace merge_index = "22" if inlist(row_ind, 24, 25)
replace new_description = "Utilities" if inlist(row_ind, 24, 25)

replace merge_index = "42" if inlist(row_ind, 28, 29)
replace new_description = "Wholesale trade" if inlist(row_ind, 28, 29)


* Drop everything related to previous industry


drop row_ind country_ind code description

save tempfile/usa_firm/q_estimation_v3_usa_estab.dta, replace


*** Summing up directly additive variables ***

use tempfile/usa_firm/q_estimation_v3_usa_estab.dta, clear
collapse (sum) F_TOT real_F_TOT F_TOT_pyp TOT real_TOT TOT_pyp LAB CAP GO II K, by(merge_index row_country year)
drop if merge_index == "."
save tempfile/usa_firm/q_estimation_v3_sum.dta, replace



*** Calculating weighted averages for "shock" and "inflation" group ***

use tempfile/usa_firm/q_estimation_v3_usa_estab.dta, clear
drop if merge_index == "."
collapse (mean) shock eta_noss eta_noss_oecd shock_oecd deflator p_index F_inflation_rate [aw=F_TOT], by(merge_index row_country year)
save tempfile/usa_firm/q_estimation_v3_weighted.dta, replace


*** Merge collapsed data
use tempfile/usa_firm/q_estimation_v3_weighted.dta, clear
merge 1:1 merge_index row_country year using tempfile/usa_firm/q_estimation_v3_sum.dta
drop if _merge == 2
drop _merge


*** Merge with USA firm data 
use tempfile/usa_estab_num.dta, clear



*** ren
ren merge_index industry_index 
label variable industry_index "NAICS 2 digit classification of industries"
