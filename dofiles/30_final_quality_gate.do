version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local derived "`project'/02_derived"
local output "`project'/04_output"
local docs "`project'/99_docs"

cd "`project'"
log using "`output'/logs/30_final_quality_gate.log", text replace
display as text "FINAL_QUALITY_GATE_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)

tempname fg
postfile `fg' str64 check_name str24 status str244 detail ///
    using "`output'/diagnostics/final_quality_gate.dta", replace
global FINAL_GATE_HANDLE `fg'
local failures = 0

* Required artifacts. The source manifest is checked separately because its
* inventory rows currently carry an explicit open hash/release status.
local required_files ///
    "99_docs/decision_defaults_2026-09-05.md 99_docs/primary_specification_lock.md 99_docs/estimand_register.md 99_docs/decision_log.csv 99_docs/variable_crosswalk.csv 99_docs/survey_design_decision.md 99_docs/first_pass_result_memo_2026-09-05.md 02_derived/person_spine.dta 02_derived/roster_long.dta 02_derived/roster_relation_long.dta 02_derived/household_lineage.dta 02_derived/r1_mother_international_treatment.dta 02_derived/r3_child_labor_treatment.dta 02_derived/w1_baseline_controls.dta 02_derived/w5_adult_outcomes.dta 02_derived/r1_analysis_base.dta 02_derived/r3_analysis_base.dta 04_output/tables/first_pass_model_results.dta 04_output/tables/first_pass_model_results.csv 04_output/tables/first_pass_primary_results.csv 04_output/diagnostics/analysis_sample_flow.csv 04_output/diagnostics/analysis_base_merge_audit.csv 04_output/diagnostics/analysis_outcome_support.csv 04_output/diagnostics/codebook_metadata_audit.csv 04_output/diagnostics/w1_baseline_validity_audit.csv 04_output/diagnostics/w5_outcome_validity_audit.csv 04_output/diagnostics/r3_age_profile_support.csv 04_output/diagnostics/r1_heterogeneity_descriptive.csv 04_output/figures/first_pass_coefficients_R1.png 04_output/figures/first_pass_coefficients_R3.png"
foreach relpath of local required_files {
    capture confirm file "`project'/`relpath'"
    if _rc == 0 {
        post $FINAL_GATE_HANDLE ("artifact_`relpath'") ("pass") ("required artifact exists")
    }
    else {
        post $FINAL_GATE_HANDLE ("artifact_`relpath'") ("fail") ("required artifact is missing")
        local failures = `failures' + 1
    }
}

* Source inventory status. This is deliberately nonblocking for the current
* first pass: the local inventory is complete, while release/hash metadata is
* still explicitly pending rather than fabricated.
capture confirm file "`docs'/source_manifest.csv"
if _rc == 0 {
    import delimited using "`docs'/source_manifest.csv", clear varnames(1) stringcols(_all)
    local manifest_rows = _N
    count if missing(sha256) | strpos(lower(sha256), "pending") > 0 | ///
        missing(release_id) | strpos(lower(release_id), "pending") > 0
    local pending_provenance = r(N)
    if `pending_provenance' > 0 {
        post $FINAL_GATE_HANDLE ("source_manifest_hashes") ("open_nonblocking") ///
            ("`pending_provenance' of `manifest_rows' rows retain pending official release metadata; local hashes are checked")
    }
    else {
        post $FINAL_GATE_HANDLE ("source_manifest_hashes") ("pass") ///
            ("all source inventory rows have non-pending hash metadata")
    }
}
else {
    post $FINAL_GATE_HANDLE ("source_manifest") ("fail") ("source_manifest.csv is missing")
    local failures = `failures' + 1
}

* Crosswalk and decision-log parse checks.
capture import delimited using "`docs'/variable_crosswalk.csv", clear varnames(1) stringcols(_all)
if _rc != 0 {
    post $FINAL_GATE_HANDLE ("variable_crosswalk_parse") ("fail") ("Stata could not parse variable_crosswalk.csv")
    local failures = `failures' + 1
}
else {
    count if missing(canonical_name) | missing(raw_name)
    if r(N) == 0 post $FINAL_GATE_HANDLE ("variable_crosswalk_parse") ("pass") ("no blank canonical/raw fields")
    else {
        post $FINAL_GATE_HANDLE ("variable_crosswalk_parse") ("fail") ("blank canonical/raw fields detected")
        local failures = `failures' + 1
    }
}
capture import delimited using "`docs'/decision_log.csv", clear varnames(1) stringcols(_all)
if _rc != 0 {
    post $FINAL_GATE_HANDLE ("decision_log_parse") ("fail") ("Stata could not parse decision_log.csv")
    local failures = `failures' + 1
}
else {
    count if missing(decision_id) | missing(status)
    if r(N) == 0 post $FINAL_GATE_HANDLE ("decision_log_parse") ("pass") ("decision_id/status present for all rows")
    else {
        post $FINAL_GATE_HANDLE ("decision_log_parse") ("fail") ("decision_id/status missing")
        local failures = `failures' + 1
    }
}

