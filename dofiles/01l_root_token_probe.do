version 16.0
clear all
set more off
local raw "/Users/titus/Documents/ais-tea/00_raw"
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
