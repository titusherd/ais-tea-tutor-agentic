version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/16_adult_outcome_availability_audit.log", text replace
display as text "ADULT_OUTCOME_AVAILABILITY_AUDIT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"
display as text "NOTE=raw availability and coverage only; no outcome recode or final estimand is constructed"

* Reusable one-row-per-person spine extracts for link and age coverage.
tempfile spine2 spine3 spine4 spine5
use "`derived'/person_spine.dta", clear
foreach w in 2 3 4 5 {
    preserve
    keep if wave == `w'
    keep pidlink age_at_interview birth_date sex present_roster hhid_wave pid_wave
    isid pidlink
    save "`spine`w''", replace
    restore
}

* Candidate raw variables are selected only where the local IFLS label/codebook
* audit identified a substantive measure. Their analytic meaning remains open.
local spec1 "2 1997 health b3b_kk.dta srh kk01 generally_health"
local spec2 "3 2000 health b3b_kk.dta srh kk01 generally_health"
local spec3 "3 2000 mental_health b3b_kk.dta mental_item kk04 sleep_difficulty"
local spec4 "3 2000 mental_health b3b_kk.dta mental_item kk05 bothered_by_things"
local spec5 "3 2000 mental_health b3b_kk.dta mental_item kk06 felt_lonely"
local spec6 "3 2000 mental_health b3b_kk.dta mental_item kk07 sadness"
local spec7 "3 2000 mental_health b3b_kk.dta mental_item kk08 anxiety"
local spec8 "3 2000 mental_health b3b_kk.dta mental_item kk09 concentration"
local spec9 "3 2000 mental_health b3b_kk.dta mental_item kk10 tasks"
local spec10 "3 2000 mental_health b3b_kk.dta mental_item kk11 memory"
local spec11 "4 2007 labor b3a_tk1.dta labor_screen tk01 primary_activity"
local spec12 "4 2007 labor b3a_tk1.dta employment tk02 worked_for_pay_1hr"
local spec13 "4 2007 labor b3a_tk1.dta employment tk03 job_but_did_not_work"
local spec14 "4 2007 labor b3a_tk1.dta employment tk04 family_business_work"
local spec15 "4 2007 labor b3a_tk1.dta labor_history tk05 ever_worked"
local spec16 "4 2007 labor b3a_tk1.dta labor_status tk15 last_job_status"
local spec17 "4 2007 labor b3a_tk2.dta hours tk21a last_week_hours_job1"
local spec18 "4 2007 labor b3a_tk2.dta hours tk22a normal_week_hours_job1"
local spec19 "4 2007 labor b3a_tk2.dta hours tk23a weeks_worked_year_job1"
local spec20 "4 2007 labor b3a_tk2.dta labor_status tk24a working_status_job1"
local spec21 "4 2007 labor b3a_tk2.dta payment tk24a2 payment_system_job1"
local spec22 "4 2007 labor b3a_tk2.dta contract tk24a5 contract_job1"
local spec23 "4 2007 labor b3a_tk2.dta earnings tk25a1 net_salary_month_job1"
local spec24 "4 2007 labor b3a_tk2.dta earnings tk25a2 net_salary_year_job1"
local spec25 "4 2007 labor b3a_tk2.dta self_employment_profit tk26a1 net_profit_month_job1"
local spec26 "4 2007 labor b3a_tk2.dta self_employment_profit tk26a3 net_profit_year_job1"
local spec27 "4 2007 health b3b_kk1.dta srh kk01 generally_health"
local spec28 "4 2007 health_assessment b3a_sw.dta srh sw06 health_assessment"
local spec29 "4 2007 symptoms b3b_vg.dta symptom vg01a mobility_problem"
local spec30 "4 2007 symptoms b3b_vg.dta symptom vg02a bodily_aches"
local spec31 "4 2007 symptoms b3b_vg.dta symptom vg03a memory_problem"
local spec32 "4 2007 symptoms b3b_vg.dta symptom vg04a sleep_problem"
local spec33 "4 2007 symptoms b3b_vg.dta depression_screen vg05a depression_problem"
local spec34 "4 2007 symptoms b3b_vg.dta symptom vg06a shortness_breath"
local spec35 "4 2007 anthropometry bus1_1.dta weight us06 weight_kg"
local spec36 "4 2007 anthropometry bus1_2.dta height us04 height_cm"
local spec37 "4 2007 anthropometry bus1_1.dta blood_pressure us07a1 systolic_1"
local spec38 "4 2007 anthropometry bus1_1.dta blood_pressure us07a2 diastolic_1"
local spec39 "4 2007 anthropometry bus1_1.dta blood_pressure us07b1 systolic_2"
local spec40 "4 2007 anthropometry bus1_1.dta blood_pressure us07b2 diastolic_2"
local spec41 "4 2007 anthropometry bus1_2.dta blood_pressure us07c1 systolic_3"
local spec42 "4 2007 anthropometry bus1_2.dta blood_pressure us07c2 diastolic_3"
local spec43 "4 2007 chronic_condition b3b_cd2.dta diagnosis cd01 diagnosed_condition"
local spec44 "4 2007 chronic_condition b3b_cd3.dta diagnosis cd05 cancer_diagnosis"
local spec45 "4 2007 chronic_condition b3b_cd3.dta diagnosis cdtype chronic_condition_type"
local spec46 "4 2007 education b3a_dl1.dta education dl06 highest_education_level"
local spec47 "4 2007 education b3a_dl1.dta education dl07 highest_grade_completed"
local spec48 "4 2007 education b3a_dl1.dta education dl07a currently_attending_school"
local spec49 "4 2007 education b3a_dl1.dta education dl07byr graduation_or_exit_year"
local spec50 "4 2007 cognition b3b_co2.dta word_recall co07_1 immediate_recall_item1"
local spec51 "4 2007 cognition b3b_co2.dta word_recall co07_10 immediate_recall_item10"
local spec52 "4 2007 cognition b3b_co3.dta word_recall co10_1 delayed_recall_item1"
local spec53 "4 2007 cognition b3b_co3.dta word_recall co10_10 delayed_recall_item10"
local spec54 "4 2007 smoking b3b_km.dta smoking km01a ever_tobacco_habit"
local spec55 "4 2007 smoking b3b_km.dta smoking km01e ever_cigarette_habit"
local spec56 "4 2007 smoking b3b_km.dta smoking km04 current_or_quit"
local spec57 "4 2007 smoking b3b_km.dta smoking km08x cigarettes_per_day"
local spec58 "4 2007 smoking b3b_km.dta smoking km10 smoking_start_age"
local spec59 "4 2007 marriage b3a_pk1.dta marriage pk00a current_married"
local spec60 "4 2007 marriage b3a_pk1.dta marriage pk19by current_marriage_year"
local spec61 "4 2007 marriage b3a_kw3.dta marriage kw11 age_marriage_started"
local spec62 "4 2007 marriage b3a_kw3.dta marriage kw11b marriage_status"
local spec63 "4 2007 marriage b3a_kw3.dta marriage kw19 age_marriage_ended"
local spec64 "4 2007 trust b3a_tr.dta trust tr01 willing_help_village"
local spec65 "4 2007 trust b3a_tr.dta trust tr02 perceived_take_advantage"
local spec66 "4 2007 trust b3a_tr.dta trust tr03 trust_same_ethnicity"
local spec67 "4 2007 trust b3a_tr.dta trust tr04 leave_children_neighbors"
local spec68 "4 2007 trust b3a_tr.dta trust tr05 ask_neighbors_watch_house"
local spec69 "4 2007 trust b3a_tr.dta trust tr06 village_safety"
local spec70 "4 2007 trust b3a_tr.dta trust tr28 trust_different_faith"
local spec71 "4 2007 preferences b3a_si.dta preference si01 earning_option_1"
local spec72 "4 2007 preferences b3a_si.dta preference si03 earning_option_2"
local spec73 "4 2007 preferences b3a_si.dta preference si11 earning_option_3"
local spec74 "4 2007 preferences b3a_si.dta preference si13 earning_option_4"
local spec75 "4 2007 preferences b3a_si.dta preference si21a lottery_one_year_1"
local spec76 "4 2007 preferences b3a_si.dta preference si22a lottery_five_year_1"
local spec77 "5 2014 labor b3a_tk1.dta labor_screen tk01 primary_activity"
local spec78 "5 2014 labor b3a_tk1.dta employment tk02 worked_for_pay_1hr"
local spec79 "5 2014 labor b3a_tk1.dta employment tk03 job_but_did_not_work"
local spec80 "5 2014 labor b3a_tk1.dta employment tk04 family_business_work"
local spec81 "5 2014 labor b3a_tk1.dta labor_history tk05 ever_worked"
local spec82 "5 2014 labor b3a_tk1.dta labor_status tk15 last_job_status"
local spec83 "5 2014 labor b3a_tk2.dta hours tk21a last_week_hours_job1"
local spec84 "5 2014 labor b3a_tk2.dta hours tk22a normal_week_hours_job1"
local spec85 "5 2014 labor b3a_tk2.dta hours tk23a weeks_worked_year_job1"
local spec86 "5 2014 labor b3a_tk2.dta labor_status tk24a working_status_job1"
local spec87 "5 2014 labor b3a_tk2.dta payment tk24a2 payment_system_job1"
local spec88 "5 2014 labor b3a_tk2.dta contract tk24a5 contract_job1"
local spec89 "5 2014 labor b3a_tk2.dta earnings tk25a1 salary_month_job1"
local spec90 "5 2014 labor b3a_tk2.dta earnings tk25a2 salary_year_job1"
local spec91 "5 2014 labor b3a_tk2.dta self_employment_profit tk26a1 net_profit_month_job1"
local spec92 "5 2014 labor b3a_tk2.dta self_employment_profit tk26a3 net_profit_year_job1"
local spec93 "5 2014 health b3b_kk1.dta srh kk01 generally_health"
local spec94 "5 2014 health_assessment b3a_sw.dta srh sw06 health_assessment"
local spec95 "5 2014 symptoms b3b_vg.dta depression_screen vg05a depression_problem"
local spec96 "5 2014 anthropometry bus_us.dta height us04 height_cm"
local spec97 "5 2014 anthropometry bus_us.dta weight us06 weight_kg"
local spec98 "5 2014 anthropometry bus_us.dta blood_pressure us07a1 systolic_1"
local spec99 "5 2014 anthropometry bus_us.dta blood_pressure us07a2 diastolic_1"
local spec100 "5 2014 anthropometry bus_us.dta blood_pressure us07b1 systolic_2"
local spec101 "5 2014 anthropometry bus_us.dta blood_pressure us07b2 diastolic_2"
local spec102 "5 2014 anthropometry bus_us.dta blood_pressure us07c1 systolic_3"
local spec103 "5 2014 anthropometry bus_us.dta blood_pressure us07c2 diastolic_3"
local spec104 "5 2014 health_comparison bus_us.dta srh us14 comparative_health_status"
local spec105 "5 2014 chronic_condition b3b_cd2.dta diagnosis cd01 diagnosed_condition"
local spec106 "5 2014 chronic_condition b3b_cd3.dta diagnosis cd05 cancer_diagnosis"
local spec107 "5 2014 chronic_condition b3b_cd3.dta diagnosis cdtype chronic_condition_type"
local spec108 "5 2014 education b3a_dl1.dta education dl06 highest_education_level"
local spec109 "5 2014 education b3a_dl1.dta education dl07 highest_grade_completed"
local spec110 "5 2014 education b3a_dl1.dta education dl07a currently_attending_school"
local spec111 "5 2014 education b3a_dl1.dta education dl07byr graduation_or_exit_year"
local spec112 "5 2014 cognition b3b_co1.dta word_recall co07count immediate_recall_count"
local spec113 "5 2014 cognition b3b_co1.dta word_recall co10count delayed_recall_count"
local spec114 "5 2014 cognition b3b_co1.dta serial_subtraction co04a serial_subtraction_start"
local spec115 "5 2014 cognition b3b_co1.dta serial_subtraction co04b serial_subtraction_item2"
local spec116 "5 2014 cognition b3b_co1.dta serial_subtraction co04c serial_subtraction_item3"
local spec117 "5 2014 cognition b3b_co1.dta serial_subtraction co04d serial_subtraction_item4"
local spec118 "5 2014 cognition b3b_co1.dta serial_subtraction co04e serial_subtraction_item5"
local spec119 "5 2014 cognition b3b_cob.dta cognition cob18 animal_names_count"
local spec120 "5 2014 cognition b3b_cob.dta cognition cob19a overlapping_pentagons"
local spec121 "5 2014 smoking b3b_km.dta smoking km01a ever_tobacco_habit"
local spec122 "5 2014 smoking b3b_km.dta smoking km01e ever_cigarette_habit"
local spec123 "5 2014 smoking b3b_km.dta smoking km04 current_or_quit"
local spec124 "5 2014 smoking b3b_km.dta smoking km08x cigarettes_per_day"
local spec125 "5 2014 smoking b3b_km.dta smoking km10 smoking_start_age"
local spec126 "5 2014 marriage b3a_pk1.dta marriage pk00a current_married"
local spec127 "5 2014 marriage b3a_pk1.dta marriage pk19by current_marriage_year"
local spec128 "5 2014 marriage b3a_kw3.dta marriage kw11 age_marriage_started"
local spec129 "5 2014 marriage b3a_kw3.dta marriage kw11b marriage_status"
local spec130 "5 2014 marriage b3a_kw3.dta marriage kw19 age_marriage_ended"
local spec131 "5 2014 trust b3a_tr.dta trust tr01 willing_help_village"
local spec132 "5 2014 trust b3a_tr.dta trust tr02 perceived_take_advantage"
local spec133 "5 2014 trust b3a_tr.dta trust tr03 trust_ethnicity_scenario"
local spec134 "5 2014 trust b3a_tr.dta trust tr04 leave_children_neighbors"
local spec135 "5 2014 trust b3a_tr.dta trust tr05 ask_neighbors_watch_house"
local spec136 "5 2014 trust b3a_tr.dta trust tr06 village_safety"
local spec137 "5 2014 preferences b3a_si.dta preference si01 earning_option_1"
local spec138 "5 2014 preferences b3a_si.dta preference si03 earning_option_2"
local spec139 "5 2014 preferences b3a_si.dta preference si11 earning_option_3"
local spec140 "5 2014 preferences b3a_si.dta preference si13 earning_option_4"
local spec141 "5 2014 preferences b3a_si.dta preference si21a lottery_one_year_1"
local spec142 "5 2014 preferences b3a_si.dta preference si22a lottery_five_year_1"
local n_specs = 142
local master "`output'/diagnostics/adult_outcome_variable_audit.dta"
local rowfiles ""

capture program drop adult_write_outcome_audit_row
program define adult_write_outcome_audit_row
    args rowfile wave survey_year domain outcome_role module raw_varname relpath file_exists variable_exists availability_status variable_label storage_type value_label module_rows pidlink_nonmissing pidlink_unique raw_nonmissing_rows raw_missing_rows raw_min raw_max linked_rows linked_persons linked_nonmissing_persons age_17_21_persons age_22_25_persons age_26_29_persons age_30_33_persons age_34_36_persons
    clear
    set obs 1
    generate byte wave = `wave'
    generate int survey_year = `survey_year'
    generate str32 domain = ""
    replace domain = `"`domain'"'
    generate str48 outcome_role = ""
    replace outcome_role = `"`outcome_role'"'
    generate str32 module = ""
    replace module = `"`module'"'
    generate str32 raw_varname = ""
    replace raw_varname = `"`raw_varname'"'
    generate str244 relpath = ""
    replace relpath = `"`relpath'"'
    generate byte file_exists = `file_exists'
    generate byte variable_exists = `variable_exists'
    generate str32 availability_status = ""
    replace availability_status = `"`availability_status'"'
    generate str244 variable_label = ""
    replace variable_label = `"`variable_label'"'
    generate str16 storage_type = ""
    replace storage_type = `"`storage_type'"'
    generate str32 value_label = ""
    replace value_label = `"`value_label'"'
    generate long module_rows = `module_rows'
    generate long pidlink_nonmissing = `pidlink_nonmissing'
    generate byte pidlink_unique = `pidlink_unique'
    generate long raw_nonmissing_rows = `raw_nonmissing_rows'
    generate long raw_missing_rows = `raw_missing_rows'
    generate double raw_min = `raw_min'
    generate double raw_max = `raw_max'
    generate long linked_rows = `linked_rows'
    generate long linked_persons = `linked_persons'
    generate long linked_nonmissing_persons = `linked_nonmissing_persons'
    generate long age_17_21_persons = `age_17_21_persons'
    generate long age_22_25_persons = `age_22_25_persons'
    generate long age_26_29_persons = `age_26_29_persons'
    generate long age_30_33_persons = `age_30_33_persons'
    generate long age_34_36_persons = `age_34_36_persons'
    save "`rowfile'", replace
end

forvalues i = 1/`n_specs' {
    local specname spec`i'
    local spec ``specname''
    tokenize `"`spec'"'
    local w `1'
    local yr `2'
    local domain `3'
    local file `4'
    local role `5'
    local v `6'
    local outcome_role `7'

    local folder ""
    if `w' == 2 local folder "wave2_hh97"
    if `w' == 3 local folder "wave3_hh00"
    if `w' == 4 local folder "wave4_hh07"
    if `w' == 5 local folder "wave5_hh14"
    local relpath "`folder'/`file'"
    local path "`raw'/`relpath'"
    local spinefile "`spine`w''"

    tempfile rowfile
    local hname adultpost`i'

    capture confirm file "`path'"
    if _rc != 0 {
        adult_write_outcome_audit_row "`rowfile'" `w' `yr' `"`domain'"' `"`outcome_role'"' `"`file'"' `"`v'"' `"`relpath'"' 0 0 "file_missing" "" "" "" . . . . . . . . . . . . . . .
        local rowfiles "`rowfiles' `rowfile'"
        continue
    }

    use "`path'", clear
    local module_rows = _N
    local pidlink_nonmissing = .
    local pidlink_unique = .
    capture confirm variable pidlink
    if _rc == 0 {
        count if !missing(pidlink)
        local pidlink_nonmissing = r(N)
        preserve
        keep if !missing(pidlink)
        capture isid pidlink
        local pidlink_unique = (_rc == 0)
        restore
    }

    capture confirm variable `v'
    if _rc != 0 {
        adult_write_outcome_audit_row "`rowfile'" `w' `yr' `"`domain'"' `"`outcome_role'"' `"`file'"' `"`v'"' `"`relpath'"' 1 0 "variable_missing" "" "" "" `module_rows' `pidlink_nonmissing' `pidlink_unique' . . . . . . . . . . . . . . .
        local rowfiles "`rowfiles' `rowfile'"
        continue
    }

    local vlabel : variable label `v'
    local vtype : type `v'
    local vallabel : value label `v'
    count if !missing(`v')
    local raw_nonmissing = r(N)
    count if missing(`v')
    local raw_missing = r(N)
    local raw_min = .
    local raw_max = .
    capture confirm numeric variable `v'
    if _rc == 0 {
        summarize `v', meanonly
        local raw_min = r(min)
        local raw_max = r(max)
    }

    local linked_rows = .
    local linked_persons = .
    local linked_nonmissing_persons = .
    local age17 = .
    local age22 = .
    local age26 = .
    local age30 = .
    local age34 = .
    capture confirm variable pidlink
    if _rc == 0 {
        merge m:1 pidlink using "`spinefile'", gen(_adult_spine_merge)
        keep if _adult_spine_merge != 2
        gen byte _adult_tag = 0
        egen _adult_tag_tmp = tag(pidlink) if _adult_spine_merge == 3 & !missing(pidlink)
        replace _adult_tag = _adult_tag_tmp
        count if _adult_spine_merge == 3
        local linked_rows = r(N)
        count if _adult_spine_merge == 3 & _adult_tag == 1
        local linked_persons = r(N)
        egen _adult_tag_nonmissing = tag(pidlink) if _adult_spine_merge == 3 & !missing(pidlink) & !missing(`v')
        count if _adult_tag_nonmissing == 1
        local linked_nonmissing_persons = r(N)
        gen byte _adult_agevalid = !missing(age_at_interview) & age_at_interview >= 0 & age_at_interview <= 100
        count if _adult_spine_merge == 3 & _adult_tag == 1 & _adult_agevalid == 1 & inrange(age_at_interview, 17, 21)
        local age17 = r(N)
        count if _adult_spine_merge == 3 & _adult_tag == 1 & _adult_agevalid == 1 & inrange(age_at_interview, 22, 25)
        local age22 = r(N)
        count if _adult_spine_merge == 3 & _adult_tag == 1 & _adult_agevalid == 1 & inrange(age_at_interview, 26, 29)
        local age26 = r(N)
        count if _adult_spine_merge == 3 & _adult_tag == 1 & _adult_agevalid == 1 & inrange(age_at_interview, 30, 33)
        local age30 = r(N)
        count if _adult_spine_merge == 3 & _adult_tag == 1 & _adult_agevalid == 1 & inrange(age_at_interview, 34, 36)
        local age34 = r(N)
    }

    postfile `hname' byte wave int survey_year str32 domain str48 outcome_role str32 module str32 raw_varname str244 relpath ///
        byte file_exists byte variable_exists str32 availability_status str244 variable_label str16 storage_type str32 value_label ///
        long module_rows long pidlink_nonmissing byte pidlink_unique long raw_nonmissing_rows long raw_missing_rows ///
        double raw_min double raw_max long linked_rows long linked_persons long linked_nonmissing_persons ///
        long age_17_21_persons long age_22_25_persons long age_26_29_persons long age_30_33_persons long age_34_36_persons ///
        using "`rowfile'", replace
    post `hname' (`w') (`yr') ("`domain'") ("`outcome_role'") ("`file'") ("`v'") ("`relpath'") (1) (1) ("raw_available_uninterpreted") ///
        ("`vlabel'") ("`vtype'") ("`vallabel'") (`module_rows') (`pidlink_nonmissing') (`pidlink_unique') ///
        (`raw_nonmissing') (`raw_missing') (`raw_min') (`raw_max') (`linked_rows') (`linked_persons') (`linked_nonmissing_persons') ///
        (`age17') (`age22') (`age26') (`age30') (`age34')
    postclose `hname'
    local rowfiles "`rowfiles' `rowfile'"
}

local first = 1
foreach rf of local rowfiles {
    if `first' == 1 {
        use "`rf'", clear
        local first = 0
    }
    else {
        append using "`rf'"
    }
}
sort wave domain module outcome_role
save "`master'", replace
export delimited using "`output'/diagnostics/adult_outcome_variable_audit.csv", replace

preserve
keep wave survey_year domain outcome_role module raw_varname relpath file_exists variable_exists availability_status
duplicates drop
sort wave domain module outcome_role
save "`output'/diagnostics/adult_outcome_file_summary.dta", replace
export delimited using "`output'/diagnostics/adult_outcome_file_summary.csv", replace
restore

display as result "ADULT_OUTCOME_VARIABLE_AUDIT_ROWS=" _N
display as result "ADULT_OUTCOME_AVAILABILITY_AUDIT_PASS"
display as result "ADULT_OUTCOME_AVAILABILITY_AUDIT_NOTE=no_recode_no_index_no_final_estimand"
log close
exit 0
