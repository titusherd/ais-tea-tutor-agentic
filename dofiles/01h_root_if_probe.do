version 16.0
clear all
set more off
local project = c(pwd)
local raw "`project'/00_raw"
local output "`project'/04_output"
local roots ///
    "`raw'/wave1_hh93" ///
    "`raw'/wave1_cf93" ///
    "`raw'/wave2_hh97" ///
    "`raw'/wave2_cf97" ///
    "`raw'/wave3_hh00" ///
    "`raw'/wave3_cf00" ///
    "`raw'/wave4_hh07" ///
    "`raw'/wave4_cf07" ///
    "`raw'/wave5_hh14" ///
    "`raw'/wave5_cf14"
log using "`output'/logs/01h_root_if_probe.log", text replace
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
    if strpos("`root'", "/wave5_hh") {
        local wave "2014"
        local source_id "IFLS5-HH"
        local archive "IFLS/IFLS 5/hh14_all_dta (1).zip"
        local codebook "IFLS/IFLS 5/IFLS5_all_doc (1)/IFLS5_hh_codebooks/ifls2014_hhd_*.txt"
        local module_area "household"
    }
    display as text "ROOT=`root' WAVE=`wave' SOURCE=`source_id' ARCHIVE=`archive' CODEBOOK=`codebook' AREA=`module_area'"
}
log close
exit 0
