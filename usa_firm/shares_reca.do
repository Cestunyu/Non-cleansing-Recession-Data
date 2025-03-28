*** demand portfolio composition ***


// local dir "G:/GVC"
*local dir "C:/Users/alessandro/OneDrive - Istituto Universitario Europeo/GBC and GVC/July"

local dir "/Users/yuun/Documents/Research_Projects/data_task_2.20/"

clear all
set maxvar  32000,perm

cd "`dir'"

*------------------------------------------------------------
* this code cleans and formats the raw WIOD data 
*------------------------------------------------------------

*--------------------------------------------
* create portfolio shares
*--------------------------------------------

set matsize 11000,perm



**************************************
* prepare the WIOD data
**************************************

cap mkdir "`dir'/tempfile"


** portfolio shares are a measure of how much of the output of ind r in country i
* ends us being final consumption of j. this is computed as Y^-1[I-A]^-1 F_j


forval y=2000/2014 {
	use tempfile/usa_firm/wiot_`y'_reclassified.dta,clear
	
	* merge with inventory data to correct gross output

	merge 1:1 country_ind using tempfile/usa_firm/inventories/N`y'.dta

	levelsof row_country if row_country!="ZZZ", local(country)
	levelsof row_ind if row_ind!="73" & row_ind!="70", local(industry)
	quietly {
		foreach c of local country {
			foreach i of local industry {
			
				* apply inventory correction
				
				egen inv=sum(N`c'`i')
				
				** NOTE: here a further correction is necessary:
				* by the imputation method for inventories, it may happen
				* that some industry gets imputed inventories usage higher than
				* their value added, this would result in the sum of the a coefficients
				* being larger than 1. if that is the case then the convergence result for 
				* the Leontief inverse does not hold any longer
				* for this reason if N>VA i set N=VA, so that the convergence occurs again.
				
				if inv> v`c'`i'[_N-1] {
					replace inv=v`c'`i'[_N-1]
				}
							
				replace v`c'`i'=v`c'`i'[_N]-inv if row_country=="ZZZ" & _n==_N
				drop inv 
				
				* compute input requirements coefficients
				gen a`c'`i'=v`c'`i'/v`c'`i'[_N] if _n!=_N
				qui replace a`c'`i'=0 if missing(a`c'`i')
				qui replace a`c'`i'=v`c'`i' if _n==_N

				drop v`c'`i' N`c'`i'
				
				egen sum`c'`i'=sum(a`c'`i') if _n<_N-1
				
			}
			
			* compute final consumption from destination country
			
			egen F`c'=rowtotal(v`c'57 v`c'58 v`c'59)
		}
		
		egen F=rowtotal(v*57 v*58 v*59)

		drop if row_country=="ZZZ"
		mkmat F, matrix(F)
		drop v*

		ren country_ind ind_country

		* create matrices for shares calculation
		* numerator is [I-A]^-1 F_j
		* denominator is diag(Y)
		
		local n _N
		mkmat a*,matrix(A)
		mat L=inv(I(`n')-A)	
		mat B=L*F
		svmat B
		gen B_inv=1/B
		replace B_inv=0 if missing(B_inv)
		mkmat B_inv, matrix(B_inv)
		mat B_inv_mat=diag(B_inv)	
		foreach c of local country {
			di "`c'"
			mkmat F`c', matrix(F`c')
			mat xi_`c'=B_inv_mat*L*F`c'
			svmat xi_`c'
			ren xi_`c' xi_`c'
		}
	}
	
	keep row_country year ind_country row_ind xi*
	ren ind_country country_ind
	save tempfile/usa_firm/temporary/portfolio_`y',replace
	
}

clear
forval y=2000/2014 {
	append using tempfile/usa_firm/temporary/portfolio_`y'
}

save tempfile/industry/portfolio, replace


