version 16.0
clear all
set more off
local project = c(pwd)
local raw "`project'/00_raw"
local roots ///
    "`raw'/wave1_hh93" ///
    "`raw'/wave1_cf93" ///
    "`raw'/wave2_hh97" ///
    "`raw'/wave2_cf97" ///
    "`raw'/wave3_hh00" ///
    "`raw'/wave3_cf00" ///
    "`raw'/wave4_hh07" ///
    "`raw'/wave4_cf07" ///
    "`raw'/wave5_hh14" ///
    "`raw'/wave5_cf14"
foreach root of local roots {
    display as text "ROOT=`root'"
}
exit 0
