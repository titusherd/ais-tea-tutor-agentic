version 16.0
clear all
set more off
local project = c(pwd)
local raw "`project'/00_raw"
local roots "`raw'/wave1_hh93 `raw'/wave1_cf93"
foreach root of local roots {
    local files : dir "`root'" files "*.dta"
    local nfiles : word count `files'
    display as text "ROOT=`root' FILES=`nfiles'"
}
exit 0
