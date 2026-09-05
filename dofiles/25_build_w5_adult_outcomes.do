version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local raw "`project'/00_raw"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/25_build_w5_adult_outcomes.log", text replace
display as text "W5_ADULT_OUTCOMES_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SPEC_LOCK_ID=R1-MAIN/R3-MAIN-D031-D032-D040-D041"
display as text "NOTE=W5 age 17-36; outcome-specific valid-code rules; no combined IMDI is created"

* The outcome universe is observed W5 persons aged 17--36 with a valid W5
* household key. Modules are merged at pidlink, and module-specific coverage
* remains visible through link flags and the merge audit.
use "`derived'/person_spine.dta", clear
keep if wave == 5 & present_roster == 1 & !missing(hhid_wave) & ///
    !missing(age_at_interview) & inrange(age_at_interview, 17, 36)
keep pidlink wave survey_year hhid_wave age_at_interview birth_date sex
rename hhid_wave w5_hhid
isid pidlink
gen byte adult_outcome_age17_36 = 1
gen byte w5_person_universe = 1

tempname ma
postfile `ma' str24 module str80 relpath long master_n long matched_n ///
    long master_only_n long using_only_n str244 merge_rule ///
    using "`output'/diagnostics/w5_outcome_merge_audit.dta", replace

* Helper pattern repeated explicitly so every merge has a visible cardinality
* and unmatched count in the audit.
preserve
use "`raw'/wave5_hh14/b3a_tk1.dta", clear
keep pidlink tk01 tk02 tk03 tk04 tk05
isid pidlink
tempfile tk1
save "`tk1'", replace
restore
use "`derived'/person_spine.dta", clear
keep if wave == 5 & present_roster == 1 & !missing(hhid_wave) & ///
    !missing(age_at_interview) & inrange(age_at_interview, 17, 36)
