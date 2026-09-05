version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local output "`project'/04_output"
local master "`output'/diagnostics/adult_outcome_variable_audit.dta"

cd "`project'"
log using "`output'/logs/16a_adult_outcome_age_coverage.log", text replace
display as text "ADULT_OUTCOME_AGE_COVERAGE_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "NOTE=unique linked persons with raw outcome nonmissing by adult age band; no recode or estimand"

* Save one-row-per-person spine extracts for the outcome waves.
tempfile spine2 spine3 spine4 spine5
use "`project'/02_derived/person_spine.dta", clear
foreach w in 2 3 4 5 {
    preserve
    keep if wave == `w'
    keep pidlink age_at_interview birth_date sex present_roster hhid_wave pid_wave
    isid pidlink
    save "`spine`w''", replace
    restore
}

* The source audit is the authoritative candidate list. This file adds only
* outcome-nonmissing coverage; it does not decide which raw codes are valid.
use "`master'", clear
gen long outcome_audit_id = _n
local n = _N
local rowfiles ""

forvalues i = 1/`n' {
    use "`master'" in `i', clear
    local w = wave[1]
    local yr = survey_year[1]
    local relpath = relpath[1]
    local v = raw_varname[1]
    local path "`raw'/`relpath'"
    local spinefile "`spine`w''"

    local outcome_nonmissing_linked = .
    local outcome_nonmissing_17_21 = .
    local outcome_nonmissing_22_25 = .
    local outcome_nonmissing_26_29 = .
    local outcome_nonmissing_30_33 = .
    local outcome_nonmissing_34_36 = .

    capture confirm file "`path'"
    if _rc == 0 {
        use "`path'", clear
        capture confirm variable pidlink
        if _rc == 0 {
            capture confirm variable `v'
            if _rc == 0 {
                merge m:1 pidlink using "`spinefile'", gen(_adult_age_merge)
                keep if _adult_age_merge == 3
                gen byte _outcome_nonmissing = 0
                capture confirm numeric variable `v'
                if _rc == 0 {
                    replace _outcome_nonmissing = 1 if !missing(`v')
                }
                else {
                    replace _outcome_nonmissing = 1 if trim(`v') != ""
                }

                * A repeated module record counts once per pidlink if any
                * source record has a nonmissing candidate outcome.
                bysort pidlink: egen byte _has_outcome = max(_outcome_nonmissing)
                bysort pidlink: keep if _n == 1
                count if _has_outcome == 1
                local outcome_nonmissing_linked = r(N)
                gen byte _adult_age_valid = !missing(age_at_interview) & age_at_interview >= 0 & age_at_interview <= 100
                count if _has_outcome == 1 & _adult_age_valid == 1 & inrange(age_at_interview,17,21)
                local outcome_nonmissing_17_21 = r(N)
                count if _has_outcome == 1 & _adult_age_valid == 1 & inrange(age_at_interview,22,25)
                local outcome_nonmissing_22_25 = r(N)
                count if _has_outcome == 1 & _adult_age_valid == 1 & inrange(age_at_interview,26,29)
                local outcome_nonmissing_26_29 = r(N)
                count if _has_outcome == 1 & _adult_age_valid == 1 & inrange(age_at_interview,30,33)
                local outcome_nonmissing_30_33 = r(N)
                count if _has_outcome == 1 & _adult_age_valid == 1 & inrange(age_at_interview,34,36)
                local outcome_nonmissing_34_36 = r(N)
            }
        }
    }

    use "`master'" in `i', clear
    gen long outcome_audit_id = `i'
    gen long out_nonmiss_linked = `outcome_nonmissing_linked'
    gen long out_nonmiss_17_21 = `outcome_nonmissing_17_21'
    gen long out_nonmiss_22_25 = `outcome_nonmissing_22_25'
    gen long out_nonmiss_26_29 = `outcome_nonmissing_26_29'
    gen long out_nonmiss_30_33 = `outcome_nonmissing_30_33'
    gen long out_nonmiss_34_36 = `outcome_nonmissing_34_36'
    tempfile rowfile
    save "`rowfile'", replace
    local rowfiles "`rowfiles' `rowfile'"
}

local first = 1
foreach rf of local rowfiles {
    if `first' == 1 {
        use "`rf'", clear
        local first = 0
    }
    else {
        append using "`rf'"
    }
}
sort wave domain outcome_role module raw_varname
save "`output'/diagnostics/adult_outcome_age_coverage.dta", replace
export delimited using "`output'/diagnostics/adult_outcome_age_coverage.csv", replace

display as result "ADULT_OUTCOME_AGE_COVERAGE_ROWS=" _N
display as result "ADULT_OUTCOME_AGE_COVERAGE_PASS"
display as result "ADULT_OUTCOME_AGE_COVERAGE_NOTE=no_recode_no_final_estimand"
log close
exit 0
