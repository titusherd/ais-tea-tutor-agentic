version 16.0
clear all
set more off

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/04_household_tracking_probe.log", text replace
display as text "HOUSEHOLD_TRACKING_PROBE_START=" c(current_date) " " c(current_time)

local files "`raw'/wave2_hh97/htrack.dta `raw'/wave3_hh00/htrack.dta `raw'/wave4_hh07/htrack.dta `raw'/wave5_hh14/htrack.dta"
foreach path of local files {
    display as result "=== FILE `path' ==="
    use "`path'", clear
    describe, short
    capture ds hhid* pidlink pid* splitoff* mover* hwt* commid*
    if _rc == 0 display as text "TRACK_VARS=`r(varlist)'"
    capture list hhid93 hhid97 hhid00 hhid07 hhid14 pidlink pid14 splitoff97 splitoff00 splitoff07 splitoff14 in 1/12, noobs
    if strpos("`path'", "wave5") {
        count if missing(hhid14)
        display as text "MISSING_HHID14_ROWS=" r(N)
        list hhid93 hhid97 hhid00 hhid07 hhid14 pidlink pid14 splitoff97 splitoff00 splitoff07 splitoff14 if missing(hhid14) in 1/40, noobs
    }
}

display as result "HOUSEHOLD_TRACKING_PROBE_PASS"
log close
exit 0
