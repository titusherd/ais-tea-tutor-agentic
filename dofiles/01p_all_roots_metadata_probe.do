version 16.0
clear all
set more off
local project = c(pwd)
local raw "`project'/00_raw"
local roots "`raw'/wave1_hh93 `raw'/wave1_cf93 `raw'/wave2_hh97 `raw'/wave2_cf97 `raw'/wave3_hh00 `raw'/wave3_cf00 `raw'/wave4_hh07 `raw'/wave4_cf07 `raw'/wave5_hh14 `raw'/wave5_cf14"
foreach root of local roots {
    local wave "unknown"
    local source_id "unknown"
    local archive "unknown"
    local module_area "household_or_community"
    if strpos("`root'", "/wave1_hh") {
        local wave "1993"
        local source_id "IFLS1-HH"
        local archive "IFLS/hh93dta.zip"
        local module_area "household"
    }
    if strpos("`root'", "/wave5_hh") {
        local wave "2014"
        local source_id "IFLS5-HH"
        local archive "IFLS/IFLS 5/hh14_all_dta (1).zip"
        local module_area "household"
    }
    display as text "ROOT=`root' WAVE=`wave' SOURCE=`source_id' ARCHIVE=`archive' AREA=`module_area'"
}
exit 0
