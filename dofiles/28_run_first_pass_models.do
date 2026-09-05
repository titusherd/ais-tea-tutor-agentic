version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/28_run_first_pass_models.log", text replace
display as text "FIRST_PASS_MODELS_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SPEC_LOCK_ID=R1-MAIN/R3-MAIN-D030-D032-D041-D042"
display as text "NOTE=linear adjusted associations; robust VCE clustered at locked household IDs; support gate requires >=10 treated observations, >=5 treated clusters, and >=20 controls"

tempname rh
postfile `rh' str8 paper str24 family str40 outcome str32 model_tier ///
    str24 status long sample_n treated_n control_n treated_cluster_n ///
    cluster_n double coefficient standard_error p_value r2 long df_r ///
    using "`output'/tables/first_pass_model_results.dta", replace
global FIRST_PASS_RESULT_HANDLE `rh'

capture program drop run_assoc_model
program define run_assoc_model
    version 16.0
    syntax, Paper(string) Family(string) Outcome(name) Treatment(name) ///
        Cluster(name) Frame(name) Tier(string)

    local controls_run ""
    if "`tier'" == "core_adjusted_clustered" & "`paper'" == "R1" {
        local controls_run "c.w1_age i.w1_child_female c.w1_hh_size c.w1_mother_age c.w1_father_age"
    }
    if "`tier'" == "core_adjusted_clustered" & "`paper'" == "R3" {
        local controls_run "c.w1_age i.w1_child_female c.w1_hh_size c.w1_mother_age c.w1_father_age i.wave"
    }

    preserve
    keep if `frame' == 1
    keep if !missing(`outcome') & !missing(`treatment') & !missing(`cluster')
    count
    local n = r(N)
    count if `treatment' == 1
    local nt = r(N)
    count if `treatment' == 0
    local nc = r(N)
    egen long _treated_cluster_tag = tag(`cluster') if `treatment' == 1
    count if _treated_cluster_tag == 1
    local ntc = r(N)
    egen long _cluster_tag = tag(`cluster')
    count if _cluster_tag == 1
    local ncl = r(N)

    if `nt' < 10 | `ntc' < 5 | `nc' < 20 {
        post $FIRST_PASS_RESULT_HANDLE ("`paper'") ("`family'") ///
            ("`outcome'") ("`tier'") ("support_below_gate") ///
            (`n') (`nt') (`nc') (`ntc') (`ncl') (.) (.) (.) (.) (.)
        restore
        exit
    }

    capture noisily regress `outcome' `treatment' `controls_run', ///
        vce(cluster `cluster')
    local rc = _rc
    if `rc' != 0 {
        post $FIRST_PASS_RESULT_HANDLE ("`paper'") ("`family'") ///
            ("`outcome'") ("`tier'") ("model_error_rc_`rc'") ///
            (`n') (`nt') (`nc') (`ntc') (`ncl') (.) (.) (.) (.) (.)
        restore
        exit
    }

    local b = _b[`treatment']
    local se = _se[`treatment']
    local df = e(df_r)
    local p = .
    if `se' > 0 & `se' < . {
        local p = 2 * ttail(`df', abs(`b' / `se'))
    }
    local r2 = e(r2)
    local est_clusters = `ncl'
    post $FIRST_PASS_RESULT_HANDLE ("`paper'") ("`family'") ///
        ("`outcome'") ("`tier'") ("pass") ///
        (`n') (`nt') (`nc') (`ntc') (`est_clusters') ///
        (`b') (`se') (`p') (`r2') (`df')
    restore
end

* Primary control tier: age, sex, baseline household size, and both linked
* parent ages. R3 additionally includes treatment-wave fixed effects.
local r1_core "c.w1_age i.w1_child_female c.w1_hh_size c.w1_mother_age c.w1_father_age"
local r3_core "c.w1_age i.w1_child_female c.w1_hh_size c.w1_mother_age c.w1_father_age i.wave"

local labor "adult_employed adult_ln1p_salary_monthly adult_ln1p_abs_profit"
local education "adult_college"
local health "adult_srh_score adult_good_health adult_bmi_raw adult_health_adequacy"
local social "adult_current_smoker adult_married adult_any_listed_condition adult_tr01_score adult_tr02_score adult_tr03_score adult_tr04_score adult_tr05_score adult_tr06_score"

* R1 models.
use "`derived'/r1_analysis_base.dta", clear
foreach family in labor education health social_behavioral {
    local outcomes ""
    if "`family'" == "labor" local outcomes "`labor'"
    if "`family'" == "education" local outcomes "`education'"
    if "`family'" == "health" local outcomes "`health'"
    if "`family'" == "social_behavioral" local outcomes "`social'"
    foreach outcome of local outcomes {
        run_assoc_model, paper(R1) family(`family') outcome(`outcome') ///
            treatment(r1_treatment) cluster(r1_cluster_id) ///
            frame(r1_analysis_frame) tier(unadjusted_clustered)
        run_assoc_model, paper(R1) family(`family') outcome(`outcome') ///
            treatment(r1_treatment) cluster(r1_cluster_id) ///
            frame(r1_analysis_frame) tier(core_adjusted_clustered)
    }
}

* R3 models. Pooled W2/W3 estimates include wave fixed effects in the core
* adjusted tier; the locked cluster remains treatment-wave household.
use "`derived'/r3_analysis_base.dta", clear
foreach family in labor education health social_behavioral {
    local outcomes ""
    if "`family'" == "labor" local outcomes "`labor'"
    if "`family'" == "education" local outcomes "`education'"
    if "`family'" == "health" local outcomes "`health'"
    if "`family'" == "social_behavioral" local outcomes "`social'"
    foreach outcome of local outcomes {
        run_assoc_model, paper(R3) family(`family') outcome(`outcome') ///
            treatment(r3_treatment) cluster(r3_cluster_id) ///
            frame(r3_analysis_frame) tier(unadjusted_clustered)
        run_assoc_model, paper(R3) family(`family') outcome(`outcome') ///
            treatment(r3_treatment) cluster(r3_cluster_id) ///
            frame(r3_analysis_frame) tier(core_adjusted_clustered)
    }
}
postclose `rh'
macro drop FIRST_PASS_RESULT_HANDLE

use "`output'/tables/first_pass_model_results.dta", clear
gen str64 spec_lock_id = ""
replace spec_lock_id = "R1-MAIN-D010-D011-D012-D030-D031-D032-D033-D040-D041-D042" if paper == "R1"
replace spec_lock_id = "R3-MAIN-D020-D021-D022-D023-D030-D031-D032-D033-D040-D041-D042" if paper == "R3"
gen str24 weight_rule = "unweighted_primary"
gen str80 cluster_rule = ""
replace cluster_rule = "W1 origin household; robust VCE" if paper == "R1"
replace cluster_rule = "treatment-wave household; robust VCE" if paper == "R3"
gen str32 interpretation_label = "adjusted_association"
gen long result_id = _n
gen double bh_q_value = .

* Benjamini-Hochberg q-values are computed only for successful primary
* adjusted models, separately inside each predeclared paper x outcome family.
preserve
keep if status == "pass" & model_tier == "core_adjusted_clustered" & ///
    !missing(p_value)
sort paper family p_value outcome
by paper family: gen long family_m = _N
by paper family: gen long family_rank = _n
gen double bh_raw = p_value * family_m / family_rank
gsort paper family -family_rank
by paper family: gen double bh_q_temp = bh_raw if _n == 1
by paper family: replace bh_q_temp = min(bh_raw, bh_q_temp[_n-1]) if _n > 1
keep result_id bh_q_temp
tempfile bh
save "`bh'", replace
restore
merge 1:1 result_id using "`bh'", nogen
replace bh_q_value = bh_q_temp if !missing(bh_q_temp)
drop bh_q_temp
sort paper family model_tier outcome
save "`output'/tables/first_pass_model_results.dta", replace
export delimited using "`output'/tables/first_pass_model_results.csv", replace

preserve
keep if status == "pass"
contract paper family model_tier
rename _freq successful_models
sort paper family model_tier
save "`output'/tables/first_pass_model_summary.dta", replace
export delimited using "`output'/tables/first_pass_model_summary.csv", replace
restore

* Mechanical result gate: every successful model must have a treatment and
* control group, a nonmissing cluster count, and a finite coefficient/SE.
use "`output'/tables/first_pass_model_results.dta", clear
count if status == "pass" & (treated_n < 10 | treated_cluster_n < 5 | ///
    control_n < 20 | missing(coefficient) | missing(standard_error) | ///
    missing(cluster_n))
if r(N) > 0 {
    display as error "FIRST_PASS_MODELS_FAIL=support or coefficient contract"
    log close
    exit 459
}
count if status == "pass" & model_tier == "core_adjusted_clustered" & ///
    missing(bh_q_value)
if r(N) > 0 {
    display as error "FIRST_PASS_MODELS_FAIL=missing BH q value for successful adjusted model"
    log close
    exit 459
}
display as result "FIRST_PASS_MODELS_PASS"
display as result "FIRST_PASS_MODELS_NOTE=outcomes below support gate are labelled support_below_gate and are not broadened or interpreted as inferential results"
log close
exit 0
