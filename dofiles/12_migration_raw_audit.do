version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local raw "`project'/00_raw"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/12_migration_raw_audit.log", text replace
display as text "MIGRATION_RAW_AUDIT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

tempname sh
postfile `sh' byte wave int survey_year str16 module str244 relpath byte file_exists ///
    long rows long pidlink_nonmissing byte pidlink_unique byte secondary_key_unique ///
    str32 variable long nonmissing long missing double raw_min double raw_max ///
    using "`output'/diagnostics/migration_raw_summary.dta", replace

* One-row-per-person migration modules. The raw indicators are reported under
* their original names; no across-wave harmonisation is imposed here.
foreach w in 1 2 3 4 5 {
    local yr = cond(`w' == 1, 1993, cond(`w' == 2, 1997, cond(`w' == 3, 2000, cond(`w' == 4, 2007, 2014))))
    local folder ""
    local file ""
    local vars ""
    if `w' == 1 {
        local folder "wave1_hh93"
        local file "buk3mg1.dta"
        local vars "mg20 mg2100"
    }
    if `w' == 2 {
        local folder "wave2_hh97"
        local file "b3a_mg1.dta"
        local vars "mg20b mg21n"
    }
    if `w' == 3 {
        local folder "wave3_hh00"
        local file "b3a_mg1.dta"
        local vars "mg20b mg20c"
    }
    if `w' == 4 {
        local folder "wave4_hh07"
        local file "b3a_mg1.dta"
        local vars "mg20b mg20c"
    }
    if `w' == 5 {
        local folder "wave5_hh14"
        local file "b3a_mg1.dta"
        local vars "mg20b mg20c mg20d"
    }
    local relpath "`folder'/`file'"
    capture confirm file "`raw'/`relpath'"
    if _rc != 0 {
        post `sh' (`w') (`yr') ("mg1_summary") ("`relpath'") (0) (.) (.) (.) (.) ///
            ("__file_missing__") (.) (.) (.) (.)
    }
    else {
        use "`raw'/`relpath'", clear
        local nobs = _N
        count if !missing(pidlink)
        local pid_nonmiss = r(N)
        preserve
        keep if !missing(pidlink)
        capture isid pidlink
        local pid_unique = (_rc == 0)
        restore
        foreach v of local vars {
            capture confirm variable `v'
            if _rc != 0 {
                post `sh' (`w') (`yr') ("mg1_summary") ("`relpath'") (1) (`nobs') (`pid_nonmiss') (`pid_unique') (.) ///
                    ("`v'") (.) (.) (.) (.)
            }
            else {
                count if !missing(`v')
                local v_nonmiss = r(N)
                count if missing(`v')
                local v_missing = r(N)
                summarize `v', meanonly
                local v_min = r(min)
                local v_max = r(max)
                post `sh' (`w') (`yr') ("mg1_summary") ("`relpath'") (1) (`nobs') (`pid_nonmiss') (`pid_unique') (.) ///
                    ("`v'") (`v_nonmiss') (`v_missing') (`v_min') (`v_max')
                display as text "MG1_W`w'_`v'_VALUE_COUNTS"
                tabulate `v', missing
            }
        }
    }
}

* Multi-record migration histories. W2 is explicitly retained as a missing
* module row because the local data release has no b3a_mg2.dta.
foreach w in 1 2 3 4 5 {
    local yr = cond(`w' == 1, 1993, cond(`w' == 2, 1997, cond(`w' == 3, 2000, cond(`w' == 4, 2007, 2014))))
    local folder ""
    if `w' == 1 local folder "wave1_hh93"
    if `w' == 2 local folder "wave2_hh97"
    if `w' == 3 local folder "wave3_hh00"
    if `w' == 4 local folder "wave4_hh07"
    if `w' == 5 local folder "wave5_hh14"
    local relpath "`folder'/b3a_mg2.dta"
    if `w' == 1 local relpath "`folder'/buk3mg2.dta"
    capture confirm file "`raw'/`relpath'"
    local geo "mg21e"
    if `w' == 1 local geo "mg21d2"
    local vars "`geo' mg24yr mg25 mg26 mg28 mg29 mg30 mg31 mg34 mg35"
    if _rc != 0 {
        post `sh' (`w') (`yr') ("mg2_event") ("`relpath'") (0) (.) (.) (.) (.) ///
            ("__file_missing__") (.) (.) (.) (.)
    }
    else {
        use "`raw'/`relpath'", clear
        local nobs = _N
        count if !missing(pidlink)
        local pid_nonmiss = r(N)
        preserve
        keep if !missing(pidlink)
        capture isid pidlink
        local pid_unique = (_rc == 0)
        restore
        local secondary_unique = .
        capture confirm variable movenum
        if _rc == 0 {
            preserve
            keep if !missing(pidlink) & !missing(movenum)
            capture isid pidlink movenum
            local secondary_unique = (_rc == 0)
            restore
        }
        foreach v of local vars {
            capture confirm variable `v'
            if _rc != 0 {
                post `sh' (`w') (`yr') ("mg2_event") ("`relpath'") (1) (`nobs') (`pid_nonmiss') (`pid_unique') (`secondary_unique') ///
                    ("`v'") (.) (.) (.) (.)
            }
            else {
                count if !missing(`v')
                local v_nonmiss = r(N)
                count if missing(`v')
                local v_missing = r(N)
                summarize `v', meanonly
                local v_min = r(min)
                local v_max = r(max)
                post `sh' (`w') (`yr') ("mg2_event") ("`relpath'") (1) (`nobs') (`pid_nonmiss') (`pid_unique') (`secondary_unique') ///
                    ("`v'") (`v_nonmiss') (`v_missing') (`v_min') (`v_max')
            }
        }
    }
}

postclose `sh'
use "`output'/diagnostics/migration_raw_summary.dta", clear
sort wave module relpath variable
save "`output'/diagnostics/migration_raw_summary.dta", replace
export delimited using "`output'/diagnostics/migration_raw_summary.csv", replace
list, noobs abbreviate(28)

* The W5 MG20C label is a semantic break from W3/W4 and is recorded directly
* in the audit document rather than silently recoded into an age-12 measure.
tempname mh
postfile `mh' byte wave str32 variable str28 semantic_status str244 evidence using "`output'/diagnostics/migration_semantic_flags.dta", replace
post `mh' (1) ("mg2100") ("age12_history_candidate") ("label: number of migrations since age 12")
post `mh' (2) ("mg21n") ("age12_history_candidate") ("label: number of migrations since age 12")
post `mh' (3) ("mg20c") ("age12_history_candidate") ("label: CAFE generated number of migrations age>=12")
post `mh' (4) ("mg20c") ("age12_history_candidate") ("label: CAFE generated number of migrations age>=12")
post `mh' (5) ("mg20c") ("not_age12_harmonized") ("label: number of moves since interview; do not equate to W3/W4 age>=12 count")
post `mh' (5) ("mg20d") ("verification_field") ("label: check MG20C")
postclose `mh'
use "`output'/diagnostics/migration_semantic_flags.dta", clear
export delimited using "`output'/diagnostics/migration_semantic_flags.csv", replace

display as result "MIGRATION_RAW_AUDIT_PASS"
display as result "MIGRATION_RAW_AUDIT_NOTE=no_final_treatment_definition"
log close
exit 0
