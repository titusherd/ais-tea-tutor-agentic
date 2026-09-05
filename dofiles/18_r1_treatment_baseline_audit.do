version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/18_r1_treatment_baseline_audit.log", text replace
display as text "R1_TREATMENT_BASELINE_AUDIT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "NOTE=raw migration evidence and parent-link coverage only; no r1_lbe, tier, or final sample"

* --------------------------------------------------------------------------
* Part 1. Create one raw-evidence row per person x migration wave.
* --------------------------------------------------------------------------
tempfile ev1 ev2 ev3 ev4 ev5
forvalues w = 1/5 {
    local folder ""
    local mg1 ""
    local mg2 ""
    if `w' == 1 {
        local folder "wave1_hh93"
        local mg1 "buk3mg1.dta"
        local mg2 "buk3mg2.dta"
    }
    if `w' == 2 {
        local folder "wave2_hh97"
        local mg1 "b3a_mg1.dta"
        local mg2 "b3a_mg2.dta"
    }
    if `w' == 3 {
        local folder "wave3_hh00"
        local mg1 "b3a_mg1.dta"
        local mg2 "b3a_mg2.dta"
    }
    if `w' == 4 {
        local folder "wave4_hh07"
        local mg1 "b3a_mg1.dta"
        local mg2 "b3a_mg2.dta"
    }
    if `w' == 5 {
        local folder "wave5_hh14"
        local mg1 "b3a_mg1.dta"
        local mg2 "b3a_mg2.dta"
    }
    local yr = cond(`w' == 1, 1993, cond(`w' == 2, 1997, cond(`w' == 3, 2000, cond(`w' == 4, 2007, 2014))))

    use "`raw'/`folder'/`mg1'", clear
    keep pidlink
    if `w' == 1 {
        merge 1:1 pidlink using "`raw'/`folder'/`mg1'", keepusing(mg20 mg2100) gen(_mg1_merge)
        gen double mg1_screen_raw = mg20
        gen double mg1_since12_raw = mg2100
    }
    if `w' > 1 {
        if `w' == 2 {
            merge 1:1 pidlink using "`raw'/`folder'/`mg1'", keepusing(mg20b mg21n) gen(_mg1_merge)
        }
        if `w' >= 3 {
            merge 1:1 pidlink using "`raw'/`folder'/`mg1'", keepusing(mg20b mg20c) gen(_mg1_merge)
        }
        gen double mg1_screen_raw = mg20b
        if `w' == 2 gen double mg1_since12_raw = mg21n
        if `w' >= 3 gen double mg1_since12_raw = mg20c
    }
    drop _mg1_merge
    isid pidlink
    gen long mg1_rows = 1
    gen long mg2_event_records = .
    gen long work_reason_code1_n = .
    gen long country_code_nonmissing_n = .
    gen double country_code_raw_min = .
    gen double country_code_raw_max = .
    gen double move_year_raw_min = .
    gen double move_year_raw_max = .
    gen double move_age_raw_min = .
    gen double move_age_raw_max = .
    gen long move_with_household_code1_n = .
    gen long current_residence_check_code1_n = .
    gen double movenum_raw_min = .
    gen double movenum_raw_max = .
    gen byte mg2_pidlink_match = 0

    tempfile mg1base mg2agg
    save "`mg1base'", replace

    use "`raw'/`folder'/`mg2'", clear
    local mg2_rows = _N
    capture confirm variable pidlink
    if _rc == 0 {
        gen byte _work_code1 = (mg28 == 1) if !missing(mg28)
        replace _work_code1 = 0 if missing(_work_code1)
        gen double _country_raw = .
        gen byte _country_nonmissing = .
        if `w' > 1 {
            replace _country_raw = mg21e
            replace _country_nonmissing = !missing(mg21e)
        }
        gen byte _move_with_hh_code1 = (mg34 == 1) if !missing(mg34)
        replace _move_with_hh_code1 = 0 if missing(_move_with_hh_code1)
        gen byte _current_check_code1 = .
        capture confirm variable mg40
        if _rc == 0 {
            replace _current_check_code1 = (mg40 == 1) if !missing(mg40)
            replace _current_check_code1 = 0 if missing(_current_check_code1)
        }
        gen byte _event_row = 1
        collapse (sum) evn=_event_row ///
            (sum) workn=_work_code1 ///
            countryn=_country_nonmissing ///
            hhmoven=_move_with_hh_code1 ///
            checkn=_current_check_code1 ///
            (min) countrymin=_country_raw countrymax=_country_raw ///
            yearmin=mg24yr yearmax=mg24yr ///
            agemin=mg25 agemax=mg25 ///
            movemin=movenum movemax=movenum, by(pidlink)
        isid pidlink
        save "`mg2agg'", replace
    }

    use "`mg1base'", clear
    capture confirm file "`raw'/`folder'/`mg2'"
    if _rc == 0 {
        merge 1:1 pidlink using "`mg2agg'", gen(_mg2_merge)
        replace mg2_pidlink_match = (_mg2_merge == 3)
        replace mg2_event_records = evn if _mg2_merge == 3
        replace work_reason_code1_n = workn if _mg2_merge == 3
        replace country_code_nonmissing_n = countryn if _mg2_merge == 3
        replace move_with_household_code1_n = hhmoven if _mg2_merge == 3
        replace current_residence_check_code1_n = checkn if _mg2_merge == 3
        replace country_code_raw_min = countrymin if _mg2_merge == 3
        replace country_code_raw_max = countrymax if _mg2_merge == 3
        replace move_year_raw_min = yearmin if _mg2_merge == 3
        replace move_year_raw_max = yearmax if _mg2_merge == 3
        replace move_age_raw_min = agemin if _mg2_merge == 3
        replace move_age_raw_max = agemax if _mg2_merge == 3
        replace movenum_raw_min = movemin if _mg2_merge == 3
        replace movenum_raw_max = movemax if _mg2_merge == 3
        drop evn workn countryn hhmoven checkn countrymin countrymax yearmin ///
            yearmax agemin agemax movemin movemax
        drop _mg2_merge
    }
    gen byte migration_module_available = 1
    gen byte mg1_screen_nonmissing = !missing(mg1_screen_raw)
    gen byte mg1_since12_nonmissing = !missing(mg1_since12_raw)
    gen byte wave = `w'
    gen int survey_year = `yr'
    order wave survey_year pidlink
    save "`ev`w''", replace
}

