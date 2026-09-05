version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local output "`project'/04_output"
local docs "`project'/99_docs"

cd "`project'"
log using "`output'/logs/15_adult_outcome_module_inventory.log", text replace
display as text "ADULT_OUTCOME_MODULE_INVENTORY_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)

use "`output'/diagnostics/variable_inventory.dta", clear
gen byte target_module = regexm(lower(file_name), "^(b3b_kk|b3b_co|b3b_cd|b3b_cov|b3b_ba|b3b_km|b3b_vg|b3a_sw|b3a_tr|b3a_pk|b3a_kw|b3a_dl|b3a_tk|b5_d|bus)")
gen byte target_wave = inlist(real(wave), 1997, 2000, 2007, 2014)
keep if target_module == 1 & target_wave == 1
sort wave file_name raw_name
save "`output'/diagnostics/adult_outcome_module_inventory.dta", replace
export delimited using "`output'/diagnostics/adult_outcome_module_inventory.csv", replace

preserve
keep wave file_name file_path observation_count variable_count read_status
duplicates drop
sort wave file_name
save "`output'/diagnostics/adult_outcome_module_file_inventory.dta", replace
export delimited using "`output'/diagnostics/adult_outcome_module_file_inventory.csv", replace
restore

display as result "ADULT_OUTCOME_MODULE_INVENTORY_ROWS=" _N
display as result "ADULT_OUTCOME_MODULE_INVENTORY_PASS"
log close
exit 0
