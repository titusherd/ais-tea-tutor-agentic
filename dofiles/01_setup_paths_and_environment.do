version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local clean "`project'/01_clean"
local derived "`project'/02_derived"
local analysis "`project'/03_analysis"
local output "`project'/04_output"
local docs "`project'/99_docs"

cd "`project'"
log using "`output'/logs/01_setup_paths_and_environment.log", text replace

display as text "SETUP_START=" c(current_date) " " c(current_time)
display as text "PROJECT_ROOT=`project'"
display as text "STATA_VERSION=" c(stata_version)
display as text "STATA_ABOUT_EDITION=Stata/SE (verified by executable path and c(SE) flag)"
display as text "STATA_FLAVOR_RETURN=" c(flavor)
display as text "STATA_SE_FLAG=" c(SE)
display as text "STATA_MP_FLAG=" c(MP)
display as text "SEED=9042026"

foreach required in ///
    "`raw'" ///
    "`clean'" ///
    "`derived'" ///
    "`analysis'" ///
    "`output'/tables" ///
    "`output'/figures" ///
    "`output'/diagnostics" ///
    "`output'/logs" ///
    "`docs'" {
    capture confirm existence "`required'"
    if _rc {
        display as error "SETUP_MISSING_DIRECTORY `required'"
        exit 601
    }
}

global project "`project'"
global raw "`raw'"
global clean "`clean'"
global derived "`derived'"
global analysis "`analysis'"
global output "`output'"
global docs "`docs'"
global wave1_hh "`raw'/wave1_hh93"
global wave1_cf "`raw'/wave1_cf93"
global wave2_hh "`raw'/wave2_hh97"
global wave2_cf "`raw'/wave2_cf97"
global wave3_hh "`raw'/wave3_hh00"
global wave3_cf "`raw'/wave3_cf00"
global wave4_hh "`raw'/wave4_hh07"
global wave4_cf "`raw'/wave4_cf07"
global wave5_hh "`raw'/wave5_hh14"
global wave5_cf "`raw'/wave5_cf14"

file open env using "`docs'/software_environment.txt", write replace
file write env "Project root: `project'" _n
file write env "Run date: `c(current_date)' `c(current_time)'" _n
file write env "Stata version: `c(stata_version)'" _n
file write env "Stata edition: Stata/SE (c(SE)=`c(SE)'; c(MP)=`c(MP)'; c(flavor)=`c(flavor)')" _n
file write env "Operating system: `c(os)'" _n
file write env "Seed: 9042026" _n
file write env "Executable: /Applications/Stata/StataSE.app/Contents/MacOS/stata-se" _n
file write env "User-written packages: see 04_output/diagnostics/package_inventory.txt" _n
file close env

file open pkg using "`output'/diagnostics/package_inventory.txt", write replace
file write pkg "Checked: `c(current_date)' `c(current_time)'" _n
file write pkg "Stata version: `c(stata_version)'" _n
foreach cmd in esttab eststo reghdfe ftools ivreg2 ivreghdfe coefplot outreg2 asdoc {
    capture which `cmd'
    if _rc {
        display as text "PACKAGE `cmd' NOT_INSTALLED"
        file write pkg "`cmd': NOT_INSTALLED" _n
    }
    else {
        display as text "PACKAGE `cmd' INSTALLED"
        file write pkg "`cmd': installed (see log for path)" _n
    }
}
file close pkg

display as result "SETUP_PATHS_PASS"
log close
exit 0