use "`ev1'", clear
append using "`ev2'"
append using "`ev3'"
append using "`ev4'"
append using "`ev5'"
sort pidlink wave
isid pidlink wave
save "`derived'/r1_parent_migration_evidence.dta", replace
export delimited using "`output'/diagnostics/r1_parent_migration_evidence.csv", replace
display as text "R1_PARENT_MIGRATION_EVIDENCE_ROWS=" _N

* Raw summary by wave: these columns are deliberately raw-code summaries.
preserve
collapse (sum) person_rows=mg1_rows mg1_screen_nonmissing mg1_since12_nonmissing ///
    mg2_pidlink_match work_reason_code1_n country_code_nonmissing_n ///
    move_with_household_code1_n current_residence_check_code1_n ///
    (min) country_code_raw_min move_year_raw_min move_age_raw_min movenum_raw_min ///
    (max) country_code_raw_max move_year_raw_max move_age_raw_max movenum_raw_max, ///
    by(wave survey_year)
sort wave
save "`output'/diagnostics/r1_migration_raw_candidate_summary.dta", replace
export delimited using "`output'/diagnostics/r1_migration_raw_candidate_summary.csv", replace
restore

* --------------------------------------------------------------------------
* Part 2. Collapse raw migration evidence to person-level availability,
* separating baseline W1 evidence from later-wave evidence.
* --------------------------------------------------------------------------
preserve
gen byte evidence_any = 1
gen byte evidence_screen_any = mg1_screen_nonmissing
gen byte evidence_postw1 = (wave >= 2)
gen byte evidence_postw1_screen = mg1_screen_nonmissing if wave >= 2
replace evidence_postw1_screen = 0 if missing(evidence_postw1_screen)
gen byte evidence_postw1_work_code1 = (work_reason_code1_n > 0) if wave >= 2
replace evidence_postw1_work_code1 = 0 if missing(evidence_postw1_work_code1)
gen byte evidence_postw1_country = (country_code_nonmissing_n > 0) if wave >= 2
replace evidence_postw1_country = 0 if missing(evidence_postw1_country)
gen byte evidence_w1_screen = mg1_screen_nonmissing if wave == 1
replace evidence_w1_screen = 0 if missing(evidence_w1_screen)
gen byte evidence_w1_event = (mg2_event_records > 0) if wave == 1
replace evidence_w1_event = 0 if missing(evidence_w1_event)
collapse (max) evidence_any evidence_screen_any evidence_postw1 evidence_postw1_screen ///
    evidence_postw1_work_code1 evidence_postw1_country evidence_w1_screen evidence_w1_event, by(pidlink)
isid pidlink
tempfile parent_any
save "`parent_any'", replace
restore

