version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local docs "`project'/99_docs"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/31_finalize_local_source_hashes.log", text replace
display as text "LOCAL_SOURCE_HASH_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "NOTE=compute local extracted-DTA hash and byte size; do not infer official release identity"

import delimited using "`docs'/source_manifest.csv", clear varnames(1) stringcols(_all)
local manifest_n = _N
tempfile hashline sizeline
local hashed_n = 0
local missing_n = 0
local invalid_hash_n = 0

forvalues i = 1/`manifest_n' {
    local directory "`=read_only_location[`i']'"
    local filename "`=notes[`i']'"
    local path "`directory'/`filename'"

    capture confirm file "`path'"
    if _rc != 0 {
        replace availability_status = "missing_local" in `i'
        local missing_n = `missing_n' + 1
        continue
    }

    shell shasum -a 256 "`path'" > "`hashline'"
    file open hashread using "`hashline'", read text
    file read hashread hashline_text
    file close hashread
    local hash_value ""
    gettoken hash_value hash_rest : hashline_text

    shell stat -f %z "`path'" > "`sizeline'"
    file open sizeread using "`sizeline'", read text
    file read sizeread sizeline_text
    file close sizeread
    local byte_value = real(strtrim(`"`sizeline_text'"'))

    if strlen("`hash_value'") == 64 {
        replace sha256 = "`hash_value'" in `i'
        replace file_size_bytes = "`byte_value'" in `i'
        replace availability_status = "readable_local_hash_recorded" in `i'
        local hashed_n = `hashed_n' + 1
    }
    else {
        replace availability_status = "readable_local_hash_failed" in `i'
        local invalid_hash_n = `invalid_hash_n' + 1
    }
}

export delimited using "`docs'/source_manifest.csv", replace
capture erase "`hashline'"
capture erase "`sizeline'"

display as text "MANIFEST_ROWS=`manifest_n'"
display as text "LOCAL_HASHED_ROWS=`hashed_n'"
display as text "LOCAL_MISSING_ROWS=`missing_n'"
display as text "LOCAL_INVALID_HASH_ROWS=`invalid_hash_n'"
if `hashed_n' != `manifest_n' | `missing_n' > 0 | `invalid_hash_n' > 0 {
    display as error "LOCAL_SOURCE_HASH_FAIL=not every manifest row has a local SHA-256"
    log close
    exit 459
}
display as result "LOCAL_SOURCE_HASH_PASS"
display as result "LOCAL_SOURCE_HASH_NOTE=official release identifiers remain unchanged and may still be pending"
log close
exit 0
