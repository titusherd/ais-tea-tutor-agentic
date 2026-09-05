version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local raw "`project'/00_raw"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/17_survey_design_weight_audit.log", text replace
display as text "SURVEY_DESIGN_WEIGHT_AUDIT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "NOTE=official local weight/geography fields audited; no final weight, svyset, PSU, stratum, or cluster decision"

capture program drop survey_write_row
program define survey_write_row
    args rowfile wave survey_year level source relpath varname audit_role keyvar file_exists variable_exists availability_status variable_label storage_type value_label module_rows key_nonmissing key_unique raw_nonmissing raw_missing raw_min raw_max zero_n negative_n
    clear
    set obs 1
    generate byte wave = `wave'
    generate int survey_year = `survey_year'
    generate str12 level = ""
    replace level = `"`level'"'
    generate str12 source = ""
    replace source = `"`source'"'
    generate str244 relpath = ""
    replace relpath = `"`relpath'"'
    generate str32 varname = ""
    replace varname = `"`varname'"'
    generate str32 audit_role = ""
    replace audit_role = `"`audit_role'"'
    generate str32 keyvar = ""
    replace keyvar = `"`keyvar'"'
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
    generate long key_nonmissing = `key_nonmissing'
    generate byte key_unique = `key_unique'
    generate long raw_nonmissing = `raw_nonmissing'
    generate long raw_missing = `raw_missing'
    generate double raw_min = `raw_min'
    generate double raw_max = `raw_max'
    generate long zero_n = `zero_n'
    generate long negative_n = `negative_n'
    save "`rowfile'", replace
end

* Weight fields are enumerated from the local IFLS tracking files and their
* labels. They are candidates only; similar names have different target
* populations (cross-section, longitudinal, health, cognitive, or DBS).
local w2p "pwt93 pwt93in pwt93us pwt97inl pwt97l pwt97x"
local w3p "pwt00la pwt00lb pwt00xa pwt00xb pwt93 pwt93in pwt93us pwt97ekx pwt97inl pwt97l pwt97usl pwt97usx pwt97x"
local w4p "pwt00la pwt00lb pwt00xa pwt00xb pwt07dbsx_ pwt07dbsxa pwt07la pwt07usx_ pwt07usxa pwt07x_ pwt07xa pwt93 pwt97ekx pwt97inl pwt97l pwt97usl pwt97usx pwt97x"
local w5p "pwt00la pwt00lb pwt00xa pwt00xb pwt07dbsx_ pwt07dbsxa pwt07la pwt07usx_ pwt07usxa pwt07x_ pwt07xa pwt14dbsla pwt14dbsx_ pwt14dbsxa pwt14la pwt14usx_ pwt14usxa pwt14x_ pwt14xa pwt93 pwt93in pwt93us pwt93970007usl pwt939700_07lr pwt93_97_00_07l pwt97ekx pwt97inl pwt97l pwt97usl pwt97usx pwt97x pwt_5_waves_l pwt_5_waves_lr pwt_5_waves_usl"

local w2h "hwt93 hwt93smp hwt97l hwt97x"
local w3h "hwt00la hwt00lb hwt00xa hwt00xb hwt93 hwt93smp hwt97l hwt97x"
local w4h "hwt00la hwt00lb hwt00xa hwt00xb hwt07l_ hwt07la hwt07x_ hwt07xa hwt93 hwt9307l hwt93smp hwt97l hwt97x"
local w5h "hwt00la hwt00lb hwt00xa hwt00xb hwt07l_ hwt07la hwt07x_ hwt07xa hwt14l_ hwt14la hwt14x_ hwt14xa hwt93 hwt93_97_00_07l hwt93smp hwt97l hwt97x hwt_5_waves_l"

local n_specs = 0
foreach v of local w2p {
    local ++n_specs
    local spec`n_specs' "2 person ptrack `v' weight_candidate"
}
foreach v of local w3p {
    local ++n_specs
    local spec`n_specs' "3 person ptrack `v' weight_candidate"
}
foreach v of local w4p {
    local ++n_specs
    local spec`n_specs' "4 person ptrack `v' weight_candidate"
}
foreach v of local w5p {
    local ++n_specs
    local spec`n_specs' "5 person ptrack `v' weight_candidate"
}
foreach v of local w2h {
    local ++n_specs
    local spec`n_specs' "2 household htrack `v' weight_candidate"
}
foreach v of local w3h {
    local ++n_specs
    local spec`n_specs' "3 household htrack `v' weight_candidate"
}
foreach v of local w4h {
    local ++n_specs
    local spec`n_specs' "4 household htrack `v' weight_candidate"
}
foreach v of local w5h {
    local ++n_specs
    local spec`n_specs' "5 household htrack `v' weight_candidate"
}

* Community IDs and geography fields are recorded as possible design or
* fixed-effect fields. They are not assumed to be survey PSUs or strata.
local g2 "commid93 commid97 sc01_93 sc01_97 sc05_93 sc05_97"
local g3 "commid93 commid97 commid00 sc01_93 sc01_97 sc010000 sc010099 sc0193r2 sc0197r2 sc05_93 sc05_97"
local g4 "commid93 commid97 commid00 commid07 sc01_93 sc01_97 sc010000 sc010099 sc010700 sc010707 sc0193r2 sc0197r2 sc05_93 sc05_97"
local g5 "commid93 commid97 commid00 commid07 commid14 sc01_93 sc01_97 sc01_07_00 sc01_07_07 sc01_14_00 sc01_14_07 sc01_14_14 sc010000 sc010099 sc0193r2 sc0197r2 sc05_93 sc05_97"
foreach v of local g2 {
    local ++n_specs
    local spec`n_specs' "2 household htrack `v' geography_candidate"
}
foreach v of local g3 {
    local ++n_specs
    local spec`n_specs' "3 household htrack `v' geography_candidate"
}
foreach v of local g4 {
    local ++n_specs
    local spec`n_specs' "4 household htrack `v' geography_candidate"
}
foreach v of local g5 {
    local ++n_specs
    local spec`n_specs' "5 household htrack `v' geography_candidate"
}

