clear all

*local dir "C:/Users/alessandro/OneDrive - Istituto Universitario Europeo/GBC and GVC/data/wiot_stata_16"
local dir "/Users/yuun/Documents/Research_Projects/data_task_2.20/"
*local codes "C:/Users/alessandro/Dropbox/research/GVC and GBC/codes"

cd "`dir'"
clear

*** U no Services **

*------------------------------------------------------------
* this code starts by computing upstreamness and downstreamness for each
* country-industry pair. then it proceeds to compute the
* bilateral measures via trade weights.
*------------------------------------------------------------

*--------------------------------------------
* create measure of upstreamness
*--------------------------------------------

set matsize 11000,perm


**************************************
* split the WIOD data into year by year I-O tables
**************************************

cap mkdir "`dir'/tempfile"
cap mkdir "`dir'/tempfile/usa_firm/inventories"


forval y=2000/2014 {
	quietly {
		use tempfile/usa_firm/wiot_`y'_reclassified.dta,clear
		drop if row_country=="ZZZ"
		levelsof row_country , local(country)
		levelsof row_ind , local(industry)
		*create use industry weights
		foreach c of local country {
			egen intermediate_total=rowtotal(v`c'*)
			*egen finalconsumption=rowtotal(v`c'57-v`c'61)
			* create country inventory consumption (N_ij^r)
			gen N`c'=v`c'60+v`c'61
			foreach i of local industry {
				* create industry inventory consumption (N_ij^rs)
				gen weight=v`c'`i'/intermediate_total	//(-finalconsumption)
				gen N`c'`i'=N`c'*weight
				drop weight
			}
		drop intermediate_total N`c' // finalconsumption
		}
	*drop v*
	}
save tempfile/usa_firm/inventories/N`y'.dta,replace
	
}


