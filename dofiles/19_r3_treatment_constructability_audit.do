version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/19_r3_treatment_constructability_audit.log", text replace
display as text "R3_TREATMENT_CONSTRUCTABILITY_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "NOTE=raw support and candidate threshold counts only; no final child-labor treatment or hazard mapping"

* The two candidate treatment waves have different occupation/industry
* representations. Hours are common across waves; all raw fields remain
* available in the source modules and are not silently recoded here.
tempname ca
postfile `ca' byte wave int survey_year str28 module str28 raw_variable str28 role ///
    str120 variable_label str32 value_label str244 relpath byte file_exists ///
    long module_rows long pidlink_nonmissing byte pidlink_unique long duplicate_pid_cases ///
    long nonmissing long missing double raw_min double raw_max long bounded_n ///
    long special_ge900_n long out_of_range_n ///
    using "`output'/diagnostics/r3_treatment_constructability.dta", replace

local module_specs `" "2 1997 wave2_hh97 b3a_tk1.dta screen tk01 tk02 tk03 tk04 tk05" "2 1997 wave2_hh97 b3a_tk2.dta hours tk21a tk21b tk22a tk22b tk23a tk23b tk24a tk20aind tk20aocc" "3 2000 wave3_hh00 b3a_tk1.dta screen tk01 tk02 tk03 tk04 tk05" "3 2000 wave3_hh00 b3a_tk2.dta hours tk21a tk21b tk22a tk22b tk23a tk23b tk24a tk19aa tk20a" "'
foreach spec of local module_specs {
    tokenize `"`spec'"'
    local w `1'
    local yr `2'
    local folder `3'
    local file `4'
    local module `5'
    macro shift 5
    local vars "`*'"
    local relpath "`folder'/`file'"
    local path "`raw'/`relpath'"

    capture confirm file "`path'"
    if _rc != 0 {
        post `ca' (`w') (`yr') ("`module'") ("__file__") ("file_missing") ("file not found") ("") ("`relpath'") (0) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.)
        continue
    }

    use "`path'", clear
    local module_rows = _N
    local pidlink_nonmissing = .
    local pidlink_unique = .
    local duplicate_pid_cases = .
    capture confirm variable pidlink
    if _rc == 0 {
        count if !missing(pidlink)
        local pidlink_nonmissing = r(N)
        preserve
        keep if !missing(pidlink)
        bysort pidlink: gen long _pid_n = _N
        count if _pid_n > 1
        local duplicate_pid_cases = r(N)
        capture isid pidlink
        local pidlink_unique = (_rc == 0)
        restore
    }

    foreach v of local vars {
        local role "other"
        if inlist("`v'", "tk21a", "tk21b") local role "last_week_hours"
        if inlist("`v'", "tk22a", "tk22b") local role "normal_week_hours"
        if inlist("`v'", "tk23a", "tk23b") local role "weeks_last_year"
        local exists = 1
        capture confirm variable `v'
        if _rc != 0 local exists = 0
        if `exists' == 0 {
            post `ca' (`w') (`yr') ("`module'") ("`v'") ("`role'") ("variable not found") ("") ("`relpath'") (1) (`module_rows') (`pidlink_nonmissing') (`pidlink_unique') (`duplicate_pid_cases') (.) (.) (.) (.) (.) (.) (.) (.) (.)
            continue
        }

        local vlabel : variable label `v'
        local vallabel : value label `v'
        count if !missing(`v')
        local n_nonmissing = r(N)
        count if missing(`v')
        local n_missing = r(N)
        local v_min = .
        local v_max = .
        local bounded_n = .
        local special_ge900_n = .
        local out_of_range_n = .
        capture confirm numeric variable `v'
        if _rc == 0 {
            summarize `v', meanonly
            local v_min = r(min)
            local v_max = r(max)
            count if `v' >= 900 & !missing(`v')
            local special_ge900_n = r(N)
            if inlist("`role'", "last_week_hours", "normal_week_hours") {
                count if inrange(`v', 0, 168)
                local bounded_n = r(N)
                count if (`v' < 0 | `v' > 168) & !missing(`v')
                local out_of_range_n = r(N)
            }
            if "`role'" == "weeks_last_year" {
                count if inrange(`v', 0, 52)
                local bounded_n = r(N)
                count if (`v' < 0 | `v' > 52) & !missing(`v')
                local out_of_range_n = r(N)
            }
        }
        post `ca' (`w') (`yr') ("`module'") ("`v'") ("`role'") ("`vlabel'") ("`vallabel'") ("`relpath'") (1) (`module_rows') (`pidlink_nonmissing') (`pidlink_unique') (`duplicate_pid_cases') (`n_nonmissing') (`n_missing') (`v_min') (`v_max') (`bounded_n') (`special_ge900_n') (`out_of_range_n')
    }
}
postclose `ca'
use "`output'/diagnostics/r3_treatment_constructability.dta", clear
sort wave module raw_variable
save "`output'/diagnostics/r3_treatment_constructability.dta", replace
export delimited using "`output'/diagnostics/r3_treatment_constructability.csv", replace
display as text "R3_TREATMENT_CONSTRUCTABILITY_ROWS=" _N

* Build one person-level linkage frame for each treatment wave. The screen and
* hours modules are collapsed only to calculate person coverage and candidate
* support. Raw duplicate rows are counted above and are not deleted from raw.
tempfile link2 link3
forvalues w = 2/3 {
    local yr = cond(`w' == 2, 1997, 2000)
    local folder = cond(`w' == 2, "wave2_hh97", "wave3_hh00")
    local screen "`raw'/`folder'/b3a_tk1.dta"
    local hours "`raw'/`folder'/b3a_tk2.dta"
    local spine "`derived'/person_spine.dta"

    use "`screen'", clear
    keep pidlink tk01 tk02 tk03 tk04 tk05
    gen byte screen_any_nonmissing = !missing(tk01) | !missing(tk02) | !missing(tk03) | !missing(tk04) | !missing(tk05)
    gen byte screen_work_code1 = (tk02 == 1 | tk03 == 1 | tk04 == 1) if screen_any_nonmissing
    replace screen_work_code1 = 0 if missing(screen_work_code1)
    bysort pidlink: gen long screen_duplicate_rows = _N
    collapse (max) screen_any_nonmissing screen_work_code1 screen_duplicate_rows, by(pidlink)
    gen byte screen_duplicate_case = screen_duplicate_rows > 1
    tempfile screen_person
    save "`screen_person'", replace

    if `w' == 2 {
        use "`hours'", clear
        keep pidlink tk21a tk21b tk22a tk22b tk23a tk23b tk24a tk27 tk20aind tk20aocc
        gen byte industry_evidence = !missing(tk20aind)
        gen byte occupation_evidence = !missing(tk20aocc)
    }
    if `w' == 3 {
        use "`hours'", clear
        keep pidlink tk21a tk21b tk22a tk22b tk23a tk23b tk24a tk27 tk19aa tk20a
        * W3 stores a field-of-work code and a text duty description rather
        * than the W2 office-coded industry/occupation pair.
        capture confirm variable tk19aa
        if _rc == 0 gen byte industry_evidence = !missing(tk19aa)
        else gen byte industry_evidence = 0
        capture confirm variable tk20a
        if _rc == 0 gen byte occupation_evidence = !missing(tk20a)
        else gen byte occupation_evidence = 0
    }
    gen byte h1last_bounded = inrange(tk21a, 0, 168) if !missing(tk21a)
    replace h1last_bounded = 0 if missing(h1last_bounded)
    gen byte h2last_bounded = inrange(tk21b, 0, 168) if !missing(tk21b)
    replace h2last_bounded = 0 if missing(h2last_bounded)
    gen byte h1normal_bounded = inrange(tk22a, 0, 168) if !missing(tk22a)
    replace h1normal_bounded = 0 if missing(h1normal_bounded)
    gen byte h2normal_bounded = inrange(tk22b, 0, 168) if !missing(tk22b)
    replace h2normal_bounded = 0 if missing(h2normal_bounded)
    gen byte h1last_special = tk21a >= 900 if !missing(tk21a)
    replace h1last_special = 0 if missing(h1last_special)
    gen byte h2last_special = tk21b >= 900 if !missing(tk21b)
    replace h2last_special = 0 if missing(h2last_special)
    gen double h1last_valid = tk21a if h1last_bounded
    gen double h2last_valid = tk21b if h2last_bounded
    gen double h1normal_valid = tk22a if h1normal_bounded
    gen double h2normal_valid = tk22b if h2normal_bounded
    gen byte detail_any_nonmissing = !missing(tk21a) | !missing(tk21b) | !missing(tk22a) | !missing(tk22b) | !missing(tk23a) | !missing(tk23b) | !missing(tk24a)
    bysort pidlink: gen long hours_duplicate_rows = _N
    collapse (max) h1last_bounded h2last_bounded h1normal_bounded h2normal_bounded ///
        h1last_special h2last_special industry_evidence occupation_evidence detail_any_nonmissing ///
        (max) h1last_valid h2last_valid h1normal_valid h2normal_valid hours_duplicate_rows, by(pidlink)
    gen byte hours_duplicate_case = hours_duplicate_rows > 1
    gen double hours_last_primary_candidate = h1last_valid
    gen double hours_last_total_candidate = cond(missing(h1last_valid), 0, h1last_valid) + cond(missing(h2last_valid), 0, h2last_valid)
    gen byte hours_last_primary_valid = h1last_bounded
    gen byte hours_last_total_has_valid = h1last_bounded | h2last_bounded
    tempfile hours_person
    save "`hours_person'", replace

    use "`spine'", clear
    keep if wave == `w'
    keep pidlink wave survey_year age_at_interview birth_date sex present_roster
    isid pidlink
    merge 1:1 pidlink using "`screen_person'", keep(1 3) gen(_screen_merge)
    gen byte screen_module_observed = (_screen_merge == 3)
    replace screen_module_observed = 0 if missing(screen_module_observed)
    drop _screen_merge
    merge 1:1 pidlink using "`hours_person'", keep(1 3) gen(_hours_merge)
    gen byte hours_module_observed = (_hours_merge == 3)
    replace hours_module_observed = 0 if missing(hours_module_observed)
    drop _hours_merge
    replace screen_any_nonmissing = 0 if missing(screen_any_nonmissing)
    replace screen_work_code1 = 0 if missing(screen_work_code1)
    replace screen_duplicate_case = 0 if missing(screen_duplicate_case)
    replace hours_duplicate_case = 0 if missing(hours_duplicate_case)
    replace h1last_bounded = 0 if missing(h1last_bounded)
    replace h2last_bounded = 0 if missing(h2last_bounded)
    replace h1normal_bounded = 0 if missing(h1normal_bounded)
    replace h2normal_bounded = 0 if missing(h2normal_bounded)
    replace h1last_special = 0 if missing(h1last_special)
    replace h2last_special = 0 if missing(h2last_special)
    replace industry_evidence = 0 if missing(industry_evidence)
    replace occupation_evidence = 0 if missing(occupation_evidence)
    replace detail_any_nonmissing = 0 if missing(detail_any_nonmissing)
    gen byte both_modules_observed = screen_module_observed & hours_module_observed
    gen byte age_valid = !missing(age_at_interview) & age_at_interview >= 0 & age_at_interview <= 100
    gen byte candidate_primary_cl = 0
    replace candidate_primary_cl = 1 if age_valid & age_at_interview >= 10 & age_at_interview <= 11 & hours_last_primary_valid == 1 & hours_last_primary_candidate >= 1
    replace candidate_primary_cl = 1 if age_valid & age_at_interview >= 12 & age_at_interview <= 14 & hours_last_primary_valid == 1 & hours_last_primary_candidate >= 14
    replace candidate_primary_cl = 1 if age_valid & age_at_interview == 15 & hours_last_primary_valid == 1 & hours_last_primary_candidate > 43
    gen byte candidate_total_cl = 0
    replace candidate_total_cl = 1 if age_valid & age_at_interview >= 10 & age_at_interview <= 11 & hours_last_total_has_valid == 1 & hours_last_total_candidate >= 1
    replace candidate_total_cl = 1 if age_valid & age_at_interview >= 12 & age_at_interview <= 14 & hours_last_total_has_valid == 1 & hours_last_total_candidate >= 14
    replace candidate_total_cl = 1 if age_valid & age_at_interview == 15 & hours_last_total_has_valid == 1 & hours_last_total_candidate > 43
    gen byte r3_age_10_11 = age_valid & inrange(age_at_interview, 10, 11)
    gen byte r3_age_12_14 = age_valid & inrange(age_at_interview, 12, 14)
    gen byte r3_age_15 = age_valid & age_at_interview == 15
    gen byte r3_age_10_15 = r3_age_10_11 | r3_age_12_14 | r3_age_15
    gen int treatment_wave = `w'
    gen int treatment_year = `yr'
    sort pidlink
    isid pidlink
    save "`link`w''", replace
}

use "`link2'", clear
append using "`link3'"
sort wave pidlink
isid pidlink wave
save "`output'/diagnostics/r3_treatment_module_linkage.dta", replace
export delimited using "`output'/diagnostics/r3_treatment_module_linkage.csv", replace

tempname lk
postfile `lk' byte wave int survey_year str8 age_band long spine_n long screen_linked_n long hours_linked_n long both_linked_n ///
    long hours_primary_valid_n long hours_total_candidate_n long candidate_primary_cl_n long candidate_total_cl_n ///
    long screen_work_code1_n long industry_evidence_n long occupation_evidence_n long screen_duplicate_case_n long hours_duplicate_case_n ///
    str244 interpretation using "`output'/diagnostics/r3_treatment_module_linkage_summary.dta", replace
foreach w in 2 3 {
    local yr = cond(`w' == 2, 1997, 2000)
    foreach band in "10_11" "12_14" "15" {
        use "`output'/diagnostics/r3_treatment_module_linkage.dta", clear
        keep if wave == `w'
        if "`band'" == "10_11" keep if r3_age_10_11 == 1
        if "`band'" == "12_14" keep if r3_age_12_14 == 1
        if "`band'" == "15" keep if r3_age_15 == 1
        local spine_n = _N
        count if screen_module_observed == 1
        local screen_n = r(N)
        count if hours_module_observed == 1
        local hours_n = r(N)
        count if both_modules_observed == 1
        local both_n = r(N)
        count if hours_module_observed == 1 & hours_last_primary_valid == 1
        local hpv_n = r(N)
        count if hours_module_observed == 1 & hours_last_total_has_valid == 1
        local htv_n = r(N)
        count if candidate_primary_cl == 1
        local cpc_n = r(N)
        count if candidate_total_cl == 1
        local ctc_n = r(N)
        count if screen_work_code1 == 1
        local sw_n = r(N)
        count if hours_module_observed == 1 & industry_evidence == 1
        local ind_n = r(N)
        count if hours_module_observed == 1 & occupation_evidence == 1
        local occ_n = r(N)
        count if screen_duplicate_case == 1
        local sd_n = r(N)
        count if hours_duplicate_case == 1
        local hd_n = r(N)
        local note "threshold counts are candidate support only; primary-job versus total-hours rule, valid-code rule, hazard mapping, and final treatment remain unlocked"
        post `lk' (`w') (`yr') ("`band'") (`spine_n') (`screen_n') (`hours_n') (`both_n') (`hpv_n') (`htv_n') (`cpc_n') (`ctc_n') (`sw_n') (`ind_n') (`occ_n') (`sd_n') (`hd_n') ("`note'")
    }
}
postclose `lk'
use "`output'/diagnostics/r3_treatment_module_linkage_summary.dta", clear
sort wave age_band
save "`output'/diagnostics/r3_treatment_module_linkage_summary.dta", replace
export delimited using "`output'/diagnostics/r3_treatment_module_linkage_summary.csv", replace

display as result "R3_TREATMENT_CONSTRUCTABILITY_PASS"
display as result "R3_TREATMENT_CONSTRUCTABILITY_NOTE=W2 detail modules are locally available; candidate counts do not lock CL thresholds, hazard, chores, cohort, or treatment"
log close
exit 0