keep pidlink wave survey_year hhid_wave age_at_interview birth_date sex
rename hhid_wave w5_hhid
isid pidlink
local master_n = _N
merge 1:1 pidlink using "`tk1'", gen(_m_tk1)
count if _m_tk1 == 3
local matched_n = r(N)
count if _m_tk1 == 1
local master_only_n = r(N)
count if _m_tk1 == 2
local using_only_n = r(N)
post `ma' ("b3a_tk1") ("wave5_hh14/b3a_tk1.dta") (`master_n') (`matched_n') (`master_only_n') (`using_only_n') ("1:1 pidlink; keep universe and matched")
gen byte w5_tk1_linked = _m_tk1 == 3
drop if _m_tk1 == 2
drop _m_tk1

preserve
use "`raw'/wave5_hh14/b3a_tk2.dta", clear
keep pidlink tk25a1 tk25a1x tk25a2 tk25a2x tk26a1 tk26a1x tk26a3 tk26a3x
isid pidlink
tempfile tk2
save "`tk2'", replace
restore
merge 1:1 pidlink using "`tk2'", gen(_m_tk2)
count if _m_tk2 == 3
local matched_n = r(N)
count if _m_tk2 == 1
local master_only_n = r(N)
count if _m_tk2 == 2
local using_only_n = r(N)
post `ma' ("b3a_tk2") ("wave5_hh14/b3a_tk2.dta") (`master_n') (`matched_n') (`master_only_n') (`using_only_n') ("1:1 pidlink; keep universe and matched")
gen byte w5_tk2_linked = _m_tk2 == 3
drop if _m_tk2 == 2
drop _m_tk2

preserve
use "`raw'/wave5_hh14/b3a_dl1.dta", clear
keep pidlink dl06 dl07
isid pidlink
tempfile dl1
save "`dl1'", replace
restore
merge 1:1 pidlink using "`dl1'", gen(_m_dl1)
count if _m_dl1 == 3
local matched_n = r(N)
count if _m_dl1 == 1
local master_only_n = r(N)
count if _m_dl1 == 2
local using_only_n = r(N)
post `ma' ("b3a_dl1") ("wave5_hh14/b3a_dl1.dta") (`master_n') (`matched_n') (`master_only_n') (`using_only_n') ("1:1 pidlink; keep universe and matched")
gen byte w5_dl1_linked = _m_dl1 == 3
drop if _m_dl1 == 2
drop _m_dl1

preserve
use "`raw'/wave5_hh14/b3a_pk1.dta", clear
keep pidlink pk00a
isid pidlink
tempfile pk1
save "`pk1'", replace
restore
merge 1:1 pidlink using "`pk1'", gen(_m_pk1)
count if _m_pk1 == 3
local matched_n = r(N)
count if _m_pk1 == 1
local master_only_n = r(N)
count if _m_pk1 == 2
local using_only_n = r(N)
post `ma' ("b3a_pk1") ("wave5_hh14/b3a_pk1.dta") (`master_n') (`matched_n') (`master_only_n') (`using_only_n') ("1:1 pidlink; keep universe and matched")
gen byte w5_pk1_linked = _m_pk1 == 3
drop if _m_pk1 == 2
drop _m_pk1

preserve
use "`raw'/wave5_hh14/b3a_sw.dta", clear
keep pidlink sw06
isid pidlink
tempfile sw
save "`sw'", replace
restore
merge 1:1 pidlink using "`sw'", gen(_m_sw)
count if _m_sw == 3
local matched_n = r(N)
count if _m_sw == 1
local master_only_n = r(N)
count if _m_sw == 2
local using_only_n = r(N)
post `ma' ("b3a_sw") ("wave5_hh14/b3a_sw.dta") (`master_n') (`matched_n') (`master_only_n') (`using_only_n') ("1:1 pidlink; keep universe and matched")
gen byte w5_sw_linked = _m_sw == 3
drop if _m_sw == 2
drop _m_sw

preserve
use "`raw'/wave5_hh14/b3a_tr.dta", clear
keep pidlink tr01 tr02 tr03 tr04 tr05 tr06
isid pidlink
tempfile tr
save "`tr'", replace
restore
merge 1:1 pidlink using "`tr'", gen(_m_tr)
count if _m_tr == 3
local matched_n = r(N)
count if _m_tr == 1
local master_only_n = r(N)
count if _m_tr == 2
local using_only_n = r(N)
post `ma' ("b3a_tr") ("wave5_hh14/b3a_tr.dta") (`master_n') (`matched_n') (`master_only_n') (`using_only_n') ("1:1 pidlink; keep universe and matched")
gen byte w5_tr_linked = _m_tr == 3
drop if _m_tr == 2
drop _m_tr

preserve
use "`raw'/wave5_hh14/b3b_kk1.dta", clear
keep pidlink kk01
isid pidlink
tempfile kk1
save "`kk1'", replace
restore
merge 1:1 pidlink using "`kk1'", gen(_m_kk1)
count if _m_kk1 == 3
local matched_n = r(N)
count if _m_kk1 == 1
local master_only_n = r(N)
count if _m_kk1 == 2
local using_only_n = r(N)
post `ma' ("b3b_kk1") ("wave5_hh14/b3b_kk1.dta") (`master_n') (`matched_n') (`master_only_n') (`using_only_n') ("1:1 pidlink; keep universe and matched")
gen byte w5_kk1_linked = _m_kk1 == 3
drop if _m_kk1 == 2
drop _m_kk1

preserve
use "`raw'/wave5_hh14/b3b_km.dta", clear
keep pidlink km01a km01e km04
isid pidlink
tempfile km
save "`km'", replace
restore
merge 1:1 pidlink using "`km'", gen(_m_km)
count if _m_km == 3
local matched_n = r(N)
count if _m_km == 1
local master_only_n = r(N)
count if _m_km == 2
local using_only_n = r(N)
post `ma' ("b3b_km") ("wave5_hh14/b3b_km.dta") (`master_n') (`matched_n') (`master_only_n') (`using_only_n') ("1:1 pidlink; keep universe and matched")
gen byte w5_km_linked = _m_km == 3
drop if _m_km == 2
drop _m_km

preserve
use "`raw'/wave5_hh14/bus_us.dta", clear
keep pidlink us04 us04x us06 us06x
isid pidlink
tempfile us
save "`us'", replace
restore
merge 1:1 pidlink using "`us'", gen(_m_us)
count if _m_us == 3
local matched_n = r(N)
count if _m_us == 1
local master_only_n = r(N)
count if _m_us == 2
local using_only_n = r(N)
post `ma' ("bus_us") ("wave5_hh14/bus_us.dta") (`master_n') (`matched_n') (`master_only_n') (`using_only_n') ("1:1 pidlink; keep universe and matched")
gen byte w5_us_linked = _m_us == 3
drop if _m_us == 2
drop _m_us

* CD01 is a repeated condition-level file. It is collapsed only after retaining
* the condition type and response; no condition row is treated as a person.
preserve
use "`raw'/wave5_hh14/b3b_cd2.dta", clear
keep pidlink cd01
gen byte cd_yes = cd01 == 1
gen byte cd_no = cd01 == 3
gen byte cd_dk = cd01 == 8
collapse (max) cd_yes cd_no cd_dk, by(pidlink)
isid pidlink
tempfile cd
save "`cd'", replace
restore
merge 1:1 pidlink using "`cd'", gen(_m_cd)
count if _m_cd == 3
local matched_n = r(N)
count if _m_cd == 1
local master_only_n = r(N)
count if _m_cd == 2
local using_only_n = r(N)
post `ma' ("b3b_cd2") ("wave5_hh14/b3b_cd2.dta; collapsed by pidlink") (`master_n') (`matched_n') (`master_only_n') (`using_only_n') ("m:1 condition rows collapsed to pidlink; keep universe and matched")
gen byte w5_cd_linked = _m_cd == 3
drop if _m_cd == 2
drop _m_cd
postclose `ma'

* Outcome-specific recodes. Raw values remain in the file beside derived
* variables, so every transformation can be audited.
gen byte adult_employment_observed = !missing(tk01)
gen byte adult_employment_valid = inlist(tk01, 1, 2, 3, 4, 5, 7, 95)
gen byte adult_employed = .
replace adult_employed = 1 if tk01 == 1
replace adult_employed = 0 if inlist(tk01, 2, 3, 4, 5, 7, 95)

gen byte adult_salary_observed = !missing(tk25a1x) | !missing(tk25a1)
gen byte adult_salary_valid = tk25a1x == 1 & ///
    tk25a1 >= 0 & tk25a1 < 999999997
gen double adult_salary_monthly = tk25a1 if adult_salary_valid == 1
gen double adult_ln1p_salary_monthly = ln(1 + adult_salary_monthly) ///
    if adult_salary_valid == 1

gen byte adult_profit_observed = !missing(tk26a1x) | !missing(tk26a1)
gen byte adult_profit_valid = inlist(tk26a1x, 1, 2) & ///
    tk26a1 >= 0 & tk26a1 < 999999999998
gen double adult_profit_monthly = tk26a1 if adult_profit_valid == 1
replace adult_profit_monthly = -tk26a1 if adult_profit_valid == 1 & ///
    tk26a1x == 2
gen double adult_ln1p_abs_profit = ln(1 + abs(adult_profit_monthly)) ///
    if adult_profit_valid == 1

gen byte adult_dl06_observed = !missing(dl06)
gen byte adult_dl06_valid = inrange(dl06, 2, 6) | ///
    inrange(dl06, 11, 15) | dl06 == 17 | inrange(dl06, 60, 63) | ///
    inrange(dl06, 72, 74) | inlist(dl06, 90, 95)
gen byte adult_education_level = dl06 if adult_dl06_valid == 1
gen byte adult_college_observed = adult_dl06_valid
gen byte adult_college = .
replace adult_college = 1 if inrange(dl06, 60, 63)
replace adult_college = 0 if adult_dl06_valid == 1 & adult_college == .
gen byte adult_grade_observed = !missing(dl07)
gen byte adult_grade_valid = inrange(dl07, 0, 7)
gen byte adult_grade_completed = dl07 if adult_grade_valid == 1

gen byte adult_srh_observed = !missing(kk01)
gen byte adult_srh_valid = inrange(kk01, 1, 4)
gen byte adult_srh_score = 5 - kk01 if adult_srh_valid == 1
gen byte adult_good_health = inlist(kk01, 1, 2) if adult_srh_valid == 1

* Anthropometric plausibility limits are declared here: measured height
* 100--250 cm and measured weight 20--250 kg, followed by BMI 10--80.
gen byte adult_height_observed = !missing(us04x) | !missing(us04)
gen byte adult_weight_observed = !missing(us06x) | !missing(us06)
gen byte adult_height_valid = us04x == 1 & inrange(us04, 100, 250)
gen byte adult_weight_valid = us06x == 1 & inrange(us06, 20, 250)
gen double adult_bmi_raw = us06 / ((us04 / 100)^2) ///
    if adult_height_valid == 1 & adult_weight_valid == 1
gen byte adult_bmi_valid = inrange(adult_bmi_raw, 10, 80)
replace adult_bmi_raw = . if adult_bmi_valid == 0

gen byte adult_smoking_observed = !missing(km01a) | !missing(km01e) | ///
    !missing(km04)
gen byte adult_ever_cigarette = .
replace adult_ever_cigarette = 1 if km01e == 1
replace adult_ever_cigarette = 0 if km01a == 3 | km01e == 3
gen byte adult_current_smoker = .
replace adult_current_smoker = 1 if km01e == 1 & km04 == 1
replace adult_current_smoker = 0 if km01a == 3 | km01e == 3 | ///
    (km01e == 1 & km04 == 3)
gen byte adult_ever_cigarette_valid = inlist(adult_ever_cigarette, 0, 1)
gen byte adult_current_smoker_valid = !missing(adult_current_smoker)
gen byte adult_smoking_valid = adult_current_smoker_valid

gen byte adult_marriage_observed = !missing(pk00a)
gen byte adult_marriage_valid = inlist(pk00a, 1, 3)
gen byte adult_married = .
replace adult_married = 1 if pk00a == 1
replace adult_married = 0 if pk00a == 3

foreach v in tr01 tr02 tr03 tr04 tr05 tr06 {
    gen byte adult_`v'_valid = inrange(`v', 1, 4)
    gen byte adult_`v'_score = 5 - `v' if adult_`v'_valid == 1
}
gen byte adult_health_adequacy_valid = inrange(sw06, 1, 3)
gen byte adult_health_adequacy = sw06 if adult_health_adequacy_valid == 1

