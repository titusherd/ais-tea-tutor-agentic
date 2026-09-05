version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local raw "`project'/00_raw"
local output "`project'/04_output"
local docs "`project'/99_docs"

cd "`project'"
log using "`output'/logs/02_inventory_and_codebook_audit.log", text replace

display as text "INVENTORY_START=" c(current_date) " " c(current_time)
display as text "PROJECT_ROOT=`project'"
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

capture confirm file "`docs'/source_manifest.csv"
if _rc {
    display as error "MISSING_CONTROL_DOCUMENT `docs'/source_manifest.csv"
    exit 601
}

tempfile inventory
tempname inv
postfile `inv' ///
    str32 source_id ///
    str12 wave ///
    str244 source_path ///
    str80 archive_or_file ///
    str80 module ///
    str40 unit ///
    str120 candidate_key ///
    long observation_count ///
    int variable_count ///
    str80 release_id ///
    str80 file_size_bytes ///
    str100 sha256 ///
    str244 codebook_path ///
    str80 official_n_target ///
    str30 availability_status ///
    str244 read_only_location ///
    str30 checked_date ///
    str244 notes ///
    using "`inventory'", replace

local roots "`raw'/wave1_hh93 `raw'/wave1_cf93 `raw'/wave2_hh97 `raw'/wave2_cf97 `raw'/wave3_hh00 `raw'/wave3_cf00 `raw'/wave4_hh07 `raw'/wave4_cf07 `raw'/wave5_hh14 `raw'/wave5_cf14"

foreach root of local roots {
    local wave "unknown"
    local source_id "unknown"
    local archive "unknown"
    local codebook "pending_codebook_audit"
    local module_area "household_or_community"

    if strpos("`root'", "/wave1_hh") {
        local wave "1993"
        local source_id "IFLS1-HH"
        local archive "IFLS/hh93dta.zip"
        local codebook "IFLS/vol1_7/volume5-txt.zip; IFLS/vol1_7/volume7.pdf"
        local module_area "household"
    }
    if strpos("`root'", "/wave1_cf") {
        local wave "1993"
        local source_id "IFLS1-CF"
        local archive "IFLS/hh93dta.zip"
        local codebook "IFLS/vol1_7/volume6-txt.zip; IFLS/vol1_7/volume7.pdf"
        local module_area "community"
    }
    if strpos("`root'", "/wave2_hh") {
        local wave "1997"
        local source_id "IFLS2-HH"
        local archive "IFLS/hh97dta.zip plus nested hh97b*.zip"
        local codebook "IFLS/vol1_7/volume5-txt.zip; IFLS/vol1_7/volume7.pdf"
        local module_area "household"
    }
    if strpos("`root'", "/wave2_cf") {
        local wave "1997"
        local source_id "IFLS2-CF"
        local archive "IFLS/cf97dta"
        local codebook "IFLS/vol1_7/volume6-txt.zip; IFLS/vol1_7/volume7.pdf"
        local module_area "community"
    }
    if strpos("`root'", "/wave3_hh") {
        local wave "2000"
        local source_id "IFLS3-HH"
        local archive "IFLS/hh00_all_dta.zip"
        local codebook "IFLS/hh00_all_doc/ifls2000_hhd_*.cbk"
        local module_area "household"
    }
    if strpos("`root'", "/wave3_cf") {
        local wave "2000"
        local source_id "IFLS3-CF"
        local archive "IFLS/cf00_all_dta"
        local codebook "IFLS/hh00_all_doc/ifls2000_cfd_*.cbk if available"
        local module_area "community"
    }
    if strpos("`root'", "/wave4_hh") {
        local wave "2007"
        local source_id "IFLS4-HH"
        local archive "IFLS/hh07_all_dta.zip"
        local codebook "IFLS/IFLS 4/hh07_all_doc/ifls2007_hhd_*.txt"
        local module_area "household"
    }
    if strpos("`root'", "/wave4_cf") {
        local wave "2007"
        local source_id "IFLS4-CF"
        local archive "IFLS/cf07_all_dta"
        local codebook "IFLS/IFLS 4/hh07_all_doc/ifls2007_cfd_*.txt if available"
        local module_area "community"
    }
    if strpos("`root'", "/wave5_hh") {
        local wave "2014"
        local source_id "IFLS5-HH"
        local archive "IFLS/IFLS 5/hh14_all_dta (1).zip"
        local codebook "IFLS/IFLS 5/IFLS5_all_doc (1)/IFLS5_hh_codebooks/ifls2014_hhd_*.txt"
        local module_area "household"
    }
    if strpos("`root'", "/wave5_cf") {
        local wave "2014"
        local source_id "IFLS5-CF"
        local archive "IFLS/IFLS 5/cf14_all_dta (2).zip"
        local codebook "IFLS/IFLS 5/IFLS5_all_doc (1)/IFLS5_cf_codebooks/ifls2014_cf_*.txt"
        local module_area "community"
    }

    local files : dir "`root'" files "*.dta"
    local nfiles : word count `files'
    display as text "ROOT `root' FILES=`nfiles'"
    if `nfiles' == 0 {
        post `inv' ("`source_id'") ("`wave'") ("`root'") ("`archive'") ("`module_area'") ("pending") ("pending") (.) (.) ("pending_release_audit") ("pending_file_size") ("archive_hash_pending") ("`codebook'") ("pending_official_n") ("absent_or_empty") ("`root'") ("`c(current_date)'") ("No .dta files discovered")
        continue
    }

    foreach f of local files {
        local path "`root'/`f'"
        use "`path'", clear
        local N = _N
        local K = c(k)
        post `inv' ("`source_id'") ("`wave'") ("`path'") ("`archive'") ("`module_area'") ("pending_codebook_unit") ("pending_codebook_key") (`N') (`K') ("pending_release_audit") ("pending_file_size") ("archive_hash_pending") ("`codebook'") ("pending_official_n") ("readable_pending_unit_audit") ("`root'") ("`c(current_date)'") ("`f'")
    }
}

postclose `inv'
use "`inventory'", clear
sort wave source_path
save "`output'/diagnostics/file_inventory.dta", replace
export delimited using "`output'/diagnostics/file_inventory.csv", replace

drop source_path
order source_id wave archive_or_file module unit candidate_key observation_count variable_count release_id file_size_bytes sha256 codebook_path official_n_target availability_status read_only_location checked_date notes
export delimited using "`docs'/source_manifest.csv", replace

display as result "FILE_INVENTORY_ROWS=" _N
log close
exit 0
