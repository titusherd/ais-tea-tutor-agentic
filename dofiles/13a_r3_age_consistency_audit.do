version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/13a_r3_age_consistency_audit.log", text replace
display as text "R3_AGE_CONSISTENCY_AUDIT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)

* The survey files provide a survey-year age and a date of birth. Because
* interview dates are not carried in the canonical spine, the comparison is
* deliberately approximate: survey_year minus birth year. A gap of one year
* can be explained by interview timing and is not automatically an error.
use "`derived'/person_spine.dta", clear
keep if inrange(wave, 1, 5)
gen int birth_year_from_date = year(birth_date)
gen byte age_valid = !missing(age_at_interview) & age_at_interview >= 0 & age_at_interview <= 100
gen byte birth_year_valid = !missing(birth_year_from_date) & birth_year_from_date >= survey_year - 100 & birth_year_from_date <= survey_year
gen byte age_birth_comparable = age_valid & birth_year_valid
gen int approx_age_from_birth = survey_year - birth_year_from_date if age_birth_comparable
gen double age_gap = age_at_interview - approx_age_from_birth if age_birth_comparable
gen double abs_age_gap = abs(age_gap) if age_birth_comparable
gen byte fractional_age = age_valid & age_at_interview != floor(age_at_interview)
gen byte age_gap_gt1 = age_birth_comparable & abs_age_gap > 1
gen byte age_gap_gt2 = age_birth_comparable & abs_age_gap > 2
gen str32 age_issue = ""
replace age_issue = "invalid_or_special_age" if !age_valid & !missing(age_at_interview)
replace age_issue = "invalid_birth_year" if age_valid & !birth_year_valid & !missing(birth_date)
replace age_issue = "age_birth_gap_gt1" if age_gap_gt1
replace age_issue = "age_birth_gap_gt2" if age_gap_gt2
replace age_issue = "" if age_birth_comparable & !age_gap_gt1
gen byte age_anomaly = age_issue != ""

tempfile allspine
save "`allspine'", replace

* Summary by wave for the shared spine.
tempname sh
postfile `sh' byte wave int survey_year long spine_rows long age_nonmissing long age_invalid ///
    long birth_nonmissing long birth_invalid long comparable long gap_le1 long gap_gt1 ///
    long gap_gt2 long fractional_age long anomaly_rows ///
    using "`output'/diagnostics/r3_age_consistency_summary.dta", replace
foreach w in 1 2 3 4 5 {
    use "`allspine'", clear
    keep if wave == `w'
    count
    local n = r(N)
    summarize survey_year, meanonly
    local sy = r(mean)
    count if !missing(age_at_interview)
    local age_nonmissing = r(N)
    count if !age_valid & !missing(age_at_interview)
    local age_invalid = r(N)
    count if !missing(birth_date)
    local birth_nonmissing = r(N)
    count if !birth_year_valid & !missing(birth_date)
    local birth_invalid = r(N)
    count if age_birth_comparable
    local comparable = r(N)
    count if age_birth_comparable & abs_age_gap <= 1
    local gap_le1 = r(N)
    count if age_gap_gt1
    local gap_gt1 = r(N)
    count if age_gap_gt2
    local gap_gt2 = r(N)
    count if fractional_age
    local fractional_age = r(N)
    count if age_anomaly
    local anomaly_rows = r(N)
    post `sh' (`w') (`sy') (`n') (`age_nonmissing') (`age_invalid') (`birth_nonmissing') (`birth_invalid') ///
        (`comparable') (`gap_le1') (`gap_gt1') (`gap_gt2') (`fractional_age') (`anomaly_rows')
}
postclose `sh'
use "`output'/diagnostics/r3_age_consistency_summary.dta", clear
sort wave
export delimited using "`output'/diagnostics/r3_age_consistency_summary.csv", replace

* Preserve auditable person-wave cases. These are flags, not automatic drops.
use "`allspine'", clear
keep if age_anomaly
keep pidlink wave survey_year age_at_interview birth_date birth_year_from_date ///
    approx_age_from_birth age_gap abs_age_gap age_valid birth_year_valid ///
    age_issue present_roster hhid_wave pid_wave
sort wave pidlink
save "`output'/diagnostics/r3_age_consistency_anomaly_cases.dta", replace
export delimited using "`output'/diagnostics/r3_age_consistency_anomaly_cases.csv", replace

* The R3 treatment candidates are especially sensitive to age mismeasurement.
* Report the candidate age bands by consistency category without deciding which
* source should win. The later specification review must make that choice.
tempname th
postfile `th' byte treatment_wave int survey_year int treatment_age_low int treatment_age_high ///
    str24 age_consistency_category long n ///
    using "`output'/diagnostics/r3_treatment_age_consistency.dta", replace
foreach tw in 1 2 3 {
    foreach band in "10 11" "12 14" "15 15" {
        tokenize `"`band'"'
        local low = `1'
        local high = `2'
        use "`allspine'", clear
        keep if wave == `tw' & age_valid & inrange(age_at_interview, `low', `high')
        summarize survey_year, meanonly
        local sy = r(mean)
        count if age_birth_comparable & abs_age_gap <= 1
        local n1 = r(N)
        count if age_birth_comparable & abs_age_gap > 1
        local n2 = r(N)
        count if !age_birth_comparable
        local n3 = r(N)
        post `th' (`tw') (`sy') (`low') (`high') ("consistent_gap_le1") (`n1')
        post `th' (`tw') (`sy') (`low') (`high') ("discrepant_gap_gt1") (`n2')
        post `th' (`tw') (`sy') (`low') (`high') ("not_comparable") (`n3')
    }
}
postclose `th'
use "`output'/diagnostics/r3_treatment_age_consistency.dta", clear
sort treatment_wave treatment_age_low age_consistency_category
export delimited using "`output'/diagnostics/r3_treatment_age_consistency.csv", replace

* Print only compact diagnostics to the log; the CSV/DTA files are the audit
* record for review.
list, noobs abbreviate(24)
use "`output'/diagnostics/r3_age_consistency_summary.dta", clear
list, noobs abbreviate(24)
display as result "R3_AGE_CONSISTENCY_AUDIT_PASS"
display as result "R3_AGE_CONSISTENCY_NOTE=year-based age comparison is approximate; no anomaly was recoded or dropped"
log close
exit 0