gen byte adult_condition_observed = cd_yes == 1 | cd_no == 1 | cd_dk == 1
gen byte adult_any_listed_condition = .
replace adult_any_listed_condition = 1 if cd_yes == 1
replace adult_any_listed_condition = 0 if cd_yes == 0 & cd_no == 1 & cd_dk == 0

label variable adult_employed "W5 employed from TK01==1"
label variable adult_ln1p_salary_monthly "ln(1 + W5 monthly salary/wage job 1)"
label variable adult_ln1p_abs_profit "ln(1 + absolute W5 monthly job-1 profit)"
label variable adult_college "W5 highest education is college/university"
label variable adult_srh_score "W5 self-rated health score, higher is better"
label variable adult_bmi_raw "W5 measured BMI after declared plausibility limits"
label variable adult_current_smoker "W5 current cigarette/cigar smoker"
label variable adult_married "W5 currently married/cohabitating"
label variable adult_any_listed_condition "Any listed CD01 condition, not a general chronic-disease index"

sort pidlink
isid pidlink
save "`derived'/w5_adult_outcomes.dta", replace
export delimited using "`output'/diagnostics/w5_adult_outcomes.csv", replace

* Validity summary for outcomes that may enter the separate outcome families.
tempname va
postfile `va' str36 outcome str244 rule long universe_n long observed_n ///
    long valid_n long invalid_observed_n long missing_n long positive_n ///
    using "`output'/diagnostics/w5_outcome_validity_audit.dta", replace
