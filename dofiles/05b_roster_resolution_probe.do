version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/05b_roster_resolution_probe.log", text replace
display as text "ROSTER_RESOLUTION_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

use "`derived'/roster_source_long.dta", clear

tempfile spine_lookup
preserve
use "`derived'/person_spine.dta", clear
keep pidlink wave present_roster hhid_wave person_wave_ambiguous
rename hhid_wave spine_hhid_wave
rename present_roster spine_present_roster
save "`spine_lookup'", replace
restore
merge m:1 pidlink wave using "`spine_lookup'", keepusing(spine_hhid_wave spine_present_roster person_wave_ambiguous) gen(spine_merge)
count if spine_merge == 2
display as text "SPINE_ONLY_ROWS_EXCLUDED=" r(N)
keep if spine_merge != 2

sort wave pidlink hhid_wave pid_wave
by wave pidlink: gen long rows_wave = _N
by wave pidlink: gen byte pidlink_tag = (_n == 1)
by wave pidlink: gen byte hhid_tag = (_n == 1)
by wave pidlink: replace hhid_tag = (hhid_wave != hhid_wave[_n-1]) if _n > 1
by wave pidlink: egen long hh_count_wave = total(hhid_tag)

* Resident-status candidate is a transparent, codebook-backed flag only.
* It is not yet the final analysis sample rule. Wave 1 Book K is a roster of
* members; later waves use wave-specific AR01A codes.
gen byte resident_candidate = .
replace resident_candidate = 1 if wave == 1
replace resident_candidate = inlist(roster_status_raw, 1, 4, 5) if wave == 2
replace resident_candidate = inlist(roster_status_raw, 1, 5) if wave == 3
replace resident_candidate = inlist(roster_status_raw, 1, 2, 5) if inlist(wave, 4, 5)
replace resident_candidate = 0 if missing(resident_candidate)

gen byte roster_hh_matches_spine = (spine_merge == 3 & hhid_wave == spine_hhid_wave)
gen byte roster_hh_differs_spine = (spine_merge == 3 & hhid_wave != spine_hhid_wave)
by wave pidlink: egen long resident_candidate_n = total(resident_candidate)
by wave pidlink: egen long resident_candidate_match_n = total(resident_candidate * roster_hh_matches_spine)
by wave pidlink: egen long spine_match_n = total(roster_hh_matches_spine)
by wave pidlink: egen long spine_diff_n = total(roster_hh_differs_spine)

* Evidence labels for AR01A/status values, kept as text because the numeric
* codes are not identical across all waves.
gen str36 status_meaning = ""
replace status_meaning = "wave1 roster member" if wave == 1
replace status_meaning = "dead" if wave >= 2 & roster_status_raw == 0
replace status_meaning = "in household" if wave >= 2 & roster_status_raw == 1
replace status_meaning = "not in household/moved" if wave >= 2 & roster_status_raw == 3
replace status_meaning = "in new household" if wave == 2 & roster_status_raw == 4
replace status_meaning = "new household member" if wave >= 2 & roster_status_raw == 5
replace status_meaning = "ART comeback/current" if wave == 4 & roster_status_raw == 2
replace status_meaning = "was in other HH prior/current" if wave == 5 & roster_status_raw == 2
replace status_meaning = "duplicate" if wave >= 3 & roster_status_raw == 6
replace status_meaning = "entered after interview" if wave >= 4 & roster_status_raw == 11
replace status_meaning = "other/unmapped code" if status_meaning == ""

* One case category per pidlink x wave. Rows are never selected here.
gen byte resolution_category = .
replace resolution_category = 1 if pidlink_tag == 1 & rows_wave == 1
replace resolution_category = 2 if pidlink_tag == 1 & rows_wave > 1 & hh_count_wave == 1
replace resolution_category = 3 if pidlink_tag == 1 & rows_wave > 1 & hh_count_wave > 1 & resident_candidate_n == 1
replace resolution_category = 4 if pidlink_tag == 1 & rows_wave > 1 & hh_count_wave > 1 & resident_candidate_n == 0
replace resolution_category = 5 if pidlink_tag == 1 & rows_wave > 1 & hh_count_wave > 1 & resident_candidate_n > 1
label define resolution_category_lbl 1 "one roster row" 2 "repeat row same HH" 3 "multi-HH one resident candidate" 4 "multi-HH no resident candidate" 5 "multi-HH multiple resident candidates"
label values resolution_category resolution_category_lbl