* --------------------------------------------------------------------------
* Part 3. Build one canonical child x baseline-wave audit row from roster
* source rows. Multiple household candidates are retained as flags, not
* resolved silently.
* --------------------------------------------------------------------------
tempfile baseline_spine w5_spine
use "`derived'/person_spine.dta", clear
keep if inlist(wave,1,2)
keep pidlink wave age_at_interview birth_date sex present_roster hhid_wave
rename hhid_wave child_spine_hhid
isid pidlink wave
save "`baseline_spine'", replace

use "`derived'/person_spine.dta", clear
keep if wave == 5
keep pidlink present_roster hhid_wave
rename present_roster w5_present_roster
rename hhid_wave w5_hhid
isid pidlink
save "`w5_spine'", replace

use "`derived'/roster_relation_long.dta", clear
keep if inlist(wave,1,2)
merge m:1 pidlink wave using "`baseline_spine'", gen(_child_spine_merge)
keep if _child_spine_merge == 3
drop _child_spine_merge

sort wave pidlink hhid_wave pid_wave
by wave pidlink: gen byte _source_hh_tag = (_n == 1)
by wave pidlink: replace _source_hh_tag = (hhid_wave != hhid_wave[_n-1]) if _n > 1
by wave pidlink: egen long source_hh_count = total(_source_hh_tag)
by wave pidlink: egen byte mother_link_any = max(mother_linked)
by wave pidlink: egen byte father_link_any = max(father_linked)
by wave pidlink: egen byte caregiver_link_any = max(caregiver_linked)
by wave pidlink: egen byte mother_code51_any = max(mother_ref_code_51)
by wave pidlink: egen byte mother_code52_any = max(mother_ref_code_52)
by wave pidlink: egen byte mother_code97_any = max(mother_ref_code_97)
by wave pidlink: egen byte mother_code98_any = max(mother_ref_code_98)
by wave pidlink: egen byte mother_code99_any = max(mother_ref_code_99)
by wave pidlink: egen byte father_code51_any = max(father_ref_code_51)
by wave pidlink: egen byte father_code52_any = max(father_ref_code_52)
by wave pidlink: egen byte father_code97_any = max(father_ref_code_97)
by wave pidlink: egen byte father_code98_any = max(father_ref_code_98)
by wave pidlink: egen byte father_code99_any = max(father_ref_code_99)
by wave pidlink: egen byte mother_valid_any = max(mother_ref_valid_id)
by wave pidlink: egen byte father_valid_any = max(father_ref_valid_id)
gen byte _parent_self_row = (father_linked == 1 & father_pidlink == pidlink) | ///
    (mother_linked == 1 & mother_pidlink == pidlink)
by wave pidlink: egen byte parent_self_any = max(_parent_self_row)
by wave pidlink: keep if _n == 1

gen byte cohort_0_5 = age_at_interview >= 0 & age_at_interview <= 5 if !missing(age_at_interview)
gen byte cohort_6_12 = age_at_interview >= 6 & age_at_interview <= 12 if !missing(age_at_interview)
gen byte cohort_0_12 = inrange(age_at_interview,0,12) if !missing(age_at_interview)
replace cohort_0_5 = 0 if missing(cohort_0_5)
replace cohort_6_12 = 0 if missing(cohort_6_12)
replace cohort_0_12 = 0 if missing(cohort_0_12)
gen byte both_parent_links = mother_link_any == 1 & father_link_any == 1
gen byte one_parent_link = (mother_link_any + father_link_any == 1)
gen byte known_nonresident_or_dead = (mother_code51_any | mother_code52_any | father_code51_any | father_code52_any)
gen byte unknown_or_unresolved_parent = (mother_valid_any == 1 & mother_link_any == 0) | ///
    (father_valid_any == 1 & father_link_any == 0) | mother_code97_any | mother_code98_any | ///
    mother_code99_any | father_code97_any | father_code98_any | father_code99_any
gen str32 baseline_parent_link_status = ""
replace baseline_parent_link_status = "both_parent_links" if both_parent_links == 1
replace baseline_parent_link_status = "one_parent_link" if baseline_parent_link_status == "" & one_parent_link == 1
replace baseline_parent_link_status = "known_nonresident_or_dead" if baseline_parent_link_status == "" & known_nonresident_or_dead == 1
replace baseline_parent_link_status = "unknown_or_unresolved" if baseline_parent_link_status == "" & unknown_or_unresolved_parent == 1
replace baseline_parent_link_status = "no_parent_link" if baseline_parent_link_status == ""
gen byte source_hh_ambiguous = source_hh_count > 1

merge m:1 pidlink using "`w5_spine'", gen(_w5_merge)
drop if _w5_merge == 2
gen byte w5_roster_tracked = (_w5_merge == 3 & w5_present_roster == 1)
replace w5_roster_tracked = 0 if missing(w5_roster_tracked)
drop _w5_merge

