** This code help mapping 56 WIOT industry codes to 19 NAICS industry codes and merge it with USA firm data.



clear
local dir "/Users/yuun/Documents/Research_Projects/data_task_2.20"

** this code maps WIOT to NAICS, using wiot_`y' and save the output in wiot_`y'_reclassified
do code/usa_firm/reclassify.do

* this code computes the imputed inventories for the inventory adjustment
do code/usa_firm/N_reca.do

* compute shares for aggregation and shift-share
do code/usa_firm/shares_reca.do

* this codes generate f_`y' for later computation of shocks
do code/usa_firm/genshocks_reca.do

* compute endogenous variable
do code/usa_firm/shocks_reca.do

* compute shift-share instrument
do code/usa_firm/shocks_noss_reca.do

* Import the usa firm data and merge to generate the final dataset
do code/usa_firm/import_usa_firm.do
