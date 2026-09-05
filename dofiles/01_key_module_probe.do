version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
log using "`project'/04_output/logs/01_key_module_probe.log", text replace

local files ///
    "`project'/00_raw/wave1_hh93/buk3mg1.dta" ///
    "`project'/00_raw/wave1_hh93/buk3tk1.dta" ///
    "`project'/00_raw/wave1_hh93/buk1ks1.dta" ///
    "`project'/00_raw/wave2_hh97/ptrack.dta" ///
    "`project'/00_raw/wave2_hh97/htrack.dta" ///
    "`project'/00_raw/wave2_hh97/bk_cov.dta" ///
    "`project'/00_raw/wave2_hh97/b3a_cov.dta" ///
    "`project'/00_raw/wave2_hh97/b3a_mg1.dta" ///
    "`project'/00_raw/wave2_hh97/b3a_tk1.dta" ///
    "`project'/00_raw/wave2_hh97/b3b_cov.dta" ///
    "`project'/00_raw/wave2_hh97/b3b_ma1.dta" ///
    "`project'/00_raw/wave3_hh00/ptrack.dta" ///
    "`project'/00_raw/wave3_hh00/htrack.dta" ///
    "`project'/00_raw/wave3_hh00/bk_cov.dta" ///
    "`project'/00_raw/wave3_hh00/b3a_cov.dta" ///
    "`project'/00_raw/wave3_hh00/b3a_mg1.dta" ///
    "`project'/00_raw/wave3_hh00/b3a_tk1.dta" ///
    "`project'/00_raw/wave3_hh00/b3b_cov.dta" ///
    "`project'/00_raw/wave3_hh00/b3b_ma1.dta" ///
    "`project'/00_raw/wave4_hh07/ptrack.dta" ///
    "`project'/00_raw/wave4_hh07/htrack.dta" ///
    "`project'/00_raw/wave4_hh07/bk_cov.dta" ///
    "`project'/00_raw/wave4_hh07/b3a_cov.dta" ///
    "`project'/00_raw/wave4_hh07/b3a_mg1.dta" ///
    "`project'/00_raw/wave4_hh07/b3a_tk1.dta" ///
    "`project'/00_raw/wave4_hh07/b3b_cov.dta" ///
    "`project'/00_raw/wave4_hh07/b3b_vg.dta" ///
    "`project'/00_raw/wave5_hh14/ptrack.dta" ///
    "`project'/00_raw/wave5_hh14/htrack.dta" ///
    "`project'/00_raw/wave5_hh14/bk_cov.dta" ///
    "`project'/00_raw/wave5_hh14/b3a_cov.dta" ///
    "`project'/00_raw/wave5_hh14/b3a_mg1.dta" ///
    "`project'/00_raw/wave5_hh14/b3a_tk1.dta" ///
    "`project'/00_raw/wave5_hh14/b3b_cov.dta" ///
    "`project'/00_raw/wave5_hh14/b3b_vg.dta" ///
    "`project'/00_raw/wave5_hh14/bus.dta" ///
    "`project'/00_raw/wave5_hh14/ek_ek2.dta"

foreach path of local files {
    capture confirm file "`path'"
    if _rc {
        display as error "MISSING_FILE `path'"
        continue
    }
    display as text "============================================================"
    display as text "FILE `path'"
    use "`path'", clear
    count
    describe, short
    ds
    local vars `r(varlist)'
    local nshow = min(wordcount("`vars'"), 20)
    forvalues j = 1/`nshow' {
        local v : word `j' of `vars'
        local vl : variable label `v'
        display as text "VAR `v' | `vl'"
    }
}

log close
exit 0