* Summary of candidate-based resolution by wave.
preserve
keep if pidlink_tag == 1
collapse (sum) cases=pidlink_tag, by(wave survey_year resolution_category)
sort wave resolution_category
save "`output'/diagnostics/roster_resolution_summary.dta", replace
export delimited using "`output'/diagnostics/roster_resolution_summary.csv", replace
list, noobs abbreviate(28)
restore

* Compact case-level file for repeated PIDLINKs and all HHID mismatches.
preserve
gen byte case_review = (pidlink_tag == 1 & (rows_wave > 1 | spine_diff_n > 0))
keep if case_review
keep wave survey_year pidlink rows_wave hh_count_wave resident_candidate_n ///
    resident_candidate_match_n spine_match_n spine_diff_n spine_hhid_wave ///
    spine_present_roster person_wave_ambiguous resolution_category
sort wave pidlink
save "`output'/diagnostics/roster_resolution_cases.dta", replace
export delimited using "`output'/diagnostics/roster_resolution_cases.csv", replace
count
display as text "ROSTER_RESOLUTION_CASES=" r(N)
restore

* Cases with more than one codebook-based resident candidate violate the
* expected one-current-household pattern and are isolated for review.
preserve
keep if rows_wave > 1 & hh_count_wave > 1 & resident_candidate_n > 1
sort wave pidlink hhid_wave pid_wave
save "`output'/diagnostics/roster_multiple_resident_candidate_rows.dta", replace
export delimited using "`output'/diagnostics/roster_multiple_resident_candidate_rows.csv", replace
count
display as text "MULTIPLE_RESIDENT_CANDIDATE_ROWS=" r(N)
restore

* The 1993 HHID mismatches are kept separately because Wave 1 has no AR01A
* status field to adjudicate the discrepancy.
preserve
keep if pidlink_tag == 1 & spine_diff_n > 0
keep wave survey_year pidlink hhid_wave pid_wave spine_hhid_wave ///
    spine_present_roster person_wave_ambiguous
sort wave pidlink
save "`output'/diagnostics/roster_spine_hhid_mismatch_cases.dta", replace
export delimited using "`output'/diagnostics/roster_spine_hhid_mismatch_cases.csv", replace
list, noobs abbreviate(28)
restore

* Full source rows for cases requiring a household-resolution review.
preserve
gen byte case_review_row = (rows_wave > 1 | spine_diff_n > 0)
keep if case_review_row
sort wave pidlink hhid_wave pid_wave
keep wave survey_year pidlink hhid_wave pid_wave roster_status_raw status_meaning ///
    resident_candidate rows_wave hh_count_wave resident_candidate_n ///
    resident_candidate_match_n spine_match_n spine_diff_n spine_hhid_wave ///
    spine_present_roster person_wave_ambiguous source_module source_file ///
    parent_father_pid_raw parent_mother_pid_raw
save "`output'/diagnostics/roster_resolution_detail.dta", replace
export delimited using "`output'/diagnostics/roster_resolution_detail.csv", replace
count
display as text "ROSTER_RESOLUTION_DETAIL_ROWS=" r(N)
restore

* Status frequencies by wave, preserving missing status as a separate row.
preserve
contract wave survey_year roster_status_raw status_meaning
sort wave roster_status_raw
save "`output'/diagnostics/roster_status_distribution.dta", replace
export delimited using "`output'/diagnostics/roster_status_distribution.csv", replace
list, noobs abbreviate(28)
restore

* Parent references are resolved only in a later build after this evidence is
* checked; this file provides a concise starting point for that gate.
preserve
gen byte father_nonmissing = !missing(parent_father_pid_raw)
gen byte mother_nonmissing = !missing(parent_mother_pid_raw)
collapse (count) roster_rows=roster_source_row ///
    (sum) father_nonmissing mother_nonmissing, by(wave survey_year)
sort wave
save "`output'/diagnostics/roster_parent_reference_availability.dta", replace
export delimited using "`output'/diagnostics/roster_parent_reference_availability.csv", replace
restore

display as result "ROSTER_RESOLUTION_PASS"
log close
exit 0
