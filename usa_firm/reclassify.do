*** This file collapse the original 56 industries into 19 industries and alter 


cd "/Users/yuun/Documents/Research_Projects/data_task_2.20/"

forval y=2000/2014 {
	quietly {
		use tempfile/temporary/wiot_`y',clear
		drop if row_country == "ZZZ"
		levelsof row_country , local(country)
		foreach c of local country {					
			gen temp_v`c'01 = v`c'36
			gen temp_v`c'02 = v`c'26 + v`c'50
			gen temp_v`c'03 = v`c'01 + v`c'02 + v`c'03
			gen temp_v`c'04 = v`c'27
			gen temp_v`c'05 = v`c'52
			gen temp_v`c'06 = v`c'41 + v`c'42 + v`c'43
			gen temp_v`c'07 = v`c'53
			gen temp_v`c'08 = v`c'37 + v`c'38 + v`c'39 + v`c'40
			gen temp_v`c'09 = v`c'05 + v`c'06 + v`c'07 + v`c'08 + v`c'09 + v`c'10 + v`c'11 + v`c'12 + v`c'13 + v`c'14 + v`c'15 + v`c'16 + v`c'17 + v`c'18 + v`c'19 + v`c'20 + v`c'21 + v`c'22
			gen temp_v`c'10 = v`c'04
			gen temp_v`c'11 = v`c'23 + v`c'54
			gen temp_v`c'12 = v`c'45 + v`c'46 + v`c'47 + v`c'48 + v`c'49
			gen temp_v`c'13 = v`c'44
			gen temp_v`c'14 = v`c'30
			gen temp_v`c'15 = v`c'31 + v`c'32 + v`c'33 + v`c'34 + v`c'35
			gen temp_v`c'16 = v`c'24 + v`c'25
			gen temp_v`c'17 = v`c'28 + v`c'29
			
			drop v`c'01-v`c'56
			
			rename temp_v`c'01 v`c'01
			rename temp_v`c'02 v`c'02
			rename temp_v`c'03 v`c'03
			rename temp_v`c'04 v`c'04
			rename temp_v`c'05 v`c'05
			rename temp_v`c'06 v`c'06
			rename temp_v`c'07 v`c'07
			rename temp_v`c'08 v`c'08
			rename temp_v`c'09 v`c'09
			rename temp_v`c'10 v`c'10
			rename temp_v`c'11 v`c'11
			rename temp_v`c'12 v`c'12
			rename temp_v`c'13 v`c'13
			rename temp_v`c'14 v`c'14
			rename temp_v`c'15 v`c'15
			rename temp_v`c'16 v`c'16
			rename temp_v`c'17 v`c'17
		}
		
		
		
	}
	save tempfile/usa_firm/wiot_`y'_reclassified.dta,replace
}






	

	
// Configure progress display parameters
local start_year 2000
local end_year 2014
local total_years = `end_year' - `start_year' + 1

