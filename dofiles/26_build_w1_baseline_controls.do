version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/26_build_w1_baseline_controls.log", text replace
display as text "W1_BASELINE_CONTROLS_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "NOTE=verified W1 pre-treatment controls only; raw roster values retained beside recodes"

tempfile w1_spine w1_raw hh_size relation w1_master mother_lookup father_lookup

* --------------------------------------------------------------------------
* 1. Canonical W1 person rows and household-size denominator.
* --------------------------------------------------------------------------
use "`derived'/person_spine.dta", clear
keep if wave == 1
keep pidlink wave survey_year hhid_wave origin_hh birth_date birth_date_available ///
    sex age_at_interview present_roster person_wave_ambiguous
rename hhid_wave w1_hhid
rename origin_hh w1_origin_hhid
rename birth_date w1_birth_date
rename birth_date_available w1_birth_date_available
rename sex w1_sex_spine
rename age_at_interview w1_age
rename present_roster w1_present_roster
isid pidlink
gen byte w1_present_valid = inlist(w1_present_roster, 0, 1)
gen byte w1_present_for_size = w1_present_roster == 1 if w1_present_valid == 1
replace w1_present_for_size = 0 if missing(w1_present_for_size) & !missing(w1_hhid)
save "`w1_spine'", replace

preserve
keep if !missing(w1_hhid)
gen byte w1_one_roster_row = 1
collapse (sum) w1_hh_size=w1_present_for_size ///
    (sum) w1_hh_roster_rows=w1_one_roster_row, by(w1_hhid)
isid w1_hhid
save "`hh_size'", replace
restore

* --------------------------------------------------------------------------
* 2. W1 roster education/school/activity fields. The IFLS1 Appendix C
* codebook verifies AR07, AR16, AR17, AR18, and AR22. Raw fields remain in
* the output; only documented response ranges are promoted to valid recodes.
* --------------------------------------------------------------------------
use "`raw'/wave1_hh93/bukkar2.dta", clear
keep pidlink ar001a ar02 ar07 ar08mth ar08yr ar09yr ar09mth ar10 ar11 ar12 ///
    ar13 ar15 ar16 ar16_10 ar17 ar18 ar22
isid pidlink
rename ar001a w1_roster_line
rename ar02 w1_relation_raw
rename ar07 w1_sex_raw
rename ar08mth w1_birth_month_raw
rename ar08yr w1_birth_year_raw
rename ar09yr w1_age_roster_raw
rename ar09mth w1_age_month_raw
rename ar10 w1_father_line_raw
rename ar11 w1_mother_line_raw
rename ar12 w1_caregiver_line_raw
rename ar13 w1_marital_raw
rename ar15 w1_religion_raw
rename ar16 w1_education_level_raw
rename ar16_10 w1_education_other_original
rename ar17 w1_grade_completed_raw
rename ar18 w1_current_school_raw
rename ar22 w1_primary_activity_raw
save "`w1_raw'", replace

* --------------------------------------------------------------------------
* 3. Attach raw W1 fields, household size, and verified W1 parent links.
* --------------------------------------------------------------------------
tempname ma va sf
postfile `ma' str40 source str80 merge_rule long master_n matched_n ///
    master_only_n using "`output'/diagnostics/w1_baseline_merge_audit.dta", replace

