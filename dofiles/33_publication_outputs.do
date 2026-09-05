version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local derived "`project'/02_derived"
local output "`project'/04_output"
local submission "`project'/05_submission"

cd "`project'"
log using "`output'/logs/33_publication_outputs.log", text replace
display as text "PUBLICATION_OUTPUTS_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SPEC_LOCK=R1-MAIN/R3-MAIN-D030-D032-D041-D042"

* --------------------------------------------------------------------------
* 1. Preserve a publication-ready copy of every adjusted primary result.
*    The full table prevents selective reporting; the headline table is a
*    pre-labelled domain summary, not a post-result significance filter.
* --------------------------------------------------------------------------
use "`output'/tables/first_pass_primary_results.dta", clear
gen double ci_low_t = coefficient - invttail(df_r, .025) * standard_error
gen double ci_high_t = coefficient + invttail(df_r, .025) * standard_error
assert abs(ci_low - ci_low_t) < 1e-8 if !missing(ci_low)
assert abs(ci_high - ci_high_t) < 1e-8 if !missing(ci_high)
drop ci_low_t ci_high_t
gen str36 outcome_label = outcome
replace outcome_label = "College attainment" if outcome == "adult_college"
replace outcome_label = "Employment" if outcome == "adult_employed"
replace outcome_label = "Log monthly salary (ln(1+salary))" if outcome == "adult_ln1p_salary_monthly"
replace outcome_label = "Log absolute monthly profit (ln(1+abs(profit)))" if outcome == "adult_ln1p_abs_profit"
replace outcome_label = "Self-rated health score" if outcome == "adult_srh_score"
replace outcome_label = "Good self-rated health" if outcome == "adult_good_health"
replace outcome_label = "BMI" if outcome == "adult_bmi_raw"
replace outcome_label = "Health adequacy" if outcome == "adult_health_adequacy"
replace outcome_label = "Currently married/cohabiting" if outcome == "adult_married"
replace outcome_label = "Current smoker" if outcome == "adult_current_smoker"
replace outcome_label = "Any listed chronic condition" if outcome == "adult_any_listed_condition"
replace outcome_label = "Trust item 1" if outcome == "adult_tr01_score"
replace outcome_label = "Trust item 2" if outcome == "adult_tr02_score"
replace outcome_label = "Trust item 3" if outcome == "adult_tr03_score"
replace outcome_label = "Trust item 4" if outcome == "adult_tr04_score"
replace outcome_label = "Trust item 5" if outcome == "adult_tr05_score"
replace outcome_label = "Trust item 6" if outcome == "adult_tr06_score"
gen str18 scale = "continuous"
replace scale = "percentage_points" if inlist(outcome, "adult_college", "adult_employed", "adult_good_health", "adult_health_adequacy", "adult_current_smoker", "adult_married", "adult_any_listed_condition")
gen byte full_result_table = 1
order paper family outcome_label outcome scale status sample_n treated_n control_n treated_cluster_n cluster_n coefficient standard_error ci_low ci_high p_value bh_q_value spec_lock_id weight_rule cluster_rule interpretation_label
sort paper family outcome
save "`submission'/tables/all_adjusted_primary_results.dta", replace
export delimited using "`submission'/tables/all_adjusted_primary_results.csv", replace

* The headline table covers the domains named in the brief. Every other
* outcome remains in the full appendix table above.
gen byte headline = 0
replace headline = 1 if inlist(outcome, "adult_college", "adult_employed", "adult_good_health", "adult_ln1p_salary_monthly", "adult_srh_score", "adult_married", "adult_tr03_score")
preserve
keep if headline == 1
gen byte headline_order = .
replace headline_order = 1 if outcome == "adult_college"
replace headline_order = 2 if outcome == "adult_employed"
replace headline_order = 3 if outcome == "adult_ln1p_salary_monthly"
replace headline_order = 4 if outcome == "adult_srh_score"
replace headline_order = 5 if outcome == "adult_good_health"
replace headline_order = 6 if outcome == "adult_married"
replace headline_order = 7 if outcome == "adult_tr03_score"
sort paper headline_order
order paper headline_order family outcome_label outcome scale status sample_n treated_n control_n treated_cluster_n cluster_n coefficient standard_error ci_low ci_high p_value bh_q_value spec_lock_id weight_rule cluster_rule interpretation_label
save "`submission'/tables/headline_adjusted_results.dta", replace
export delimited using "`submission'/tables/headline_adjusted_results.csv", replace
restore

* --------------------------------------------------------------------------
* 2. Baseline descriptive table. Means are descriptive within the locked
*    analysis frame; no balance test is promoted as causal evidence.
* --------------------------------------------------------------------------
tempname b
postfile `b' str8 paper str12 group str32 variable long n double mean sd using "`submission'/tables/baseline_descriptives.dta", replace

use "`derived'/r1_analysis_base.dta", clear
keep if r1_analysis_frame == 1
foreach g in 0 1 {
    local glabel = cond(`g' == 1, "treated", "control")
    foreach v in w1_age w1_child_female w1_hh_size w1_mother_age w1_father_age {
        summarize `v' if r1_treatment == `g'
        post `b' ("R1") ("`glabel'") ("`v'") (r(N)) (r(mean)) (r(sd))
    }
}

use "`derived'/r3_analysis_base.dta", clear
keep if r3_analysis_frame == 1
foreach g in 0 1 {
    local glabel = cond(`g' == 1, "treated", "control")
    foreach v in w1_age w1_child_female w1_hh_size w1_mother_age w1_father_age {
        summarize `v' if r3_treatment == `g'
        post `b' ("R3") ("`glabel'") ("`v'") (r(N)) (r(mean)) (r(sd))
    }
}
postclose `b'
use "`submission'/tables/baseline_descriptives.dta", clear
sort paper variable group
export delimited using "`submission'/tables/baseline_descriptives.csv", replace

* --------------------------------------------------------------------------
* 3. Model registry with an explicit omission/support status. The source
*    first-pass model table already records every outcome and is retained.
* --------------------------------------------------------------------------
use "`output'/tables/first_pass_model_results.dta", clear
gen str80 command_family = "linear regression with household-clustered robust VCE"
gen str80 controls = "W1 age, child sex, household size, linked parent ages; R3 adds wave indicator"
gen str120 omission_reason = ""
replace omission_reason = "Below predeclared treated/support gate; coefficient withheld" if status == "support_below_gate"
replace omission_reason = "Model did not converge or returned Stata error" if strpos(status, "model_error") == 1
order result_id paper family outcome model_tier status sample_n treated_n control_n treated_cluster_n cluster_n coefficient standard_error p_value bh_q_value spec_lock_id weight_rule cluster_rule interpretation_label command_family controls omission_reason
sort paper family outcome model_tier
export delimited using "`submission'/tables/model_registry.csv", replace

display as result "PUBLICATION_OUTPUTS_PASS"
display as result "PUBLICATION_OUTPUTS_NOTE=full results, labelled headline table, baseline descriptives, and model registry exported"
log close
exit 0
