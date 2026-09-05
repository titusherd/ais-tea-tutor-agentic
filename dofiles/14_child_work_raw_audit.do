version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/14_child_work_raw_audit.log", text replace
display as text "CHILD_WORK_RAW_AUDIT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

* The audit reports raw file availability, key integrity, labels, missingness,
* and age coverage. It intentionally does not construct CL_10_11,
* CL_12_14, CL_15, hazardous work, or Chores_21.
tempname rh ah
postfile `rh' byte wave int survey_year str28 module str244 relpath byte file_exists ///
    long module_rows long pidlink_nonmissing byte pidlink_unique ///
    str32 varname str120 variable_label str16 storage_type str32 value_label ///
    long nonmissing long missing double raw_min double raw_max ///
    using "`output'/diagnostics/child_work_raw_summary.dta", replace
postfile `ah' byte wave int survey_year str28 module str244 relpath byte file_exists ///
    long module_rows long pidlink_nonmissing byte pidlink_unique ///
    long spine_linked_rows long spine_linked_persons long age_valid_persons ///
    long age_5_20_persons long age_10_11_persons long age_12_14_persons long age_15_persons ///
    using "`output'/diagnostics/child_work_age_coverage.dta", replace

* One-row-per-person screen modules. W2 is present only because the local
* working extraction copied the verified source file from the original archive.
local screen_specs `" "1 1993 wave1_hh93 buk3tk1.dta child_work_screen" "2 1997 wave2_hh97 b3a_tk1.dta child_work_screen" "3 2000 wave3_hh00 b3a_tk1.dta child_work_screen" "4 2007 wave4_hh07 b3a_tk1.dta child_work_screen" "5 2014 wave5_hh14 b3a_tk1.dta child_work_screen" "'
foreach spec of local screen_specs {
    tokenize `"`spec'"'
    local w `1'
    local yr `2'
    local folder `3'
    local file `4'
    local module `5'
    local relpath "`folder'/`file'"
    local path "`raw'/`relpath'"

    capture confirm file "`path'"
    if _rc != 0 {
        post `rh' (`w') (`yr') ("`module'") ("`relpath'") (0) (.) (.) (.) ///
            ("__file_missing__") ("file not found in local working extraction") ("") ("") (.) (.) (.) (.)
        post `ah' (`w') (`yr') ("`module'") ("`relpath'") (0) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.)
        continue
    }

    use "`path'", clear
    local module_rows = _N
    local pidlink_nonmissing = .
    local pidlink_unique = .
    capture confirm variable pidlink
    if _rc == 0 {
        count if !missing(pidlink)
        local pidlink_nonmissing = r(N)
        preserve
        keep if !missing(pidlink)
        capture isid pidlink
        local pidlink_unique = (_rc == 0)
        restore
    }

    local vars "tk01 tk02 tk03 tk04 tk05"
    if `w' == 1 local vars "tk01 tk02 tk03 tk04 tk05 tk13"
    if inlist(`w', 4, 5) local vars "tk01 tk01a tk01b tk01c tk01d tk02 tk03 tk04 tk05"
    foreach v of local vars {
        capture confirm variable `v'
        if _rc != 0 {
            post `rh' (`w') (`yr') ("`module'") ("`relpath'") (1) (`module_rows') (`pidlink_nonmissing') (`pidlink_unique') ///
                ("`v'") ("variable not found in module") ("") ("") (.) (.) (.) (.)
        }
        else {
            local vlabel : variable label `v'
            local vtype : type `v'
            local vformat : format `v'
            local vallabel : value label `v'
            count if !missing(`v')
            local v_nonmissing = r(N)
            count if missing(`v')
            local v_missing = r(N)
            local v_min = .
            local v_max = .
            capture confirm numeric variable `v'
            if _rc == 0 {
                summarize `v', meanonly
                local v_min = r(min)
                local v_max = r(max)
            }
            post `rh' (`w') (`yr') ("`module'") ("`relpath'") (1) (`module_rows') (`pidlink_nonmissing') (`pidlink_unique') ///
                ("`v'") ("`vlabel'") ("`vtype'") ("`vallabel'") (`v_nonmissing') (`v_missing') (`v_min') (`v_max')
            display as text "CHILD_WORK_W`w'_`v'_VALUE_COUNTS"
            capture tabulate `v', missing
        }
    }

    * Link module rows to the canonical spine only for age-coverage reporting.
    * The module's duplicate status is retained above; no duplicate is dropped.
    preserve
    use "`derived'/person_spine.dta", clear
    keep if wave == `w'
    keep pidlink age_at_interview birth_date present_roster sex
    isid pidlink
    tempfile spinew
    save "`spinew'", replace
    restore
    capture confirm variable pidlink
    if _rc == 0 {
        merge m:1 pidlink using "`spinew'", gen(_age_merge)
        keep if _age_merge != 2
        gen byte _module_pid_tag = 0
        egen _module_pid_tag_tmp = tag(pidlink) if !missing(pidlink)
        replace _module_pid_tag = _module_pid_tag_tmp
        count if _age_merge == 3
        local linked_rows = r(N)
        count if _age_merge == 3 & _module_pid_tag == 1
        local linked_persons = r(N)
        gen byte _age_valid = !missing(age_at_interview) & age_at_interview >= 0 & age_at_interview <= 100
        count if _age_merge == 3 & _module_pid_tag == 1 & _age_valid
        local age_valid_persons = r(N)
        count if _age_merge == 3 & _module_pid_tag == 1 & _age_valid & inrange(age_at_interview, 5, 20)
        local age_5_20 = r(N)
        count if _age_merge == 3 & _module_pid_tag == 1 & _age_valid & inrange(age_at_interview, 10, 11)
        local age_10_11 = r(N)
        count if _age_merge == 3 & _module_pid_tag == 1 & _age_valid & inrange(age_at_interview, 12, 14)
        local age_12_14 = r(N)
        count if _age_merge == 3 & _module_pid_tag == 1 & _age_valid & age_at_interview == 15
        local age_15 = r(N)
    }
    else {
        local linked_rows = .
        local linked_persons = .
        local age_valid_persons = .
        local age_5_20 = .
        local age_10_11 = .
        local age_12_14 = .
        local age_15 = .
    }
    post `ah' (`w') (`yr') ("`module'") ("`relpath'") (1) (`module_rows') (`pidlink_nonmissing') (`pidlink_unique') ///
        (`linked_rows') (`linked_persons') (`age_valid_persons') (`age_5_20') (`age_10_11') (`age_12_14') (`age_15')
}

* Hour and work-detail modules. W2 detail files are present in the original
* local archive and copied into the working extraction with identical hashes;
* this audit therefore treats W2 as available evidence.
postclose `ah'
tempname ahh
postfile `ahh' byte wave int survey_year str28 module str244 relpath byte file_exists ///
    long module_rows long pidlink_nonmissing byte pidlink_unique ///
    long spine_linked_rows long spine_linked_persons long age_valid_persons ///
    long age_5_20_persons long age_10_11_persons long age_12_14_persons long age_15_persons ///
    using "`output'/diagnostics/child_work_age_coverage_hours.dta", replace
local hour_specs `" "1 1993 wave1_hh93 buk3tk2.dta child_work_hours" "2 1997 wave2_hh97 b3a_tk2.dta child_work_hours" "3 2000 wave3_hh00 b3a_tk2.dta child_work_hours" "4 2007 wave4_hh07 b3a_tk2.dta child_work_hours" "5 2014 wave5_hh14 b3a_tk2.dta child_work_hours" "'
foreach spec of local hour_specs {
    tokenize `"`spec'"'
    local w `1'
    local yr `2'
    local folder `3'
    local file `4'
    local module `5'
    local relpath "`folder'/`file'"
    local path "`raw'/`relpath'"

    capture confirm file "`path'"
    if _rc != 0 {
        post `rh' (`w') (`yr') ("`module'") ("`relpath'") (0) (.) (.) (.) ///
            ("__file_missing__") ("file not found in local working extraction") ("") ("") (.) (.) (.) (.)
        post `ahh' (`w') (`yr') ("`module'") ("`relpath'") (0) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.)
        continue
    }

    use "`path'", clear
    local module_rows = _N
    local pidlink_nonmissing = .
    local pidlink_unique = .
    capture confirm variable pidlink
    if _rc == 0 {
        count if !missing(pidlink)
        local pidlink_nonmissing = r(N)
        preserve
        keep if !missing(pidlink)
        capture isid pidlink
        local pidlink_unique = (_rc == 0)
        restore
    }
    foreach v in tk21a tk21b tk22a tk22b tk23a tk23b {
        capture confirm variable `v'
        if _rc != 0 {
            post `rh' (`w') (`yr') ("`module'") ("`relpath'") (1) (`module_rows') (`pidlink_nonmissing') (`pidlink_unique') ///
                ("`v'") ("variable not found in module") ("") ("") (.) (.) (.) (.)
        }
        else {
            local vlabel : variable label `v'
            local vtype : type `v'
            local vallabel : value label `v'
            count if !missing(`v')
            local v_nonmissing = r(N)
            count if missing(`v')
            local v_missing = r(N)
            summarize `v', meanonly
            local v_min = r(min)
            local v_max = r(max)
            post `rh' (`w') (`yr') ("`module'") ("`relpath'") (1) (`module_rows') (`pidlink_nonmissing') (`pidlink_unique') ///
                ("`v'") ("`vlabel'") ("`vtype'") ("`vallabel'") (`v_nonmissing') (`v_missing') (`v_min') (`v_max')
        }
    }

    preserve
    use "`derived'/person_spine.dta", clear
    keep if wave == `w'
    keep pidlink age_at_interview birth_date present_roster sex
    isid pidlink
    tempfile spinew
    save "`spinew'", replace
    restore
    capture confirm variable pidlink
    if _rc == 0 {
        merge m:1 pidlink using "`spinew'", gen(_age_merge)
        keep if _age_merge != 2
        egen _module_pid_tag = tag(pidlink) if !missing(pidlink)
        count if _age_merge == 3
        local linked_rows = r(N)
        count if _age_merge == 3 & _module_pid_tag == 1
        local linked_persons = r(N)
        gen byte _age_valid = !missing(age_at_interview) & age_at_interview >= 0 & age_at_interview <= 100
        count if _age_merge == 3 & _module_pid_tag == 1 & _age_valid
        local age_valid_persons = r(N)
        count if _age_merge == 3 & _module_pid_tag == 1 & _age_valid & inrange(age_at_interview, 5, 20)
        local age_5_20 = r(N)
        count if _age_merge == 3 & _module_pid_tag == 1 & _age_valid & inrange(age_at_interview, 10, 11)
        local age_10_11 = r(N)
        count if _age_merge == 3 & _module_pid_tag == 1 & _age_valid & inrange(age_at_interview, 12, 14)
        local age_12_14 = r(N)
        count if _age_merge == 3 & _module_pid_tag == 1 & _age_valid & age_at_interview == 15
        local age_15 = r(N)
    }
    else {
        local linked_rows = .
        local linked_persons = .
        local age_valid_persons = .
        local age_5_20 = .
        local age_10_11 = .
        local age_12_14 = .
        local age_15 = .
    }
    post `ahh' (`w') (`yr') ("`module'") ("`relpath'") (1) (`module_rows') (`pidlink_nonmissing') (`pidlink_unique') ///
        (`linked_rows') (`linked_persons') (`age_valid_persons') (`age_5_20') (`age_10_11') (`age_12_14') (`age_15')
}

postclose `rh'
postclose `ahh'

use "`output'/diagnostics/child_work_raw_summary.dta", clear
sort wave module relpath varname
save "`output'/diagnostics/child_work_raw_summary.dta", replace
export delimited using "`output'/diagnostics/child_work_raw_summary.csv", replace

use "`output'/diagnostics/child_work_age_coverage.dta", clear
append using "`output'/diagnostics/child_work_age_coverage_hours.dta"
sort wave module relpath
save "`output'/diagnostics/child_work_age_coverage.dta", replace
export delimited using "`output'/diagnostics/child_work_age_coverage.csv", replace

* Search the complete local variable inventory for individual housework,
* housekeeping, and chores wording. Household-transfer questions are kept in
* this evidence file but are not declared equivalent to individual weekly
* hours.
use "`output'/diagnostics/variable_inventory.dta", clear
gen byte chores_keyword_match = regexm(lower(variable_label), "housework|housekeeping|chores")
keep if chores_keyword_match
sort wave file_path raw_name
save "`output'/diagnostics/child_work_chores_variable_inventory.dta", replace
export delimited using "`output'/diagnostics/child_work_chores_variable_inventory.csv", replace

* A compact contract register records what each relevant source can and cannot
* support at this stage. Compatibility is not locked here because units and
* the exact Chores_21 rule still require specification review.
tempname ch
postfile `ch' byte wave int survey_year str244 relpath str32 varname str40 measure_type ///
    str16 file_or_variable_status str24 chores21_status str244 evidence ///
    using "`output'/diagnostics/child_work_chores_availability.dta", replace
post `ch' (1) (1993) ("wave1_hh93/buk3aw1.dta") ("aw2_e") ("housework screen") ("verified") ("screen_only") ///
    ("individual question: did respondent do housework in past 7 days; does not supply hours alone")
post `ch' (1) (1993) ("wave1_hh93/buk3aw1.dta") ("aw3_e") ("housework time") ("verified") ("candidate_unit_review") ///
    ("individual label says time spent on housework past 7 days; unit and valid-code treatment require codebook review")
post `ch' (2) (1997) ("local variable inventory") ("__none_exact__") ("individual weekly housework hours") ("not_located") ("not_supported") ///
    ("no exact comparable individual weekly housework-hours variable located by the local inventory search")
post `ch' (3) (2000) ("local variable inventory") ("__none_exact__") ("individual weekly housework hours") ("not_located") ("not_supported") ///
    ("no exact comparable individual weekly housework-hours variable located by the local inventory search")
post `ch' (4) (2007) ("wave4_hh07/b3a_tk1.dta") ("tk01c") ("housekeeping activity screen") ("verified") ("screen_only") ///
    ("housekeeping yes/no activity item; no compatible weekly hours in this variable")
post `ch' (5) (2014) ("wave5_hh14/b3a_tk1.dta") ("tk01c") ("housekeeping activity screen") ("verified") ("screen_only") ///
    ("housekeeping yes/no activity item; no compatible weekly hours in this variable")
postclose `ch'
use "`output'/diagnostics/child_work_chores_availability.dta", clear
sort wave varname
save "`output'/diagnostics/child_work_chores_availability.dta", replace
export delimited using "`output'/diagnostics/child_work_chores_availability.csv", replace

display as result "CHILD_WORK_RAW_AUDIT_PASS"
display as result "CHILD_WORK_RAW_AUDIT_NOTE=no_child_labor_or_chores_threshold_was_constructed"
log close
exit 0