* Link each baseline child to raw migration-evidence availability of the
* linked mother and father. The evidence variables remain non-semantic.
preserve
use "`parent_any'", clear
rename pidlink mother_pidlink
rename evidence_any mom_ev_any
rename evidence_screen_any mom_screen_ev
rename evidence_postw1_screen mom_post_screen
rename evidence_postw1_work_code1 mom_post_work
rename evidence_postw1_country mom_post_country
rename evidence_w1_screen mom_w1_screen
rename evidence_w1_event mom_w1_event
keep mother_pidlink mom_ev_any mom_screen_ev mom_post_screen mom_post_work mom_post_country mom_w1_screen mom_w1_event
isid mother_pidlink
tempfile mother_any
save "`mother_any'", replace
restore
merge m:1 mother_pidlink using "`mother_any'", gen(_mother_evidence_merge)
drop if _mother_evidence_merge == 2

preserve
use "`parent_any'", clear
rename pidlink father_pidlink
rename evidence_any dad_ev_any
rename evidence_screen_any dad_screen_ev
rename evidence_postw1_screen dad_post_screen
rename evidence_postw1_work_code1 dad_post_work
rename evidence_postw1_country dad_post_country
rename evidence_w1_screen dad_w1_screen
rename evidence_w1_event dad_w1_event
keep father_pidlink dad_ev_any dad_screen_ev dad_post_screen dad_post_work dad_post_country dad_w1_screen dad_w1_event
isid father_pidlink
tempfile father_any
save "`father_any'", replace
restore
merge m:1 father_pidlink using "`father_any'", gen(_father_evidence_merge)
drop if _father_evidence_merge == 2

gen byte mother_evidence_linked = (_mother_evidence_merge == 3)
gen byte father_evidence_linked = (_father_evidence_merge == 3)
replace mother_evidence_linked = 0 if missing(mother_evidence_linked)
replace father_evidence_linked = 0 if missing(father_evidence_linked)
gen byte parent_evidence_any = mother_evidence_linked == 1 | father_evidence_linked == 1
gen byte postw1_work_code1_evidence_any = mom_post_work == 1 | dad_post_work == 1
replace postw1_work_code1_evidence_any = 0 if missing(postw1_work_code1_evidence_any)
gen byte postw1_country_evidence_any = mom_post_country == 1 | dad_post_country == 1
replace postw1_country_evidence_any = 0 if missing(postw1_country_evidence_any)

sort wave pidlink
count if missing(pidlink) | missing(wave)
if r(N) > 0 {
    preserve
    keep if missing(pidlink) | missing(wave)
    save "`output'/diagnostics/r1_child_parent_key_anomalies.dta", replace
    export delimited using "`output'/diagnostics/r1_child_parent_key_anomalies.csv", replace
    restore
    drop if missing(pidlink) | missing(wave)
}
else {
    * Remove stale artifacts from an earlier failed parser run so a clean
    * zero-anomaly result cannot be confused with obsolete output.
    capture erase "`output'/diagnostics/r1_child_parent_key_anomalies.dta"
    capture erase "`output'/diagnostics/r1_child_parent_key_anomalies.csv"
}
isid pidlink wave
save "`output'/diagnostics/r1_child_parent_link_audit.dta", replace
export delimited using "`output'/diagnostics/r1_child_parent_link_audit.csv", replace

preserve
keep if cohort_0_12 == 1
gen byte child_row = 1
collapse (sum) child_rows=child_row ///
    (sum) cohort_0_5 cohort_6_12 both_parent_links one_parent_link known_nonresident_or_dead ///
    unknown_or_unresolved_parent source_hh_ambiguous w5_roster_tracked ///
    mother_evidence_linked father_evidence_linked parent_evidence_any ///
    postw1_work_code1_evidence_any postw1_country_evidence_any, by(wave survey_year)
sort wave
save "`output'/diagnostics/r1_child_parent_link_summary.dta", replace
export delimited using "`output'/diagnostics/r1_child_parent_link_summary.csv", replace
restore

preserve
keep if cohort_0_12 == 1
contract wave survey_year baseline_parent_link_status
sort wave baseline_parent_link_status
save "`output'/diagnostics/r1_baseline_parent_status.dta", replace
export delimited using "`output'/diagnostics/r1_baseline_parent_status.csv", replace
restore

display as result "R1_TREATMENT_BASELINE_AUDIT_ROWS=" _N
display as result "R1_TREATMENT_BASELINE_AUDIT_PASS"
display as result "R1_TREATMENT_BASELINE_AUDIT_NOTE=no_r1_lbe_no_tier_no_work_migration_recode_no_primary_sample"
log close
exit 0