* Reusable uniqueness checks for canonical files.
capture program drop final_key_check
program define final_key_check
    version 16.0
    args file key check_name
    capture use "`file'", clear
    if _rc != 0 {
        post $FINAL_GATE_HANDLE ("key_`check_name'") ("fail") ("could not open `file'")
        exit
    }
    capture isid `key'
    if _rc == 0 post $FINAL_GATE_HANDLE ("key_`check_name'") ("pass") ("isid `key'")
    else post $FINAL_GATE_HANDLE ("key_`check_name'") ("fail") ("key failure: `key'")
end

final_key_check "`derived'/person_spine.dta" "pidlink wave" "person_spine"
final_key_check "`derived'/roster_long.dta" "pidlink wave" "roster_long"
final_key_check "`derived'/roster_relation_long.dta" "wave hhid_wave pid_wave" "roster_relation"
final_key_check "`derived'/household_lineage.dta" "lineage_row_id" "household_lineage"
final_key_check "`derived'/r1_mother_international_treatment.dta" "child_pidlink" "r1_treatment"
final_key_check "`derived'/r3_child_labor_treatment.dta" "pidlink wave" "r3_treatment"
final_key_check "`derived'/w1_baseline_controls.dta" "pidlink" "w1_baseline"
final_key_check "`derived'/w5_adult_outcomes.dta" "pidlink" "w5_outcomes"
final_key_check "`derived'/r1_analysis_base.dta" "child_pidlink" "r1_analysis_base"
final_key_check "`derived'/r3_analysis_base.dta" "pidlink wave" "r3_analysis_base"

* Treatment status contracts: unresolved observations must not carry a
* treatment value, and primary eligibility must be a clean treated/control
* status.
use "`derived'/r1_mother_international_treatment.dta", clear
count if r1_status == "unresolved_exposure" & !missing(r1_treatment)
if r(N) == 0 post $FINAL_GATE_HANDLE ("r1_unresolved_not_forced_control") ("pass") ("unresolved exposure has missing treatment")
else {
    post $FINAL_GATE_HANDLE ("r1_unresolved_not_forced_control") ("fail") ("unresolved exposure carries a treatment value")
    local failures = `failures' + 1
}
count if r1_primary_eligible == 1 & !inlist(r1_status, "treated", "control")
if r(N) == 0 post $FINAL_GATE_HANDLE ("r1_primary_status_contract") ("pass") ("eligible rows are treated/control only")
else {
    post $FINAL_GATE_HANDLE ("r1_primary_status_contract") ("fail") ("invalid R1 primary status")
    local failures = `failures' + 1
}

