version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/09_selected_module_variable_probe.log", text replace
display as text "SELECTED_MODULE_PROBE_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

tempname audit_h var_h
postfile `audit_h' int wave int survey_year str24 topic str244 relpath ///
    byte file_exists long obs_count int var_count using ///
    "`output'/diagnostics/selected_module_file_audit.dta", replace
postfile `var_h' int wave int survey_year str24 topic str244 relpath ///
    str32 varname str80 variable_label str16 storage_type str32 display_format ///
    str32 value_label using ///
    "`output'/diagnostics/selected_module_variables.dta", replace

global AUDIT_HANDLE `audit_h'
global VAR_HANDLE `var_h'
global PROJECT_ROOT "`project'"

capture program drop collect_selected_file
program define collect_selected_file
    version 16.0
    syntax, Wave(integer) Year(integer) Topic(string) Relpath(string)
    local path "${PROJECT_ROOT}/00_raw/`relpath'"
    capture confirm file "`path'"
    if _rc != 0 {
        post $AUDIT_HANDLE (`wave') (`year') ("`topic'") ("`relpath'") (0) (.) (.)
        exit
    }
    use "`path'", clear
    local nobs = _N
    local nvars = c(k)
    post $AUDIT_HANDLE (`wave') (`year') ("`topic'") ("`relpath'") (1) (`nobs') (`nvars')
    ds
    local vars "`r(varlist)'"
    foreach v of local vars {
        local vlabel : variable label `v'
        local vtype : type `v'
        local vformat : format `v'
        local vallabel : value label `v'
        post $VAR_HANDLE (`wave') (`year') ("`topic'") ("`relpath'") ///
            ("`v'") ("`vlabel'") ("`vtype'") ("`vformat'") ("`vallabel'")
    }
end

* Wave 1: migration, work, baseline, and roster.
foreach file in buk3mg1.dta buk3mg2.dta buk3mg3.dta {
    collect_selected_file, wave(1) year(1993) topic(migration) relpath(wave1_hh93/`file')
}
foreach file in buk3tk1.dta buk3tk2.dta buk3tk3.dta buk3tk5.dta {
    collect_selected_file, wave(1) year(1993) topic(child_work) relpath(wave1_hh93/`file')
}
foreach file in buk1ks1.dta buk1ks2a.dta buk1ks2b.dta buk1ks3a.dta buk1ks3b.dta buk1ks4.dta buk1pp1.dta bukkar2.dta {
    collect_selected_file, wave(1) year(1993) topic(baseline_roster) relpath(wave1_hh93/`file')
}

* Wave 2: migration, child work, baseline, roster, and adult-outcome source modules.
foreach file in b3a_mg1.dta b3a_mg2.dta {
    collect_selected_file, wave(2) year(1997) topic(migration) relpath(wave2_hh97/`file')
}
foreach file in b3a_tk1.dta b3a_tk2.dta b3a_tk3.dta b3a_tk4.dta {
    collect_selected_file, wave(2) year(1997) topic(child_work) relpath(wave2_hh97/`file')
}
foreach file in b1_cov.dta b1_ks0.dta b1_ks1.dta b1_ks2.dta b1_ks3.dta b1_ks4.dta b1_pp1.dta bk_ar1.dta {
    collect_selected_file, wave(2) year(1997) topic(baseline_roster) relpath(wave2_hh97/`file')
}
foreach file in b3b_cov.dta b3b_ba0.dta b3b_ba1.dta b3b_ba2.dta b3b_ba3.dta b3b_ba4.dta b3b_ba5.dta b3b_ba6.dta b3b_ps.dta b3b_ak.dta b3b_km.dta b3b_ma1.dta b3b_ma2.dta b3b_rj1.dta b3b_rj2.dta b3b_rn1.dta b3b_rn2.dta {
    collect_selected_file, wave(2) year(1997) topic(adult_outcome_source) relpath(wave2_hh97/`file')
}

* Wave 3.
foreach file in b3a_mg1.dta b3a_mg2.dta {
    collect_selected_file, wave(3) year(2000) topic(migration) relpath(wave3_hh00/`file')
}
foreach file in b3a_tk1.dta b3a_tk2.dta b3a_tk3.dta b3a_tk4.dta {
    collect_selected_file, wave(3) year(2000) topic(child_work) relpath(wave3_hh00/`file')
}
foreach file in b1_cov.dta b1_ks0.dta b1_ks1.dta b1_ks2.dta b1_ks3.dta b1_ks4.dta b1_pp.dta bk_ar1.dta bek.dta {
    collect_selected_file, wave(3) year(2000) topic(baseline_roster) relpath(wave3_hh00/`file')
}
foreach file in b3b_cov.dta b3b_ba0.dta b3b_ba1.dta b3b_ba2.dta b3b_ba3.dta b3b_ba4.dta b3b_ba5.dta b3b_ba6.dta b3b_bh1.dta b3b_bh2.dta b3b_ps.dta b3b_ak.dta b3b_km.dta b3b_ma1.dta b3b_ma2.dta b3b_pm1.dta b3b_pm3.dta b3b_rj1.dta b3b_rj2.dta b3b_rj3.dta b3b_rj4.dta b3b_rn1.dta b3b_rn2.dta b3b_tf.dta {
    collect_selected_file, wave(3) year(2000) topic(adult_outcome_source) relpath(wave3_hh00/`file')
}

* Wave 4.
foreach file in b3a_mg1.dta b3a_mg2.dta {
    collect_selected_file, wave(4) year(2007) topic(migration) relpath(wave4_hh07/`file')
}
foreach file in b3a_tk1.dta b3a_tk2.dta b3a_tk3.dta b3a_tk4.dta {
    collect_selected_file, wave(4) year(2007) topic(child_work) relpath(wave4_hh07/`file')
}
foreach file in b1_cov.dta b1_ks0.dta b1_ks1.dta b1_ks2.dta b1_ks3.dta b1_ks4.dta b1_pp.dta bk_ar1.dta bek_ek1.dta bek_ek2.dta {
    collect_selected_file, wave(4) year(2007) topic(baseline_roster) relpath(wave4_hh07/`file')
}
foreach file in b3b_cov.dta b3b_ba0.dta b3b_ba1.dta b3b_ba4.dta b3b_ba5.dta b3b_ba6.dta b3b_cd1.dta b3b_cd2.dta b3b_cd3.dta b3b_co1.dta b3b_co2.dta b3b_co3.dta b3b_ep1.dta b3b_ep2.dta b3b_km.dta b3b_ps.dta b3b_ak1.dta b3b_ak2.dta b3b_ma1.dta b3b_ma2.dta b3b_rj0.dta b3b_rj1.dta b3b_rj3.dta b3b_rn1.dta b3b_rn2.dta b3b_tf.dta b3b_vg.dta bus_us.dta {
    collect_selected_file, wave(4) year(2007) topic(adult_outcome_source) relpath(wave4_hh07/`file')
}
foreach file in bus1_0.dta bus1_1.dta bus1_2.dta bus1_3.dta bus1_4.dta bus2_0.dta bus2_1.dta bus2_2.dta bus2_3.dta {
    collect_selected_file, wave(4) year(2007) topic(adult_outcome_source) relpath(wave4_hh07/`file')
}

* Wave 5.
foreach file in b3a_mg1.dta b3a_mg2.dta {
    collect_selected_file, wave(5) year(2014) topic(migration) relpath(wave5_hh14/`file')
}
foreach file in b3a_tk1.dta b3a_tk2.dta b3a_tk3.dta b3a_tk4.dta {
    collect_selected_file, wave(5) year(2014) topic(child_work) relpath(wave5_hh14/`file')
}
foreach file in b1_cov.dta b1_ks0.dta b1_ks1.dta b1_ks2.dta b1_ks3.dta b1_ks4.dta b1_pp.dta bk_ar1.dta ek_time1.dta ek_time2.dta {
    collect_selected_file, wave(5) year(2014) topic(baseline_roster) relpath(wave5_hh14/`file')
}
foreach file in b3b_cov.dta b3b_ba0.dta b3b_ba1.dta b3b_ba4.dta b3b_ba6.dta b3b_cd1.dta b3b_cd2.dta b3b_cd3.dta b3b_co1.dta b3b_cob.dta b3b_eh.dta b3b_ep1.dta b3b_ep2.dta b3b_km.dta b3b_ps.dta b3b_psn.dta b3b_ak1.dta b3b_ak2.dta b3b_ma1.dta b3b_ma2.dta b3b_rj0.dta b3b_rj1.dta b3b_rj2.dta b3b_rj3.dta b3b_rn1.dta b3b_rn2.dta b3b_sa.dta b3b_tdr.dta b3b_tf.dta bus_us.dta {
    collect_selected_file, wave(5) year(2014) topic(adult_outcome_source) relpath(wave5_hh14/`file')
}

postclose `audit_h'
postclose `var_h'
macro drop AUDIT_HANDLE VAR_HANDLE PROJECT_ROOT

use "`output'/diagnostics/selected_module_file_audit.dta", clear
sort wave topic relpath
save "`output'/diagnostics/selected_module_file_audit.dta", replace
export delimited using "`output'/diagnostics/selected_module_file_audit.csv", replace
list if file_exists == 0, noobs abbreviate(28)

use "`output'/diagnostics/selected_module_variables.dta", clear
sort wave topic relpath varname
save "`output'/diagnostics/selected_module_variables.dta", replace
export delimited using "`output'/diagnostics/selected_module_variables.csv", replace
display as text "SELECTED_VARIABLE_ROWS=" _N

display as result "SELECTED_MODULE_PROBE_PASS"
log close
exit 0
