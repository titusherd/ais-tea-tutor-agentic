version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local logdir "`project'/04_output/logs"
local docdir "`project'/99_docs"

log using "`logdir'/00_stata_environment_probe.log", text replace

display as text "PROJECT_ROOT=`project'"
display as text "RUN_DATE=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "STATA_EDITION=" c(flavor)
display as text "STATA_SE_FLAG=" c(SE)
display as text "STATA_MP_FLAG=" c(MP)
display as text "OS=" c(os)
display as text "SEED=9042026"
about

local run_date "`c(current_date)'"
local run_time "`c(current_time)'"
local stata_version "`c(stata_version)'"
local stata_edition "`c(flavor)'"
local stata_se_flag "`c(SE)'"
local stata_mp_flag "`c(MP)'"
local operating_system "`c(os)'"

file open env using "`docdir'/software_environment.txt", write replace
file write env "Project root: `project'" _n
file write env "Run date: `run_date' `run_time'" _n
file write env "Stata version: `stata_version'" _n
file write env "Stata edition: `stata_edition'" _n
file write env "Stata SE flag: `stata_se_flag'" _n
file write env "Stata MP flag: `stata_mp_flag'" _n
file write env "Operating system: `operating_system'" _n
file write env "Seed: 9042026" _n
file write env "Executable: /Applications/Stata/StataSE.app/Contents/MacOS/stata-se" _n
file write env "User-written packages: inventory pending" _n
file close env

log close
exit 0
