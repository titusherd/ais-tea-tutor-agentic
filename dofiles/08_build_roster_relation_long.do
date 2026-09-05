version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/08_build_roster_relation_long.log", text replace
display as text "ROSTER_RELATION_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

use "`derived'/roster_source_long.dta", clear
display as text "SOURCE_ROWS=" _N

isid wave hhid_wave pid_wave
display as text "SOURCE_KEY_PASS=wave_hhid_pid"

* The codebooks define AR10/AR11/AR12 as within-household person IDs. Codes
* 1-50 are treated as linkable IDs; other values are retained as reported
* status codes and are never sent to the merge as person IDs.
gen double father_pid_lookup = parent_father_pid_raw if inrange(parent_father_pid_raw, 1, 50)
gen double mother_pid_lookup = parent_mother_pid_raw if inrange(parent_mother_pid_raw, 1, 50)
gen double caregiver_pid_lookup = caregiver_pid_raw if inrange(caregiver_pid_raw, 1, 50)

gen byte father_ref_valid_id = !missing(father_pid_lookup)
gen byte mother_ref_valid_id = !missing(mother_pid_lookup)
gen byte caregiver_ref_valid_id = !missing(caregiver_pid_lookup)
gen byte father_ref_code_51 = (parent_father_pid_raw == 51)
gen byte father_ref_code_52 = (parent_father_pid_raw == 52)
gen byte father_ref_code_96 = (parent_father_pid_raw == 96)
gen byte father_ref_code_97 = (parent_father_pid_raw == 97)
gen byte father_ref_code_98 = (parent_father_pid_raw == 98)
gen byte father_ref_code_99 = (parent_father_pid_raw == 99)
gen byte mother_ref_code_51 = (parent_mother_pid_raw == 51)
gen byte mother_ref_code_52 = (parent_mother_pid_raw == 52)
gen byte mother_ref_code_96 = (parent_mother_pid_raw == 96)
gen byte mother_ref_code_97 = (parent_mother_pid_raw == 97)
gen byte mother_ref_code_98 = (parent_mother_pid_raw == 98)
gen byte mother_ref_code_99 = (parent_mother_pid_raw == 99)

tempfile father_lookup mother_lookup caregiver_lookup
preserve
keep wave hhid_wave pid_wave pidlink
rename pid_wave father_pid_lookup
rename pidlink father_pidlink
isid wave hhid_wave father_pid_lookup
save "`father_lookup'", replace
restore

preserve
keep wave hhid_wave pid_wave pidlink
rename pid_wave mother_pid_lookup
rename pidlink mother_pidlink
isid wave hhid_wave mother_pid_lookup
save "`mother_lookup'", replace
restore

preserve
keep wave hhid_wave pid_wave pidlink
rename pid_wave caregiver_pid_lookup
rename pidlink caregiver_pidlink
isid wave hhid_wave caregiver_pid_lookup
save "`caregiver_lookup'", replace
restore

merge m:1 wave hhid_wave father_pid_lookup using "`father_lookup'", ///
    keepusing(father_pidlink) gen(father_merge)
count if father_merge == 2
display as text "FATHER_LOOKUP_ONLY_ROWS_REMOVED=" r(N)
drop if father_merge == 2

merge m:1 wave hhid_wave mother_pid_lookup using "`mother_lookup'", ///
    keepusing(mother_pidlink) gen(mother_merge)
count if mother_merge == 2
display as text "MOTHER_LOOKUP_ONLY_ROWS_REMOVED=" r(N)
drop if mother_merge == 2

merge m:1 wave hhid_wave caregiver_pid_lookup using "`caregiver_lookup'", ///
    keepusing(caregiver_pidlink) gen(caregiver_merge)
count if caregiver_merge == 2
display as text "CAREGIVER_LOOKUP_ONLY_ROWS_REMOVED=" r(N)
drop if caregiver_merge == 2

gen byte father_linked = (father_ref_valid_id == 1 & father_merge == 3)
gen byte mother_linked = (mother_ref_valid_id == 1 & mother_merge == 3)
gen byte caregiver_linked = (caregiver_ref_valid_id == 1 & caregiver_merge == 3)

gen str28 father_resolution_status = ""
replace father_resolution_status = "not_reported" if missing(parent_father_pid_raw)
replace father_resolution_status = "valid_id_linked" if father_linked == 1
replace father_resolution_status = "valid_id_not_found" if father_ref_valid_id == 1 & father_merge != 3
replace father_resolution_status = "code_51_not_in_household" if parent_father_pid_raw == 51
replace father_resolution_status = "code_52_dead" if parent_father_pid_raw == 52
replace father_resolution_status = "code_96_not_applicable" if parent_father_pid_raw == 96
replace father_resolution_status = "code_97_refused" if parent_father_pid_raw == 97
replace father_resolution_status = "code_98_dont_know" if parent_father_pid_raw == 98
replace father_resolution_status = "code_99_missing" if parent_father_pid_raw == 99
replace father_resolution_status = "other_reported_code" if father_resolution_status == ""

