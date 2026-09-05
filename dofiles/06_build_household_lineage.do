version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local raw "`project'/00_raw"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/06_build_household_lineage.log", text replace
display as text "HOUSEHOLD_LINEAGE_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

use "`raw'/wave5_hh14/htrack.dta", clear
display as text "SOURCE_FILE=wave5_hh14/htrack.dta"
display as text "SOURCE_OBS=" _N

gen long lineage_row_id = _n
gen byte current_hh_observed = !missing(hhid14)
gen byte current_hh_unobserved = missing(hhid14)

* The current household identifier is a household-level key only when
* nonmissing. Historical/attrited HTRACK rows remain in the lineage file.
preserve
keep if current_hh_observed == 1
isid hhid14
count
local current_hh_n = r(N)
display as text "CURRENT_HH_NONMISSING_ROWS=`current_hh_n'"
restore

count if current_hh_unobserved == 1
display as text "CURRENT_HH_UNOBSERVED_ROWS=" r(N)

* Select only identifiers, splitoff/mover flags, community IDs, and published
* HTRACK weights. No household status is inferred from missing HHID14.
keep lineage_row_id current_hh_observed current_hh_unobserved ///
    hhid93 hhid97 hhid00 hhid07 hhid14 hhid14_9 ///
    commid93 commid97 commid00 commid07 commid14 ///
    splitoff97 splitoff98 splitoff00 splitoff07 splitoff14 ///
    mover97 mover00 mover07 mover14 ///
    hwt93 hwt93smp hwt97l hwt97x ///
    hwt00la hwt00lb hwt00xa hwt00xb ///
    hwt07la hwt07l_ hwt07xa hwt07x_ ///
    hwt14la hwt14l_ hwt14xa hwt14x_ ///
    hwt93_97_00_07l hwt_5_waves_l

order lineage_row_id current_hh_observed current_hh_unobserved ///
    hhid93 hhid97 hhid00 hhid07 hhid14 hhid14_9
sort hhid14 hhid07 hhid00 hhid97 hhid93 lineage_row_id

label variable lineage_row_id "Stable row ID from IFLS5 HTRACK14 source order"
label variable current_hh_observed "HHID14 nonmissing in IFLS5 HTRACK14"
label variable current_hh_unobserved "HHID14 missing in IFLS5 HTRACK14; no death inference"
label data "IFLS household lineage derived from IFLS5 HTRACK14"

save "`derived'/household_lineage.dta", replace
export delimited using "`output'/diagnostics/household_lineage.csv", replace

preserve
collapse (count) lineage_rows=lineage_row_id ///
    (sum) current_hh_unobserved, by(current_hh_observed)
sort current_hh_observed
save "`output'/diagnostics/household_lineage_observation_summary.dta", replace
export delimited using "`output'/diagnostics/household_lineage_observation_summary.csv", replace
list, noobs abbreviate(28)
restore

preserve
gen byte has_hhid93 = !missing(hhid93)
gen byte has_hhid97 = !missing(hhid97)
gen byte has_hhid00 = !missing(hhid00)
gen byte has_hhid07 = !missing(hhid07)
gen byte has_hhid14 = !missing(hhid14)
collapse (count) lineage_rows=lineage_row_id ///
    (sum) has_hhid93 has_hhid97 has_hhid00 has_hhid07 has_hhid14, ///
    by(current_hh_observed current_hh_unobserved)
sort current_hh_observed
save "`output'/diagnostics/household_lineage_id_availability.dta", replace
export delimited using "`output'/diagnostics/household_lineage_id_availability.csv", replace
list, noobs abbreviate(28)
restore

preserve
keep if current_hh_unobserved == 1
gen byte splitoff97_nonmissing = !missing(splitoff97)
gen byte splitoff00_nonmissing = !missing(splitoff00)
gen byte splitoff07_nonmissing = !missing(splitoff07)
gen byte splitoff14_nonmissing = !missing(splitoff14)
gen byte mover97_nonmissing = !missing(mover97)
gen byte mover00_nonmissing = !missing(mover00)
gen byte mover07_nonmissing = !missing(mover07)
gen byte mover14_nonmissing = !missing(mover14)
collapse (count) rows=lineage_row_id ///
    (sum) splitoff97_nonmissing splitoff00_nonmissing splitoff07_nonmissing ///
    splitoff14_nonmissing mover97_nonmissing mover00_nonmissing ///
    mover07_nonmissing mover14_nonmissing
save "`output'/diagnostics/household_lineage_unobserved_flags.dta", replace
export delimited using "`output'/diagnostics/household_lineage_unobserved_flags.csv", replace
list, noobs abbreviate(28)
restore

display as result "HOUSEHOLD_LINEAGE_PASS"
log close
exit 0
