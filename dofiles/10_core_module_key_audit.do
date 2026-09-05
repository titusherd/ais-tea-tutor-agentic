version 16.0
clear all
set more off
set seed 9042026

local project = c(pwd)
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/10_core_module_key_audit.log", text replace
display as text "CORE_MODULE_KEY_AUDIT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "SEED=9042026"

tempname h
postfile `h' int wave int survey_year str24 topic str244 relpath ///
    byte file_exists long obs_count int var_count ///
    byte has_pidlink long pidlink_nonmissing long pidlink_missing byte pidlink_unique ///
    byte has_hhid_pid long hhid_pid_nonmissing long hhid_pid_missing byte hhid_pid_unique ///
    byte has_secondary byte pidlink_secondary_unique byte unit_code ///
    using "`output'/diagnostics/core_module_key_audit.dta", replace
global CORE_KEY_HANDLE `h'
global PROJECT_ROOT "`project'"

* This program only inspects a file and returns scalars.  Posting is kept at
* the caller level because Stata 16 can misparse a post command inside a
* program after a long sequence of file loads.
capture program drop inspect_core_file
program define inspect_core_file, rclass
    version 16.0
    syntax, Wave(integer) Year(integer) Topic(string) Relpath(string) Hhid(string) Pid(string) Pidlink(string) [Secondary(string)]

    local path "${PROJECT_ROOT}/00_raw/`relpath'"
    return scalar wave = `wave'
    return scalar survey_year = `year'
    return local topic "`topic'"
    return local relpath "`relpath'"

    capture confirm file "`path'"
    if _rc != 0 {
        return scalar file_exists = 0
        return scalar obs_count = .
        return scalar var_count = .
        return scalar has_pidlink = .
        return scalar pidlink_nonmissing = .
        return scalar pidlink_missing = .
        return scalar pidlink_unique = .
        return scalar has_hhid_pid = .
        return scalar hhid_pid_nonmissing = .
        return scalar hhid_pid_missing = .
        return scalar hhid_pid_unique = .
        return scalar has_secondary = .
        return scalar pidlink_secondary_unique = .
        return scalar unit_code = .
        exit
    }

    use "`path'", clear
    local nobs = _N
    local nvars = c(k)

    local has_pidlink = 0
    local pid_nonmiss = .
    local pid_miss = .
    local pid_unique = .
    capture confirm variable `pidlink'
    if _rc == 0 {
        local has_pidlink = 1
        count if !missing(`pidlink')
        local pid_nonmiss = r(N)
        count if missing(`pidlink')
        local pid_miss = r(N)
        preserve
        keep if !missing(`pidlink')
        capture isid `pidlink'
        local pid_unique = (_rc == 0)
        restore
    }

    local has_hhid_pid = 0
    local hp_nonmiss = .
    local hp_miss = .
    local hp_unique = .
    capture confirm variable `hhid'
    local hhid_rc = _rc
    capture confirm variable `pid'
    local pid_rc = _rc
    if `hhid_rc' == 0 & `pid_rc' == 0 {
        local has_hhid_pid = 1
        count if !missing(`hhid') & !missing(`pid')
        local hp_nonmiss = r(N)
        count if missing(`hhid') | missing(`pid')
        local hp_miss = r(N)
        preserve
        keep if !missing(`hhid') & !missing(`pid')
        capture isid `hhid' `pid'
        local hp_unique = (_rc == 0)
        restore
    }

    local has_secondary = 0
    local pid_secondary_unique = .
    if "`secondary'" != "" {
        capture confirm variable `secondary'
        if _rc == 0 & `has_pidlink' == 1 {
            local has_secondary = 1
            preserve
            keep if !missing(`pidlink') & !missing(`secondary')
            capture isid `pidlink' `secondary'
            local pid_secondary_unique = (_rc == 0)
            restore
        }
    }

    local unit_code = 5
    if `pid_unique' == 1 local unit_code = 1
    else if `pid_secondary_unique' == 1 local unit_code = 2
    else if `hp_unique' == 1 local unit_code = 3
    else if `has_pidlink' == 0 & `has_hhid_pid' == 1 local unit_code = 4

    return scalar file_exists = 1
    return scalar obs_count = `nobs'
    return scalar var_count = `nvars'
    return scalar has_pidlink = `has_pidlink'
    return scalar pidlink_nonmissing = `pid_nonmiss'
    return scalar pidlink_missing = `pid_miss'
    return scalar pidlink_unique = `pid_unique'
    return scalar has_hhid_pid = `has_hhid_pid'
    return scalar hhid_pid_nonmissing = `hp_nonmiss'
    return scalar hhid_pid_missing = `hp_miss'
    return scalar hhid_pid_unique = `hp_unique'
    return scalar has_secondary = `has_secondary'
    return scalar pidlink_secondary_unique = `pid_secondary_unique'
    return scalar unit_code = `unit_code'
end

* The caller posts one row per selected file, including missing-file rows.
foreach spec in ///
    "1 1993 migration wave1_hh93/buk3mg1.dta hhid93 pid93 pidlink NONE" ///
    "1 1993 migration wave1_hh93/buk3mg2.dta hhid93 pid93 pidlink movenum" ///
    "1 1993 child_work wave1_hh93/buk3tk1.dta hhid93 pid93 pidlink NONE" ///
    "1 1993 child_work wave1_hh93/buk3tk2.dta hhid93 pid93 pidlink NONE" ///
    "1 1993 child_work wave1_hh93/buk3tk3.dta hhid93 pid93 pidlink NONE" ///
    "1 1993 child_work wave1_hh93/buk3tk5.dta hhid93 pid93 pidlink NONE" ///
    "2 1997 migration wave2_hh97/b3a_mg1.dta hhid97 pid97 pidlink NONE" ///
    "2 1997 migration wave2_hh97/b3a_mg2.dta hhid97 pid97 pidlink movenum" ///
    "2 1997 child_work wave2_hh97/b3a_tk1.dta hhid97 pid97 pidlink NONE" ///
    "3 2000 migration wave3_hh00/b3a_mg1.dta hhid00 pid00 pidlink NONE" ///
    "3 2000 migration wave3_hh00/b3a_mg2.dta hhid00 pid00 pidlink movenum" ///
    "3 2000 child_work wave3_hh00/b3a_tk1.dta hhid00 pid00 pidlink NONE" ///
    "3 2000 child_work wave3_hh00/b3a_tk2.dta hhid00 pid00 pidlink jobnum" ///
    "3 2000 child_work wave3_hh00/b3a_tk3.dta hhid00 pid00 pidlink year" ///
    "3 2000 child_work wave3_hh00/b3a_tk4.dta hhid00 pid00 pidlink jobnum" ///
    "4 2007 migration wave4_hh07/b3a_mg1.dta hhid07 pid07 pidlink NONE" ///
    "4 2007 migration wave4_hh07/b3a_mg2.dta hhid07 pid07 pidlink movenum" ///
    "4 2007 child_work wave4_hh07/b3a_tk1.dta hhid07 pid07 pidlink NONE" ///
    "4 2007 child_work wave4_hh07/b3a_tk2.dta hhid07 pid07 pidlink jobnum" ///
    "4 2007 child_work wave4_hh07/b3a_tk3.dta hhid07 pid07 pidlink year" ///
    "4 2007 child_work wave4_hh07/b3a_tk4.dta hhid07 pid07 pidlink jobnum" ///
    "5 2014 migration wave5_hh14/b3a_mg1.dta hhid14 pid14 pidlink NONE" ///
    "5 2014 migration wave5_hh14/b3a_mg2.dta hhid14 pid14 pidlink movenum" ///
    "5 2014 child_work wave5_hh14/b3a_tk1.dta hhid14 pid14 pidlink NONE" ///
    "5 2014 child_work wave5_hh14/b3a_tk2.dta hhid14 pid14 pidlink jobnum" ///
    "5 2014 child_work wave5_hh14/b3a_tk3.dta hhid14 pid14 pidlink year" ///
    "5 2014 child_work wave5_hh14/b3a_tk4.dta hhid14 pid14 pidlink jobnum" {
    tokenize `"`spec'"'
    local swave "`1'"
    local syear "`2'"
    local stopic "`3'"
    local srelpath "`4'"
    local shhid "`5'"
    local spid "`6'"
    local spidlink "`7'"
    local ssecondary "`8'"
    if "`ssecondary'" == "NONE" local ssecondary ""
    if "`ssecondary'" == "" {
        inspect_core_file, wave(`swave') year(`syear') topic(`stopic') relpath(`srelpath') hhid(`shhid') pid(`spid') pidlink(`spidlink')
    }
    else {
        inspect_core_file, wave(`swave') year(`syear') topic(`stopic') relpath(`srelpath') hhid(`shhid') pid(`spid') pidlink(`spidlink') secondary(`ssecondary')
    }
    post $CORE_KEY_HANDLE (`r(wave)') (`r(survey_year)') ("`r(topic)'") ("`r(relpath)'") ///
        (`r(file_exists)') (`r(obs_count)') (`r(var_count)') (`r(has_pidlink)') ///
        (`r(pidlink_nonmissing)') (`r(pidlink_missing)') (`r(pidlink_unique)') ///
        (`r(has_hhid_pid)') (`r(hhid_pid_nonmissing)') (`r(hhid_pid_missing)') (`r(hhid_pid_unique)') ///
        (`r(has_secondary)') (`r(pidlink_secondary_unique)') (`r(unit_code)')
}

* Roster and key adult-outcome source modules used for the next crosswalk pass.
foreach wave in 1 2 3 4 5 {
    local year = cond(`wave' == 1, 1993, cond(`wave' == 2, 1997, cond(`wave' == 3, 2000, cond(`wave' == 4, 2007, 2014))))
    local folder = cond(`wave' == 1, "wave1_hh93", cond(`wave' == 2, "wave2_hh97", cond(`wave' == 3, "wave3_hh00", cond(`wave' == 4, "wave4_hh07", "wave5_hh14"))))
    local hhid = cond(`wave' == 1, "hhid93", cond(`wave' == 2, "hhid97", cond(`wave' == 3, "hhid00", cond(`wave' == 4, "hhid07", "hhid14"))))
    local pid = cond(`wave' == 1, "pid93", cond(`wave' == 2, "pid97", cond(`wave' == 3, "pid00", cond(`wave' == 4, "pid07", "pid14"))))
    local bkfile = cond(`wave' == 1, "bukkar2.dta", "bk_ar1.dta")
    inspect_core_file, wave(`wave') year(`year') topic(roster) relpath(`folder'/`bkfile') hhid(`hhid') pid(`pid') pidlink(pidlink)
    post $CORE_KEY_HANDLE (`r(wave)') (`r(survey_year)') ("`r(topic)'") ("`r(relpath)'") ///
        (`r(file_exists)') (`r(obs_count)') (`r(var_count)') (`r(has_pidlink)') ///
        (`r(pidlink_nonmissing)') (`r(pidlink_missing)') (`r(pidlink_unique)') ///
        (`r(has_hhid_pid)') (`r(hhid_pid_nonmissing)') (`r(hhid_pid_missing)') (`r(hhid_pid_unique)') ///
        (`r(has_secondary)') (`r(pidlink_secondary_unique)') (`r(unit_code)')
}

foreach spec in ///
    "2 1997 b3b_cov.dta" "3 2000 b3b_cov.dta" "4 2007 b3b_cov.dta" "5 2014 b3b_cov.dta" ///
    "4 2007 b3b_rj0.dta" "4 2007 b3b_rj1.dta" "4 2007 b3b_rj3.dta" ///
    "5 2014 b3b_rj0.dta" "5 2014 b3b_rj1.dta" "5 2014 b3b_rj2.dta" "5 2014 b3b_rj3.dta" ///
    "4 2007 b3b_ps.dta" "5 2014 b3b_ps.dta" "5 2014 b3b_psn.dta" ///
    "4 2007 b3b_ak1.dta" "4 2007 b3b_ak2.dta" "5 2014 b3b_ak1.dta" "5 2014 b3b_ak2.dta" ///
    "4 2007 b3b_km.dta" "5 2014 b3b_km.dta" "4 2007 b3b_cd1.dta" "4 2007 b3b_cd2.dta" "4 2007 b3b_cd3.dta" ///
    "5 2014 b3b_cd1.dta" "5 2014 b3b_cd2.dta" "5 2014 b3b_cd3.dta" "4 2007 b3b_co1.dta" "4 2007 b3b_co2.dta" "4 2007 b3b_co3.dta" ///
    "5 2014 b3b_co1.dta" "5 2014 b3b_cob.dta" "4 2007 bek_ek1.dta" "4 2007 bek_ek2.dta" "5 2014 ek_time1.dta" "5 2014 ek_time2.dta" {
    tokenize `"`spec'"'
    local swave "`1'"
    local syear "`2'"
    local sfile "`3'"
    local sfolder = cond(`swave' == 2, "wave2_hh97", cond(`swave' == 3, "wave3_hh00", cond(`swave' == 4, "wave4_hh07", "wave5_hh14")))
    local shhid = cond(`swave' == 2, "hhid97", cond(`swave' == 3, "hhid00", cond(`swave' == 4, "hhid07", "hhid14")))
    local spid = cond(`swave' == 2, "pid97", cond(`swave' == 3, "pid00", cond(`swave' == 4, "pid07", "pid14")))
    inspect_core_file, wave(`swave') year(`syear') topic(adult_outcome_source) relpath(`sfolder'/`sfile') hhid(`shhid') pid(`spid') pidlink(pidlink)
    post $CORE_KEY_HANDLE (`r(wave)') (`r(survey_year)') ("`r(topic)'") ("`r(relpath)'") ///
        (`r(file_exists)') (`r(obs_count)') (`r(var_count)') (`r(has_pidlink)') ///
        (`r(pidlink_nonmissing)') (`r(pidlink_missing)') (`r(pidlink_unique)') ///
        (`r(has_hhid_pid)') (`r(hhid_pid_nonmissing)') (`r(hhid_pid_missing)') (`r(hhid_pid_unique)') ///
        (`r(has_secondary)') (`r(pidlink_secondary_unique)') (`r(unit_code)')
}

postclose `h'

use "`output'/diagnostics/core_module_key_audit.dta", clear
label define unit_code_lbl 1 "one_row_per_pidlink" 2 "pidlink_secondary_unit" 3 "one_row_per_hhid_pid" 4 "household_or_repeated_hhid_pid" 5 "multi_record_or_key_unresolved"
label values unit_code unit_code_lbl
sort wave topic relpath
save "`output'/diagnostics/core_module_key_audit.dta", replace
export delimited using "`output'/diagnostics/core_module_key_audit.csv", replace
list if file_exists == 0, noobs abbreviate(28)
display as text "CORE_MODULE_KEY_AUDIT_ROWS=" _N
display as result "CORE_MODULE_KEY_AUDIT_PASS"
log close
exit 0
