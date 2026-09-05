version 16.0
clear all
set more off
local path "/Users/titus/Documents/ais-tea/00_raw/wave1_hh93/buk3mg1.dta"
log using "/Users/titus/Documents/ais-tea/04_output/logs/01a_wave1_path_probe.log", text replace
capture confirm file "`path'"
display as text "CONFIRM_RC=" _rc
use "`path'", clear
display as text "USE_RC=" _rc
count
describe, short
log close
exit 0
