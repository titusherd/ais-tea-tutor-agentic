version 16.0
clear all
set more off

local project = c(pwd)
local raw "`project'/00_raw"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/03c_birth_date_probe.log", text replace
display as text "BIRTH_DATE_PROBE_START=" c(current_date) " " c(current_time)
use "`raw'/wave5_hh14/ptrack.dta", clear
summarize bg_dob bth_year bth_month bth_day age_14, detail
list pidlink bg_dob bth_year bth_month bth_day age_14 in 1/20, noobs
format bg_dob %td
display as text "BG_DOB_AS_STATA_DATE"
list pidlink bg_dob bth_year bth_month bth_day age_14 in 1/20, noobs
display as result "BIRTH_DATE_PROBE_PASS"
log close
exit 0
