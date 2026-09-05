version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/05_build_roster_source_long.log", text replace
display as text "ROSTER_SOURCE_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

tempfile w1 w2 w3 w4 w5

use "`raw'/wave1_hh93/bukkar2.dta", clear
gen str10 pidlink_std = pidlink
gen str10 hhid_wave = hhid93
gen double pid_wave = pid93
gen double relation_raw = ar02
gen double sex_raw = ar07
gen double age_raw = ar09yr
gen double birth_year_raw = ar08yr
gen double birth_month_raw = ar08mth
gen double parent_father_pid_raw = ar10
gen double parent_mother_pid_raw = ar11
gen double caregiver_pid_raw = ar12
gen double roster_status_raw = .
gen byte roster_record = 1
gen byte wave = 1
gen int survey_year = 1993
gen str18 source_module = "W1 bukkar2"
gen str40 source_file = "wave1_hh93/bukkar2.dta"
gen str20 parent_id_unit = "within_hh_pid"
drop pidlink
rename pidlink_std pidlink
keep pidlink wave survey_year hhid_wave pid_wave relation_raw sex_raw age_raw birth_year_raw birth_month_raw parent_father_pid_raw parent_mother_pid_raw caregiver_pid_raw roster_status_raw roster_record source_module source_file parent_id_unit
save "`w1'", replace

use "`raw'/wave2_hh97/bk_ar1.dta", clear
gen str10 pidlink_std = pidlink
gen str10 hhid_wave = hhid97
gen double pid_wave = pid97
gen double relation_raw = ar02b
gen double sex_raw = ar07
gen double age_raw = ar09
gen double birth_year_raw = ar08yr
gen double birth_month_raw = ar08mth
gen double parent_father_pid_raw = ar10
gen double parent_mother_pid_raw = ar11
gen double caregiver_pid_raw = .
gen double roster_status_raw = ar01a
gen byte roster_record = 1
gen byte wave = 2
gen int survey_year = 1997
gen str18 source_module = "W2 bk_ar1"
gen str40 source_file = "wave2_hh97/bk_ar1.dta"
gen str20 parent_id_unit = "within_hh_pid"
drop pidlink
rename pidlink_std pidlink
keep pidlink wave survey_year hhid_wave pid_wave relation_raw sex_raw age_raw birth_year_raw birth_month_raw parent_father_pid_raw parent_mother_pid_raw caregiver_pid_raw roster_status_raw roster_record source_module source_file parent_id_unit
save "`w2'", replace

use "`raw'/wave3_hh00/bk_ar1.dta", clear
gen str10 pidlink_std = pidlink
gen str10 hhid_wave = hhid00
gen double pid_wave = pid00
gen double relation_raw = ar02b
gen double sex_raw = ar07
gen double age_raw = ar09
gen double birth_year_raw = ar08yr
gen double birth_month_raw = ar08mth
gen double parent_father_pid_raw = ar10
gen double parent_mother_pid_raw = ar11
gen double caregiver_pid_raw = .
gen double roster_status_raw = ar01a
gen byte roster_record = 1
gen byte wave = 3
gen int survey_year = 2000
gen str18 source_module = "W3 bk_ar1"
gen str40 source_file = "wave3_hh00/bk_ar1.dta"
gen str20 parent_id_unit = "within_hh_pid"
drop pidlink
rename pidlink_std pidlink
keep pidlink wave survey_year hhid_wave pid_wave relation_raw sex_raw age_raw birth_year_raw birth_month_raw parent_father_pid_raw parent_mother_pid_raw caregiver_pid_raw roster_status_raw roster_record source_module source_file parent_id_unit
save "`w3'", replace

use "`raw'/wave4_hh07/bk_ar1.dta", clear
gen str10 pidlink_std = pidlink
gen str10 hhid_wave = hhid07
gen double pid_wave = pid07
gen double relation_raw = ar02b
gen double sex_raw = ar07
gen double age_raw = ar09
gen double birth_year_raw = ar08yr
gen double birth_month_raw = ar08mth
gen double parent_father_pid_raw = ar10
gen double parent_mother_pid_raw = ar11
gen double caregiver_pid_raw = .
gen double roster_status_raw = ar01a
gen byte roster_record = 1
gen byte wave = 4
gen int survey_year = 2007
gen str18 source_module = "W4 bk_ar1"
gen str40 source_file = "wave4_hh07/bk_ar1.dta"
gen str20 parent_id_unit = "within_hh_pid"
drop pidlink
rename pidlink_std pidlink
keep pidlink wave survey_year hhid_wave pid_wave relation_raw sex_raw age_raw birth_year_raw birth_month_raw parent_father_pid_raw parent_mother_pid_raw caregiver_pid_raw roster_status_raw roster_record source_module source_file parent_id_unit
save "`w4'", replace

