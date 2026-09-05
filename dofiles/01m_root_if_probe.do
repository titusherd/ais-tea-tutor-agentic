version 16.0
clear all
set more off
local project = c(pwd)
local raw "`project'/00_raw"
local roots "`raw'/wave1_hh93 `raw'/wave1_cf93"
foreach root of local roots {
    display as text "BEGIN root=`root'"
    local wave "unknown"
    if strpos("`root'", "/wave1_hh") {
        local wave "1993"
    }
    display as text "WAVE=`wave'"
}
exit 0