use "`derived'/r3_child_labor_treatment.dta", clear
count if inlist(r3_status, "unresolved_screen", "unresolved_hours") & !missing(r3_treatment)
if r(N) == 0 post $FINAL_GATE_HANDLE ("r3_unresolved_not_forced_control") ("pass") ("unresolved screen/hour status has missing treatment")
else {
    post $FINAL_GATE_HANDLE ("r3_unresolved_not_forced_control") ("fail") ("unresolved R3 status carries a treatment value")
    local failures = `failures' + 1
}
count if r3_primary_eligible == 1 & !inlist(r3_status, "treated", "control")
if r(N) == 0 post $FINAL_GATE_HANDLE ("r3_primary_status_contract") ("pass") ("eligible rows are treated/control only")
else {
    post $FINAL_GATE_HANDLE ("r3_primary_status_contract") ("fail") ("invalid R3 primary status")
    local failures = `failures' + 1
}

* Outcome recode contracts.
use "`derived'/w5_adult_outcomes.dta", clear
local bad_outcome_contract = 0
count if adult_salary_valid == 1 & missing(adult_ln1p_salary_monthly)
local bad_outcome_contract = `bad_outcome_contract' + r(N)
count if adult_profit_valid == 1 & missing(adult_ln1p_abs_profit)
local bad_outcome_contract = `bad_outcome_contract' + r(N)
count if adult_employment_valid == 1 & missing(adult_employed)
local bad_outcome_contract = `bad_outcome_contract' + r(N)
if `bad_outcome_contract' == 0 post $FINAL_GATE_HANDLE ("w5_outcome_recode_contract") ("pass") ("valid outcomes are nonmissing")
else {
    post $FINAL_GATE_HANDLE ("w5_outcome_recode_contract") ("fail") ("valid outcome has missing derived value")
    local failures = `failures' + 1
}

* Model table contract and metadata.
use "`output'/tables/first_pass_model_results.dta", clear
capture isid result_id
if _rc == 0 post $FINAL_GATE_HANDLE ("model_result_key") ("pass") ("result_id unique")
else {
    post $FINAL_GATE_HANDLE ("model_result_key") ("fail") ("result_id is not unique")
    local failures = `failures' + 1
}
count if status == "pass" & (missing(coefficient) | missing(standard_error) | missing(cluster_n) | missing(spec_lock_id) | missing(weight_rule) | missing(cluster_rule))
if r(N) == 0 post $FINAL_GATE_HANDLE ("model_result_metadata") ("pass") ("successful models have coefficient, VCE, and lock metadata")
else {
    post $FINAL_GATE_HANDLE ("model_result_metadata") ("fail") ("successful model metadata is incomplete")
    local failures = `failures' + 1
}
count if status == "pass" & model_tier == "core_adjusted_clustered" & missing(bh_q_value)
if r(N) == 0 post $FINAL_GATE_HANDLE ("model_bh_contract") ("pass") ("successful adjusted models have BH q-values")
else {
    post $FINAL_GATE_HANDLE ("model_bh_contract") ("fail") ("successful adjusted model lacks BH q-value")
    local failures = `failures' + 1
}
count if status == "support_below_gate" & (!missing(coefficient) | !missing(standard_error))
if r(N) == 0 post $FINAL_GATE_HANDLE ("model_support_gate") ("pass") ("below-gate models have no inferential coefficient")
else {
    post $FINAL_GATE_HANDLE ("model_support_gate") ("fail") ("below-gate model has an inferential coefficient")
    local failures = `failures' + 1
}

postclose `fg'
macro drop FINAL_GATE_HANDLE
use "`output'/diagnostics/final_quality_gate.dta", clear
sort status check_name
save "`output'/diagnostics/final_quality_gate.dta", replace
export delimited using "`output'/diagnostics/final_quality_gate.csv", replace

count if status == "fail"
local recorded_failures = r(N)
if `failures' > 0 | `recorded_failures' > 0 {
    display as error "FINAL_QUALITY_GATE_FAIL=`recorded_failures'"
    log close
    exit 459
}
count if status == "open_nonblocking"
if r(N) > 0 {
    display as result "FINAL_QUALITY_GATE_PASS_WITH_OPEN_PROVENANCE"
    display as result "FINAL_QUALITY_GATE_NOTE=all analysis contracts pass; source release/hash metadata remains explicitly open"
}
else display as result "FINAL_QUALITY_GATE_PASS"
log close
exit 0
