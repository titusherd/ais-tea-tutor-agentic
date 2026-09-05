version 16.0
clear all
set more off

local project "/Users/titus/Documents/ais-tea"
local output "`project'/04_output"
local submission "`project'/05_submission"
local diagnostics "`output'/diagnostics"

cd "`project'"
log using "`output'/logs/34_publication_quality_gate.log", text replace
display as text "PUBLICATION_QUALITY_GATE_START=" c(current_date) " " c(current_time)

local fail 0
capture confirm file "`submission'/final_project_package.html"
if _rc != 0 {
    display as error "MISSING_REQUIRED_FILE=`submission'/final_project_package.html"
    local fail 1
}
foreach f in ///
    `submission'/README_FINAL_DELIVERY.md ///
    `submission'/final_results_memo.md ///
    `submission'/manuscripts/paper1_working_paper.md ///
    `submission'/manuscripts/paper1_working_paper.docx ///
    `submission'/manuscripts/paper1_working_paper.pdf ///
    `submission'/manuscripts/paper3_working_paper.md ///
    `submission'/manuscripts/paper3_working_paper.docx ///
    `submission'/manuscripts/paper3_working_paper.pdf ///
    `submission'/manuscripts/paper2_feasibility_memo.md ///
    `submission'/manuscripts/title_page_template.md ///
    `submission'/manuscripts/cover_note_template.md ///
    `submission'/tables/all_adjusted_primary_results.csv ///
    `submission'/tables/headline_adjusted_results.csv ///
    `submission'/tables/baseline_descriptives.csv ///
    `submission'/tables/model_registry.csv ///
    `submission'/figures/first_pass_coefficients_R1.png ///
    `submission'/figures/first_pass_coefficients_R3.png ///
    `submission'/replication/README.md {
    capture confirm file "`f'"
    if _rc != 0 {
        display as error "MISSING_REQUIRED_FILE=`f'"
        local fail 1
    }
}

capture confirm file "`output'/logs/00_master.log"
if _rc != 0 {
    display as error "MISSING_MASTER_LOG"
    local fail 1
}
else {
    display as text "MASTER_LOG_PRESENT=1"
}

capture confirm file "`output'/logs/30_final_quality_gate.log"
if _rc != 0 {
    display as error "MISSING_FIRST_PASS_GATE_LOG"
    local fail 1
}
else {
    display as text "FIRST_PASS_GATE_LOG_PRESENT=1"
}

import delimited using "`submission'/tables/all_adjusted_primary_results.csv", clear varnames(1) stringcols(_all)
count
display as text "ALL_PRIMARY_ROWS=" r(N)
assert r(N) == 33
assert !missing(paper) & !missing(family) & !missing(outcome) & !missing(status)
assert !missing(coefficient) if status == "pass"
assert missing(coefficient) if status == "support_below_gate"
assert strpos(interpretation_label, "association") > 0

import delimited using "`submission'/tables/headline_adjusted_results.csv", clear varnames(1) stringcols(_all)
count
display as text "HEADLINE_ROWS=" r(N)
assert r(N) == 14
assert !missing(coefficient)
assert !missing(bh_q_value)

import delimited using "`submission'/tables/baseline_descriptives.csv", clear varnames(1) stringcols(_all)
count
display as text "BASELINE_ROWS=" r(N)
assert r(N) == 20
assert !missing(mean) & !missing(sd)

import delimited using "`submission'/tables/model_registry.csv", clear varnames(1) stringcols(_all)
count
display as text "MODEL_REGISTRY_ROWS=" r(N)
assert r(N) == 68
assert !missing(paper) & !missing(outcome) & !missing(status)

file open gate using "`diagnostics'/publication_quality_gate.csv", write replace
file write gate "check,status,evidence" _n
file write gate "required_files,pass,05_submission package files" _n
file write gate "first_pass_model_rows,pass,33 adjusted primary rows" _n
file write gate "headline_rows,pass,14 prelabelled domain rows" _n
file write gate "baseline_rows,pass,20 paper-by-group descriptive rows" _n
file write gate "model_registry_rows,pass,68 model registry rows" _n
file write gate "interpretation_label,pass,all coefficients labelled adjusted_association" _n
file write gate "external_submission_items,open,author metadata source provenance and substantive review" _n
file close gate

if `fail' == 1 {
    display as error "PUBLICATION_QUALITY_GATE_FAIL"
    log close
    exit 459
}

display as result "PUBLICATION_QUALITY_GATE_PASS_WITH_OPEN_EXTERNAL_ITEMS"
display as text "OPEN_ITEMS=author metadata; exact official release provenance; substantive review; parked analyses"
log close
exit 0
