version 16.0
clear all
set more off
tempfile inventory variable_inventory
tempname inv vinv
postfile `inv' str32 source_id str12 wave str244 source_path str80 archive_or_file str80 module str40 unit str120 candidate_key long observation_count int variable_count str80 release_id str80 file_size_bytes str100 sha256 str244 codebook_path str80 official_n_target str30 availability_status str244 read_only_location str30 checked_date str244 notes using "`inventory'", replace
postfile `vinv' str32 source_id str12 wave str244 source_path str80 module str80 raw_name str244 variable_label str80 storage_type str80 display_format using "`variable_inventory'", replace
local project = c(pwd)
local path "`project'/00_raw/wave1_hh93/buk3mg1.dta"
use "`path'", clear
local N = _N
local K = c(k)
post `inv' ("IFLS1-HH") ("1993") ("`path'") ("IFLS/hh93dta.zip") ("Book 3A migration") ("pending") ("pending") (`N') (`K') ("pending") ("pending") ("pending") ("pending") ("pending") ("readable") ("`path'") ("`c(current_date)'") ("probe")
ds
local vars `r(varlist)'
foreach v of local vars {
    local type : type `v'
    local fmt : format `v'
    post `vinv' ("IFLS1-HH") ("1993") ("`path'") ("Book 3A migration") ("`v'") ("") ("`type'") ("`fmt'")
}
postclose `inv'
postclose `vinv'
use "`inventory'", clear
list in 1, noobs
use "`variable_inventory'", clear
count
exit 0
