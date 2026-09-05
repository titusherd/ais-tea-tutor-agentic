version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local raw "`project'/00_raw"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/13_r3_cohort_age_audit.log", text replace
display as text "R3_COHORT_AGE_AUDIT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

* Build the treatment-observation frame from the verified one-row-per-person
* child-work screen. W2/W3 are primary candidates; W1 is an extension only.
tempfile t1 t2 t3 treatment_long outcome_long
local first_treatment = 1
foreach tw in 1 2 3 {
    local raw_folder ""
    local raw_file ""
    local treatment_source ""
    if `tw' == 1 {
        local raw_folder "wave1_hh93"
        local raw_file "buk3tk1.dta"
        local treatment_source "verified buk3tk1.dta (W1)"
    }
    if `tw' == 2 {
        local raw_folder "wave2_hh97"
        local raw_file "b3a_tk1.dta"
        local treatment_source "verified b3a_tk1.dta (W2 local extraction)"
    }
    if `tw' == 3 {
        local raw_folder "wave3_hh00"
        local raw_file "b3a_tk1.dta"
        local treatment_source "verified b3a_tk1.dta (W3)"
    }
    use "`derived'/person_spine.dta", clear
    keep if wave == `tw'
    keep pidlink wave survey_year age_at_interview birth_date sex present_roster
    rename wave treatment_wave
    rename survey_year treatment_year
    rename age_at_interview treatment_age
    rename birth_date treatment_birth_date
    rename sex treatment_sex
    merge 1:1 pidlink using "`raw'/`raw_folder'/`raw_file'", keep(3) nogen
    gen int treatment_birth_year = year(treatment_birth_date)
    gen byte treatment_age_valid = !missing(treatment_age) & treatment_age >= 0 & treatment_age <= 100
    gen byte treatment_module_observed = 1
    keep pidlink treatment_wave treatment_year treatment_age treatment_birth_year treatment_sex present_roster treatment_age_valid treatment_module_observed
    isid pidlink
    if `first_treatment' == 1 {
        save "`treatment_long'", replace
        local first_treatment = 0
    }
    else {
        append using "`treatment_long'"
        save "`treatment_long'", replace
    }
}

use "`treatment_long'", clear
count
display as text "R3_TREATMENT_MODULE_FRAME_ROWS=" r(N)
save "`output'/diagnostics/r3_treatment_module_age_frame.dta", replace
export delimited using "`output'/diagnostics/r3_treatment_module_age_frame.csv", replace

* Outcome-age support is measured on the canonical spine, before outcome
* module missingness and final sample filters are applied.
use "`derived'/person_spine.dta", clear
keep if inlist(wave, 4, 5)
keep pidlink wave survey_year age_at_interview birth_date sex
rename wave outcome_wave
rename survey_year outcome_year
rename age_at_interview outcome_age
rename birth_date outcome_birth_date
gen int outcome_birth_year = year(outcome_birth_date)
gen byte outcome_age_valid = !missing(outcome_age) & outcome_age >= 0 & outcome_age <= 100
isid pidlink outcome_wave
save "`outcome_long'", replace

tempname ah mh
postfile `ah' str24 cohort_definition byte treatment_wave int treatment_age_low int treatment_age_high ///
    byte outcome_wave int outcome_age_low int outcome_age_high str40 eligible_for_primary ///
    str180 reason str244 source_or_calculation long treatment_module_n long treatment_age_valid_n ///
    long treatment_age_band_n long outcome_spine_band_n long paired_any_age_n long paired_age_band_n ///
    int birth_cohort_min int birth_cohort_max ///
    using "`output'/diagnostics/r3_cohort_age_audit.dta", replace
postfile `mh' str24 cohort_definition byte treatment_wave int treatment_age_low int treatment_age_high ///
    byte outcome_wave int outcome_age_low int outcome_age_high str40 eligible_for_primary ///
    str180 reason str244 source_or_calculation ///
    using "`project'/99_docs/cohort_age_matrix.dta", replace

