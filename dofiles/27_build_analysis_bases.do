version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/27_build_analysis_bases.log", text replace
display as text "ANALYSIS_BASES_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "NOTE=primary treatment frames merged to verified W1 controls and W5 outcome universe"

tempfile r1_base r3_base baseline_r1 baseline_r3 w5_r1 w5_r3
tempname ma sf oa

postfile `ma' str8 paper str40 source str100 merge_rule long master_n ///
    matched_n master_only_n using "`output'/diagnostics/analysis_base_merge_audit.dta", replace

* W1 controls are one row per canonical PIDLINK. Separate renamed copies make
* the m:1/1:1 merge roles explicit in the log and prevent accidental name
* collisions with treatment variables.
use "`derived'/w1_baseline_controls.dta", clear
keep pidlink w1_hhid w1_age w1_sex_spine w1_child_female w1_birth_date ///
    w1_birth_year w1_present_roster w1_hh_size w1_hh_size_valid ///
    w1_age_valid w1_sex_valid w1_education_level_raw w1_education_valid ///
    w1_grade_completed_raw w1_grade_valid w1_current_school_raw ///
    w1_current_school w1_current_school_valid w1_primary_activity_raw ///
    w1_activity_valid w1_working mother_pidlink father_pidlink ///
    w1_mother_age w1_father_age w1_mother_age_valid w1_father_age_valid ///
    w1_mother_education_raw w1_father_education_raw ///
    w1_mother_education_valid w1_father_education_valid ///
    w1_mother_link_valid w1_father_link_valid w1_core_controls_complete ///
    w1_expanded_controls_complete
rename pidlink child_pidlink
isid child_pidlink
save "`baseline_r1'", replace
rename child_pidlink pidlink
isid pidlink
save "`baseline_r3'", replace

* W5 outcome file is also one row per PIDLINK. Keep only analysis outcomes
* and the module/universe flags needed to document missingness.
use "`derived'/w5_adult_outcomes.dta", clear
keep pidlink w5_hhid age_at_interview adult_employment_valid adult_employed ///
    adult_salary_valid adult_ln1p_salary_monthly ///
    adult_profit_valid adult_ln1p_abs_profit adult_dl06_valid ///
    adult_college adult_grade_valid adult_grade_completed ///
    adult_srh_valid adult_srh_score adult_good_health ///
    adult_bmi_valid adult_bmi_raw adult_health_adequacy_valid ///
    adult_health_adequacy adult_smoking_valid adult_current_smoker ///
    adult_marriage_valid adult_married adult_condition_observed ///
    adult_any_listed_condition adult_tr01_valid adult_tr01_score ///
    adult_tr02_valid adult_tr02_score adult_tr03_valid adult_tr03_score ///
    adult_tr04_valid adult_tr04_score adult_tr05_valid adult_tr05_score ///
    adult_tr06_valid adult_tr06_score
rename pidlink child_pidlink
isid child_pidlink
save "`w5_r1'", replace
rename child_pidlink pidlink
isid pidlink
save "`w5_r3'", replace

