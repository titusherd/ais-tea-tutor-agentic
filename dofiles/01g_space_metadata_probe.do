version 16.0
clear all
tempfile out
tempname h
postfile `h' str244 a str244 b str244 c using "`out'", replace
local a "IFLS/IFLS 5/hh14_all_dta (1).zip"
local b "IFLS/vol1_7/volume5-txt.zip; IFLS/vol1_7/volume7.pdf"
local c "pending_codebook_unit"
post `h' ("`a'") ("`b'") ("`c'")
postclose `h'
use "`out'", clear
list, noobs
exit 0