gen str28 mother_resolution_status = ""
replace mother_resolution_status = "not_reported" if missing(parent_mother_pid_raw)
replace mother_resolution_status = "valid_id_linked" if mother_linked == 1
replace mother_resolution_status = "valid_id_not_found" if mother_ref_valid_id == 1 & mother_merge != 3
replace mother_resolution_status = "code_51_not_in_household" if parent_mother_pid_raw == 51
replace mother_resolution_status = "code_52_dead" if parent_mother_pid_raw == 52
replace mother_resolution_status = "code_96_not_applicable" if parent_mother_pid_raw == 96
replace mother_resolution_status = "code_97_refused" if parent_mother_pid_raw == 97
replace mother_resolution_status = "code_98_dont_know" if parent_mother_pid_raw == 98
replace mother_resolution_status = "code_99_missing" if parent_mother_pid_raw == 99
replace mother_resolution_status = "other_reported_code" if mother_resolution_status == ""

gen str28 caregiver_resolution_status = ""
replace caregiver_resolution_status = "not_reported" if missing(caregiver_pid_raw)
replace caregiver_resolution_status = "valid_id_linked" if caregiver_linked == 1
replace caregiver_resolution_status = "valid_id_not_found" if caregiver_ref_valid_id == 1 & caregiver_merge != 3
replace caregiver_resolution_status = "code_51_not_in_household" if caregiver_pid_raw == 51
replace caregiver_resolution_status = "code_96_not_applicable" if caregiver_pid_raw == 96
replace caregiver_resolution_status = "code_98_dont_know" if caregiver_pid_raw == 98
replace caregiver_resolution_status = "code_99_missing" if caregiver_pid_raw == 99
replace caregiver_resolution_status = "other_reported_code" if caregiver_resolution_status == ""

label variable father_linked "Father within-household PID resolved to PIDLINK"
label variable mother_linked "Mother within-household PID resolved to PIDLINK"
label variable caregiver_linked "Caregiver within-household PID resolved to PIDLINK"
label data "IFLS roster parent and caregiver links resolved within household"

sort wave hhid_wave pid_wave
isid wave hhid_wave pid_wave
save "`derived'/roster_relation_long.dta", replace
export delimited using "`output'/diagnostics/roster_relation_long.csv", replace

preserve
gen byte row_unit = 1
collapse (sum) roster_rows=row_unit father_valid_id=father_ref_valid_id ///
    father_linked mother_valid_id=mother_ref_valid_id mother_linked ///
    caregiver_valid_id=caregiver_ref_valid_id caregiver_linked, by(wave survey_year)
sort wave
save "`output'/diagnostics/roster_relation_wave_summary.dta", replace
export delimited using "`output'/diagnostics/roster_relation_wave_summary.csv", replace
list, noobs abbreviate(28)
restore

preserve
contract wave survey_year father_resolution_status
sort wave father_resolution_status
save "`output'/diagnostics/roster_father_resolution_distribution.dta", replace
export delimited using "`output'/diagnostics/roster_father_resolution_distribution.csv", replace
restore

preserve
contract wave survey_year mother_resolution_status
sort wave mother_resolution_status
save "`output'/diagnostics/roster_mother_resolution_distribution.dta", replace
export delimited using "`output'/diagnostics/roster_mother_resolution_distribution.csv", replace
restore

preserve
keep if father_resolution_status == "valid_id_not_found" | ///
    mother_resolution_status == "valid_id_not_found" | ///
    caregiver_resolution_status == "valid_id_not_found"
keep wave survey_year pidlink hhid_wave pid_wave ///
    parent_father_pid_raw parent_mother_pid_raw caregiver_pid_raw ///
    father_pidlink mother_pidlink caregiver_pidlink ///
    father_resolution_status mother_resolution_status caregiver_resolution_status
sort wave pidlink
save "`output'/diagnostics/roster_relation_unresolved_valid_ids.dta", replace
export delimited using "`output'/diagnostics/roster_relation_unresolved_valid_ids.csv", replace
list, noobs abbreviate(28)
restore

gen byte father_self_link = (father_linked == 1 & father_pidlink == pidlink)
gen byte mother_self_link = (mother_linked == 1 & mother_pidlink == pidlink)
gen byte caregiver_self_link = (caregiver_linked == 1 & caregiver_pidlink == pidlink)
count if father_self_link == 1 | mother_self_link == 1 | caregiver_self_link == 1
display as text "SELF_REFERENCE_LINK_ROWS=" r(N)

preserve
keep if father_self_link == 1 | mother_self_link == 1 | caregiver_self_link == 1
keep wave survey_year pidlink hhid_wave pid_wave relation_raw sex_raw age_raw ///
    parent_father_pid_raw parent_mother_pid_raw caregiver_pid_raw ///
    father_pidlink mother_pidlink caregiver_pidlink ///
    father_self_link mother_self_link caregiver_self_link
sort wave hhid_wave pid_wave
save "`output'/diagnostics/roster_relation_self_reference_cases.dta", replace
export delimited using "`output'/diagnostics/roster_relation_self_reference_cases.csv", replace
list, noobs abbreviate(28)
restore

preserve
gen byte row_unit = 1
collapse (sum) row_count=row_unit father_self_link mother_self_link caregiver_self_link, ///
    by(wave survey_year)
sort wave
save "`output'/diagnostics/roster_relation_self_reference_summary.dta", replace
export delimited using "`output'/diagnostics/roster_relation_self_reference_summary.csv", replace
list, noobs abbreviate(28)
restore

display as result "ROSTER_RELATION_PASS"
log close
exit 0
