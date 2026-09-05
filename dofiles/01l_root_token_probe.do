version 16.0
clear all
set more off
local project = c(pwd)
local raw "`project'/00_raw"
local roots ///
    "`raw'/wave1_hh93" ///
    "`raw'/wave1_cf93" ///
    "`raw'/wave2_hh97"
foreach root of local roots {
    display as text "BEGIN"
    display as text "ROOT=`root'"
    display as text "END"
}
exit 0