use "`w1_spine'", clear
local master_n = _N
merge 1:1 pidlink using "`w1_raw'", gen(_raw_merge)
count if _raw_merge == 3
local matched_n = r(N)
count if _raw_merge == 1
local master_only_n = r(N)
count if _raw_merge == 2
local raw_only_n = r(N)
post `ma' ("W1 bukkar2 roster") ("1:1 pidlink; retain canonical spine") ///
    (`master_n') (`matched_n') (`master_only_n')
gen byte w1_raw_roster_linked = _raw_merge == 3
drop if _raw_merge == 2
drop _raw_merge

local master_n = _N
merge m:1 w1_hhid using "`hh_size'", gen(_hh_merge)
count if _hh_merge == 3
local matched_n = r(N)
count if _hh_merge == 1
local master_only_n = r(N)
count if _hh_merge == 2
local hh_only_n = r(N)
post `ma' ("W1 household size") ("m:1 w1_hhid; retain person rows") ///
    (`master_n') (`matched_n') (`master_only_n')
gen byte w1_hh_size_linked = _hh_merge == 3
drop if _hh_merge == 2
drop _hh_merge

use "`derived'/roster_relation_long.dta", clear
keep if wave == 1
keep pidlink hhid_wave pid_wave mother_pidlink father_pidlink mother_linked ///
    father_linked mother_resolution_status father_resolution_status
rename hhid_wave relation_w1_hhid
rename pid_wave relation_w1_pid
isid pidlink
save "`relation'", replace

local master_n = _N
use "`w1_spine'", clear
merge 1:1 pidlink using "`relation'", gen(_relation_merge)
count if _relation_merge == 3
local matched_n = r(N)
count if _relation_merge == 1
local master_only_n = r(N)
count if _relation_merge == 2
local relation_only_n = r(N)
post `ma' ("W1 roster relation") ("1:1 pidlink; retain canonical spine") ///
    (`master_n') (`matched_n') (`master_only_n')
gen byte w1_relation_linked = _relation_merge == 3
drop if _relation_merge == 2
drop _relation_merge

* Reattach the raw roster fields and household size after the relation merge.
merge 1:1 pidlink using "`w1_raw'", gen(_raw_merge2)
count if _raw_merge2 == 3
local matched_n = r(N)
count if _raw_merge2 == 1
local master_only_n = r(N)
count if _raw_merge2 == 2
local raw2_only_n = r(N)
post `ma' ("W1 bukkar2 roster reattach") ("1:1 pidlink; retain canonical spine") ///
    (`master_n') (`matched_n') (`master_only_n')
gen byte w1_raw_roster_linked = _raw_merge2 == 3
drop if _raw_merge2 == 2
drop _raw_merge2

merge m:1 w1_hhid using "`hh_size'", gen(_hh_merge2)
count if _hh_merge2 == 3
local matched_n = r(N)
count if _hh_merge2 == 1
local master_only_n = r(N)
count if _hh_merge2 == 2
local hh2_only_n = r(N)
post `ma' ("W1 household size reattach") ("m:1 w1_hhid; retain person rows") ///
    (`master_n') (`matched_n') (`master_only_n')
gen byte w1_hh_size_linked = _hh_merge2 == 3
drop if _hh_merge2 == 2
drop _hh_merge2
save "`w1_master'", replace

* --------------------------------------------------------------------------
* 4. Parent-characteristic lookups. Parent attributes are kept as controls
* only when the within-household parent link is explicitly resolved.
* --------------------------------------------------------------------------
use "`w1_master'", clear
keep pidlink w1_hhid w1_age w1_sex_spine w1_present_roster ///
    w1_education_level_raw w1_grade_completed_raw w1_current_school_raw ///
    w1_primary_activity_raw
rename pidlink mother_pidlink
rename w1_hhid w1_mother_hhid_source
rename w1_age w1_mother_age_source
rename w1_sex_spine w1_mother_sex_source
rename w1_present_roster w1_mother_present_source
rename w1_education_level_raw w1_mother_education_raw
rename w1_grade_completed_raw w1_mother_grade_raw
rename w1_current_school_raw w1_mother_school_raw
rename w1_primary_activity_raw w1_mother_activity_raw
isid mother_pidlink
save "`mother_lookup'", replace

use "`w1_master'", clear
keep pidlink w1_hhid w1_age w1_sex_spine w1_present_roster ///
    w1_education_level_raw w1_grade_completed_raw w1_current_school_raw ///
    w1_primary_activity_raw
rename pidlink father_pidlink
rename w1_hhid w1_father_hhid_source
rename w1_age w1_father_age_source
rename w1_sex_spine w1_father_sex_source
rename w1_present_roster w1_father_present_source
rename w1_education_level_raw w1_father_education_raw
rename w1_grade_completed_raw w1_father_grade_raw
rename w1_current_school_raw w1_father_school_raw
rename w1_primary_activity_raw w1_father_activity_raw
isid father_pidlink
save "`father_lookup'", replace

use "`w1_master'", clear
local master_n = _N
merge m:1 mother_pidlink using "`mother_lookup'", gen(_mother_merge)
count if _mother_merge == 3
local matched_n = r(N)
count if _mother_merge == 1
local master_only_n = r(N)
count if _mother_merge == 2
local mother_only_n = r(N)
post `ma' ("W1 mother characteristics") ("m:1 mother_pidlink; retain child rows") ///
    (`master_n') (`matched_n') (`master_only_n')
gen byte w1_mother_attribute_linked = _mother_merge == 3
drop if _mother_merge == 2
drop _mother_merge

merge m:1 father_pidlink using "`father_lookup'", gen(_father_merge)
count if _father_merge == 3
local matched_n = r(N)
count if _father_merge == 1
local master_only_n = r(N)
count if _father_merge == 2
local father_only_n = r(N)
post `ma' ("W1 father characteristics") ("m:1 father_pidlink; retain child rows") ///
    (`master_n') (`matched_n') (`master_only_n')
gen byte w1_father_attribute_linked = _father_merge == 3
drop if _father_merge == 2
drop _father_merge
postclose `ma'

* --------------------------------------------------------------------------
* 5. Exact valid-code recodes. The raw variables and source flags are kept
* beside each derived field for audit and future sensitivity specifications.
* --------------------------------------------------------------------------
gen byte w1_age_valid = !missing(w1_age) & inrange(w1_age, 0, 100)
gen byte w1_sex_valid = inlist(w1_sex_spine, 1, 3) if !missing(w1_sex_spine)
replace w1_sex_valid = 0 if missing(w1_sex_valid)
gen byte w1_child_female = w1_sex_spine == 3 if w1_sex_valid == 1
gen int w1_birth_year = year(w1_birth_date) if w1_birth_date_available == 1
gen byte w1_hh_size_valid = w1_hh_size > 0 if !missing(w1_hh_size)
replace w1_hh_size_valid = 0 if missing(w1_hh_size_valid)

gen byte w1_education_valid = inrange(w1_education_level_raw, 1, 11) ///
    if !missing(w1_education_level_raw)
replace w1_education_valid = 0 if missing(w1_education_valid)
gen byte w1_grade_valid = inrange(w1_grade_completed_raw, 1, 7) ///
    if !missing(w1_grade_completed_raw)
replace w1_grade_valid = 0 if missing(w1_grade_valid)
gen byte w1_current_school_valid = inlist(w1_current_school_raw, 1, 3) ///
    if !missing(w1_current_school_raw)
replace w1_current_school_valid = 0 if missing(w1_current_school_valid)
gen byte w1_current_school = w1_current_school_raw == 1 ///
    if w1_current_school_valid == 1
gen byte w1_activity_valid = inrange(w1_primary_activity_raw, 1, 6) ///
    if !missing(w1_primary_activity_raw)
replace w1_activity_valid = 0 if missing(w1_activity_valid)
gen byte w1_working = w1_primary_activity_raw == 1 if w1_activity_valid == 1

gen byte w1_mother_link_valid = w1_relation_linked == 1 & ///
    mother_linked == 1 & !missing(mother_pidlink)
gen byte w1_father_link_valid = w1_relation_linked == 1 & ///
    father_linked == 1 & !missing(father_pidlink)
gen byte w1_mother_age_valid = w1_mother_link_valid == 1 & ///
    inrange(w1_mother_age_source, 0, 100)
gen byte w1_father_age_valid = w1_father_link_valid == 1 & ///
    inrange(w1_father_age_source, 0, 100)
gen double w1_mother_age = w1_mother_age_source if w1_mother_age_valid == 1
gen double w1_father_age = w1_father_age_source if w1_father_age_valid == 1
gen byte w1_mother_sex_valid = w1_mother_link_valid == 1 & ///
    inlist(w1_mother_sex_source, 1, 3)
gen byte w1_father_sex_valid = w1_father_link_valid == 1 & ///
    inlist(w1_father_sex_source, 1, 3)
gen byte w1_mother_female = w1_mother_sex_source == 3 ///
    if w1_mother_sex_valid == 1
gen byte w1_father_male = w1_father_sex_source == 1 ///
    if w1_father_sex_valid == 1
gen byte w1_mother_education_valid = w1_mother_link_valid == 1 & ///
    inrange(w1_mother_education_raw, 1, 11)
gen byte w1_father_education_valid = w1_father_link_valid == 1 & ///
    inrange(w1_father_education_raw, 1, 11)
gen byte w1_mother_school_valid = w1_mother_link_valid == 1 & ///
    inlist(w1_mother_school_raw, 1, 3)
gen byte w1_father_school_valid = w1_father_link_valid == 1 & ///
    inlist(w1_father_school_raw, 1, 3)

gen byte w1_core_controls_complete = w1_age_valid == 1 & ///
    w1_sex_valid == 1 & w1_hh_size_valid == 1 & ///
    w1_mother_age_valid == 1 & w1_father_age_valid == 1
gen byte w1_expanded_controls_complete = w1_core_controls_complete == 1 & ///
    w1_education_valid == 1 & w1_current_school_valid == 1 & ///
    w1_mother_education_valid == 1 & w1_father_education_valid == 1

label variable w1_age "W1 age from canonical person spine"
label variable w1_child_female "W1 female indicator; sex code 3"
label variable w1_hh_size "W1 household size among present roster members"
label variable w1_education_level_raw "W1 AR16 highest education level raw"
label variable w1_current_school_raw "W1 AR18 current school status raw"
label variable w1_primary_activity_raw "W1 AR22 primary activity raw"
label variable w1_mother_age "W1 linked mother's age from person spine"
label variable w1_father_age "W1 linked father's age from person spine"
label variable w1_core_controls_complete "Core pre-treatment controls all observed"
label variable w1_expanded_controls_complete "Core plus education controls all observed"

order pidlink wave survey_year w1_hhid w1_origin_hhid w1_age w1_sex_spine ///
    w1_child_female w1_birth_date w1_birth_year w1_hh_size ///
    mother_pidlink father_pidlink w1_mother_age w1_father_age ///
    w1_education_level_raw w1_grade_completed_raw w1_current_school_raw ///
    w1_primary_activity_raw w1_core_controls_complete ///
    w1_expanded_controls_complete
sort pidlink
isid pidlink
save "`derived'/w1_baseline_controls.dta", replace
export delimited using "`output'/diagnostics/w1_baseline_controls.csv", replace

* --------------------------------------------------------------------------
* 6. Coverage and sample-flow diagnostics.
* --------------------------------------------------------------------------
local universe = _N
postfile `va' str40 variable long universe valid_n missing_n invalid_observed_n ///
    using "`output'/diagnostics/w1_baseline_validity_audit.dta", replace

count if w1_age_valid == 1
local valid_n = r(N)
count if missing(w1_age)
local missing_n = r(N)
count if !missing(w1_age) & w1_age_valid == 0
local invalid_n = r(N)
post `va' ("w1_age") (`universe') (`valid_n') (`missing_n') (`invalid_n')

count if w1_sex_valid == 1
local valid_n = r(N)
count if missing(w1_sex_spine)
local missing_n = r(N)
count if !missing(w1_sex_spine) & w1_sex_valid == 0
local invalid_n = r(N)
post `va' ("w1_sex") (`universe') (`valid_n') (`missing_n') (`invalid_n')

count if w1_hh_size_valid == 1
local valid_n = r(N)
count if missing(w1_hh_size)
local missing_n = r(N)
count if !missing(w1_hh_size) & w1_hh_size_valid == 0
local invalid_n = r(N)
post `va' ("w1_hh_size") (`universe') (`valid_n') (`missing_n') (`invalid_n')

count if w1_education_valid == 1
local valid_n = r(N)
count if missing(w1_education_level_raw)
local missing_n = r(N)
count if !missing(w1_education_level_raw) & w1_education_valid == 0
local invalid_n = r(N)
post `va' ("w1_education_level") (`universe') (`valid_n') (`missing_n') (`invalid_n')

count if w1_current_school_valid == 1
local valid_n = r(N)
count if missing(w1_current_school_raw)
local missing_n = r(N)
count if !missing(w1_current_school_raw) & w1_current_school_valid == 0
local invalid_n = r(N)
post `va' ("w1_current_school") (`universe') (`valid_n') (`missing_n') (`invalid_n')

count if w1_mother_age_valid == 1
local valid_n = r(N)
count if missing(w1_mother_age)
local missing_n = r(N)
count if w1_mother_link_valid == 1 & !missing(w1_mother_age_source) & ///
    w1_mother_age_valid == 0
local invalid_n = r(N)
post `va' ("w1_mother_age") (`universe') (`valid_n') (`missing_n') (`invalid_n')

count if w1_father_age_valid == 1
local valid_n = r(N)
count if missing(w1_father_age)
local missing_n = r(N)
count if w1_father_link_valid == 1 & !missing(w1_father_age_source) & ///
    w1_father_age_valid == 0
local invalid_n = r(N)
post `va' ("w1_father_age") (`universe') (`valid_n') (`missing_n') (`invalid_n')

count if w1_mother_education_valid == 1
local valid_n = r(N)
count if missing(w1_mother_education_raw)
local missing_n = r(N)
count if w1_mother_link_valid == 1 & !missing(w1_mother_education_raw) & ///
    w1_mother_education_valid == 0
local invalid_n = r(N)
post `va' ("w1_mother_education") (`universe') (`valid_n') (`missing_n') (`invalid_n')

count if w1_father_education_valid == 1
local valid_n = r(N)
count if missing(w1_father_education_raw)
local missing_n = r(N)
count if w1_father_link_valid == 1 & !missing(w1_father_education_raw) & ///
    w1_father_education_valid == 0
local invalid_n = r(N)
post `va' ("w1_father_education") (`universe') (`valid_n') (`missing_n') (`invalid_n')
postclose `va'

use "`output'/diagnostics/w1_baseline_validity_audit.dta", clear
sort variable
save "`output'/diagnostics/w1_baseline_validity_audit.dta", replace
export delimited using "`output'/diagnostics/w1_baseline_validity_audit.csv", replace

use "`derived'/w1_baseline_controls.dta", clear
postfile `sf' str120 stage long N using "`output'/diagnostics/w1_baseline_sample_flow.dta", replace
count
post `sf' ("Canonical W1 person rows") (r(N))
count if w1_present_roster == 1 & !missing(w1_hhid)
post `sf' ("Present W1 roster with valid HHID") (r(N))
count if w1_age_valid == 1 & inrange(w1_age, 0, 12)
post `sf' ("W1 child cohort age 0-12") (r(N))
count if inrange(w1_age, 0, 12) & w1_core_controls_complete == 1
post `sf' ("Age 0-12 with core controls complete") (r(N))
count if inrange(w1_age, 0, 12) & w1_expanded_controls_complete == 1
post `sf' ("Age 0-12 with expanded controls complete") (r(N))
count if inrange(w1_age, 0, 12) & w1_mother_link_valid == 1
post `sf' ("Age 0-12 with linked mother") (r(N))
count if inrange(w1_age, 0, 12) & w1_father_link_valid == 1
post `sf' ("Age 0-12 with linked father") (r(N))
count if inrange(w1_age, 0, 12) & w1_mother_link_valid == 1 & ///
    w1_father_link_valid == 1
post `sf' ("Age 0-12 with both linked parents") (r(N))
postclose `sf'
use "`output'/diagnostics/w1_baseline_sample_flow.dta", clear
export delimited using "`output'/diagnostics/w1_baseline_sample_flow.csv", replace

use "`derived'/w1_baseline_controls.dta", clear
preserve
keep if inrange(w1_age, 0, 12)
contract w1_education_level_raw
rename _freq N
sort w1_education_level_raw
save "`output'/diagnostics/w1_education_distribution.dta", replace
export delimited using "`output'/diagnostics/w1_education_distribution.csv", replace
restore

preserve
keep if inrange(w1_age, 0, 12)
contract w1_current_school_raw
rename _freq N
sort w1_current_school_raw
save "`output'/diagnostics/w1_school_distribution.dta", replace
export delimited using "`output'/diagnostics/w1_school_distribution.csv", replace
restore

* --------------------------------------------------------------------------
* 7. Mechanical gate. Missing/ambiguous controls are reported and handled at
* the outcome-specific model gate; they are never silently imputed here.
* --------------------------------------------------------------------------
use "`derived'/w1_baseline_controls.dta", clear
count if missing(pidlink)
if r(N) > 0 {
    display as error "W1_BASELINE_CONTROLS_FAIL=missing pidlink"
    log close
    exit 459
}
isid pidlink
count if !missing(w1_hhid) & w1_hh_size <= 0
if r(N) > 0 {
    display as error "W1_BASELINE_CONTROLS_FAIL=nonpositive household size with HHID"
    log close
    exit 459
}
count if w1_relation_linked == 1 & mother_linked == 1 & ///
    (missing(mother_pidlink) | w1_mother_attribute_linked != 1)
if r(N) > 0 {
    display as error "W1_BASELINE_CONTROLS_FAIL=mother link not resolved to canonical attribute"
    log close
    exit 459
}
count if w1_relation_linked == 1 & father_linked == 1 & ///
    (missing(father_pidlink) | w1_father_attribute_linked != 1)
if r(N) > 0 {
    display as error "W1_BASELINE_CONTROLS_FAIL=father link not resolved to canonical attribute"
    log close
    exit 459
}
display as result "W1_BASELINE_CONTROLS_PASS"
display as result "W1_BASELINE_CONTROLS_NOTE=education and activity are retained as expanded/exploratory controls; primary models use the predeclared core set"
log close
exit 0