* --------------------------------------------------------------------------
* R1: one row per primary child. Primary treatment already requires the W1
* parent-link/origin/W5-tracking lock; this stage verifies that the baseline
* control file agrees with that origin household and that the W5 outcome
* universe is reachable.
* --------------------------------------------------------------------------
use "`derived'/r1_mother_international_treatment.dta", clear
keep if r1_primary_eligible == 1
isid child_pidlink
local master_n = _N
merge 1:1 child_pidlink using "`baseline_r1'", gen(_baseline_merge)
count if _baseline_merge == 3
local matched_n = r(N)
count if _baseline_merge == 1
local master_only_n = r(N)
count if _baseline_merge == 2
local baseline_only_n = r(N)
post `ma' ("R1") ("W1 baseline controls") ("1:1 child_pidlink; retain treatment rows") ///
    (`master_n') (`matched_n') (`master_only_n')
gen byte r1_baseline_linked = _baseline_merge == 3
drop if _baseline_merge == 2
drop _baseline_merge

local master_n = _N
merge 1:1 child_pidlink using "`w5_r1'", gen(_w5_merge)
count if _w5_merge == 3
local matched_n = r(N)
count if _w5_merge == 1
local master_only_n = r(N)
count if _w5_merge == 2
local w5_only_n = r(N)
post `ma' ("R1") ("W5 adult outcomes") ("1:1 child_pidlink; retain treatment rows") ///
    (`master_n') (`matched_n') (`master_only_n')
gen byte r1_w5_outcome_universe_linked = _w5_merge == 3
drop if _w5_merge == 2
drop _w5_merge

gen byte r1_w1_origin_observed = r1_baseline_linked == 1 & ///
    w1_present_roster == 1 & !missing(w1_hhid)
gen byte r1_w1_origin_matches_treatment = r1_w1_origin_observed == 1 & ///
    !missing(origin_hhid) & origin_hhid == w1_hhid
gen byte r1_core_baseline_observed = r1_w1_origin_matches_treatment == 1 & ///
    w1_core_controls_complete == 1
gen byte r1_expanded_baseline_observed = r1_w1_origin_matches_treatment == 1 & ///
    w1_expanded_controls_complete == 1
gen str10 r1_cluster_hhid = origin_hhid
egen long r1_cluster_id = group(r1_cluster_hhid)
replace r1_cluster_id = . if missing(r1_cluster_hhid)
gen byte r1_analysis_frame = r1_primary_eligible == 1 & ///
    r1_w1_origin_matches_treatment == 1 & ///
    r1_w5_outcome_universe_linked == 1
label variable r1_analysis_frame "R1 primary frame with W1 origin and W5 outcome-universe link"
label variable r1_core_baseline_observed "R1 primary frame with predeclared core controls observed"
sort child_pidlink
isid child_pidlink
save "`derived'/r1_analysis_base.dta", replace
export delimited using "`output'/diagnostics/r1_analysis_base.csv", replace

* --------------------------------------------------------------------------
* R3: one row per age-15 person-wave. W1 presence is required for a usable
* pre-treatment baseline. Duplicate age-15 treatment rows for the same person
* are flagged and excluded from the primary analysis frame.
* --------------------------------------------------------------------------
use "`derived'/r3_child_labor_treatment.dta", clear
keep if r3_primary_eligible == 1
isid pidlink wave
local master_n = _N
merge m:1 pidlink using "`baseline_r3'", gen(_baseline_merge)
count if _baseline_merge == 3
local matched_n = r(N)
count if _baseline_merge == 1
local master_only_n = r(N)
count if _baseline_merge == 2
local baseline_only_n = r(N)
post `ma' ("R3") ("W1 baseline controls") ("m:1 pidlink; retain treatment person-wave rows") ///
    (`master_n') (`matched_n') (`master_only_n')
gen byte r3_baseline_linked = _baseline_merge == 3
drop if _baseline_merge == 2
drop _baseline_merge

local master_n = _N
merge m:1 pidlink using "`w5_r3'", gen(_w5_merge)
count if _w5_merge == 3
local matched_n = r(N)
count if _w5_merge == 1
local master_only_n = r(N)
count if _w5_merge == 2
local w5_only_n = r(N)
post `ma' ("R3") ("W5 adult outcomes") ("m:1 pidlink; retain treatment person-wave rows") ///
    (`master_n') (`matched_n') (`master_only_n')
gen byte r3_w5_outcome_universe_linked = _w5_merge == 3
drop if _w5_merge == 2
drop _w5_merge

sort pidlink wave
by pidlink: gen byte r3_duplicate_treatment_person = _N > 1
gen byte r3_w1_baseline_observed = r3_baseline_linked == 1 & ///
    w1_present_roster == 1 & !missing(w1_hhid)
gen byte r3_core_baseline_observed = r3_w1_baseline_observed == 1 & ///
    w1_core_controls_complete == 1
gen byte r3_expanded_baseline_observed = r3_w1_baseline_observed == 1 & ///
    w1_expanded_controls_complete == 1
gen str10 r3_cluster_hhid = hhid_wave
egen long r3_cluster_id = group(r3_cluster_hhid)
replace r3_cluster_id = . if missing(r3_cluster_hhid)
gen byte r3_analysis_frame = r3_primary_eligible == 1 & ///
    r3_w1_baseline_observed == 1 & ///
    r3_w5_outcome_universe_linked == 1 & ///
    r3_duplicate_treatment_person == 0
label variable r3_analysis_frame "R3 age-15 frame with W1 baseline and W5 outcome-universe link"
label variable r3_core_baseline_observed "R3 frame with predeclared core controls observed"
sort pidlink wave
isid pidlink wave
save "`derived'/r3_analysis_base.dta", replace
export delimited using "`output'/diagnostics/r3_analysis_base.csv", replace

postclose `ma'
use "`output'/diagnostics/analysis_base_merge_audit.dta", clear
sort paper source
save "`output'/diagnostics/analysis_base_merge_audit.dta", replace
export delimited using "`output'/diagnostics/analysis_base_merge_audit.csv", replace

* --------------------------------------------------------------------------
* Sample flow and outcome-support table. Outcome-specific listwise deletion is
* applied later, so this table reports support without silently changing the
* common analysis frame.
* --------------------------------------------------------------------------
postfile `sf' str8 paper str120 stage long N ///
    using "`output'/diagnostics/analysis_sample_flow.dta", replace

use "`derived'/r1_analysis_base.dta", clear
count
post `sf' ("R1") ("Primary treatment rows") (r(N))
count if r1_w1_origin_matches_treatment == 1
post `sf' ("R1") ("Valid W1 origin agrees with treatment") (r(N))
count if r1_core_baseline_observed == 1
post `sf' ("R1") ("Core baseline controls complete") (r(N))
count if r1_w5_outcome_universe_linked == 1
post `sf' ("R1") ("W5 adult outcome universe linked") (r(N))
count if r1_analysis_frame == 1
post `sf' ("R1") ("R1 analysis frame") (r(N))
count if r1_analysis_frame == 1 & r1_treatment == 1
post `sf' ("R1") ("R1 analysis treated") (r(N))
count if r1_analysis_frame == 1 & r1_treatment == 0
post `sf' ("R1") ("R1 analysis control") (r(N))

use "`derived'/r3_analysis_base.dta", clear
count
post `sf' ("R3") ("Primary treatment person-wave rows") (r(N))
count if r3_w1_baseline_observed == 1
post `sf' ("R3") ("Valid W1 baseline observed") (r(N))
count if r3_core_baseline_observed == 1
post `sf' ("R3") ("Core baseline controls complete") (r(N))
count if r3_w5_outcome_universe_linked == 1
post `sf' ("R3") ("W5 adult outcome universe linked") (r(N))
count if r3_duplicate_treatment_person == 1
post `sf' ("R3") ("Flagged duplicate treatment person") (r(N))
count if r3_analysis_frame == 1
post `sf' ("R3") ("R3 analysis frame") (r(N))
count if r3_analysis_frame == 1 & r3_treatment == 1
post `sf' ("R3") ("R3 analysis treated") (r(N))
count if r3_analysis_frame == 1 & r3_treatment == 0
post `sf' ("R3") ("R3 analysis control") (r(N))
postclose `sf'
use "`output'/diagnostics/analysis_sample_flow.dta", clear
sort paper stage
save "`output'/diagnostics/analysis_sample_flow.dta", replace
export delimited using "`output'/diagnostics/analysis_sample_flow.csv", replace

postfile `oa' str8 paper str24 family str40 outcome str140 valid_rule ///
    long frame_n valid_n treated_n control_n cluster_n ///
    using "`output'/diagnostics/analysis_outcome_support.dta", replace

* Outcome family list is intentionally explicit and matches the locked W5
* outcome definitions. Grade completed is retained in the data but not in the
* first-pass family because AR/DL grade semantics are not a clean common scale.
use "`derived'/r1_analysis_base.dta", clear
local frame_n = 0
count if r1_analysis_frame == 1
local frame_n = r(N)
local r1_labor "adult_employed adult_ln1p_salary_monthly adult_ln1p_abs_profit"
local r1_labor_rules "TK01 valid employment codes|TK25A1X=1 and monthly value 0 to <999999997|TK26A1X=1/2 and monthly value 0 to <999999999998"
local r1_education "adult_college"
local r1_education_rules "DL06 valid category; college/university codes 60 to 63"
local r1_health "adult_srh_score adult_good_health adult_bmi_raw adult_health_adequacy"
local r1_health_rules "KK01 codes 1 to 4; score 5 minus KK01|KK01 codes 1 to 4; good=1/2|Measured height/weight and BMI 10 to 80|SW06 codes 1 to 3"
local r1_social "adult_current_smoker adult_married adult_any_listed_condition adult_tr01_score adult_tr02_score adult_tr03_score adult_tr04_score adult_tr05_score adult_tr06_score"
local r1_social_rules "Explicit KM current smoker recode|PK00A codes 1/3|CD01 any listed condition, yes/no only|TR01 score 5 minus valid item|TR02 score 5 minus valid item|TR03 score 5 minus valid item|TR04 score 5 minus valid item|TR05 score 5 minus valid item|TR06 score 5 minus valid item"

local i = 0
foreach outcome of local r1_labor {
    local ++i
    local rule "W5 outcome-specific valid-code rule recorded in w5_outcome_definition.md"
    if "`outcome'" == "adult_employed" local rule "TK01 valid activity codes 1,2,3,4,5,7,95"
    if "`outcome'" == "adult_ln1p_salary_monthly" local rule "TK25A1X=1 and TK25A1 in 0 to <999999997; ln(1+monthly salary)"
    if "`outcome'" == "adult_ln1p_abs_profit" local rule "TK26A1X=1/2 and TK26A1 in 0 to <999999999998; signed profit mapped to ln(1+abs(profit))"
    count if r1_analysis_frame == 1 & !missing(`outcome')
    local valid_n = r(N)
    count if r1_analysis_frame == 1 & r1_treatment == 1 & !missing(`outcome')
    local treated_n = r(N)
    count if r1_analysis_frame == 1 & r1_treatment == 0 & !missing(`outcome')
    local control_n = r(N)
    preserve
    keep if r1_analysis_frame == 1 & !missing(`outcome') & !missing(r1_cluster_hhid)
    egen byte _cluster_tag = tag(r1_cluster_hhid)
    count if _cluster_tag == 1
    local cluster_n = r(N)
    restore
    post `oa' ("R1") ("labor") ("`outcome'") ("`rule'") ///
        (`frame_n') (`valid_n') (`treated_n') (`control_n') (`cluster_n')
}
local i = 0
foreach outcome of local r1_education {
    local ++i
    local rule "DL06 valid categories; college/university codes 60 to 63"
    count if r1_analysis_frame == 1 & !missing(`outcome')
    local valid_n = r(N)
    count if r1_analysis_frame == 1 & r1_treatment == 1 & !missing(`outcome')
    local treated_n = r(N)
    count if r1_analysis_frame == 1 & r1_treatment == 0 & !missing(`outcome')
    local control_n = r(N)
    preserve
    keep if r1_analysis_frame == 1 & !missing(`outcome') & !missing(r1_cluster_hhid)
    egen byte _cluster_tag = tag(r1_cluster_hhid)
    count if _cluster_tag == 1
    local cluster_n = r(N)
    restore
    post `oa' ("R1") ("education") ("`outcome'") ("`rule'") ///
        (`frame_n') (`valid_n') (`treated_n') (`control_n') (`cluster_n')
}
local i = 0
foreach outcome of local r1_health {
    local ++i
    local rule "W5 outcome-specific valid-code rule recorded in w5_outcome_definition.md"
    if "`outcome'" == "adult_srh_score" local rule "KK01 codes 1 to 4; score=5-KK01"
    if "`outcome'" == "adult_good_health" local rule "KK01 codes 1 to 4; good health=KK01 1 or 2"
    if "`outcome'" == "adult_bmi_raw" local rule "US04X/US06X measured; height 100-250 cm; weight 20-250 kg; BMI 10-80"
    if "`outcome'" == "adult_health_adequacy" local rule "SW06 codes 1 to 3"
    count if r1_analysis_frame == 1 & !missing(`outcome')
    local valid_n = r(N)
    count if r1_analysis_frame == 1 & r1_treatment == 1 & !missing(`outcome')
    local treated_n = r(N)
    count if r1_analysis_frame == 1 & r1_treatment == 0 & !missing(`outcome')
    local control_n = r(N)
    preserve
    keep if r1_analysis_frame == 1 & !missing(`outcome') & !missing(r1_cluster_hhid)
    egen byte _cluster_tag = tag(r1_cluster_hhid)
    count if _cluster_tag == 1
    local cluster_n = r(N)
    restore
    post `oa' ("R1") ("health") ("`outcome'") ("`rule'") ///
        (`frame_n') (`valid_n') (`treated_n') (`control_n') (`cluster_n')
}
local i = 0
foreach outcome of local r1_social {
    local ++i
    local rule "W5 outcome-specific valid-code rule recorded in w5_outcome_definition.md"
    if "`outcome'" == "adult_current_smoker" local rule "Explicit KM01A/KM01E/KM04 cigarette response"
    if "`outcome'" == "adult_married" local rule "PK00A codes 1 or 3"
    if "`outcome'" == "adult_any_listed_condition" local rule "CD01 collapsed across condition rows; yes=1, no=3, DK=8 excluded"
    if "`outcome'" == "adult_tr01_score" local rule "TR01 valid item 1 to 4; reverse score=5-TR01"
    if "`outcome'" == "adult_tr02_score" local rule "TR02 valid item 1 to 4; reverse score=5-TR02"
    if "`outcome'" == "adult_tr03_score" local rule "TR03 valid item 1 to 4; reverse score=5-TR03"
    if "`outcome'" == "adult_tr04_score" local rule "TR04 valid item 1 to 4; reverse score=5-TR04"
    if "`outcome'" == "adult_tr05_score" local rule "TR05 valid item 1 to 4; reverse score=5-TR05"
    if "`outcome'" == "adult_tr06_score" local rule "TR06 valid item 1 to 4; reverse score=5-TR06"
    count if r1_analysis_frame == 1 & !missing(`outcome')
    local valid_n = r(N)
    count if r1_analysis_frame == 1 & r1_treatment == 1 & !missing(`outcome')
    local treated_n = r(N)
    count if r1_analysis_frame == 1 & r1_treatment == 0 & !missing(`outcome')
    local control_n = r(N)
    preserve
    keep if r1_analysis_frame == 1 & !missing(`outcome') & !missing(r1_cluster_hhid)
    egen byte _cluster_tag = tag(r1_cluster_hhid)
    count if _cluster_tag == 1
    local cluster_n = r(N)
    restore
    post `oa' ("R1") ("social_behavioral") ("`outcome'") ("`rule'") ///
        (`frame_n') (`valid_n') (`treated_n') (`control_n') (`cluster_n')
}

use "`derived'/r3_analysis_base.dta", clear
local frame_n = 0
count if r3_analysis_frame == 1
local frame_n = r(N)
local r3_labor "adult_employed adult_ln1p_salary_monthly adult_ln1p_abs_profit"
local r3_education "adult_college"
local r3_health "adult_srh_score adult_good_health adult_bmi_raw adult_health_adequacy"
local r3_social "adult_current_smoker adult_married adult_any_listed_condition adult_tr01_score adult_tr02_score adult_tr03_score adult_tr04_score adult_tr05_score adult_tr06_score"

foreach family in labor education health social_behavioral {
    local outcomes ""
    if "`family'" == "labor" local outcomes "`r3_labor'"
    if "`family'" == "education" local outcomes "`r3_education'"
    if "`family'" == "health" local outcomes "`r3_health'"
    if "`family'" == "social_behavioral" local outcomes "`r3_social'"
    foreach outcome of local outcomes {
        local rule "W5 outcome-specific valid-code rule recorded in w5_outcome_validity_audit"
        count if r3_analysis_frame == 1 & !missing(`outcome')
        local valid_n = r(N)
        count if r3_analysis_frame == 1 & r3_treatment == 1 & !missing(`outcome')
        local treated_n = r(N)
        count if r3_analysis_frame == 1 & r3_treatment == 0 & !missing(`outcome')
        local control_n = r(N)
        preserve
        keep if r3_analysis_frame == 1 & !missing(`outcome') & !missing(r3_cluster_hhid)
        egen byte _cluster_tag = tag(r3_cluster_hhid)
        count if _cluster_tag == 1
        local cluster_n = r(N)
        restore
        post `oa' ("R3") ("`family'") ("`outcome'") ("`rule'") ///
            (`frame_n') (`valid_n') (`treated_n') (`control_n') (`cluster_n')
    }
}
postclose `oa'
use "`output'/diagnostics/analysis_outcome_support.dta", clear
sort paper family outcome
save "`output'/diagnostics/analysis_outcome_support.dta", replace
export delimited using "`output'/diagnostics/analysis_outcome_support.csv", replace

* --------------------------------------------------------------------------
* Mechanical merge and frame gates.
* --------------------------------------------------------------------------
use "`derived'/r1_analysis_base.dta", clear
count if r1_analysis_frame == 1 & r1_w1_origin_matches_treatment != 1
if r(N) > 0 {
    display as error "ANALYSIS_BASES_FAIL=R1 origin mismatch in analysis frame"
    log close
    exit 459
}
count if r1_analysis_frame == 1 & missing(r1_cluster_hhid)
if r(N) > 0 {
    display as error "ANALYSIS_BASES_FAIL=R1 missing origin household cluster"
    log close
    exit 459
}
isid child_pidlink

use "`derived'/r3_analysis_base.dta", clear
count if r3_analysis_frame == 1 & r3_duplicate_treatment_person == 1
if r(N) > 0 {
    display as error "ANALYSIS_BASES_FAIL=duplicate R3 person remains in primary frame"
    log close
    exit 459
}
count if r3_analysis_frame == 1 & missing(r3_cluster_hhid)
if r(N) > 0 {
    display as error "ANALYSIS_BASES_FAIL=R3 missing treatment household cluster"
    log close
    exit 459
}
isid pidlink wave

display as result "ANALYSIS_BASES_PASS"
display as result "ANALYSIS_BASES_NOTE=outcome-specific listwise deletion and core/expanded control tiers are evaluated in the model gate"
log close
exit 0
