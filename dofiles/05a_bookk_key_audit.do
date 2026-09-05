version 16.0
clear all
set more off

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/05a_bookk_key_audit.log", text replace
display as text "BOOKK_KEY_AUDIT_START=" c(current_date) " " c(current_time)

local files "`raw'/wave1_hh93/bukkar2.dta `raw'/wave2_hh97/bk_ar1.dta `raw'/wave3_hh00/bk_ar1.dta `raw'/wave4_hh07/bk_ar1.dta `raw'/wave5_hh14/bk_ar1.dta"
foreach path of local files {
    display as result "=== FILE `path' ==="
    use "`path'", clear
    describe, short
    lookfor hhid pid person pidlink relation father mother age sex birth member live interview
    describe
    local keyvar ""
    if strpos("`path'", "wave1") local keyvar "hhid93 pid93"
    if strpos("`path'", "wave2") local keyvar "hhid97 pid97"
    if strpos("`path'", "wave3") local keyvar "hhid00 pid00"
    if strpos("`path'", "wave4") local keyvar "hhid07 pid07"
    if strpos("`path'", "wave5") local keyvar "hhid14 pid14"
    display as text "CANDIDATE_KEY=`keyvar'"
    capture isid `keyvar'
    if _rc == 0 {
        display as result "ISID_CANDIDATE_KEY_PASS"
    }
    else {
        display as error "ISID_CANDIDATE_KEY_FAIL_RC=" _rc
        duplicates report `keyvar'
    }
    capture isid pidlink
    if _rc == 0 display as result "ISID_PIDLINK_PASS"
    else display as error "ISID_PIDLINK_FAIL_RC=" _rc
}

display as result "BOOKK_KEY_AUDIT_PASS"
log close
exit 0