local universe_n = _N

count if adult_employment_observed == 1
local observed_n = r(N)
count if adult_employment_valid == 1
local valid_n = r(N)
count if adult_employment_observed == 1 & adult_employment_valid == 0
local invalid_n = r(N)
count if adult_employment_valid != 1
local missing_n = r(N)
count if adult_employment_valid == 1 & adult_employed == 1
local positive_n = r(N)
post `va' ("employment") ("TK01 valid activity codes 1,2,3,4,5,7,95") (`universe_n') (`observed_n') (`valid_n') (`invalid_n') (`missing_n') (`positive_n')

count if adult_salary_observed == 1
local observed_n = r(N)
count if adult_salary_valid == 1
local valid_n = r(N)
count if adult_salary_observed == 1 & adult_salary_valid == 0
local invalid_n = r(N)
count if adult_salary_valid != 1
local missing_n = r(N)
count if adult_salary_valid == 1 & adult_salary_monthly > 0
local positive_n = r(N)
post `va' ("salary") ("TK25A1X==1; TK25A1>=0 and <999999997") (`universe_n') (`observed_n') (`valid_n') (`invalid_n') (`missing_n') (`positive_n')

count if adult_profit_observed == 1
local observed_n = r(N)
count if adult_profit_valid == 1
local valid_n = r(N)
count if adult_profit_observed == 1 & adult_profit_valid == 0
local invalid_n = r(N)
count if adult_profit_valid != 1
local missing_n = r(N)
count if adult_profit_valid == 1 & adult_profit_monthly > 0
local positive_n = r(N)
post `va' ("profit") ("TK26A1X in 1,2; TK26A1<999999999998; sign retained") (`universe_n') (`observed_n') (`valid_n') (`invalid_n') (`missing_n') (`positive_n')

count if adult_dl06_observed == 1
local observed_n = r(N)
count if adult_dl06_valid == 1
local valid_n = r(N)
count if adult_dl06_observed == 1 & adult_dl06_valid == 0
local invalid_n = r(N)
count if adult_dl06_valid != 1
local missing_n = r(N)
count if adult_college == 1
local positive_n = r(N)
post `va' ("education_college") ("DL06 valid categories; college codes 60-63") (`universe_n') (`observed_n') (`valid_n') (`invalid_n') (`missing_n') (`positive_n')

count if adult_srh_observed == 1
local observed_n = r(N)
count if adult_srh_valid == 1
local valid_n = r(N)
count if adult_srh_observed == 1 & adult_srh_valid == 0
local invalid_n = r(N)
count if adult_srh_valid != 1
local missing_n = r(N)
count if adult_good_health == 1
local positive_n = r(N)
post `va' ("self_rated_health") ("KK01 valid codes 1-4; higher score is better") (`universe_n') (`observed_n') (`valid_n') (`invalid_n') (`missing_n') (`positive_n')

count if adult_height_observed == 1 | adult_weight_observed == 1
local observed_n = r(N)
count if adult_bmi_valid == 1
local valid_n = r(N)
count if adult_height_observed == 1 | adult_weight_observed == 1
count if (adult_height_observed == 1 | adult_weight_observed == 1) & adult_bmi_valid == 0
local invalid_n = r(N)
count if adult_bmi_valid != 1
local missing_n = r(N)
count if adult_bmi_valid == 1 & adult_bmi_raw >= 25
local positive_n = r(N)
post `va' ("bmi") ("Measured height 100-250 cm, weight 20-250 kg, BMI 10-80") (`universe_n') (`observed_n') (`valid_n') (`invalid_n') (`missing_n') (`positive_n')

count if adult_smoking_observed == 1
local observed_n = r(N)
count if adult_current_smoker_valid == 1
local valid_n = r(N)
count if adult_smoking_observed == 1 & adult_current_smoker_valid == 0
local invalid_n = r(N)
count if adult_current_smoker_valid != 1
local missing_n = r(N)
count if adult_current_smoker == 1
local positive_n = r(N)
post `va' ("smoking") ("Explicit KM01A/KM01E/KM04 cigarette response") (`universe_n') (`observed_n') (`valid_n') (`invalid_n') (`missing_n') (`positive_n')

count if adult_marriage_observed == 1
local observed_n = r(N)
count if adult_marriage_valid == 1
local valid_n = r(N)
count if adult_marriage_observed == 1 & adult_marriage_valid == 0
local invalid_n = r(N)
count if adult_marriage_valid != 1
local missing_n = r(N)
count if adult_married == 1
local positive_n = r(N)
post `va' ("marriage") ("PK00A valid codes 1 or 3") (`universe_n') (`observed_n') (`valid_n') (`invalid_n') (`missing_n') (`positive_n')

count if adult_condition_observed == 1
local observed_n = r(N)
count if adult_condition_observed == 1
local valid_n = r(N)
count if adult_condition_observed == 1 & missing(adult_any_listed_condition)
local invalid_n = r(N)
count if missing(adult_any_listed_condition)
local missing_n = r(N)
count if adult_any_listed_condition == 1
local positive_n = r(N)
post `va' ("listed_condition") ("CD01 collapsed across condition rows; 1=yes, 3=no, 8=DK") (`universe_n') (`observed_n') (`valid_n') (`invalid_n') (`missing_n') (`positive_n')

postclose `va'
use "`output'/diagnostics/w5_outcome_validity_audit.dta", clear
sort outcome
save "`output'/diagnostics/w5_outcome_validity_audit.dta", replace
export delimited using "`output'/diagnostics/w5_outcome_validity_audit.csv", replace

use "`output'/diagnostics/w5_outcome_merge_audit.dta", clear
sort module
save "`output'/diagnostics/w5_outcome_merge_audit.dta", replace
export delimited using "`output'/diagnostics/w5_outcome_merge_audit.csv", replace

display as result "W5_ADULT_OUTCOMES_PASS"
display as result "W5_ADULT_OUTCOMES_NOTE=separate outcome families; salary/profit remain distinct; CD01 is labelled listed condition, not generic chronic disease"
log close
exit 0
