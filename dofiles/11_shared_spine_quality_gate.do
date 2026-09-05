version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/11_shared_spine_quality_gate.log", text replace
display as text "SHARED_SPINE_QUALITY_GATE_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

* --------------------------------------------------------------------------
* Structural key checks. These are hard gates; substantive anomalies are
* reported below and are not silently repaired here.
* --------------------------------------------------------------------------
use "`derived'/person_spine.dta", clear
capture isid pidlink wave
if _rc != 0 {
    display as error "STOP_PERSON_SPINE_KEY_FAILURE"
    exit 459
}
display as text "PERSON_SPINE_KEY_PASS=pidlink_wave"

use "`derived'/roster_long.dta", clear
capture isid pidlink wave
if _rc != 0 {
    display as error "STOP_ROSTER_LONG_KEY_FAILURE"
    exit 459
}
display as text "ROSTER_LONG_KEY_PASS=pidlink_wave"

use "`derived'/roster_relation_long.dta", clear
capture isid wave hhid_wave pid_wave
if _rc != 0 {
    display as error "STOP_ROSTER_RELATION_KEY_FAILURE"
    exit 459
}
display as text "ROSTER_RELATION_KEY_PASS=wave_hhid_pid"

use "`derived'/household_lineage.dta", clear
preserve
keep if !missing(hhid14)
capture isid hhid14
if _rc != 0 {
    restore
    display as error "STOP_HOUSEHOLD_LINEAGE_CURRENT_HHID_FAILURE"
    exit 459
}
restore
display as text "HOUSEHOLD_LINEAGE_KEY_PASS=nonmissing_hhid14"

* --------------------------------------------------------------------------
* Wave-level person, roster, and relation coverage summary.
* --------------------------------------------------------------------------
tempname wh
postfile `wh' byte wave int survey_year ///
    long spine_rows long spine_unique_pidlinks long spine_hhid_nonmissing long spine_pid_nonmissing ///
    long spine_present_roster long spine_age_nonmissing long spine_age_invalid long spine_age_fractional long spine_birth_nonmissing ///
    long roster_rows long roster_source_rows long roster_hhid_resolved long roster_hh_match long roster_hh_mismatch long roster_ambiguous ///
    long relation_rows long father_linked long father_valid_not_found long mother_linked long mother_valid_not_found ///
    using "`output'/diagnostics/shared_spine_quality_wave.dta", replace

