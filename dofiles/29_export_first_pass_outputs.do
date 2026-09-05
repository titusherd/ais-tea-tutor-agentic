version 16.0
clear all
set more off
set seed 9042026

local project "/Users/titus/Documents/ais-tea"
local derived "`project'/02_derived"
local output "`project'/04_output"

cd "`project'"
log using "`output'/logs/29_export_first_pass_outputs.log", text replace
display as text "FIRST_PASS_EXPORT_START=" c(current_date) " " c(current_time)
display as text "STATA_VERSION=" c(stata_version)
display as text "NOTE=descriptive support, predeclared heterogeneity counts, and coefficient/age-profile graphics only"

* --------------------------------------------------------------------------
* 1. Export a compact primary-results table and confidence intervals.
* --------------------------------------------------------------------------
use "`output'/tables/first_pass_model_results.dta", clear
keep if model_tier == "core_adjusted_clustered" & status == "pass"
gen double ci_low = coefficient - invttail(df_r, .025) * standard_error
gen double ci_high = coefficient + invttail(df_r, .025) * standard_error
order paper family outcome model_tier status sample_n treated_n control_n ///
    treated_cluster_n cluster_n coefficient standard_error ci_low ci_high ///
    p_value bh_q_value spec_lock_id weight_rule cluster_rule interpretation_label
sort paper family outcome
save "`output'/tables/first_pass_primary_results.dta", replace
export delimited using "`output'/tables/first_pass_primary_results.csv", replace

