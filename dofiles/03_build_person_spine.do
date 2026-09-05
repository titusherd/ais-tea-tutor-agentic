version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/03_build_person_spine.log", text replace
display as text "PERSON_SPINE_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

use "`raw'/wave5_hh14/ptrack.dta", clear
count
local raw_rows = r(N)
count if missing(pidlink)
if r(N) > 0 {
    display as error "STOP_MISSING_PIDLINK_ROWS=" r(N)
    exit 459
}

sort pidlink
duplicates tag, generate(exact_duplicate)
by pidlink: gen pidlink_rows_raw = _N
preserve
keep if exact_duplicate > 0 | pidlink_rows_raw > 1
save "`output'/diagnostics/person_spine_raw_duplicate_cases.dta", replace
export delimited using "`output'/diagnostics/person_spine_raw_duplicate_cases.csv", replace
restore

count if exact_duplicate > 0
local exact_duplicate_rows_tagged = r(N)
display as text "EXACT_DUPLICATE_ROWS_TAGGED=`exact_duplicate_rows_tagged'"
duplicates drop
count
local dedup_rows = r(N)
local exact_duplicate_rows_removed = `raw_rows' - `dedup_rows'
display as text "PTRACK14_RAW_ROWS=`raw_rows'"
display as text "PTRACK14_ROWS_AFTER_EXACT_DEDUP=`dedup_rows'"
display as text "EXACT_DUPLICATE_ROWS_REMOVED=`exact_duplicate_rows_removed'"

by pidlink: gen pidlink_rows_after_exact = _N
gen byte person_wave_ambiguous_14 = pidlink_rows_after_exact > 1
egen byte ambiguous_pidlink_tag = tag(pidlink) if person_wave_ambiguous_14 == 1
count if ambiguous_pidlink_tag == 1
local ambiguous_pidlink_cases = r(N)
count if person_wave_ambiguous_14 == 1
display as text "AMBIGUOUS_PIDLINK_CASES=`ambiguous_pidlink_cases'"
display as text "AMBIGUOUS_PIDLINK_ROWS=" r(N)

sort pidlink
by pidlink: gen byte keep_one_person_row = (_n == 1)
keep if keep_one_person_row == 1

* Create one person x wave row from the official PTRACK14 person-level file.
expand 5
sort pidlink
by pidlink: gen byte wave_slot = _n
gen byte wave = wave_slot
gen int survey_year = .
replace survey_year = 1993 if wave == 1
replace survey_year = 1997 if wave == 2
replace survey_year = 2000 if wave == 3
replace survey_year = 2007 if wave == 4
replace survey_year = 2014 if wave == 5

gen str10 hhid_wave = ""
replace hhid_wave = hhid93 if wave == 1
replace hhid_wave = hhid97 if wave == 2
replace hhid_wave = hhid00 if wave == 3
replace hhid_wave = hhid07 if wave == 4
replace hhid_wave = hhid14 if wave == 5

gen double pid_wave = .
replace pid_wave = pid93 if wave == 1
replace pid_wave = pid97 if wave == 2
replace pid_wave = pid00 if wave == 3
replace pid_wave = pid07 if wave == 4
replace pid_wave = pid14 if wave == 5

gen byte present_roster = .
replace present_roster = 1 if wave == 1 & member93 == 1
replace present_roster = 0 if wave == 1 & member93 == 0
replace present_roster = 1 if wave == 2 & member97 == 1
replace present_roster = 0 if wave == 2 & member97 == 0
replace present_roster = 1 if wave == 3 & member00 == 1
replace present_roster = 0 if wave == 3 & member00 == 0
replace present_roster = 1 if wave == 4 & member07 == 1
replace present_roster = 0 if wave == 4 & member07 == 0
replace present_roster = 1 if wave == 5 & member14 == 1
replace present_roster = 0 if wave == 5 & member14 == 0

gen double roster_status = .
replace roster_status = ar01a_97 if wave == 2
replace roster_status = ar01a_00 if wave == 3
replace roster_status = ar01a_07 if wave == 4
replace roster_status = ar01a_14 if wave == 5

gen double tracking_status = .
replace tracking_status = ar01b_97 if wave == 2
replace tracking_status = ar01b_00 if wave == 3
replace tracking_status = ar01b_07 if wave == 4
replace tracking_status = ar01b_14 if wave == 5

gen double interview_status = .
replace interview_status = ar01i_00 if wave == 3
replace interview_status = ar01i_07 if wave == 4
replace interview_status = ar01i_14 if wave == 5

gen double relation_to_krt = .
replace relation_to_krt = ar02_93 if wave == 1
replace relation_to_krt = ar02_97 if wave == 2
replace relation_to_krt = ar02b_00 if wave == 3
replace relation_to_krt = ar02b_07 if wave == 4
replace relation_to_krt = ar02b_14 if wave == 5

