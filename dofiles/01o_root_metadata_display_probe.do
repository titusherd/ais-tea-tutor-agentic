version 16.0
clear all
set more off
local roots "/Users/titus/Documents/ais-tea/00_raw/wave1_hh93 /Users/titus/Documents/ais-tea/00_raw/wave1_cf93"
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
    display as text "ROOT=`root' WAVE=`wave' SOURCE=`source_id' ARCHIVE=`archive' AREA=`module_area'"
}
exit 0