* Separate plots keep labels readable and do not suppress outcomes that are
* statistically unremarkable. The horizontal zero line is the association
* reference, not a causal null claim.
foreach paper in R1 R3 {
    preserve
    keep if paper == "`paper'"
    encode outcome, gen(outcome_id)
    sort outcome_id
    local max_outcomes = _N
    twoway ///
        (rcap ci_low ci_high outcome_id, horizontal lcolor(navy)) ///
        (scatter outcome_id coefficient, mcolor(maroon) msymbol(D)) ///
        , yscale(reverse) ylabel(1(1)`max_outcomes', valuelabel angle(0) labsize(vsmall)) ///
          xline(0, lpattern(dash) lcolor(gs8)) ///
          xtitle("Coefficient: adjusted association") ///
          ytitle("") title("`paper' first-pass primary associations") ///
          subtitle("95% t-based CI; household-clustered robust VCE") ///
          legend(off) graphregion(color(white)) plotregion(color(white))
    graph export "`output'/figures/first_pass_coefficients_`paper'.png", ///
        width(1900) replace
    restore
}

* --------------------------------------------------------------------------
* 2. R3 age-profile support graph. Treatment prevalence is calculated only
* among classified treated/control cases. The second panel reports the share
* unresolved, so ages with no usable screen are visible rather than silently
* presented as zero treatment prevalence.
* --------------------------------------------------------------------------
use "`derived'/r3_child_labor_treatment.dta", clear
keep if inlist(r3_age_band, "10_11", "12_14", "15")
gen byte _treated = r3_status == "treated"
gen byte _control = r3_status == "control"
gen byte _unresolved_screen = r3_status == "unresolved_screen"
gen byte _unresolved_hours = r3_status == "unresolved_hours"
gen byte _row = 1
collapse (sum) band_n=_row treated_n=_treated control_n=_control ///
    unresolved_screen_n=_unresolved_screen unresolved_hours_n=_unresolved_hours, ///
    by(wave survey_year r3_age_band)
gen classified_n = treated_n + control_n
gen double prevalence_classified_pct = 100 * treated_n / classified_n if classified_n > 0
gen double unresolved_share_pct = 100 * (unresolved_screen_n + unresolved_hours_n) / band_n if band_n > 0
sort wave r3_age_band
save "`output'/diagnostics/r3_age_profile_support.dta", replace
export delimited using "`output'/diagnostics/r3_age_profile_support.csv", replace

label define wave_lbl 2 "W2 (1997)" 3 "W3 (2000)", replace
label values wave wave_lbl
graph bar (asis) prevalence_classified_pct if classified_n > 0, ///
    over(r3_age_band, label(angle(45))) over(wave) ///
    ylabel(0(20)100, angle(0)) ///
    ytitle("Treated share among classified cases (%)") ///
    title("R3 age profile: classified treatment prevalence") ///
    note("Ages with no classified screen/hour status are omitted; see unresolved panel.") ///
    legend(off) graphregion(color(white)) plotregion(color(white))
graph save "`output'/figures/r3_age_profile_classified.gph", replace
graph export "`output'/figures/r3_age_profile_classified.png", width(1800) replace
graph bar (asis) unresolved_share_pct, ///
    over(r3_age_band, label(angle(45))) over(wave) ///
    ylabel(0(20)100, angle(0)) ///
    ytitle("Unresolved screen/hour share (%)") ///
    title("R3 age profile: unresolved treatment status") ///
    legend(off) graphregion(color(white)) plotregion(color(white))
graph save "`output'/figures/r3_age_profile_unresolved.gph", replace
graph export "`output'/figures/r3_age_profile_unresolved.png", width(1800) replace

* --------------------------------------------------------------------------
* 3. R1 heterogeneity support. The primary lock is mother-only, so migrating
* parent is not estimated as a comparison. With 25 treated children, the
* remaining dimensions are counts for feasibility and sample description,
* not subgroup regressions.
* --------------------------------------------------------------------------
tempname h
postfile `h' str28 dimension str48 category long treated_n control_n total_n ///
    str24 status str180 note ///
    using "`output'/diagnostics/r1_heterogeneity_descriptive.dta", replace

use "`derived'/r1_analysis_base.dta", clear
keep if r1_analysis_frame == 1

count if r1_treatment == 1
local r1_treated = r(N)
count if r1_treatment == 0
local r1_control = r(N)
local r1_total = `r1_treated' + `r1_control'
post `h' ("overall") ("primary analysis frame") (`r1_treated') (`r1_control') ///
    (`r1_total') ("descriptive") ///
    ("Primary frame totals; no subgroup claim is made from these counts.")

count if r1_treatment == 1
local treated_n = r(N)
post `h' ("migrating_parent") ("mother_only_primary") (`treated_n') (0) (`treated_n') ///
    ("locked_by_design") ///
    ("The primary estimand is mother-led; father/any-parent comparison is not identified by the locked treatment definition.")

levelsof first_qualifying_wave if r1_treatment == 1, local(qualifying_waves)
foreach w of local qualifying_waves {
    count if r1_treatment == 1 & first_qualifying_wave == `w'
    local n = r(N)
    post `h' ("onset_wave") ("wave_`w'") (`n') (0) (`n') ("descriptive") ///
        ("Count of treated children by first qualifying migration wave.")
}

gen double onset_age_approx = w1_age + first_qualifying_year - 1993 if r1_treatment == 1
gen str32 onset_age_bin = ""
replace onset_age_bin = "0-5" if inrange(onset_age_approx, 0, 5)
replace onset_age_bin = "6-11" if inrange(onset_age_approx, 6, 11)
replace onset_age_bin = "12-17" if inrange(onset_age_approx, 12, 17)
replace onset_age_bin = "18+" if onset_age_approx >= 18 & onset_age_approx < .
replace onset_age_bin = "unknown" if r1_treatment == 1 & missing(onset_age_bin)
levelsof onset_age_bin if r1_treatment == 1, local(onset_bins)
foreach b of local onset_bins {
    count if r1_treatment == 1 & onset_age_bin == "`b'"
    local n = r(N)
    post `h' ("approx_onset_age") ("`b'") (`n') (0) (`n') ("descriptive") ///
        ("Approximate age uses W1 survey age plus qualifying event year minus 1993; it is not exact birth-date age.")
}

post `h' ("caregiver") ("not_constructed") (.) (.) (.) ("not_estimated") ///
    ("No verified caregiver treatment field is present in the locked primary output; do not infer caregiver heterogeneity.")

postclose `h'
use "`output'/diagnostics/r1_heterogeneity_descriptive.dta", clear
sort dimension category
save "`output'/diagnostics/r1_heterogeneity_descriptive.dta", replace
export delimited using "`output'/diagnostics/r1_heterogeneity_descriptive.csv", replace

display as result "FIRST_PASS_EXPORT_PASS"
display as result "FIRST_PASS_EXPORT_NOTE=plots and heterogeneity outputs are descriptive support artifacts; no subgroup regression was promoted"
log close
exit 0
