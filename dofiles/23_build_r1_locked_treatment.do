version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local raw "`project'/00_raw"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/23_build_r1_locked_treatment.log", text replace
display as text "R1_LOCKED_TREATMENT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SPEC_LOCK_ID=R1-MAIN-D010-D011-D012-D030-D031-D032-D033-D040-D041-D042"
display as text "NOTE=mother-led international work migration after W1; unresolved and incompatible exposure states are excluded"

* Only wave-specific country values supported by the local evidence are
* promoted. W2: 0 Indonesia, 91 Other country. W3: 0 Indonesia, 99 with
* MG21EX=1 as foreign. W4: 100 Indonesia, 101-154 named foreign codes.
* W5: 62 Indonesia when MG21EX is given/same current residence. W5
* non-Indonesia candidates remain unresolved because the local text does not
* provide a complete mapping for codes 90/96/98.
tempfile ev2 ev3 ev4 ev5 parent_screen child_base child_wave event_child event_child_agg

forvalues w = 2/5 {
    local yr = cond(`w' == 2, 1997, cond(`w' == 3, 2000, cond(`w' == 4, 2007, 2014)))
    local folder = cond(`w' == 2, "wave2_hh97", cond(`w' == 3, "wave3_hh00", cond(`w' == 4, "wave4_hh07", "wave5_hh14")))

    use "`raw'/`folder'/b3a_mg2.dta", clear
    keep pidlink movenum mg21e mg21ex mg28 mg34 mg24yr mg25 mg39
    gen byte event_wave = `w'
    gen int event_year = `yr'
    sort pidlink movenum mg24yr
    by pidlink: gen int event_row = _n
    gen byte event_observed = 1

    gen byte reason_status = 2
    replace reason_status = 1 if mg28 == 1
    replace reason_status = 0 if mg28 >= 2 & mg28 <= 95 & !inlist(mg28, 98, 99)

    gen byte timing_status = 2
    replace timing_status = 1 if inrange(mg24yr, 1994, `yr' + 1)
    replace timing_status = 0 if !missing(mg24yr) & mg24yr >= 1900 & mg24yr < 1994

    gen byte country_status = 2
    if `w' == 2 {
        replace country_status = 0 if mg21e == 0
        replace country_status = 1 if mg21e == 91
    }
    if `w' == 3 {
        replace country_status = 0 if mg21e == 0
        replace country_status = 1 if mg21e == 99 & mg21ex == 1
    }
    if `w' == 4 {
        replace country_status = 0 if mg21e == 100
        replace country_status = 1 if inrange(mg21e, 101, 154) & mg21ex == 1
    }
    if `w' == 5 {
        replace country_status = 0 if mg21e == 62 & inlist(mg21ex, 1, 3)
    }

    gen byte together_status = 2
    replace together_status = 0 if mg34 == 3
    replace together_status = 1 if mg34 == 1

    gen byte possible_postw1_exposure = reason_status == 1 & ///
        country_status != 0 & timing_status != 0
    gen byte raw_event_postw1 = timing_status != 0
    save "`ev`w''", replace
}

use "`ev2'", clear
append using "`ev3'"
append using "`ev4'"
append using "`ev5'"
sort pidlink event_wave movenum event_row
rename pidlink mother_pidlink
isid mother_pidlink event_wave event_row
save "`output'/diagnostics/r1_migration_event_evidence.dta", replace
export delimited using "`output'/diagnostics/r1_migration_event_evidence.csv", replace

use "`output'/diagnostics/r1_child_parent_link_audit.dta", clear
keep if wave == 1 & cohort_0_12 == 1
keep pidlink child_spine_hhid age_at_interview birth_date sex ///
    mother_pidlink father_pidlink baseline_parent_link_status ///
    source_hh_ambiguous w5_roster_tracked w5_hhid w5_present_roster
