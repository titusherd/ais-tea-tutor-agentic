version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/15a_adult_outcome_label_search.log", text replace
display as text "ADULT_OUTCOME_LABEL_SEARCH_START=" c(current_date) " " c(current_time)

use "`output'/diagnostics/variable_inventory.dta", clear
keep if inlist(real(wave), 1997, 2000, 2007, 2014)
gen str24 domain = ""
replace domain = "earnings_employment" if regexm(lower(variable_label), "wage|salary|earnings|income|employed|employment|job|work status|main activity|formal|employee|self.?employed|business owner")
replace domain = "health" if regexm(lower(variable_label), "generally how is your health|health status|self.?reported health|depress|sadness|lonely|anxiety|sleep|chronic|diagnos|blood pressure|height|weight|body mass|bmi|morbidity|illness")
replace domain = "education" if regexm(lower(variable_label), "highest level|highest grade|education|schooling|school attended|grade completed|years.*school|school.*years")
replace domain = "cognition" if regexm(lower(variable_label), "word recall|serial|cognitive|raven|memory|concentrat|reasoning|math score|language score")
replace domain = "smoking" if regexm(lower(variable_label), "smok|tobacco|cigarette")
replace domain = "marriage" if regexm(lower(variable_label), "marri|cohabit|spouse|age.*married|marital")
replace domain = "trust" if regexm(lower(variable_label), "trust|confidence.*people|most people")
keep if domain != ""
sort domain wave file_name raw_name
save "`output'/diagnostics/adult_outcome_label_hits.dta", replace
export delimited using "`output'/diagnostics/adult_outcome_label_hits.csv", replace

display as result "ADULT_OUTCOME_LABEL_HITS=" _N
display as result "ADULT_OUTCOME_LABEL_SEARCH_PASS"
log close
exit 0
