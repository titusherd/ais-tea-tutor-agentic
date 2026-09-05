version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local output "`project'/04_output"
local docs "`project'/99_docs"
local pce_root "`project'/IFLS/IFLS pce-1993-1997_2000-2007"

cd "`project'"
log using "`output'/logs/20_pce_monetary_gap_audit.log", text replace
display as text "PCE_MONETARY_GAP_AUDIT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "NOTE=local PCE provenance and file/variable audit only; no old PCE do-file executed and no final monetary variable constructed"

* Audit all locally identified PCE, deflator, and related W1 expenditure/weight
* files. The expected W5 files are included as explicit gap checks.
tempname fi vi
postfile `fi' str40 source_kind str244 relpath byte file_exists long rows long variable_count ///
    str32 key_candidate str20 key_status long key_nonmissing byte key_unique long duplicate_key_cases str244 note ///
    using "`output'/diagnostics/pce_file_inventory.dta", replace
postfile `vi' str40 source_kind str244 relpath str32 raw_variable str120 variable_label ///
    str32 storage_type str32 display_format str32 value_label long nonmissing long missing ///
    double raw_min double raw_max byte variable_name_keyword_match ///
    using "`output'/diagnostics/pce_variable_inventory.dta", replace

forvalues i = 1/15 {
    local source_kind ""
    local path ""
    local relpath ""
    local key_candidate ""
    if `i' == 1 {
        local source_kind "pce93_nominal"
        local relpath "IFLS/IFLS pce-1993-1997_2000-2007/pce93nom.dta"
        local path "`pce_root'/pce93nom.dta"
        local key_candidate "hhid93"
    }
    if `i' == 2 {
        local source_kind "pce97_nominal"
        local relpath "IFLS/IFLS pce-1993-1997_2000-2007/pce97nom.dta"
        local path "`pce_root'/pce97nom.dta"
        local key_candidate "hhid97"
    }
    if `i' == 3 {
        local source_kind "pce97_real"
        local relpath "IFLS/IFLS pce-1993-1997_2000-2007/pce97.dta"
        local path "`pce_root'/pce97.dta"
        local key_candidate "hhid97"
    }
    if `i' == 4 {
        local source_kind "pce00_nominal"
        local relpath "IFLS/IFLS pce-1993-1997_2000-2007/pce00nom.dta"
        local path "`pce_root'/pce00nom.dta"
        local key_candidate "hhid00"
    }
    if `i' == 5 {
        local source_kind "pce00_real"
        local relpath "IFLS/IFLS pce-1993-1997_2000-2007/pce00.dta"
        local path "`pce_root'/pce00.dta"
        local key_candidate "hhid00"
    }
    if `i' == 6 {
        local source_kind "pce07_nominal"
        local relpath "IFLS/IFLS pce-1993-1997_2000-2007/pce07nom.dta"
        local path "`pce_root'/pce07nom.dta"
        local key_candidate "hhid07"
    }
    if `i' == 7 {
        local source_kind "deflator97"
        local relpath "IFLS/IFLS pce-1993-1997_2000-2007/deflate_hh97.dta"
        local path "`pce_root'/deflate_hh97.dta"
        local key_candidate "hhid97"
    }
    if `i' == 8 {
        local source_kind "deflator00"
        local relpath "IFLS/IFLS pce-1993-1997_2000-2007/deflate_hh00.dta"
        local path "`pce_root'/deflate_hh00.dta"
        local key_candidate "hhid00"
    }
    if `i' == 9 {
        local source_kind "w1_expenditure"
        local relpath "IFLS/hh93dta/expend2.dta"
        local path "`project'/IFLS/hh93dta/expend2.dta"
        local key_candidate "hhid93"
    }
    if `i' == 10 {
        local source_kind "w1_individual_weight"
        local relpath "IFLS/hh93dta/indivwt.dta"
        local path "`project'/IFLS/hh93dta/indivwt.dta"
        local key_candidate "pidlink"
    }
    if `i' == 11 {
        local source_kind "pce93_real_expected"
        local relpath "IFLS/IFLS pce-1993-1997_2000-2007/pce93.dta"
        local path "`pce_root'/pce93.dta"
        local key_candidate "hhid93"
    }
    if `i' == 12 {
        local source_kind "pce14_nominal_expected"
        local relpath "IFLS/IFLS 5/**/pce14nom.dta"
        local path "`project'/IFLS/IFLS 5/pce14nom.dta"
        local key_candidate "hhid14"
    }
    if `i' == 13 {
        local source_kind "pce14_real_expected"
        local relpath "IFLS/IFLS 5/**/pce14.dta"
        local path "`project'/IFLS/IFLS 5/pce14.dta"
        local key_candidate "hhid14"
    }
    if `i' == 14 {
        local source_kind "w5_expenditure_expected"
        local relpath "IFLS/IFLS 5/**/expenditure-derived household PCE"
        local path "`project'/IFLS/IFLS 5/expend14.dta"
        local key_candidate "hhid14"
    }
    if `i' == 15 {
        local source_kind "pce07_real_expected"
        local relpath "IFLS/IFLS pce-1993-1997_2000-2007/pce07.dta"
        local path "`pce_root'/pce07.dta"
        local key_candidate "hhid07"
    }

    capture confirm file "`path'"
    if _rc != 0 {
        local note "expected or identified local file not found; this is an evidence gap, not proof that a file cannot exist outside the inspected local archive"
        post `fi' ("`source_kind'") ("`relpath'") (0) (.) (.) ("`key_candidate'") ("absent") (.) (.) (.) ("`note'")
        continue
    }

    use "`path'", clear
    ds
    local allvars "`r(varlist)'"
    local varcount : word count `allvars'
    local key_status "absent"
    local key_nonmissing = .
    local key_unique = .
    local duplicate_key_cases = .
    capture confirm variable `key_candidate'
    if _rc == 0 {
        local key_status "present"
        count if !missing(`key_candidate')
        local key_nonmissing = r(N)
        preserve
        keep if !missing(`key_candidate')
        bysort `key_candidate': gen long _key_n = _N
        count if _key_n > 1
        local duplicate_key_cases = r(N)
        capture isid `key_candidate'
        local key_unique = (_rc == 0)
        restore
    }
    local note "file readable by Stata; key coverage and within-file uniqueness are recorded; cross-wave merge comparability remains unverified"
    post `fi' ("`source_kind'") ("`relpath'") (1) (_N) (`varcount') ("`key_candidate'") ("`key_status'") (`key_nonmissing') (`key_unique') (`duplicate_key_cases') ("`note'")

    foreach v of local allvars {
        local vlabel : variable label `v'
        local vtype : type `v'
        local vformat : format `v'
        local vallabel : value label `v'
        count if !missing(`v')
        local n_nonmissing = r(N)
        count if missing(`v')
        local n_missing = r(N)
        local v_min = .
        local v_max = .
        capture confirm numeric variable `v'
        if _rc == 0 {
            summarize `v', meanonly
            local v_min = r(min)
            local v_max = r(max)
        }
        local keyword_match = regexm(lower("`v'"), "pce|expend|food|nonfood|total|price|deflat|cpi|income|wage|salary|rtotal|rfood|rnonfood")
        post `vi' ("`source_kind'") ("`relpath'") ("`v'") ("`vlabel'") ("`vtype'") ("`vformat'") ("`vallabel'") (`n_nonmissing') (`n_missing') (`v_min') (`v_max') (`keyword_match')
    }
}
postclose `fi'
postclose `vi'

use "`output'/diagnostics/pce_file_inventory.dta", clear
sort source_kind
save "`output'/diagnostics/pce_file_inventory.dta", replace
export delimited using "`output'/diagnostics/pce_file_inventory.csv", replace

use "`output'/diagnostics/pce_variable_inventory.dta", clear
sort source_kind raw_variable
save "`output'/diagnostics/pce_variable_inventory.dta", replace
export delimited using "`output'/diagnostics/pce_variable_inventory.csv", replace

* Source-text evidence is recorded as provenance, not executed as analysis.
* These statements are intentionally limited to lines inspected in the local
* PCE do-files; no claim is made about W5 harmonization until a W5 derivation
* and its source inputs are available and independently rerun.
tempname sa
postfile `sa' str80 source_file str32 specification_dimension str80 asserted_rule str244 evidence str32 status ///
    using "`output'/diagnostics/pce_specification_audit.dta", replace
post `sa' ("IFLS/IFLS pce-1993-1997_2000-2007/pce97.do") ("temporal_base") ("December 2000") ("local source text at pce97.do:1726 states temporal deflator with December 2000 as base") ("verified_source_text")
post `sa' ("IFLS/IFLS pce-1993-1997_2000-2007/pce00.do") ("temporal_base") ("December 2000") ("local source text at pce00.do:1665 states temporal deflator with December 2000 as base") ("verified_source_text")
post `sa' ("IFLS/IFLS pce-1993-1997_2000-2007/pce97.do") ("spatial_base") ("Jakarta") ("local source text at pce97.do:1726 and subsequent calculation state spatial deflator with Jakarta as base") ("verified_source_text")
post `sa' ("IFLS/IFLS pce-1993-1997_2000-2007/pce00.do") ("spatial_base") ("Jakarta") ("local source text at pce00.do:1665 and subsequent calculation state spatial deflator with Jakarta as base") ("verified_source_text")
post `sa' ("IFLS/IFLS pce-1993-1997_2000-2007/pce*.do") ("execution_portability") ("old Windows paths") ("local do-files contain legacy drive/path references; do not execute unchanged in the current macOS project") ("verified_source_text")
post `sa' ("IFLS/IFLS 5 local archive") ("W5_PCE") ("not established") ("local file inventory identified IFLS5 price PDFs but no derived pce14/pce14nom file in the inspected working archive") ("gap_open")
postclose `sa'
use "`output'/diagnostics/pce_specification_audit.dta", clear
sort source_file specification_dimension
save "`output'/diagnostics/pce_specification_audit.dta", replace
export delimited using "`output'/diagnostics/pce_specification_audit.csv", replace

* Compact explicit gap register for monetary harmonization.
tempname gap
postfile `gap' str48 component byte local_present str40 status str244 evidence ///
    using "`output'/diagnostics/pce_monetary_gap.dta", replace
foreach item in "pce14nom" "pce14" "expend14" {
    local checkpath ""
    if "`item'" == "pce14nom" local checkpath "`project'/IFLS/IFLS 5/pce14nom.dta"
    if "`item'" == "pce14" local checkpath "`project'/IFLS/IFLS 5/pce14.dta"
    if "`item'" == "expend14" local checkpath "`project'/IFLS/IFLS 5/expend14.dta"
    capture confirm file "`checkpath'"
    local present = (_rc == 0)
    local status "not_found_at_expected_path"
    if `present' == 1 local status "found_at_expected_path"
    local evidence "expected path check only; recursive local archive inventory remains the controlling evidence for W5 gap"
    post `gap' ("`item'") (`present') ("`status'") ("`evidence'")
}
post `gap' ("IFLS5_price_pdf_market") (1) ("price_material_only") ("local IFLS5 archive contains market-price PDF; this is not a household PCE output")
post `gap' ("IFLS5_price_pdf_warung") (1) ("price_material_only") ("local IFLS5 archive contains warung-price PDF; this is not a household PCE output")
postclose `gap'
use "`output'/diagnostics/pce_monetary_gap.dta", clear
sort component
save "`output'/diagnostics/pce_monetary_gap.dta", replace
export delimited using "`output'/diagnostics/pce_monetary_gap.csv", replace

display as result "PCE_MONETARY_GAP_AUDIT_PASS"
display as result "PCE_MONETARY_GAP_AUDIT_NOTE=historical PCE/deflator outputs and source rules are recorded; W5 PCE and common-base monetary harmonization remain open"
log close
exit 0
