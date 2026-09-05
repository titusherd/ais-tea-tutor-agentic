version 16.0
clear all
set more off
local root "/Users/titus/Documents/ais-tea/00_raw/wave1_hh93"
local files : dir "`root'" files "*.dta"
local nfiles : word count `files'
display as text "ROOT=`root' FILES=`nfiles'"
exit 0
