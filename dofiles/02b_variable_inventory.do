version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/02b_variable_inventory.log", text replace

display as text "VARIABLE_INVENTORY_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

tempfile variables
tempname vinv
postfile `vinv' ///
    str32 source_id ///
    str12 wave ///
    str244 file_path ///
    str80 file_name ///
    str32 raw_name ///
    str16 storage_type ///
    str80 display_format ///
    str32 value_label ///
    str244 variable_label ///
    long observation_count ///
    int variable_count ///
    str30 read_status ///
    str244 notes ///
    using "`variables'", replace

local roots "`raw'/wave1_hh93 `raw'/wave1_cf93 `raw'/wave2_hh97 `raw'/wave2_cf97 `raw'/wave3_hh00 `raw'/wave3_cf00 `raw'/wave4_hh07 `raw'/wave4_cf07 `raw'/wave5_hh14 `raw'/wave5_cf14"

foreach root of local roots {
    local wave "unknown"
    local source_id "unknown"

    if strpos("`root'", "/wave1_hh") {
        local wave "1993"
        local source_id "IFLS1-HH"
    }
    if strpos("`root'", "/wave1_cf") {
        local wave "1993"
        local source_id "IFLS1-CF"
    }
    if strpos("`root'", "/wave2_hh") {
        local wave "1997"
        local source_id "IFLS2-HH"
    }
    if strpos("`root'", "/wave2_cf") {
        local wave "1997"
        local source_id "IFLS2-CF"
    }
    if strpos("`root'", "/wave3_hh") {
        local wave "2000"
        local source_id "IFLS3-HH"
    }
    if strpos("`root'", "/wave3_cf") {
        local wave "2000"
        local source_id "IFLS3-CF"
    }
    if strpos("`root'", "/wave4_hh") {
        local wave "2007"
        local source_id "IFLS4-HH"
    }
    if strpos("`root'", "/wave4_cf") {
        local wave "2007"
        local source_id "IFLS4-CF"
    }
    if strpos("`root'", "/wave5_hh") {
        local wave "2014"
        local source_id "IFLS5-HH"
    }
    if strpos("`root'", "/wave5_cf") {
        local wave "2014"
        local source_id "IFLS5-CF"
    }

    local files : dir "`root'" files "*.dta"
    local nfiles : word count `files'
    display as text "ROOT `root' FILES=`nfiles'"

    foreach f of local files {
        local path "`root'/`f'"
        capture use "`path'", clear
        if _rc {
            local rc = _rc
            post `vinv' ("`source_id'") ("`wave'") ("`path'") ("`f'") ("") ("") ("") ("") ("") (.) (.) ("unreadable") ("use_rc=`rc'")
            continue
        }

        local N = _N
        local K = c(k)
        foreach v of varlist _all {
            local storage : type `v'
            local fmt : format `v'
            local vallab : value label `v'
            local lab : variable label `v'
            local safe_lab = subinstr(`"`lab'"', char(34), char(39), .)
            post `vinv' ("`source_id'") ("`wave'") ("`path'") ("`f'") ("`v'") ("`storage'") ("`fmt'") ("`vallab'") ("`safe_lab'") (`N') (`K') ("readable") ("")
        }
    }
}

postclose `vinv'
use "`variables'", clear
sort wave file_path raw_name
save "`output'/diagnostics/variable_inventory.dta", replace
export delimited using "`output'/diagnostics/variable_inventory.csv", replace

count
local rows = r(N)
quietly count if read_status == "readable"
local readable_rows = r(N)
quietly count if read_status == "unreadable"
local unreadable_rows = r(N)
display as result "VARIABLE_INVENTORY_ROWS=`rows'"
display as result "VARIABLE_INVENTORY_READABLE_ROWS=`readable_rows'"
display as result "VARIABLE_INVENTORY_UNREADABLE_ROWS=`unreadable_rows'"
display as result "VARIABLE_INVENTORY_PASS"
log close
exit 0
