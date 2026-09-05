version 16.0
clear all
set more off
local project = c(pwd)
local root "`project'/00_raw/wave5_hh14"
local wave "unknown"
local source_id "unknown"
local archive "unknown"
local codebook "pending_codebook_audit"
local module_area "household_or_community"
if strpos("`root'", "/wave5_hh") {
    local wave "2014"
    local source_id "IFLS5-HH"
    local archive "IFLS/IFLS 5/hh14_all_dta (1).zip"
    local codebook "IFLS/IFLS 5/IFLS5_all_doc (1)/IFLS5_hh_codebooks/ifls2014_hhd_*.txt"
    local module_area "household"
}
display as text "ROOT=`root' WAVE=`wave' SOURCE=`source_id' ARCHIVE=`archive' CODEBOOK=`codebook' AREA=`module_area'"
exit 0
