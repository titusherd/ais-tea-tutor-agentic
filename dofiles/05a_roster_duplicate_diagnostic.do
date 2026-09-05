version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/05a_roster_duplicate_diagnostic.log", text replace
display as text "ROSTER_DUP_DIAG_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

use "`derived'/roster_source_long.dta", clear

* The build script also keeps its first-pass diagnostic fields in this file.
* Drop and recompute them here so this audit is rerunnable.
capture drop pidlink_rows_wave
capture drop pidlink_tag
capture drop hhid_tag
capture drop pidlink_hh_count_wave
capture drop pidlink_repeated_wave
capture drop pidlink_multi_hh_wave
capture drop roster_hh_matches_spine
capture drop roster_hh_differs_spine
capture drop any_roster_hh_matches_spine
capture drop any_roster_hh_differs_spine
capture drop spine_hhid_wave
capture drop spine_present_roster
capture drop person_wave_ambiguous
capture drop spine_merge

* Join only the person-spine attributes needed for comparison. Using-only
* spine rows are excluded immediately; the roster audit must remain one row
* per raw roster record.
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

* The source key is household x person within wave. This is the only
* household assignment retained without an additional resolution rule.
sort wave pidlink hhid_wave pid_wave
by wave pidlink: gen long pidlink_rows_wave = _N
by wave pidlink: gen byte pidlink_tag = (_n == 1)
by wave pidlink: gen byte hhid_tag = (_n == 1)
by wave pidlink: replace hhid_tag = (hhid_wave != hhid_wave[_n-1]) if _n > 1
by wave pidlink: egen long pidlink_hh_count_wave = total(hhid_tag)
gen byte pidlink_repeated_wave = pidlink_rows_wave > 1
gen byte pidlink_multi_hh_wave = pidlink_hh_count_wave > 1
gen byte roster_hh_matches_spine = (spine_merge == 3 & hhid_wave == spine_hhid_wave)
gen byte roster_hh_differs_spine = (spine_merge == 3 & hhid_wave != spine_hhid_wave)
by wave pidlink: egen byte any_roster_hh_matches_spine = max(roster_hh_matches_spine)
by wave pidlink: egen byte any_roster_hh_differs_spine = max(roster_hh_differs_spine)
gen byte same_household_repeat_case = (pidlink_repeated_wave == 1 & pidlink_multi_hh_wave == 0 & pidlink_tag == 1)
gen byte spine_match_any_case = (any_roster_hh_matches_spine == 1 & pidlink_tag == 1)
gen byte spine_diff_any_case = (any_roster_hh_differs_spine == 1 & pidlink_tag == 1)
gen byte spine_not_matched_row = (spine_merge != 3)
gen byte spine_present_row = (spine_merge == 3 & spine_present_roster == 1)
gen byte person_wave_ambiguous_row = (person_wave_ambiguous == 1)

* Wave-level summary: one row per wave, with cases and rows separated.
preserve
keep if pidlink_tag == 1
collapse (sum) unique_pidlinks=pidlink_tag ///
    (sum) repeated_pidlink_cases=pidlink_repeated_wave ///
    multi_household_pidlink_cases=pidlink_multi_hh_wave ///
    same_household_repeat_cases=same_household_repeat_case ///
    spine_match_any_cases=spine_match_any_case ///
    spine_diff_any_cases=spine_diff_any_case, by(wave survey_year)
sort wave
save "`output'/diagnostics/roster_duplicate_summary.dta", replace
export delimited using "`output'/diagnostics/roster_duplicate_summary.csv", replace
list, noobs abbreviate(28)
restore

* A compact case-level file retains one row per repeated pidlink within wave.
preserve
keep if pidlink_tag == 1 & pidlink_repeated_wave == 1
keep wave survey_year pidlink pidlink_rows_wave pidlink_hh_count_wave ///
    pidlink_multi_hh_wave any_roster_hh_matches_spine any_roster_hh_differs_spine ///
    spine_hhid_wave spine_present_roster person_wave_ambiguous
sort wave pidlink
save "`output'/diagnostics/roster_duplicate_cases.dta", replace
export delimited using "`output'/diagnostics/roster_duplicate_cases.csv", replace
count
display as text "REPEATED_PIDLINK_CASE_ROWS=" r(N)
restore

* Full source rows for repeated pidlinks are retained for review. No row is
* deleted or selected here.
preserve
keep if pidlink_repeated_wave == 1
sort wave pidlink hhid_wave pid_wave
save "`output'/diagnostics/roster_duplicate_rows.dta", replace
export delimited using "`output'/diagnostics/roster_duplicate_rows.csv", replace
count
display as text "REPEATED_PIDLINK_SOURCE_ROWS=" r(N)
restore

* Missingness and comparison counts by wave, without relying on visual list
* output. The 104 source rows not matched to the person spine are retained.
preserve
collapse (count) roster_rows=roster_source_row ///
    (sum) source_rows_repeated=pidlink_repeated_wave ///
    source_rows_multi_hh=pidlink_multi_hh_wave ///
    source_rows_hh_matches_spine=roster_hh_matches_spine ///
    source_rows_hh_differs_spine=roster_hh_differs_spine ///
    source_rows_spine_not_matched=spine_not_matched_row ///
    source_rows_spine_present=spine_present_row ///
    source_rows_ambig=person_wave_ambiguous_row, by(wave survey_year)
sort wave
save "`output'/diagnostics/roster_wave_audit.dta", replace
export delimited using "`output'/diagnostics/roster_wave_audit.csv", replace
list, noobs abbreviate(28)
restore

* Code/status distributions are evidence for whether repeated pidlinks can be
* resolved from the raw roster status. They are not used to resolve them.
preserve
keep if pidlink_repeated_wave == 1
contract wave roster_status_raw, zero
sort wave roster_status_raw
save "`output'/diagnostics/roster_duplicate_status_distribution.dta", replace
export delimited using "`output'/diagnostics/roster_duplicate_status_distribution.csv", replace
list, noobs abbreviate(28)
restore

* Parent-reference availability is reported before parent IDs are resolved.
preserve
gen byte father_nonmissing = !missing(parent_father_pid_raw)
gen byte mother_nonmissing = !missing(parent_mother_pid_raw)
gen byte caregiver_nonmissing = !missing(caregiver_pid_raw)
collapse (count) roster_rows=roster_source_row ///
    (sum) father_nonmissing mother_nonmissing caregiver_nonmissing, by(wave survey_year)
sort wave
save "`output'/diagnostics/roster_parent_reference_availability.dta", replace
export delimited using "`output'/diagnostics/roster_parent_reference_availability.csv", replace
list, noobs abbreviate(28)
restore

display as result "ROSTER_DUP_DIAGNOSTIC_PASS"
log close
exit 0
