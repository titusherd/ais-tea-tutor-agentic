version 16.0
clear all
set more off

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/03b_tracking_duplicate_probe.log", text replace
display as text "TRACKING_DUPLICATE_PROBE_START=" c(current_date) " " c(current_time)

use "`raw'/wave5_hh14/ptrack.dta", clear
sort pidlink
duplicates tag, generate(exact_dup)
tab exact_dup
count if exact_dup > 0
display as text "EXACT_DUPLICATE_ALLVAR_ROWS=" r(N)
by pidlink: gen pidlink_n = _N
tab pidlink_n
count if pidlink_n > 1
display as text "DUPLICATE_PIDLINK_ROWS=" r(N)
count if pidlink_n > 1 & ar01a_14 == 6
display as text "DUPLICATE_ROWS_FLAGGED_AR01A14_6=" r(N)
list pidlink hhid14 pid14 member14 ar01a_14 ar01b_14 ar01i_14 if pidlink_n > 1, sepby(pidlink) noobs

use "`raw'/wave3_hh00/htrack.dta", clear
count if !missing(hhid00)
preserve
keep if !missing(hhid00)
isid hhid00
display as result "WAVE3_HHID00_NONMISSING_ISID_PASS"
restore

use "`raw'/wave4_hh07/htrack.dta", clear
count if !missing(hhid07)
preserve
keep if !missing(hhid07)
isid hhid07
display as result "WAVE4_HHID07_NONMISSING_ISID_PASS"
restore

use "`raw'/wave5_hh14/htrack.dta", clear
count if !missing(hhid14)
preserve
keep if !missing(hhid14)
isid hhid14
display as result "WAVE5_HHID14_NONMISSING_ISID_PASS"
restore

display as result "TRACKING_DUPLICATE_PROBE_PASS"
log close
exit 0