foreach w in 1 2 3 4 5 {
    local yr = cond(`w' == 1, 1993, cond(`w' == 2, 1997, cond(`w' == 3, 2000, cond(`w' == 4, 2007, 2014))))

    use "`derived'/person_spine.dta", clear
    keep if wave == `w'
    count
    local spine_rows = r(N)
    bysort pidlink: gen byte pid_tag = (_n == 1)
    count if pid_tag == 1
    local spine_unique_pidlinks = r(N)
    count if hhid_wave != ""
    local spine_hhid_nonmissing = r(N)
    count if !missing(pid_wave)
    local spine_pid_nonmissing = r(N)
    count if present_roster == 1
    local spine_present_roster = r(N)
    count if !missing(age_at_interview)
    local spine_age_nonmissing = r(N)
    count if !missing(age_at_interview) & (age_at_interview < 0 | age_at_interview > 100)
    local spine_age_invalid = r(N)
    count if !missing(age_at_interview) & age_at_interview != floor(age_at_interview)
    local spine_age_fractional = r(N)
    count if birth_date_available == 1
    local spine_birth_nonmissing = r(N)

    use "`derived'/roster_long.dta", clear
    keep if wave == `w'
    count
    local roster_rows = r(N)
    count if roster_source_present == 1
    local roster_source_rows = r(N)
    count if roster_current_hhid_resolved == 1
    local roster_hhid_resolved = r(N)
    count if roster_current_hh_matches_spine == 1
    local roster_hh_match = r(N)
    count if roster_current_hh_mismatch_spine == 1
    local roster_hh_mismatch = r(N)
    count if person_wave_ambiguous == 1
    local roster_ambiguous = r(N)

    use "`derived'/roster_relation_long.dta", clear
    keep if wave == `w'
    count
    local relation_rows = r(N)
    count if father_linked == 1
    local father_linked = r(N)
    count if father_resolution_status == "valid_id_not_found"
    local father_valid_not_found = r(N)
    count if mother_linked == 1
    local mother_linked = r(N)
    count if mother_resolution_status == "valid_id_not_found"
    local mother_valid_not_found = r(N)

    post `wh' (`w') (`yr') (`spine_rows') (`spine_unique_pidlinks') (`spine_hhid_nonmissing') (`spine_pid_nonmissing') ///
        (`spine_present_roster') (`spine_age_nonmissing') (`spine_age_invalid') (`spine_age_fractional') (`spine_birth_nonmissing') ///
        (`roster_rows') (`roster_source_rows') (`roster_hhid_resolved') (`roster_hh_match') (`roster_hh_mismatch') (`roster_ambiguous') ///
        (`relation_rows') (`father_linked') (`father_valid_not_found') (`mother_linked') (`mother_valid_not_found')
}
postclose `wh'

use "`output'/diagnostics/shared_spine_quality_wave.dta", clear
sort wave
export delimited using "`output'/diagnostics/shared_spine_quality_wave.csv", replace
list, noobs abbreviate(28)

* --------------------------------------------------------------------------
* Person-level longitudinal consistency and anomaly counts.
* --------------------------------------------------------------------------
use "`derived'/person_spine.dta", clear
gen byte person_tag = 0
bysort pidlink: replace person_tag = (_n == 1)

egen double sex_min = min(cond(!missing(sex), sex, .)), by(pidlink)
egen double sex_max = max(cond(!missing(sex), sex, .)), by(pidlink)
gen byte sex_conflict = (sex_min != sex_max) if !missing(sex_min) & !missing(sex_max)

egen double birth_min = min(cond(!missing(birth_date), birth_date, .)), by(pidlink)
egen double birth_max = max(cond(!missing(birth_date), birth_date, .)), by(pidlink)
gen byte birth_date_conflict = (birth_min != birth_max) if !missing(birth_min) & !missing(birth_max)

count if person_tag == 1 & sex_conflict == 1
local sex_conflict_pids = r(N)
count if person_tag == 1 & birth_date_conflict == 1
local birth_date_conflict_pids = r(N)
count if person_wave_ambiguous == 1
local ambiguous_wave_rows = r(N)
count if !missing(age_at_interview) & (age_at_interview < 0 | age_at_interview > 100)
local invalid_age_rows = r(N)
count if !missing(age_at_interview) & age_at_interview != floor(age_at_interview)
local fractional_age_rows = r(N)

tempname gh
postfile `gh' str44 check_name str24 status long n str244 evidence using "`output'/diagnostics/shared_spine_quality_global.dta", replace
post `gh' ("person_spine_key") ("PASS") (0) ("isid pidlink wave")
post `gh' ("roster_long_key") ("PASS") (0) ("isid pidlink wave")
post `gh' ("roster_relation_key") ("PASS") (0) ("isid wave hhid_wave pid_wave")
post `gh' ("lineage_current_hhid_key") ("PASS") (0) ("isid hhid14 among nonmissing current HHID14")
post `gh' ("sex_conflict_pidlinks") ("FLAG") (`sex_conflict_pids') ("sex differs across nonmissing PTRACK14-linked wave rows")
post `gh' ("birth_date_conflict_pidlinks") ("FLAG") (`birth_date_conflict_pids') ("birth_date differs across nonmissing PTRACK14-linked wave rows")
post `gh' ("ambiguous_wave5_person_rows") ("FLAG") (`ambiguous_wave_rows') ("non-identical repeated PIDLINK rows retained as unresolved in W5")
post `gh' ("invalid_age_rows") ("FLAG") (`invalid_age_rows') ("reported age outside 0-100; no recode applied")
post `gh' ("fractional_age_rows") ("FLAG") (`fractional_age_rows') ("reported age is non-integer; no recode applied")
postclose `gh'
use "`output'/diagnostics/shared_spine_quality_global.dta", clear
export delimited using "`output'/diagnostics/shared_spine_quality_global.csv", replace
list, noobs abbreviate(28)

* --------------------------------------------------------------------------
* Presence pattern: descriptive only; it does not define model eligibility.
* --------------------------------------------------------------------------
use "`derived'/person_spine.dta", clear
keep pidlink wave present_roster
reshape wide present_roster, i(pidlink) j(wave)
egen byte present_wave_evidence = rownonmiss(present_roster1 present_roster2 present_roster3 present_roster4 present_roster5)
egen byte present_waves = rowtotal(present_roster1 present_roster2 present_roster3 present_roster4 present_roster5)
replace present_waves = . if present_wave_evidence == 0
contract present_wave_evidence present_waves
sort present_wave_evidence present_waves
save "`output'/diagnostics/person_presence_pattern.dta", replace
export delimited using "`output'/diagnostics/person_presence_pattern.csv", replace

* --------------------------------------------------------------------------
* Parent-child link audit. The only automatic age-order flag is a parent
* younger than the linked child in the same wave; no age-gap threshold is
* imposed here.
* --------------------------------------------------------------------------
use "`derived'/roster_relation_long.dta", clear
tempfile father_links mother_links
preserve
keep if father_linked == 1
keep wave pidlink father_pidlink
rename father_pidlink parent_pidlink
gen str6 parent_role = "father"
save "`father_links'", replace
restore
preserve
keep if mother_linked == 1
keep wave pidlink mother_pidlink
rename mother_pidlink parent_pidlink
gen str6 parent_role = "mother"
save "`mother_links'", replace
restore

use "`father_links'", clear
append using "`mother_links'"
rename pidlink child_pidlink
rename child_pidlink pidlink
merge m:1 pidlink wave using "`derived'/person_spine.dta", keep(1 3) keepusing(age_at_interview birth_date) gen(child_merge)
rename age_at_interview child_age
rename birth_date child_birth_date
rename pidlink child_pidlink

rename parent_pidlink pidlink
merge m:1 pidlink wave using "`derived'/person_spine.dta", keep(1 3) keepusing(age_at_interview birth_date) gen(parent_merge)
rename age_at_interview parent_age
rename birth_date parent_birth_date
rename pidlink parent_pidlink

gen byte child_age_available = (child_merge == 3 & !missing(child_age))
gen byte parent_age_available = (parent_merge == 3 & !missing(parent_age))
gen byte parent_younger_than_child = 0
replace parent_younger_than_child = 1 if child_age_available == 1 & parent_age_available == 1 & parent_age < child_age
gen double age_gap_parent_minus_child = parent_age - child_age if child_age_available == 1 & parent_age_available == 1
order wave parent_role child_pidlink parent_pidlink child_age parent_age age_gap_parent_minus_child child_merge parent_merge, first
sort wave parent_role child_pidlink parent_pidlink
save "`output'/diagnostics/parent_age_link_audit.dta", replace
export delimited using "`output'/diagnostics/parent_age_link_audit.csv", replace

preserve
gen byte relationship_row = 1
collapse (sum) relationship_rows=relationship_row child_age_available parent_age_available parent_younger_than_child, by(wave parent_role)
sort wave parent_role
save "`output'/diagnostics/parent_age_link_summary.dta", replace
export delimited using "`output'/diagnostics/parent_age_link_summary.csv", replace
list, noobs abbreviate(28)
restore

* Add cross-table anomaly counts to a compact global report.
use "`derived'/roster_long.dta", clear
count if roster_current_hh_mismatch_spine == 1
local roster_hhid_mismatch_rows = r(N)
count if roster_resolution_status == "multiple_resident_hh"
local multiple_resident_cases = r(N)
count if roster_resolution_status == "no_resident_candidate"
local no_resident_cases = r(N)

use "`output'/diagnostics/parent_age_link_audit.dta", clear
count if parent_younger_than_child == 1
local parent_younger_rows = r(N)
count if child_age_available == 1 & parent_age_available == 1
local parent_age_comparable_rows = r(N)

tempname ah
postfile `ah' str44 check_name str24 status long n str244 evidence using "`output'/diagnostics/shared_spine_quality_anomalies.dta", replace
post `ah' ("roster_hhid_mismatch_rows") ("FLAG") (`roster_hhid_mismatch_rows') ("roster-derived resolved HHID differs from PTRACK HHID where both are available")
post `ah' ("multiple_resident_candidate_cases") ("FLAG") (`multiple_resident_cases') ("one canonical person-wave row has more than one candidate resident household")
post `ah' ("no_resident_candidate_cases") ("FLAG") (`no_resident_cases') ("source roster case has no codebook-based resident candidate")
post `ah' ("parent_younger_than_child_rows") ("FLAG") (`parent_younger_rows') ("linked parent age is lower than child age; inspect source/link, no automatic deletion")
post `ah' ("parent_child_age_comparable_rows") ("INFO") (`parent_age_comparable_rows') ("linked parent-child rows with both ages available")
postclose `ah'
use "`output'/diagnostics/shared_spine_quality_anomalies.dta", clear
export delimited using "`output'/diagnostics/shared_spine_quality_anomalies.csv", replace
list, noobs abbreviate(28)

display as result "SHARED_SPINE_QUALITY_GATE=PASS_WITH_ANOMALY_FLAGS"
display as result "SHARED_SPINE_QUALITY_GATE_NOTE=structural keys pass; unresolved roster and source anomalies remain auditable"
log close
exit 0
