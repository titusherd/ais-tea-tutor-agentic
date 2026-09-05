version 16.0
clear all
tempfile out
tempname handle
postfile `handle' str244 label using "`out'", replace
local label `"My "quoted" label"'
local safe = subinstr(`"`label'"', char(34), char(39), .)
post `handle' (`"`safe'"')
postclose `handle'
use "`out'", clear
list, noobs
exit 0