foreach tw in 1 2 3 {
    local cohort "R3_W`tw'"
    if `tw' == 1 local cohort "R3_W1_EXTENSION"
    if `tw' == 2 local cohort "R3_W2_PRIMARY_CANDIDATE"
    if `tw' == 3 local cohort "R3_W3_PRIMARY_CANDIDATE"
    foreach ageband in "10 11" "12 14" "15 15" {
        tokenize `"`ageband'"'
        local alow "`1'"
        local ahigh "`2'"

        use "`treatment_long'", clear
        keep if treatment_wave == `tw'
        count
        local treatment_module_n = r(N)
        count if treatment_age_valid == 1
        local treatment_age_valid_n = r(N)
        count if treatment_age_valid == 1 & inrange(treatment_age, `alow', `ahigh')
        local treatment_age_band_n = r(N)
        summarize treatment_birth_year if treatment_age_valid == 1 & inrange(treatment_age, `alow', `ahigh'), meanonly
        local birth_min = r(min)
        local birth_max = r(max)
        if missing(`birth_min') local birth_min = .
        if missing(`birth_max') local birth_max = .
        tempfile treatment_band
        keep if treatment_age_valid == 1 & inrange(treatment_age, `alow', `ahigh')
        keep pidlink treatment_wave treatment_age treatment_birth_year treatment_sex
        isid pidlink
        save "`treatment_band'", replace

        foreach ow in 4 5 {
            local outlow ""
            local outhigh ""
            foreach outband in "17 21" "22 25" "26 29" "30 33" "34 36" {
                tokenize `"`outband'"'
                local outlow "`1'"
                local outhigh "`2'"

                use "`outcome_long'", clear
                keep if outcome_wave == `ow'
                count if outcome_age_valid == 1 & inrange(outcome_age, `outlow', `outhigh')
                local outcome_spine_band_n = r(N)
                merge 1:1 pidlink using "`treatment_band'", keep(1 3) gen(pair_merge)
                count if pair_merge == 3
                local paired_any_age_n = r(N)
                count if pair_merge == 3 & outcome_age_valid == 1 & inrange(outcome_age, `outlow', `outhigh')
                local paired_age_band_n = r(N)

                local eligibility "candidate_pending_review"
                local reason "age/module support only; primary cohort and outcome wave remain owner decisions"
                if `tw' == 1 {
                    local eligibility "secondary_extension_parked"
                    local reason "W1 extension is registered by the timeline but parked for first-pass estimation"
                }
                if `treatment_age_band_n' == 0 | `paired_age_band_n' == 0 {
                    local eligibility "not_supported_by_current_frame"
                    local reason "no observed treatment-age or linked outcome-age support in current spine/module frame"
                }
                local sourcecalc "PTRACK14 age_at_interview + `treatment_source' + person_spine outcome age; detailed-hours linkage audited separately in 19_r3_treatment_constructability_audit.do"

                post `ah' ("`cohort'") (`tw') (`alow') (`ahigh') (`ow') (`outlow') (`outhigh') ///
                    ("`eligibility'") ("`reason'") ("`sourcecalc'") (`treatment_module_n') (`treatment_age_valid_n') ///
                    (`treatment_age_band_n') (`outcome_spine_band_n') (`paired_any_age_n') (`paired_age_band_n') ///
                    (`birth_min') (`birth_max')
                post `mh' ("`cohort'") (`tw') (`alow') (`ahigh') (`ow') (`outlow') (`outhigh') ///
                    ("`eligibility'") ("`reason'") ("`sourcecalc'")
            }
        }
    }
}
postclose `ah'
postclose `mh'

use "`output'/diagnostics/r3_cohort_age_audit.dta", clear
sort treatment_wave treatment_age_low outcome_wave outcome_age_low
save "`output'/diagnostics/r3_cohort_age_audit.dta", replace
export delimited using "`output'/diagnostics/r3_cohort_age_audit.csv", replace
list if paired_age_band_n > 0, noobs abbreviate(28)

use "`project'/99_docs/cohort_age_matrix.dta", clear
sort treatment_wave treatment_age_low outcome_wave outcome_age_low
export delimited using "`project'/99_docs/cohort_age_matrix.csv", replace

display as result "R3_COHORT_AGE_AUDIT_PASS"
display as result "R3_COHORT_AGE_AUDIT_NOTE=age bands are candidate support counts; no primary cohort or outcome window is locked"
log close
exit 0