gen double age_at_interview = .
replace age_at_interview = age_93 if wave == 1
replace age_at_interview = age_97 if wave == 2
replace age_at_interview = age_00 if wave == 3
replace age_at_interview = age_07 if wave == 4
replace age_at_interview = age_14 if wave == 5

gen double birth_date = bg_dob
format birth_date %td
gen byte birth_date_available = !missing(birth_date)
gen str40 birth_date_source = "PTRACK14.bg_dob constructed"
replace birth_date_source = "missing in PTRACK14" if missing(birth_date)
gen byte interview_date_available = 0
gen str40 interview_date_source = "not available in PTRACK14"
gen double interview_date = .
format interview_date %td

gen byte person_wave_ambiguous = person_wave_ambiguous_14 if wave == 5
replace person_wave_ambiguous = 0 if wave < 5
gen str18 household_resolution_status = "unique"
replace household_resolution_status = "ambiguous" if person_wave_ambiguous == 1
gen long source_ptrack14_rows = pidlink_rows_after_exact

* Exact duplicates are removed; non-identical multi-household rows remain in diagnostics.
replace hhid_wave = "" if person_wave_ambiguous == 1 & wave == 5
replace pid_wave = . if person_wave_ambiguous == 1 & wave == 5
replace relation_to_krt = . if person_wave_ambiguous == 1 & wave == 5

gen str10 origin_hh = hhid93
gen str28 origin_hh_status = "ptrack_hhid93_available"
replace origin_hh_status = "missing_for_new_or_unlinked" if missing(origin_hh)
order pidlink wave survey_year hhid_wave pid_wave origin_hh origin_hh_status birth_date sex age_at_interview present_roster roster_status tracking_status interview_status relation_to_krt, first

drop exact_duplicate pidlink_rows_raw pidlink_rows_after_exact ambiguous_pidlink_tag keep_one_person_row wave_slot

keep pidlink wave survey_year hhid_wave pid_wave origin_hh origin_hh_status birth_date birth_date_available birth_date_source interview_date interview_date_available interview_date_source sex age_at_interview present_roster roster_status tracking_status interview_status relation_to_krt person_wave_ambiguous household_resolution_status source_ptrack14_rows
label variable pidlink "IFLS person identifier constant across waves"
label variable wave "IFLS wave number: 1=1993, 2=1997, 3=2000, 4=2007, 5=2014"
label variable survey_year "IFLS survey year"
label variable hhid_wave "Wave-specific household identifier"
label variable pid_wave "Wave-specific person identifier"
label variable origin_hh "1993 household identifier when available"
label variable origin_hh_status "Status of origin household mapping"
label variable birth_date "Constructed date of birth from PTRACK14 bg_dob"
label variable interview_date "Interview date; not populated from PTRACK14"
label variable sex "Best-guess sex from PTRACK14"
label variable age_at_interview "Constructed age supplied by PTRACK14"
label variable present_roster "Current resident/member flag supplied by PTRACK14"
label variable roster_status "Wave roster status from AR01A where available"
label variable tracking_status "Wave tracking status from AR01B where available"
label variable interview_status "Wave interview status from AR01I where available"
label variable relation_to_krt "Relation to household head"
label variable person_wave_ambiguous "2014 household assignment is ambiguous"
label variable household_resolution_status "Household assignment resolution status"
label variable source_ptrack14_rows "PTRACK14 rows retained before person-wave resolution"

isid pidlink wave
count
local final_rows = r(N)
count if person_wave_ambiguous == 1
local final_ambiguous_rows = r(N)
display as result "PERSON_SPINE_ROWS=`final_rows'"
display as result "PERSON_SPINE_AMBIGUOUS_ROWS=`final_ambiguous_rows'"

save "`derived'/person_spine.dta", replace

gen byte hhid_available = !missing(hhid_wave)
gen byte age_available = !missing(age_at_interview)
gen byte birth_date_available_copy = birth_date_available
gen byte one_spine_row = 1
preserve
collapse (sum) spine_rows=one_spine_row present_roster_n=present_roster hhid_available_n=hhid_available age_available_n=age_available birth_date_available_n=birth_date_available_copy ambiguous_n=person_wave_ambiguous, by(wave survey_year)
gen long ptrack14_raw_rows = `raw_rows'
gen long ptrack14_exact_removed = `exact_duplicate_rows_removed'
gen long ptrack14_ambig_pidlink_cases = `ambiguous_pidlink_cases'
gen str35 source_file = "IFLS5 PTRACK14"
order wave survey_year spine_rows ptrack14_raw_rows ptrack14_exact_removed ptrack14_ambig_pidlink_cases present_roster_n hhid_available_n age_available_n birth_date_available_n ambiguous_n source_file
save "`output'/diagnostics/person_spine_reconciliation.dta", replace
export delimited using "`output'/diagnostics/person_spine_reconciliation.csv", replace
restore

display as result "PERSON_SPINE_PASS"
log close
exit 0
