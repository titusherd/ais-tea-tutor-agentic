version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/22_codebook_validity_audit.log", text replace
display as text "CODEBOOK_VALIDITY_AUDIT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "NOTE=metadata and value distributions only; no analytic recode is created"

tempname meta freq
postfile `meta' byte wave int survey_year str24 domain str32 module ///
    str64 raw_varname str244 relpath byte file_exists byte variable_exists ///
    str16 storage_type str244 variable_label str64 value_label ///
    long module_rows long nonmissing long missing double raw_min double raw_max ///
    using "`output'/diagnostics/codebook_metadata_audit.dta", replace
postfile `freq' byte wave int survey_year str24 domain str32 module ///
    str64 raw_varname str244 relpath str244 raw_value str244 value_label_text ///
    long frequency using "`output'/diagnostics/codebook_value_distribution.dta", replace

local spec1 "1 1993 migration mg1 wave1_hh93/buk3mg1.dta mg20 mg2100"
local spec2 "1 1993 migration mg2 wave1_hh93/buk3mg2.dta mg28 mg34 mg40 mg24yr mg25 movenum mg21d2"
local spec3 "2 1997 migration mg1 wave2_hh97/b3a_mg1.dta mg20b mg21n"
local spec4 "2 1997 migration mg2 wave2_hh97/b3a_mg2.dta mg21e mg21ex mg28 mg34 mg40 mg24yr mg25 movenum"
local spec5 "3 2000 migration mg1 wave3_hh00/b3a_mg1.dta mg20b mg20c"
local spec6 "3 2000 migration mg2 wave3_hh00/b3a_mg2.dta mg21e mg21ex mg28 mg34 mg40 mg24yr mg25 movenum"
local spec7 "4 2007 migration mg1 wave4_hh07/b3a_mg1.dta mg20b mg20c"
local spec8 "4 2007 migration mg2 wave4_hh07/b3a_mg2.dta mg21e mg21ex mg28 mg34 mg40 mg24yr mg25 movenum"
local spec9 "5 2014 migration mg1 wave5_hh14/b3a_mg1.dta mg20b mg20c"
local spec10 "5 2014 migration mg2 wave5_hh14/b3a_mg2.dta mg21e mg21ex mg28 mg34 mg40 mg24yr mg25 movenum"
local spec11 "2 1997 childwork_screen tk1 wave2_hh97/b3a_tk1.dta tk01 tk02 tk03 tk04 tk05"
local spec12 "2 1997 childwork_hours tk2 wave2_hh97/b3a_tk2.dta tk21a tk21ax tk21b tk21bx tk22a tk22ax tk22b tk22bx tk23a tk23b tk24a tk27 tk20aind tk20aocc"
local spec13 "3 2000 childwork_screen tk1 wave3_hh00/b3a_tk1.dta tk01 tk02 tk03 tk04 tk05"
local spec14 "3 2000 childwork_hours tk2 wave3_hh00/b3a_tk2.dta tk21a tk21ax tk21b tk21bx tk22a tk22ax tk22b tk22bx tk23a tk23b tk24a tk27 tk19aa tk20a"
local spec15 "5 2014 outcome_labor tk1 wave5_hh14/b3a_tk1.dta tk01 tk02 tk03 tk04 tk05 tk15"
local spec16 "5 2014 outcome_hours tk2 wave5_hh14/b3a_tk2.dta tk21a tk21ax tk21b tk21bx tk22a tk22ax tk22b tk22bx tk23a tk23b tk24a tk24a2 tk24a5 tk25a1 tk25a2 tk26a1 tk26a3"
local spec17 "5 2014 outcome_health kk1 wave5_hh14/b3b_kk1.dta kk01"
local spec18 "5 2014 outcome_education dl1 wave5_hh14/b3a_dl1.dta dl06 dl07 dl07a"
local spec19 "5 2014 outcome_anthropometry us wave5_hh14/bus_us.dta us04 us06"
local spec20 "5 2014 outcome_chronic cd2 wave5_hh14/b3b_cd2.dta cd01"
local spec21 "5 2014 outcome_smoking km wave5_hh14/b3b_km.dta km01a km01e km04"
local spec22 "5 2014 outcome_marriage pk1 wave5_hh14/b3a_pk1.dta pk00a"
local spec23 "5 2014 outcome_trust tr wave5_hh14/b3a_tr.dta tr01 tr02 tr03 tr04 tr05 tr06"