* Current-wave household location fields from the household Book SC files.
local ++n_specs
local spec`n_specs' "2 household bk_sc sc01 geography_current"
local ++n_specs
local spec`n_specs' "2 household bk_sc sc05 geography_current"
local ++n_specs
local spec`n_specs' "3 household bk_sc sc01 geography_current"
local ++n_specs
local spec`n_specs' "3 household bk_sc sc05 geography_current"
local ++n_specs
local spec`n_specs' "4 household bk_sc sc010700 geography_current"
local ++n_specs
local spec`n_specs' "4 household bk_sc sc010707 geography_current"
local ++n_specs
local spec`n_specs' "4 household bk_sc sc05 geography_current"
local ++n_specs
local spec`n_specs' "5 household bk_sc1 sc01_14_14 geography_current"
local ++n_specs
local spec`n_specs' "5 household bk_sc1 sc05 geography_current"

tempfile rowfiles_master
local rowfiles ""

forvalues i = 1/`n_specs' {
    local specname spec`i'
    local spec ``specname''
    tokenize `"`spec'"'
    local w `1'
    local level `2'
    local source `3'
    local v `4'
    local audit_role `5'
    local yr = cond(`w' == 2, 1997, cond(`w' == 3, 2000, cond(`w' == 4, 2007, 2014)))

    local folder ""
    if `w' == 2 local folder "wave2_hh97"
    if `w' == 3 local folder "wave3_hh00"
    if `w' == 4 local folder "wave4_hh07"
    if `w' == 5 local folder "wave5_hh14"

    local file ""
    local keyvar ""
    if "`source'" == "ptrack" {
        local file "ptrack.dta"
        local keyvar "pidlink"
    }
    if "`source'" == "htrack" {
        local file "htrack.dta"
        if `w' == 2 local keyvar "hhid97"
        if `w' == 3 local keyvar "hhid00"
        if `w' == 4 local keyvar "hhid07"
        if `w' == 5 local keyvar "hhid14"
    }
    if "`source'" == "bk_sc" {
        local file "bk_sc.dta"
        if `w' == 2 local keyvar "hhid97"
        if `w' == 3 local keyvar "hhid00"
        if `w' == 4 local keyvar "hhid07"
    }
    if "`source'" == "bk_sc1" {
        local file "bk_sc1.dta"
        local keyvar "hhid14"
    }
    local relpath "`folder'/`file'"
    local path "`raw'/`relpath'"

    tempfile rowfile
    capture confirm file "`path'"
    if _rc != 0 {
        survey_write_row "`rowfile'" `w' `yr' `"`level'"' `"`source'"' `"`relpath'"' `"`v'"' `"`audit_role'"' `"`keyvar'"' 0 0 "file_missing" "" "" "" . . . . . . . . .
        local rowfiles "`rowfiles' `rowfile'"
        continue
    }

    use "`path'", clear
    local module_rows = _N
    local key_nonmissing = .
    local key_unique = .
    capture confirm variable `keyvar'
    if _rc == 0 {
        count if !missing(`keyvar')
        local key_nonmissing = r(N)
        preserve
        keep if !missing(`keyvar')
        capture isid `keyvar'
        local key_unique = (_rc == 0)
        restore
    }

    capture confirm variable `v'
    if _rc != 0 {
        survey_write_row "`rowfile'" `w' `yr' `"`level'"' `"`source'"' `"`relpath'"' `"`v'"' `"`audit_role'"' `"`keyvar'"' 1 0 "variable_missing" "" "" "" `module_rows' `key_nonmissing' `key_unique' . . . . . . . .
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
    local zero_n = .
    local negative_n = .
    capture confirm numeric variable `v'
    if _rc == 0 {
        summarize `v', meanonly
        local raw_min = r(min)
        local raw_max = r(max)
        count if `v' == 0
        local zero_n = r(N)
        count if `v' < 0
        local negative_n = r(N)
    }

    survey_write_row "`rowfile'" `w' `yr' `"`level'"' `"`source'"' `"`relpath'"' `"`v'"' `"`audit_role'"' `"`keyvar'"' 1 1 "raw_available_uninterpreted" `"`vlabel'"' `"`vtype'"' `"`vallabel'"' `module_rows' `key_nonmissing' `key_unique' `raw_nonmissing' `raw_missing' `raw_min' `raw_max' `zero_n' `negative_n'
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
sort wave level source audit_role varname
save "`output'/diagnostics/survey_weight_variable_audit.dta", replace
export delimited using "`output'/diagnostics/survey_weight_variable_audit.csv", replace

preserve
keep if audit_role == "geography_candidate"
sort wave source varname
save "`output'/diagnostics/survey_geography_cluster_audit.dta", replace
export delimited using "`output'/diagnostics/survey_geography_cluster_audit.csv", replace
restore

display as result "SURVEY_DESIGN_WEIGHT_AUDIT_ROWS=" _N
display as result "SURVEY_DESIGN_WEIGHT_AUDIT_PASS"
display as result "SURVEY_DESIGN_WEIGHT_AUDIT_NOTE=fields_are_candidates_only_no_svyset_no_final_weight_no_psu_or_stratum_claim"
log close
exit 0
