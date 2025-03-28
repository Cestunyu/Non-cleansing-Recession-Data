cd "/Users/yuun/Documents/Research_Projects/data_task_2.20/"

//---- Convert excel to dta file of USA firm data----//

import excel "data/BDSTIMESERIES.BDSNAICS-2024-12-05T234123.xlsx", sheet("Data") clear
drop E H I J K L M N O P Q R S T U V W X Y Z AA AB AC
ren A year
ren B row_country
ren C row_ind
ren D description
ren F firm_num
ren G est_num
drop in 1
destring year  firm_num est_num, replace ignore(",")
destring row_ind, replace
replace row_country = "USA" if row_country =="United States"
save tempfile/usa_estab_num.dta, replace


//---- Merge and rename industry of shock file ----//

use tempfile/usa_firm/demand_shocks_lco_lso.dta, clear
duplicates drop row_country row_ind year, force
merge 1:1 country_ind year using tempfile/usa_firm/demand_shocks_no_shift_share.dta
drop if _merge == 1 
drop if _merge == 2
drop _merge


gen new_row_ind = ""

replace new_row_ind = "72" if row_ind == "01"
replace new_row_ind = "56" if row_ind == "02"
replace new_row_ind = "11" if row_ind == "03"
replace new_row_ind = "23" if row_ind == "04"
replace new_row_ind = "61" if row_ind == "05"
replace new_row_ind = "52" if row_ind == "06"
replace new_row_ind = "62" if row_ind == "07"
replace new_row_ind = "51" if row_ind == "08"
replace new_row_ind = "31-33" if row_ind == "09"
replace new_row_ind = "21" if row_ind == "10"
replace new_row_ind = "81" if row_ind == "11"
replace new_row_ind = "54" if row_ind == "12"
replace new_row_ind = "53" if row_ind == "13"
replace new_row_ind = "44-45" if row_ind == "14"
replace new_row_ind = "48-49" if row_ind == "15"
replace new_row_ind = "22" if row_ind == "16"
replace new_row_ind = "42" if row_ind == "17"

drop country_ind row_ind
ren new_row_ind row_ind

merge 1:1 row_country year row_ind using tempfile/usa_estab_num.dta



save tempfile/q_estimation_v4_usa.dta, replace 



//---- Re-calculating the inflation ----//


//****
use data/wiot_data/merge_socio_tot_shock_F.dta

keep  row_country row_ind year description F_TOT F_TOT_pyp TOT TOT_pyp 

tostring row_ind, replace format("%02.0f") 
gen mystring = "  "

replace mystring = "01" if inlist(row_ind, "36", "01")
replace mystring = "02" if inlist(row_ind, "26", "50")
replace mystring = "03" if inlist(row_ind, "01", "02", "03")
replace mystring = "04" if row_ind == "27"
replace mystring = "05" if row_ind == "52"
replace mystring = "06" if inlist(row_ind, "41", "42", "43")
replace mystring = "07" if row_ind == "53"
replace mystring = "08" if inlist(row_ind, "37", "38", "39", "40")

gen code_num = real(row_ind)
replace mystring = "09" if inrange(code_num, 5, 22)
drop code_num 

replace mystring = "10" if row_ind == "04"
replace mystring = "11" if inlist(row_ind, "23", "54")
replace mystring = "12" if inlist(row_ind, "45", "46", "47", "48", "49")
replace mystring = "13" if row_ind == "44"
replace mystring = "14" if row_ind == "30"
replace mystring = "15" if inlist(row_ind, "31", "32", "33", "34", "35")
replace mystring = "16" if inlist(row_ind, "24", "25")
replace mystring = "17" if inlist(row_ind, "28", "29")

drop if row_ind == "51"| row_ind ==  "55" | row_ind == "56"
 
drop description row_ind
ren mystring row_ind

collapse (sum) F_TOT F_TOT_pyp TOT TOT_pyp, by(row_country year row_ind)

levelsof row_country, local(countries)foreach c of local countries{
	if row_country ==  "`c'"{
		 forval y = 2001/2014 {
			if year == `y' {
				capture gen deflator = .
				replace deflator = TOT/TOT_pyp - 1
				capture gen p_index = 1
				bysort Country RNr (Year): replace p_index_TOT = p_index[_n-1] * (1 + deflator)  if Year > 2001
				capture gen real_TOT =.
				replace real_TOT = TOT/p_index
			}
		}
	}
}

