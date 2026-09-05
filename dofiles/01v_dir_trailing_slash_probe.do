version 16.0
clear all
set more off
local raw "/Users/titus/Documents/ais-tea/00_raw"
local roots ///
    "`raw'/wave1_hh93" ///
    "`raw'/wave1_cf93"
foreach root of local roots {
    display as text "TRY root=`root'"
    local files : dir "`root'/" files "*.dta"
    local nfiles : word count `files'
    display as text "FILES=`nfiles'"
}
exit 0
