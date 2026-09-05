version 16.0
clear all
set more off

local project = c(pwd)
local raw "`project'/00_raw"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/03a_tracking_key_audit.log", text replace
display as text "TRACKING_KEY_AUDIT_START=" c(current_date) " " c(current_time)

local person_files "`raw'/wave2_hh97/ptrack.dta `raw'/wave3_hh00/ptrack.dta `raw'/wave4_hh07/ptrack.dta `raw'/wave5_hh14/ptrack.dta"
foreach path of local person_files {
    display as result "=== PERSON FILE `path' ==="
    use "`path'", clear
    count
    local N = r(N)
    count if missing(pidlink)
    display as text "MISSING_PIDLINK=" r(N)
    capture isid pidlink
    if _rc == 0 {
        display as result "ISID_PIDLINK_PASS"
    }
    else {
        display as error "ISID_PIDLINK_FAIL_RC=" _rc
        duplicates report pidlink
    }
    capture summarize age_* bth_* bg_dob, detail
    capture tab member93, missing
    capture tab member97, missing
    capture tab member00, missing
    capture tab member07, missing
    capture tab member14, missing
    capture tab ar01a_97, missing
    capture tab ar01a_00, missing
    capture tab ar01a_07, missing
    capture tab ar01a_14, missing
}

local household_files "`raw'/wave2_hh97/htrack.dta `raw'/wave3_hh00/htrack.dta `raw'/wave4_hh07/htrack.dta `raw'/wave5_hh14/htrack.dta"
foreach path of local household_files {
    display as result "=== HOUSEHOLD FILE `path' ==="
    use "`path'", clear
    count
    local N = r(N)
    local hhidvar ""
    if strpos("`path'", "wave2") local hhidvar "hhid97"
    if strpos("`path'", "wave3") local hhidvar "hhid00"
    if strpos("`path'", "wave4") local hhidvar "hhid07"
    if strpos("`path'", "wave5") local hhidvar "hhid14"
    display as text "CURRENT_HHID=`hhidvar'"
    capture isid `hhidvar'
    if _rc == 0 {
        display as result "ISID_CURRENT_HHID_PASS"
    }
    else {
        display as error "ISID_CURRENT_HHID_FAIL_RC=" _rc
        duplicates report `hhidvar'
    }
    count if missing(`hhidvar')
    display as text "MISSING_CURRENT_HHID=" r(N)
}

display as result "TRACKING_KEY_AUDIT_PASS"
log close
exit 0
