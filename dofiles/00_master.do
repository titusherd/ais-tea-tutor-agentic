version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local output "`project'/04_output"
local run_date "`c(current_date)'"
local run_time "`c(current_time)'"

cd "`project'"
file open master using "`output'/logs/00_master.log", write replace
file write master "MASTER_START=`run_date' `run_time'" _n
file write master "PROJECT_ROOT=`project'" _n
file write master "SEED=9042026" _n
file close master

* Canonical first-pass chain. The original IFLS source directory is never
* written by these do-files; all derived and output artifacts are downstream.
do dofiles/00_stata_environment_probe.do
do dofiles/01_setup_paths_and_environment.do
do dofiles/02_inventory_and_codebook_audit.do
do dofiles/02b_variable_inventory.do
do dofiles/03_build_person_spine.do
do dofiles/05_build_roster_source_long.do
do dofiles/07_build_roster_long.do
do dofiles/08_build_roster_relation_long.do
do dofiles/06_build_household_lineage.do
do dofiles/10_core_module_key_audit.do
do dofiles/11_shared_spine_quality_gate.do
do dofiles/12_migration_raw_audit.do
do dofiles/13_r3_cohort_age_audit.do
do dofiles/13a_r3_age_consistency_audit.do
do dofiles/14_child_work_raw_audit.do
do dofiles/15_adult_outcome_module_inventory.do
do dofiles/15a_adult_outcome_label_search.do
do dofiles/16_adult_outcome_availability_audit.do
do dofiles/16a_adult_outcome_age_coverage.do
do dofiles/17_survey_design_weight_audit.do
do dofiles/18_r1_treatment_baseline_audit.do
do dofiles/19_r3_treatment_constructability_audit.do
do dofiles/20_pce_monetary_gap_audit.do
do dofiles/22_codebook_validity_audit.do
do dofiles/31_finalize_local_source_hashes.do
do dofiles/21_review_gate_artifact_audit.do
do dofiles/23_build_r1_locked_treatment.do
do dofiles/24_build_r3_locked_treatment.do
do dofiles/25_build_w5_adult_outcomes.do
do dofiles/26_build_w1_baseline_controls.do
do dofiles/27_build_analysis_bases.do
do dofiles/28_run_first_pass_models.do
do dofiles/29_export_first_pass_outputs.do
do dofiles/30_final_quality_gate.do
do dofiles/32_publication_support_audit.do
do dofiles/33_publication_outputs.do
do dofiles/34_publication_quality_gate.do

file open master using "`output'/logs/00_master.log", write append
local pass_date "`c(current_date)'"
local pass_time "`c(current_time)'"
file write master "MASTER_PASS=`pass_date' `pass_time'" _n
file write master "NOTE=canonical first-pass and publication-support chain completed; external submission items remain explicitly open" _n
file close master
exit 0
