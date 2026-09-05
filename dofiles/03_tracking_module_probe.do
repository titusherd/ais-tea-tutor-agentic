version 16.0
clear all
set more off

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/03_tracking_module_probe.log", text replace
display as text "TRACKING_PROBE_START=" c(current_date) " " c(current_time)

local files "`raw'/wave2_hh97/ptrack.dta `raw'/wave2_hh97/htrack.dta `raw'/wave3_hh00/ptrack.dta `raw'/wave3_hh00/htrack.dta `raw'/wave4_hh07/ptrack.dta `raw'/wave4_hh07/htrack.dta `raw'/wave5_hh14/ptrack.dta `raw'/wave5_hh14/htrack.dta"
foreach path of local files {
    display as result "=== FILE `path' ==="
    use "`path'", clear
    describe, short
    lookfor pid hhid member age sex weight ar01 relation mover result interview date birth
    describe
}

display as result "TRACKING_PROBE_PASS"
log close
exit 0
