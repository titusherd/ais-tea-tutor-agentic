version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/07_build_roster_long.log", text replace
display as text "ROSTER_LONG_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

* --------------------------------------------------------------------------
* Part 1: reduce raw Book K rows to a case-level, auditable roster summary.
* A case is PIDLINK x wave. No source row is selected here.
* --------------------------------------------------------------------------
use "`derived'/roster_source_long.dta", clear
display as text "ROSTER_SOURCE_ROWS=" _N

sort wave pidlink hhid_wave pid_wave
by wave pidlink: gen long source_rows_wave = _N
by wave pidlink: gen byte pidlink_case_tag = (_n == 1)
by wave pidlink: gen byte hhid_tag = (_n == 1)
by wave pidlink: replace hhid_tag = (hhid_wave != hhid_wave[_n-1]) if _n > 1
by wave pidlink: egen long source_hh_count_wave = total(hhid_tag)

* Codebook-backed resident candidates, retained as a transparent intermediate
* and not treated as a final model sample rule.
gen byte resident_candidate = .
replace resident_candidate = 1 if wave == 1
replace resident_candidate = inlist(roster_status_raw, 1, 4, 5) if wave == 2
replace resident_candidate = inlist(roster_status_raw, 1, 5) if wave == 3
replace resident_candidate = inlist(roster_status_raw, 1, 2, 5) if inlist(wave, 4, 5)
replace resident_candidate = 0 if missing(resident_candidate)

sort wave pidlink hhid_wave resident_candidate pid_wave
by wave pidlink hhid_wave: egen byte any_resident_in_hh = max(resident_candidate)
by wave pidlink hhid_wave: gen byte resident_hh_tag = (any_resident_in_hh == 1 & _n == 1)
by wave pidlink: egen long resident_candidate_rows = total(resident_candidate)
by wave pidlink: egen long resident_candidate_hh_count = total(resident_hh_tag)

gen byte status_dead = (roster_status_raw == 0)
gen byte status_in_hh = (roster_status_raw == 1)
gen byte status_moved = (roster_status_raw == 3)
gen byte status_new_hh = (roster_status_raw == 4)
gen byte status_new_member = (roster_status_raw == 5)
gen byte status_duplicate = (roster_status_raw == 6)
gen byte status_after_interview = (roster_status_raw == 11)
gen byte status_other = (!missing(roster_status_raw) & ///
    !inlist(roster_status_raw, 0, 1, 2, 3, 4, 5, 6, 11))
by wave pidlink: egen long status_dead_n = total(status_dead)
by wave pidlink: egen long status_in_hh_n = total(status_in_hh)
by wave pidlink: egen long status_moved_n = total(status_moved)
by wave pidlink: egen long status_new_hh_n = total(status_new_hh)
by wave pidlink: egen long status_new_member_n = total(status_new_member)
by wave pidlink: egen long status_duplicate_n = total(status_duplicate)
by wave pidlink: egen long status_after_interview_n = total(status_after_interview)
by wave pidlink: egen long status_other_n = total(status_other)

* Because data are sorted with candidate rows last, the last hhid in a case
* is safe to carry only when the relevant household count is exactly one.
sort wave pidlink resident_candidate hhid_wave pid_wave
by wave pidlink: gen str8 source_hhid_single = hhid_wave[_N] if _n == 1 & source_hh_count_wave == 1
by wave pidlink: gen str8 resident_hhid_single = hhid_wave[_N] if _n == 1 & resident_candidate_hh_count == 1

gen str36 roster_resolution_status = ""
replace roster_resolution_status = "one_source_hh" if pidlink_case_tag == 1 & source_hh_count_wave == 1
replace roster_resolution_status = "no_resident_candidate" if pidlink_case_tag == 1 & resident_candidate_hh_count == 0
replace roster_resolution_status = "resident_hh_resolved" if pidlink_case_tag == 1 & resident_candidate_hh_count == 1
replace roster_resolution_status = "multiple_resident_hh" if pidlink_case_tag == 1 & resident_candidate_hh_count > 1
replace roster_resolution_status = "multiple_source_hh_nonresident" if pidlink_case_tag == 1 & source_hh_count_wave > 1 & resident_candidate_hh_count == 0

tempfile roster_case
preserve
keep if pidlink_case_tag == 1
keep pidlink wave source_rows_wave source_hh_count_wave source_hhid_single ///
    resident_candidate_rows resident_candidate_hh_count resident_hhid_single ///
    status_dead_n status_in_hh_n status_moved_n status_new_hh_n ///
    status_new_member_n status_duplicate_n status_after_interview_n status_other_n ///
    roster_resolution_status
isid pidlink wave
save "`roster_case'", replace
local roster_case_n = _N
restore

display as text "ROSTER_CASES=`roster_case_n'"

* --------------------------------------------------------------------------
* Part 2: attach the case-level roster evidence to the five-wave person spine.
* Person-spine household IDs remain a separate, independently sourced field.
* --------------------------------------------------------------------------
use "`derived'/person_spine.dta", clear
rename hhid_wave spine_hhid_wave
merge 1:1 pidlink wave using "`roster_case'", gen(roster_case_merge)
tab roster_case_merge
count if roster_case_merge == 2
display as text "ROSTER_CASES_NOT_IN_PERSON_SPINE=" r(N)
keep if roster_case_merge != 2

gen byte person_wave_row = 1
gen byte roster_source_present = (roster_case_merge == 3)
replace roster_resolution_status = "no_roster_source" if roster_case_merge == 1
gen byte roster_current_hhid_resolved = (resident_hhid_single != "")
gen byte roster_current_hh_matches_spine = .
replace roster_current_hh_matches_spine = (resident_hhid_single == spine_hhid_wave) ///
    if resident_hhid_single != "" & spine_hhid_wave != ""
gen byte roster_current_hh_mismatch_spine = .
replace roster_current_hh_mismatch_spine = (resident_hhid_single != spine_hhid_wave) ///
    if resident_hhid_single != "" & spine_hhid_wave != ""

label variable person_wave_row "One canonical person x wave row"
label variable roster_source_present "PIDLINK x wave appears in raw Book K source"
label variable roster_current_hhid_resolved "Exactly one codebook-based resident HH candidate"
label variable roster_current_hh_matches_spine "Resolved roster HHID equals PTRACK spine HHID"
label variable roster_current_hh_mismatch_spine "Resolved roster HHID differs from PTRACK spine HHID"
label data "IFLS person-wave spine with auditable Book K roster evidence"

isid pidlink wave
sort pidlink wave
save "`derived'/roster_long.dta", replace
export delimited using "`output'/diagnostics/roster_long.csv", replace
display as text "ROSTER_LONG_ROWS=" _N

preserve
collapse (sum) person_wave_rows=person_wave_row ///
    roster_source_rows=roster_source_present ///
    current_hhid_resolved=roster_current_hhid_resolved ///
    current_hh_match=roster_current_hh_matches_spine ///
    current_hh_mismatch=roster_current_hh_mismatch_spine ///
    person_wave_ambiguous, by(wave survey_year)
sort wave
save "`output'/diagnostics/roster_long_wave_summary.dta", replace
export delimited using "`output'/diagnostics/roster_long_wave_summary.csv", replace
list, noobs abbreviate(28)
restore

preserve
keep if roster_source_present == 1
contract wave survey_year roster_resolution_status
sort wave roster_resolution_status
save "`output'/diagnostics/roster_long_resolution_distribution.dta", replace
export delimited using "`output'/diagnostics/roster_long_resolution_distribution.csv", replace
list, noobs abbreviate(28)
restore

display as result "ROSTER_LONG_PASS"
log close
exit 0
