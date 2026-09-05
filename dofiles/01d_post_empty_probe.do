version 16.0
clear all
tempfile out
tempname handle
postfile `handle' str20 a str20 b using "`out'", replace
post `handle' ("x") ("")
postclose `handle'
use "`out'", clear
list, noobs
exit 0
