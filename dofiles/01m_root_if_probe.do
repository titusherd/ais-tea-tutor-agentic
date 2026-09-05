version 16.0
clear all
set more off
local roots "/Users/titus/Documents/ais-tea/00_raw/wave1_hh93 /Users/titus/Documents/ais-tea/00_raw/wave1_cf93"
foreach root of local roots {
    display as text "BEGIN root=`root'"
    local wave "unknown"
    if strpos("`root'", "/wave1_hh") {
        local wave "1993"
    }
    display as text "WAVE=`wave'"
}
exit 0