forvalues s = 1/23 {
    local spec "`spec`s''"
    tokenize `"`spec'"'
    local wave `1'
    local year `2'
    local domain `3'
    local module `4'
    local relpath `5'
    macro shift 5
    local vars "`*'"
    local path "`raw'/`relpath'"

    capture confirm file "`path'"
    if _rc != 0 {
        foreach v of local vars {
            post `meta' (`wave') (`year') ("`domain'") ("`module'") ("`v'") ///
                ("`relpath'") (0) (0) ("") ("file not found") ("") (.) (.) (.) (.) (.)
        }
        continue
    }

    use "`path'", clear
    local module_rows = _N
    foreach v of local vars {
        local variable_exists = 1
        capture confirm variable `v'
        if _rc != 0 local variable_exists = 0
        if `variable_exists' == 0 {
            post `meta' (`wave') (`year') ("`domain'") ("`module'") ("`v'") ///
                ("`relpath'") (1) (0) ("") ("variable not found") ("") (`module_rows') (.) (.) (.) (.)
            continue
        }

        local vlabel : variable label `v'
        local vallabel : value label `v'
        local storage : type `v'
        count if !missing(`v')
        local n_nonmissing = r(N)
        count if missing(`v')
        local n_missing = r(N)
        local v_min = .
        local v_max = .
        capture confirm numeric variable `v'
        if _rc == 0 {
            quietly summarize `v', meanonly
            local v_min = r(min)
            local v_max = r(max)
        }
        post `meta' (`wave') (`year') ("`domain'") ("`module'") ("`v'") ///
            ("`relpath'") (1) (1) ("`storage'") ("`vlabel'") ("`vallabel'") ///
            (`module_rows') (`n_nonmissing') (`n_missing') (`v_min') (`v_max')

        preserve
        keep if !missing(`v')
        if _N > 0 {
            contract `v'
            gen str244 _raw_value = ""
            gen str244 _value_label_text = ""
            capture confirm numeric variable `v'
            if _rc == 0 {
                replace _raw_value = string(`v', "%30.0g")
                replace _value_label_text = _raw_value
                capture decode `v', gen(_decoded_value)
                if _rc == 0 replace _value_label_text = _decoded_value
            }
            else {
                replace _raw_value = `v'
                replace _value_label_text = _raw_value
            }
            quietly count
            local n_values = r(N)
            forvalues i = 1/`n_values' {
                local raw_value = _raw_value[`i']
                local value_label_text = _value_label_text[`i']
                local frequency = _freq[`i']
                post `freq' (`wave') (`year') ("`domain'") ("`module'") ("`v'") ///
                    ("`relpath'") ("`raw_value'") ("`value_label_text'") (`frequency')
            }
        }
        restore
    }
}

postclose `meta'
postclose `freq'

use "`output'/diagnostics/codebook_metadata_audit.dta", clear
sort wave domain module raw_varname
save "`output'/diagnostics/codebook_metadata_audit.dta", replace
export delimited using "`output'/diagnostics/codebook_metadata_audit.csv", replace
display as result "CODEBOOK_METADATA_ROWS=" _N

use "`output'/diagnostics/codebook_value_distribution.dta", clear
sort wave domain module raw_varname raw_value
save "`output'/diagnostics/codebook_value_distribution.dta", replace
export delimited using "`output'/diagnostics/codebook_value_distribution.csv", replace
display as result "CODEBOOK_VALUE_ROWS=" _N

display as result "CODEBOOK_VALIDITY_AUDIT_PASS"
log close
exit 0
