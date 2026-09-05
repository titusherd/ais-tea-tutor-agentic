version 16.0
clear all
set more off

local project = c(pwd)
local raw "`project'/00_raw"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/05_roster_module_probe.log", text replace
display as text "ROSTER_MODULE_PROBE_START=" c(current_date) " " c(current_time)

local files "`raw'/wave2_hh97/bk_cov.dta `raw'/wave2_hh97/bk_ar0.dta `raw'/wave2_hh97/bk_ar1.dta `raw'/wave2_hh97/bk_krk.dta `raw'/wave3_hh00/bk_cov.dta `raw'/wave3_hh00/bk_ar0.dta `raw'/wave3_hh00/bk_ar1.dta `raw'/wave3_hh00/bk_krk.dta `raw'/wave4_hh07/bk_cov.dta `raw'/wave4_hh07/bk_ar0.dta `raw'/wave4_hh07/bk_ar1.dta `raw'/wave4_hh07/bk_krk.dta `raw'/wave5_hh14/bk_cov.dta `raw'/wave5_hh14/bk_ar0.dta `raw'/wave5_hh14/bk_ar1.dta `raw'/wave5_hh14/bk_krk.dta"
foreach path of local files {
    capture confirm file "`path'"
    if _rc {
        display as error "MISSING_FILE=`path'"
        continue
    }
    display as result "=== FILE `path' ==="
    use "`path'", clear
    describe, short
    lookfor hhid pid person member relation head parent mother father age sex birth respondent
    describe
}

display as result "ROSTER_MODULE_PROBE_PASS"
log close
exit 0
