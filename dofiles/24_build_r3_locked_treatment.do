version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/24_build_r3_locked_treatment.log", text replace
display as text "R3_LOCKED_TREATMENT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SPEC_LOCK_ID=R3-MAIN-D020-D021-D022-D023-D030-D031-D032-D033-D040-D041-D042"
display as text "NOTE=age 15 primary; market/economic screen; codebook-valid last-week total hours; unresolved screen/hour states excluded"

* R3 treatment uses the detailed work modules for W2 and W3. The primary
* cohort is age 15. Younger age bands are retained as descriptive/feasibility
* outputs under the candidate thresholds registered in the working plan.
tempfile treatment2 treatment3 w1_frame

forvalues w = 2/3 {
    local yr = cond(`w' == 2, 1997, 2000)
    local folder = cond(`w' == 2, "wave2_hh97", "wave3_hh00")

    * Screen module. TK01==1 is the direct work activity category. TK02,
    * TK03, and TK04 are the follow-up economic-work questions. Missing
    * follow-up values are allowed when questionnaire routing skips them;
    * non-1/non-3 observed special values are not treated as a clean no.
    use "`raw'/`folder'/b3a_tk1.dta", clear
    keep pidlink tk01 tk02 tk03 tk04 tk05
    isid pidlink
    gen byte screen_module_observed = 1
    gen byte screen_any_nonmissing = !missing(tk01) | !missing(tk02) | ///
        !missing(tk03) | !missing(tk04) | !missing(tk05)
    gen byte screen_activity_known = inrange(tk01, 1, 89) if !missing(tk01)
    replace screen_activity_known = 0 if missing(screen_activity_known)
    gen byte screen_detail_unknown = 0
    replace screen_detail_unknown = 1 if !missing(tk02) & !inlist(tk02, 1, 3)
    replace screen_detail_unknown = 1 if !missing(tk03) & !inlist(tk03, 1, 3)
    replace screen_detail_unknown = 1 if !missing(tk04) & !inlist(tk04, 1, 3)
    gen byte screen_market_work = (tk01 == 1 | tk02 == 1 | tk04 == 1)
    replace screen_market_work = 0 if missing(screen_market_work)
    gen byte screen_any_economic_work = (tk01 == 1 | tk02 == 1 | ///
        tk03 == 1 | tk04 == 1)
    replace screen_any_economic_work = 0 if missing(screen_any_economic_work)
    gen byte screen_no_market_clear = screen_any_nonmissing == 1 & ///
        screen_activity_known == 1 & screen_market_work == 0 & ///
        screen_detail_unknown == 0
    gen byte screen_unresolved = screen_any_nonmissing == 0 | ///
        (screen_market_work == 0 & screen_no_market_clear == 0)
    tempfile screen_person
    save "`screen_person'", replace

    * Detailed hours module. Status code 1 is the locally verified input/
    * given status for TK21A and TK21B. Only numeric values 0--168 are valid.
    * A missing second-job hour is set to zero only when TK27 explicitly says
    * there is no additional job (code 3). Unknown/refusal/special states
    * remain unresolved.
    use "`raw'/`folder'/b3a_tk2.dta", clear
    keep pidlink tk21a tk21b tk21ax tk21bx tk27
    isid pidlink
    gen byte hours_module_observed = 1
    gen byte h1_valid = tk21ax == 1 & inrange(tk21a, 0, 168)
    gen byte h2_valid = tk21bx == 1 & inrange(tk21b, 0, 168)
    gen byte h2_no_job_valid = tk27 == 3
    gen byte h1_invalid_observed = (!missing(tk21ax) | !missing(tk21a)) & ///
        h1_valid == 0
    gen byte h2_invalid_observed = (!missing(tk21bx) | !missing(tk21b)) & ///
        h2_valid == 0 & h2_no_job_valid == 0
    gen byte total_hours_valid = h1_valid == 1 & ///
        (h2_valid == 1 | h2_no_job_valid == 1)
    gen double total_hours_last_week = tk21a + ///
        cond(h2_valid == 1, tk21b, 0) if total_hours_valid == 1
    gen byte hours_any_nonmissing = !missing(tk21a) | !missing(tk21b) | ///
        !missing(tk21ax) | !missing(tk21bx) | !missing(tk27)
    tempfile hours_person
    save "`hours_person'", replace

    * Start from the shared person-wave spine. A person × wave row is retained
    * even when a module does not link, so module coverage is visible.
    use "`derived'/person_spine.dta", clear
    keep if wave == `w'
    keep pidlink wave survey_year hhid_wave age_at_interview birth_date sex ///
        present_roster
    isid pidlink
    merge 1:1 pidlink using "`screen_person'", keep(1 3) gen(_screen_merge)
    gen byte screen_linked = _screen_merge == 3
    replace screen_linked = 0 if missing(screen_linked)
    drop _screen_merge
    merge 1:1 pidlink using "`hours_person'", keep(1 3) gen(_hours_merge)
    gen byte hours_linked = _hours_merge == 3
    replace hours_linked = 0 if missing(hours_linked)
    drop _hours_merge

    foreach v in screen_module_observed screen_any_nonmissing ///
        screen_activity_known screen_detail_unknown screen_market_work ///
        screen_any_economic_work screen_no_market_clear screen_unresolved ///
        hours_module_observed h1_valid h2_valid h2_no_job_valid ///
        h1_invalid_observed h2_invalid_observed total_hours_valid ///
        hours_any_nonmissing {
        replace `v' = 0 if missing(`v')
    }
    replace screen_unresolved = 1 if screen_linked == 0 | ///
        screen_any_nonmissing == 0

    gen byte age_valid = !missing(age_at_interview) & ///
        inrange(age_at_interview, 0, 100)
    gen byte r3_age_10_11 = age_valid == 1 & inrange(age_at_interview, 10, 11)
    gen byte r3_age_12_14 = age_valid == 1 & inrange(age_at_interview, 12, 14)
    gen byte r3_age_15 = age_valid == 1 & age_at_interview == 15
    gen byte r3_age_10_15 = r3_age_10_11 | r3_age_12_14 | r3_age_15
    gen str8 r3_age_band = ""
    replace r3_age_band = "10_11" if r3_age_10_11 == 1
    replace r3_age_band = "12_14" if r3_age_12_14 == 1
    replace r3_age_band = "15" if r3_age_15 == 1

    gen double r3_threshold_hours = .
    replace r3_threshold_hours = 1 if r3_age_10_11 == 1
    replace r3_threshold_hours = 14 if r3_age_12_14 == 1
    replace r3_threshold_hours = 43 if r3_age_15 == 1
    gen byte r3_screen_observed = screen_linked == 1 & ///
        screen_any_nonmissing == 1
    gen byte r3_market_work_screen = screen_market_work == 1
    gen byte r3_clear_nonmarket_screen = screen_no_market_clear == 1
    gen byte r3_qualifying_hours = r3_market_work_screen == 1 & ///
        total_hours_valid == 1 & !missing(r3_threshold_hours) & ///
        ((r3_age_10_11 == 1 & total_hours_last_week >= 1) | ///
         (r3_age_12_14 == 1 & total_hours_last_week >= 14) | ///
         (r3_age_15 == 1 & total_hours_last_week > 43))
    gen byte r3_below_threshold = r3_market_work_screen == 1 & ///
        total_hours_valid == 1 & !missing(r3_threshold_hours) & ///
        r3_qualifying_hours == 0
    gen byte r3_treatment = .
    gen str32 r3_status = "outside_age_frame"
    replace r3_status = "unresolved_screen" if r3_age_10_15 == 1 & ///
        screen_unresolved == 1
    replace r3_status = "control" if r3_age_10_15 == 1 & ///
        screen_no_market_clear == 1
    replace r3_status = "unresolved_hours" if r3_age_10_15 == 1 & ///
        screen_market_work == 1 & total_hours_valid == 0
    replace r3_status = "treated" if r3_age_10_15 == 1 & ///
        r3_qualifying_hours == 1
    replace r3_status = "control" if r3_age_10_15 == 1 & ///
        screen_market_work == 1 & total_hours_valid == 1 & ///
        r3_qualifying_hours == 0
    replace r3_treatment = 1 if r3_status == "treated"
    replace r3_treatment = 0 if r3_status == "control"
    gen byte r3_primary_frame = r3_age_15 == 1 & present_roster == 1 & ///
        !missing(hhid_wave) & r3_screen_observed == 1
    gen byte r3_primary_eligible = r3_primary_frame == 1 & ///
        inlist(r3_status, "treated", "control")
    gen byte r3_control_nonmarket = r3_status == "control" & ///
        r3_clear_nonmarket_screen == 1
    gen byte r3_control_below_threshold = r3_status == "control" & ///
        r3_market_work_screen == 1 & r3_below_threshold == 1
    gen int treatment_wave = `w'
    gen int treatment_year = `yr'
    label define r3status 0 "control" 1 "treated", replace
    label values r3_treatment r3status
    order pidlink wave survey_year hhid_wave age_at_interview birth_date sex ///
        r3_age_band r3_status r3_treatment r3_primary_frame ///
        r3_primary_eligible
    sort pidlink
    isid pidlink
    if `w' == 2 save "`treatment2'", replace
    if `w' == 3 save "`treatment3'", replace
}

* W1 linkage is preserved as a flag for the later baseline-control gate. It is
* not used to reclassify the treatment itself.
use "`derived'/person_spine.dta", clear
keep if wave == 1
keep pidlink hhid_wave age_at_interview birth_date sex present_roster
rename hhid_wave w1_hhid
rename age_at_interview w1_age
rename birth_date w1_birth_date
rename sex w1_sex
rename present_roster w1_present_roster
isid pidlink
save "`w1_frame'", replace

use "`treatment2'", clear
append using "`treatment3'"
sort wave pidlink
isid pidlink wave
merge m:1 pidlink using "`w1_frame'", keep(1 3) gen(_w1_merge)
gen byte w1_linked = _w1_merge == 3
replace w1_linked = 0 if missing(w1_linked)
drop _w1_merge
save "`derived'/r3_child_labor_treatment.dta", replace
export delimited using "`output'/diagnostics/r3_child_labor_treatment.csv", replace

* Prevalence/support table. The denominator is the explicit status frame, not
* the entire person spine and not the unresolved group.
preserve
keep if r3_age_10_15 == 1
contract wave survey_year r3_age_band r3_status
rename _freq N
sort wave r3_age_band r3_status
save "`output'/diagnostics/r3_treatment_prevalence_by_wave_age.dta", replace
export delimited using "`output'/diagnostics/r3_treatment_prevalence_by_wave_age.csv", replace
restore

tempname sf
postfile `sf' byte wave int survey_year str8 age_band str120 stage long N ///
    using "`output'/diagnostics/r3_treatment_sample_flow.dta", replace
foreach w in 2 3 {
    local yr = cond(`w' == 2, 1997, 2000)
    foreach band in "10_11" "12_14" "15" {
        use "`derived'/r3_child_labor_treatment.dta", clear
        keep if wave == `w' & r3_age_band == "`band'"
        local age_n = _N
        post `sf' (`w') (`yr') ("`band'") ("Person-wave in age band") (`age_n')
        count if present_roster == 1 & !missing(hhid_wave)
        post `sf' (`w') (`yr') ("`band'") ("Present roster with valid treatment household") (r(N))
        count if r3_screen_observed == 1
        post `sf' (`w') (`yr') ("`band'") ("Work screen observed") (r(N))
        count if r3_market_work_screen == 1 & total_hours_valid == 1
        post `sf' (`w') (`yr') ("`band'") ("Market-work screen with valid total hours") (r(N))
        count if r3_status == "treated"
        post `sf' (`w') (`yr') ("`band'") ("Qualifying treatment under age-band threshold") (r(N))
        count if r3_status == "control"
        post `sf' (`w') (`yr') ("`band'") ("Observed control status") (r(N))
        count if r3_status == "unresolved_screen"
        post `sf' (`w') (`yr') ("`band'") ("Excluded: unresolved screen") (r(N))
        count if r3_status == "unresolved_hours"
        post `sf' (`w') (`yr') ("`band'") ("Excluded: unresolved or invalid hours") (r(N))
        count if r3_primary_eligible == 1
        post `sf' (`w') (`yr') ("`band'") ("Primary R3 age-15 eligible") (r(N))
    }
}
postclose `sf'
use "`output'/diagnostics/r3_treatment_sample_flow.dta", clear
sort wave age_band stage
save "`output'/diagnostics/r3_treatment_sample_flow.dta", replace
export delimited using "`output'/diagnostics/r3_treatment_sample_flow.csv", replace

* Mechanical contracts for the lock.
use "`derived'/r3_child_labor_treatment.dta", clear
count if r3_primary_eligible == 1 & !inlist(r3_status, "treated", "control")
if r(N) > 0 {
    display as error "R3_LOCKED_TREATMENT_FAIL=primary eligibility/status mismatch"
    log close
    exit 459
}
count if r3_primary_eligible == 1 & age_at_interview != 15
if r(N) > 0 {
    display as error "R3_LOCKED_TREATMENT_FAIL=non-age15 primary row"
    log close
    exit 459
}
isid pidlink wave
display as result "R3_LOCKED_TREATMENT_PASS"
display as result "R3_LOCKED_TREATMENT_NOTE=unresolved screen and hours are excluded; younger age bands are descriptive only"
log close
exit 0