rename pidlink child_pidlink
isid child_pidlink
gen byte baseline_clean = baseline_parent_link_status == "both_parent_links" & ///
    source_hh_ambiguous == 0 & w5_roster_tracked == 1 & ///
    !missing(child_spine_hhid) & !missing(mother_pidlink) & !missing(father_pidlink)
rename child_spine_hhid origin_hhid
save "`child_base'", replace

use "`derived'/r1_parent_migration_evidence.dta", clear
keep if wave >= 2
gen byte postw1_screen_observed = mg1_screen_nonmissing == 1
gen byte postw1_event_observed = mg2_pidlink_match == 1 & mg2_event_records > 0
replace postw1_screen_observed = 0 if missing(postw1_screen_observed)
replace postw1_event_observed = 0 if missing(postw1_event_observed)
collapse (max) postw1_screen_observed postw1_event_observed, by(pidlink)
rename pidlink mother_pidlink
gen byte mother_postw1_observed = postw1_screen_observed | postw1_event_observed
isid mother_pidlink
save "`parent_screen'", replace

use "`output'/diagnostics/r1_migration_event_evidence.dta", clear
joinby mother_pidlink using "`child_base'", unmatched(none)

preserve
use "`derived'/person_spine.dta", clear
keep pidlink wave hhid_wave present_roster
rename pidlink child_pidlink
rename wave event_wave
rename hhid_wave child_event_hhid
rename present_roster child_event_present
isid child_pidlink event_wave
save "`child_wave'", replace
restore

merge m:1 child_pidlink event_wave using "`child_wave'", keep(1 3) gen(_child_wave_merge)
gen byte child_event_observed = _child_wave_merge == 3
replace child_event_observed = 0 if missing(child_event_observed)
drop _child_wave_merge
gen byte child_remains_origin = child_event_observed == 1 & ///
    child_event_present == 1 & !missing(child_event_hhid) & ///
    child_event_hhid == origin_hhid

gen byte event_incompatible = possible_postw1_exposure == 1 & ///
    (together_status == 1 | ///
     (child_event_observed == 1 & child_event_present == 1 & ///
      !missing(child_event_hhid) & child_event_hhid != origin_hhid))
gen byte event_unresolved = possible_postw1_exposure == 1 & ///
    event_incompatible == 0 & ///
    (country_status == 2 | timing_status == 2 | together_status == 2 | ///
     child_event_observed == 0 | child_event_present != 1 | ///
     missing(child_event_hhid))
gen byte event_qualifying = possible_postw1_exposure == 1 & ///
    reason_status == 1 & country_status == 1 & timing_status == 1 & ///
    together_status == 0 & child_remains_origin == 1 & ///
    event_incompatible == 0 & event_unresolved == 0
gen int qualifying_wave = event_wave if event_qualifying == 1
gen int qualifying_year = event_year if event_qualifying == 1
gen byte event_possible_or_qualifying = possible_postw1_exposure
sort child_pidlink event_wave mother_pidlink movenum event_row
save "`event_child'", replace
export delimited using "`output'/diagnostics/r1_child_migration_event_linkage.csv", replace

preserve
collapse (max) any_possible_exposure=event_possible_or_qualifying ///
    any_qualifying_exposure=event_qualifying ///
    any_incompatible_exposure=event_incompatible ///
    any_unresolved_exposure=event_unresolved ///
    (sum) possible_event_count=event_possible_or_qualifying ///
    qualifying_event_count=event_qualifying ///
    incompatible_event_count=event_incompatible ///
    unresolved_event_count=event_unresolved ///
    (min) first_qualifying_wave=qualifying_wave first_qualifying_year=qualifying_year, ///
    by(child_pidlink)
isid child_pidlink
save "`event_child_agg'", replace
restore

