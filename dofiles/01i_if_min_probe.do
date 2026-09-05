version 16.0
clear all
set more off
local project = c(pwd)
local root "`project'/00_raw/wave1_hh93"
local wave "unknown"
if strpos("`root'", "/wave1_hh") {
    local wave "1993"
}
display as text "ROOT=`root' WAVE=`wave'"
exit 0
