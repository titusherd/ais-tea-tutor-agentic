version 16.0
clear all
tempfile inventory
tempname inv
postfile `inv' str32 source_id str12 wave str244 source_path str80 archive_or_file str80 module str40 unit str120 candidate_key long observation_count int variable_count str80 release_id str80 file_size_bytes str100 sha256 str244 codebook_path str80 official_n_target str30 availability_status str244 read_only_location str30 checked_date str244 notes using "`inventory'", replace
local roots "/Users/titus/Documents/ais-tea/00_raw/wave1_hh93 /Users/titus/Documents/ais-tea/00_raw/wave1_cf93"
foreach root of local roots {
    local source_id "IFLS1"
    local wave "1993"
    local archive "IFLS/hh93dta.zip"
    local codebook "IFLS/vol1_7/volume5-txt.zip"
    local files : dir "`root'" files "*.dta"
    foreach f of local files {
        local path "`root'/`f'"
        use "`path'", clear
        local N = _N
        local K = c(k)
        local module "`f'"
        post `inv' ("`source_id'") ("`wave'") ("`path'") ("`archive'") ("`module'") ("pending") ("pending") (`N') (`K') ("pending") ("pending") ("pending") ("`codebook'") ("pending") ("readable") ("`root'") ("`c(current_date)'") ("`f'")
    }
}
postclose `inv'
use "`inventory'", clear
count
exit 0