use "`raw'/wave5_hh14/bk_ar1.dta", clear
gen str10 pidlink_std = pidlink
gen str10 hhid_wave = hhid14
gen double pid_wave = pid14
gen double relation_raw = ar02b
gen double sex_raw = ar07
gen double age_raw = ar09
gen double birth_year_raw = ar08yr
gen double birth_month_raw = ar08mth
gen double parent_father_pid_raw = ar10
gen double parent_mother_pid_raw = ar11
gen double caregiver_pid_raw = .
gen double roster_status_raw = ar01a
gen byte roster_record = 1
gen byte wave = 5
gen int survey_year = 2014
gen str18 source_module = "W5 bk_ar1"
gen str40 source_file = "wave5_hh14/bk_ar1.dta"
gen str20 parent_id_unit = "within_hh_pid"
drop pidlink
rename pidlink_std pidlink
keep pidlink wave survey_year hhid_wave pid_wave relation_raw sex_raw age_raw birth_year_raw birth_month_raw parent_father_pid_raw parent_mother_pid_raw caregiver_pid_raw roster_status_raw roster_record source_module source_file parent_id_unit
save "`w5'", replace

use "`w1'", clear
append using "`w2'"
append using "`w3'"
append using "`w4'"
append using "`w5'"
sort wave hhid_wave pid_wave
gen long roster_source_row = _n
save "`derived'/roster_source_long.dta", replace
export delimited using "`output'/diagnostics/roster_source_long.csv", replace

display as result "ROSTER_SOURCE_ROWS=" _N
forvalues w = 1/5 {
    preserve
    keep if wave == `w'
    count
    local n = r(N)
    isid hhid_wave pid_wave
    display as text "WAVE=`w' RAW_ROSTER_ROWS=`n' ISID_HHID_PID_PASS"
    restore
}

sort wave pidlink
by wave pidlink: gen long pidlink_rows_wave = _N
by wave pidlink: gen byte pidlink_tag = (_n == 1)
gen byte pidlink_multiple_household = pidlink_rows_wave > 1
count if pidlink_multiple_household == 1
display as text "MULTI_HOUSEHOLD_PIDLINK_ROWS=" r(N)
count if pidlink_multiple_household == 1 & pidlink_tag == 1
display as text "MULTI_HOUSEHOLD_PIDLINK_CASES=" r(N)
list wave pidlink hhid_wave pid_wave roster_status_raw parent_father_pid_raw parent_mother_pid_raw if pidlink_multiple_household == 1, sepby(wave pidlink) noobs

count if missing(pidlink)
display as text "MISSING_PIDLINK_ROSTER_ROWS=" r(N)
count if missing(hhid_wave) | missing(pid_wave)
display as text "MISSING_HHID_OR_PID_ROSTER_ROWS=" r(N)

tempfile spine_lookup
preserve
use "`derived'/person_spine.dta", clear
keep pidlink wave present_roster hhid_wave person_wave_ambiguous
rename hhid_wave spine_hhid_wave
rename present_roster spine_present_roster
save "`spine_lookup'", replace
restore
merge m:1 pidlink wave using "`spine_lookup'", keepusing(spine_hhid_wave spine_present_roster person_wave_ambiguous) gen(spine_merge)
tab spine_merge
count if spine_merge == 2
display as text "SPINE_ONLY_ROWS_EXCLUDED_FROM_ROSTER_AUDIT=" r(N)
keep if spine_merge != 2
count if spine_merge != 3
display as text "ROSTER_ROWS_NOT_MATCHED_TO_PERSON_SPINE=" r(N)
count if spine_merge == 3 & spine_present_roster == 1
display as text "ROSTER_ROWS_MATCHED_PRESENT_PTRACK=" r(N)
save "`derived'/roster_source_long_spine_audit.dta", replace
export delimited using "`output'/diagnostics/roster_source_long_spine_audit.csv", replace

display as result "ROSTER_SOURCE_PASS"
log close
exit 0
