version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/32_publication_support_audit.log", text replace
display as text "PUBLICATION_SUPPORT_AUDIT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)

foreach f in r1_mother_international_treatment r3_child_labor_treatment r1_analysis_base r3_analysis_base {
    display as text "--- DATASET `f' ---"
    use "`derived'/`f'.dta", clear
    describe
    ds
    summarize
}

use "`derived'/r1_mother_international_treatment.dta", clear
display as text "--- R1 STATUS/TIER ---"
tabulate r1_status, missing
foreach v in r1_treatment r1_primary_eligible r1_tier1 r1_tier2 r1_mother_mig r1_father_mig first_qualifying_wave first_qualifying_year {
    capture confirm variable `v'
    if _rc == 0 {
        display as text "R1_VAR=`v'"
        tabulate `v', missing
    }
}

use "`derived'/r3_child_labor_treatment.dta", clear
display as text "--- R3 STATUS/AGE ---"
tabulate r3_status, missing
tabulate r3_age_band r3_status, missing
foreach v in r3_treatment r3_primary_eligible r3_cl_10_11 r3_cl_12_14 r3_cl_15 r3_work_hours r3_total_hours r3_paid_work {
    capture confirm variable `v'
    if _rc == 0 {
        display as text "R3_VAR=`v'"
        summarize `v', detail
    }
}

display as result "PUBLICATION_SUPPORT_AUDIT_PASS"
log close
exit 0