use "`child_base'", clear
merge 1:1 child_pidlink using "`event_child_agg'", keep(1 3) gen(_event_agg_merge)
foreach v in any_possible_exposure any_qualifying_exposure ///
    any_incompatible_exposure any_unresolved_exposure possible_event_count ///
    qualifying_event_count incompatible_event_count unresolved_event_count {
    replace `v' = 0 if missing(`v')
}
drop _event_agg_merge
merge m:1 mother_pidlink using "`parent_screen'", keep(1 3) gen(_mother_obs_merge)
replace mother_postw1_observed = 0 if missing(mother_postw1_observed)
replace postw1_screen_observed = 0 if missing(postw1_screen_observed)
replace postw1_event_observed = 0 if missing(postw1_event_observed)
drop _mother_obs_merge

gen str32 r1_status = "outside_primary_frame"
replace r1_status = "baseline_excluded" if baseline_clean == 0
replace r1_status = "unresolved_exposure" if baseline_clean == 1 & ///
    mother_postw1_observed == 0
replace r1_status = "incompatible_exposure" if baseline_clean == 1 & ///
    any_incompatible_exposure == 1
replace r1_status = "unresolved_exposure" if baseline_clean == 1 & ///
    any_incompatible_exposure == 0 & any_unresolved_exposure == 1
replace r1_status = "treated" if baseline_clean == 1 & ///
    mother_postw1_observed == 1 & any_qualifying_exposure == 1 & ///
    any_incompatible_exposure == 0 & any_unresolved_exposure == 0
replace r1_status = "control" if baseline_clean == 1 & ///
    mother_postw1_observed == 1 & any_possible_exposure == 0
gen byte r1_treatment = .
replace r1_treatment = 1 if r1_status == "treated"
replace r1_treatment = 0 if r1_status == "control"
gen byte r1_primary_eligible = inlist(r1_status, "treated", "control")
gen byte r1_primary_frame = baseline_clean == 1

label define r1status 0 "control" 1 "treated", replace
label values r1_treatment r1status
order child_pidlink origin_hhid mother_pidlink father_pidlink r1_status ///
    r1_treatment r1_primary_eligible r1_primary_frame
sort child_pidlink
isid child_pidlink
save "`derived'/r1_mother_international_treatment.dta", replace
export delimited using "`output'/diagnostics/r1_mother_international_treatment.csv", replace

tempname sf
postfile `sf' str120 stage long N using "`output'/diagnostics/r1_treatment_sample_flow.dta", replace
count
post `sf' ("W1 child cohort age 0-12") (r(N))
count if baseline_clean == 1
post `sf' ("Both parents linked; clean origin; W5 tracked") (r(N))
count if baseline_clean == 1 & mother_postw1_observed == 1
post `sf' ("Mother post-W1 migration evidence observed") (r(N))
count if r1_status == "treated"
post `sf' ("Primary treated: verified mother-led international work") (r(N))
count if r1_status == "control"
post `sf' ("Primary control: observed no qualifying exposure") (r(N))
count if r1_status == "incompatible_exposure"
post `sf' ("Excluded: incompatible origin-child exposure evidence") (r(N))
count if r1_status == "unresolved_exposure"
post `sf' ("Excluded: unresolved exposure evidence") (r(N))
count if r1_primary_eligible == 1
post `sf' ("Primary R1 analysis frame") (r(N))
postclose `sf'
use "`output'/diagnostics/r1_treatment_sample_flow.dta", clear
export delimited using "`output'/diagnostics/r1_treatment_sample_flow.csv", replace

use "`derived'/r1_mother_international_treatment.dta", clear
contract r1_status
rename _freq N
sort r1_status
save "`output'/diagnostics/r1_treatment_status_summary.dta", replace
export delimited using "`output'/diagnostics/r1_treatment_status_summary.csv", replace

use "`output'/diagnostics/r1_migration_event_evidence.dta", clear
contract event_wave country_status reason_status timing_status together_status
rename _freq N
save "`output'/diagnostics/r1_event_code_status_summary.dta", replace
export delimited using "`output'/diagnostics/r1_event_code_status_summary.csv", replace

display as result "R1_LOCKED_TREATMENT_PASS"
display as result "R1_LOCKED_TREATMENT_NOTE=country codes are promoted only where wave-specific evidence supports the mapping; unresolved is excluded"
log close
exit 0