forval y = `start_year'/`end_year' {
    // Display year progress

	
    noi di _n(2) "====== Processing Year `y' ======"
    noi di "Overall Progress: " `y'-`start_year'+1 "/`total_years' (" %4.1f 100*(`y'-`start_year')/`total_years' "%)"
	
    quietly {
        use tempfile/usa_firm/wiot_`y'_reclassified.dta, clear
        drop if row_country == "ZZZ"
        levelsof row_country, local(countries)
        
        // Initialize country counters
        local country_counter 0
        local total_countries : word count `countries'
        
        foreach country of local countries {
			local ++country_counter
            noi di "Processing `country' (" %3.1f 100*(`country_counter'-1)/`total_countries' "%)" _continue
			quietly {
			
			
				/* ====== Basic Settings ====== */
				
				local base_code "temp"   // new code prefix
				local year_var "year"    // time variable name
				local row_country "row_country"  // row country identifier variable
// 				local country "AUS"
				
				/* ====== Mapping Processing ====== */

				// Mapping rule 1: 36 → 01
				preserve
				keep if country_ind == "`country'36"
				replace country_ind = "`base_code'_`country'01"
				replace row_ind = "01"
				tempfile temp01
				save `temp01'
				restore
				append using `temp01'

				// Mapping rule 2: 26+50 → 02
				preserve
				keep if inlist(country_ind, "`country'26", "`country'50")
				quietly ds `row_country' `year_var' country_ind row_ind, not
				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
				gen country_ind = "`base_code'_`country'02" 
				gen row_ind = "02"
				tempfile temp02
				save `temp02'
				restore
				append using `temp02'

				// Mapping rule 3: 1+2+3 → 03
				preserve
				keep if inlist(country_ind, "`country'01", "`country'02", "`country'03")
				quietly ds `row_country' `year_var' country_ind row_ind, not  
				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
				gen country_ind = "`base_code'_`country'03"
				gen row_ind = "03"
				tempfile temp03
				save `temp03'
				restore
				append using `temp03'

				// Mapping rule 4: 27 → 04 (single value copy)
				preserve
				keep if country_ind == "`country'27"
				replace country_ind = "`base_code'_`country'04"
				replace row_ind = "04"
				tempfile temp04
				save `temp04' 
				restore
				append using `temp04'

				// Mapping rule 5: 52 → 05 (single value copy)
				preserve
				keep if country_ind == "`country'52"
				replace country_ind = "`base_code'_`country'05"
				replace row_ind = "05"
				tempfile temp05
				save `temp05'
				restore
				append using `temp05'

				// Mapping rule 6: 41+42+43 → 06
				preserve
				keep if inlist(country_ind, "`country'41", "`country'42", "`country'43")
				quietly ds `row_country' `year_var' country_ind row_ind, not
				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
				gen country_ind = "`base_code'_`country'06"
				gen row_ind = "06"
				tempfile temp06
				save `temp06'
				restore
				append using `temp06'

				// Mapping rule 7: 53 → 07 (single value copy)
				preserve
				keep if country_ind == "`country'53"
				replace country_ind = "`base_code'_`country'07"
				replace row_ind = "07"
				tempfile temp07
				save `temp07'
				restore
				append using `temp07'

				// Mapping rule 8: 37-40 → 08
				preserve
				keep if inlist(country_ind, "`country'37", "`country'38", "`country'39", "`country'40")
				quietly ds `row_country' `year_var' country_ind row_ind, not
				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
				gen country_ind = "`base_code'_`country'08"
				gen row_ind = "08"
				tempfile temp08
				save `temp08'
				restore
				append using `temp08'

				// Mapping rule 9: 5-22 → 09
				preserve
				gen code_num = real(substr(country_ind, 4, 2))
				keep if substr(country_ind,1,3)== "`country'"  & inrange(code_num, 5, 22)
				//  levelsof country_ind
				quietly ds `row_country' `year_var' country_ind row_ind, not
				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
				gen country_ind = "`base_code'_`country'09"
				gen row_ind = "09"
				tempfile temp09
				save `temp09'
				restore
				append using `temp09'
				drop code_num

				// Mapping rule 10: 4 → 10 (single value copy)
				preserve
				keep if country_ind == "`country'04"
				replace country_ind = "`base_code'_`country'10"
				replace row_ind = "10"
				tempfile temp10
				save `temp10'
				restore
				append using `temp10'

				// Mapping rule 11: 23+54 → 11
				preserve
				keep if inlist(country_ind, "`country'23", "`country'54")
				quietly ds `row_country' `year_var' country_ind row_ind, not
				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
				gen country_ind = "`base_code'_`country'11"
				gen row_ind = "11"
				tempfile temp11
				save `temp11'
				restore
				append using `temp11'

				// Mapping rule 12: 45-49 → 12
				preserve
				keep if inlist(country_ind, "`country'45", "`country'46", "`country'47", "`country'48", "`country'49")
				quietly ds `row_country' `year_var' country_ind row_ind, not
				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
				gen country_ind = "`base_code'_`country'12"
				gen row_ind = "12"
				tempfile temp12
				save `temp12'
				restore
				append using `temp12'

				// Mapping rule 13: 44 → 13 (single value copy)
				preserve
				keep if country_ind == "`country'44"
				replace country_ind = "`base_code'_`country'13"
				replace row_ind = "13"
				tempfile temp13
				save `temp13'
				restore
				append using `temp13'

				// Mapping rule 14: 30 → 14 (single value copy)
				preserve
				keep if country_ind == "`country'30"
				replace country_ind = "`base_code'_`country'14"
				replace row_ind = "14"
				tempfile temp14
				save `temp14'
				restore
				append using `temp14'

				// Mapping rule 15: 31-35 → 15
				preserve
				keep if inlist(country_ind, "`country'31", "`country'32", "`country'33", "`country'34", "`country'35")
				quietly ds `row_country' `year_var' country_ind row_ind, not
				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
				gen country_ind = "`base_code'_`country'15"
				gen row_ind = "15"
				tempfile temp15
				save `temp15'
				restore
				append using `temp15'

				// Mapping rule 16: 24+25 → 16
				preserve
				keep if inlist(country_ind, "`country'24", "`country'25")
				quietly ds `row_country' `year_var' country_ind row_ind, not
				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
				gen country_ind = "`base_code'_`country'16"
				gen row_ind = "16"
				tempfile temp16
				save `temp16'
				restore
				append using `temp16'

				// Mapping rule 17: 28+29 → 17
				preserve
				keep if inlist(country_ind, "`country'28", "`country'29")
				quietly ds `row_country' `year_var' country_ind row_ind, not
				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
				gen country_ind = "`base_code'_`country'17"
				gen row_ind = "17"
				tempfile temp17
				save `temp17'
				restore
				append using `temp17'

				/* ====== Final Processing ====== */
				compress  // compress storage space
				label drop _all  // drop all old labels

				/* ====== Drop and Rename ====== */
				drop if substr(country_ind, 1, 3) == "`country'"
				forval i = 1/17 {
					local ii : display %02.0f `i'
					replace country_ind = "`country'`ii'" if country_ind == "temp_`country'`ii'"
				}
	
			}
			}
	}
    save tempfile/usa_firm/wiot_`y'_reclassified.dta, replace
}







// forval y=2000/2014 {
// 	quietly {
// 		use tempfile/usa_firm/wiot_`y'_reclassified.dta,clear
// 		drop if row_country == "ZZZ"
// 		levelsof row_country , local(countries)
// 		foreach country of local countries {	
// // 			use tempfile/usa_firm/wiot_2014_reclassified.dta, clear		
// // 			local country "AUS" 
// 			di country
// 			quietly {
// 				/* ====== Basic Settings ====== */
				
// 				local base_code "temp"   // new code prefix
// 				local year_var "year"    // time variable name
// 				local row_country "row_country"  // row country identifier variable

// 				/* ====== Mapping Processing ====== */

// 				// Mapping rule 1: 36 → 01
// 				preserve
// 				keep if country_ind == "`country'36"
// 				replace country_ind = "`base_code'_`country'01"
// 				replace row_ind = "01"
// 				tempfile temp01
// 				save `temp01'
// 				restore
// 				append using `temp01'

// 				// Mapping rule 2: 26+50 → 02
// 				preserve
// 				keep if inlist(country_ind, "`country'26", "`country'50")
// 				quietly ds `row_country' `year_var' country_ind row_ind, not
// 				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
// 				gen country_ind = "`base_code'_`country'02" 
// 				gen row_ind = "02"
// 				tempfile temp02
// 				save `temp02'
// 				restore
// 				append using `temp02'

// 				// Mapping rule 3: 1+2+3 → 03
// 				preserve
// 				keep if inlist(country_ind, "`country'01", "`country'02", "`country'03")
// 				quietly ds `row_country' `year_var' country_ind row_ind, not  
// 				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
// 				gen country_ind = "`base_code'_`country'03"
// 				gen row_ind = "03"
// 				tempfile temp03
// 				save `temp03'
// 				restore
// 				append using `temp03'

// 				// Mapping rule 4: 27 → 04 (single value copy)
// 				preserve
// 				keep if country_ind == "`country'27"
// 				replace country_ind = "`base_code'_`country'04"
// 				replace row_ind = "04"
// 				tempfile temp04
// 				save `temp04' 
// 				restore
// 				append using `temp04'

// 				// Mapping rule 5: 52 → 05 (single value copy)
// 				preserve
// 				keep if country_ind == "`country'52"
// 				replace country_ind = "`base_code'_`country'05"
// 				replace row_ind = "05"
// 				tempfile temp05
// 				save `temp05'
// 				restore
// 				append using `temp05'

// 				// Mapping rule 6: 41+42+43 → 06
// 				preserve
// 				keep if inlist(country_ind, "`country'41", "`country'42", "`country'43")
// 				quietly ds `row_country' `year_var' country_ind row_ind, not
// 				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
// 				gen country_ind = "`base_code'_`country'06"
// 				gen row_ind = "06"
// 				tempfile temp06
// 				save `temp06'
// 				restore
// 				append using `temp06'

// 				// Mapping rule 7: 53 → 07 (single value copy)
// 				preserve
// 				keep if country_ind == "`country'53"
// 				replace country_ind = "`base_code'_`country'07"
// 				replace row_ind = "07"
// 				tempfile temp07
// 				save `temp07'
// 				restore
// 				append using `temp07'

// 				// Mapping rule 8: 37-40 → 08
// 				preserve
// 				keep if inlist(country_ind, "`country'37", "`country'38", "`country'39", "`country'40")
// 				quietly ds `row_country' `year_var' country_ind row_ind, not
// 				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
// 				gen country_ind = "`base_code'_`country'08"
// 				gen row_ind = "08"
// 				tempfile temp08
// 				save `temp08'
// 				restore
// 				append using `temp08'

// 				// Mapping rule 9: 5-22 → 09
// 				preserve
// 				gen code_num = real(substr(country_ind, 4, 2))
// 				keep if substr(country_ind,1,3)== "`country'"  & inrange(code_num, 5, 22)
// 				//  levelsof country_ind
// 				quietly ds `row_country' `year_var' country_ind row_ind, not
// 				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
// 				gen country_ind = "`base_code'_`country'09"
// 				gen row_ind = "09"
// 				tempfile temp09
// 				save `temp09'
// 				restore
// 				append using `temp09'
// 				drop code_num

// 				// Mapping rule 10: 4 → 10 (single value copy)
// 				preserve
// 				keep if country_ind == "`country'04"
// 				replace country_ind = "`base_code'_`country'10"
// 				replace row_ind = "10"
// 				tempfile temp10
// 				save `temp10'
// 				restore
// 				append using `temp10'

// 				// Mapping rule 11: 23+54 → 11
// 				preserve
// 				keep if inlist(country_ind, "`country'23", "`country'54")
// 				quietly ds `row_country' `year_var' country_ind row_ind, not
// 				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
// 				gen country_ind = "`base_code'_`country'11"
// 				gen row_ind = "11"
// 				tempfile temp11
// 				save `temp11'
// 				restore
// 				append using `temp11'

// 				// Mapping rule 12: 45-49 → 12
// 				preserve
// 				keep if inlist(country_ind, "`country'45", "`country'46", "`country'47", "`country'48", "`country'49")
// 				quietly ds `row_country' `year_var' country_ind row_ind, not
// 				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
// 				gen country_ind = "`base_code'_`country'12"
// 				gen row_ind = "12"
// 				tempfile temp12
// 				save `temp12'
// 				restore
// 				append using `temp12'

// 				// Mapping rule 13: 44 → 13 (single value copy)
// 				preserve
// 				keep if country_ind == "`country'44"
// 				replace country_ind = "`base_code'_`country'13"
// 				replace row_ind = "13"
// 				tempfile temp13
// 				save `temp13'
// 				restore
// 				append using `temp13'

// 				// Mapping rule 14: 30 → 14 (single value copy)
// 				preserve
// 				keep if country_ind == "`country'30"
// 				replace country_ind = "`base_code'_`country'14"
// 				replace row_ind = "14"
// 				tempfile temp14
// 				save `temp14'
// 				restore
// 				append using `temp14'

// 				// Mapping rule 15: 31-35 → 15
// 				preserve
// 				keep if inlist(country_ind, "`country'31", "`country'32", "`country'33", "`country'34", "`country'35")
// 				quietly ds `row_country' `year_var' country_ind row_ind, not
// 				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
// 				gen country_ind = "`base_code'_`country'15"
// 				gen row_ind = "15"
// 				tempfile temp15
// 				save `temp15'
// 				restore
// 				append using `temp15'

// 				// Mapping rule 16: 24+25 → 16
// 				preserve
// 				keep if inlist(country_ind, "`country'24", "`country'25")
// 				quietly ds `row_country' `year_var' country_ind row_ind, not
// 				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
// 				gen country_ind = "`base_code'_`country'16"
// 				gen row_ind = "16"
// 				tempfile temp16
// 				save `temp16'
// 				restore
// 				append using `temp16'

// 				// Mapping rule 17: 28+29 → 17
// 				preserve
// 				keep if inlist(country_ind, "`country'28", "`country'29")
// 				quietly ds `row_country' `year_var' country_ind row_ind, not
// 				collapse (sum) `r(varlist)', by(`row_country' `year_var') fast
// 				gen country_ind = "`base_code'_`country'17"
// 				gen row_ind = "17"
// 				tempfile temp17
// 				save `temp17'
// 				restore
// 				append using `temp17'

// 				/* ====== Final Processing ====== */
// 				compress  // compress storage space
// 				label drop _all  // drop all old labels

// 				/* ====== Drop and Rename ====== */
// 				drop if substr(country_ind, 1, 3) == "`country'"
// 				forval i = 1/17 {
// 					local ii : display %02.0f `i'
// 					replace country_ind = "`country'`ii'" if country_ind == "temp_`country'`ii'"
// 				}
	
// 			}
// 		}		
// 	}
// 	save tempfile/usa_firm/wiot_`y'_reclassified.dta,replace
// }




