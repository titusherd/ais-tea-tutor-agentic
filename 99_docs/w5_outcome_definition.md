# W5 adult outcomes

Date: 2026-09-05  
Status: `technical_gate_pass`  
Specification: `D-031/D-032/D-040/D-041`

## Outcome universe

The W5 outcome universe is observed W5 persons aged 17–36 with a nonmissing
W5 household ID: 18,132 person records in 11,153 households. Modules are
merged at `pidlink`; repeated condition records are collapsed to one
person-level condition flag before merging.

Each outcome is analysed separately. No combined 14-item IMDI is created,
and the missing W5 `b3b_vg` module is not described as a complete CES-D-10
measure.

## Outcome-family register

| Family | Outcome | Raw basis and valid rule | Valid N in universe |
|---|---|---|---:|
| labor | `adult_employed` | `TK01` in valid activity codes `1,2,3,4,5,7,95`; employed=`1` only | 15,846 |
| labor | `adult_ln1p_salary_monthly` | `TK25A1X==1`, `TK25A1` in `0` to `<999999997`; `ln(1+salary)` | 7,069 |
| labor | `adult_ln1p_abs_profit` | `TK26A1X` in `1,2`, `TK26A1` in `0` to `<999999999998`; sign retained, model uses `ln(1+abs(profit))` | 3,018 |
| education | `adult_college` | valid `DL06`; college/university codes `60–63` | 15,728 |
| health | `adult_srh_score` | `KK01` codes `1–4`; score=`5-KK01`, higher is better | 15,770 |
| health | `adult_good_health` | valid `KK01`; good health=`KK01` 1 or 2 | 15,770 |
| health | `adult_bmi_raw` | measured `US04X/US06X`; height 100–250 cm; weight 20–250 kg; BMI 10–80 | 15,089 |
| health | `adult_health_adequacy` | `SW06` codes `1–3` | 15,038* |
| social/behavioral | `adult_current_smoker` | explicit `KM01A/KM01E/KM04` cigarette response; current smoker only when current use is supported | 15,770 |
| social/behavioral | `adult_married` | `PK00A` codes `1` or `3` | 10,787 |
| social/behavioral | `adult_any_listed_condition` | `CD01` collapsed across condition rows; yes=`1`, no=`3`, DK=`8` excluded | 15,764 |
| social/behavioral | `adult_tr01_score`–`adult_tr06_score` | each `TR` item valid `1–4`; reverse score=`5-item` | module-specific; see support CSV |

\* `SW06` is retained with its module-specific coverage; the exact analytic
support is recorded in `04_output/diagnostics/analysis_outcome_support.csv`.

Salary and profit are not converted into cross-wave real money. They are
within-W5 variables with their original W5 reference period. There is no
PCE deflation or NPV in the first pass.

## Validity audit facts

The W5 validity audit records the following observed/invalid/missing facts:

- salary: 7,152 observed, 83 invalid, 11,063 not valid;
- profit: 3,090 observed, 72 invalid, 15,114 not valid;
- BMI: 15,132 height/weight observations, 43 invalid, 3,043 not valid;
- employment: 15,846 valid, 2,286 not valid or unavailable;
- college indicator: 15,728 valid, 2,404 not valid or unavailable;
- listed condition: 15,764 valid, 6 invalid, 2,374 not valid or unavailable;
- self-rated health: 15,770 valid, 2,362 not valid or unavailable;
- marriage: 10,787 valid, 7,345 not valid or unavailable.

## Model handling

The primary missingness rule is outcome-specific listwise deletion within the
common R1/R3 analysis frame. The model does not impute missing outcomes and
does not force a common index. Benjamini–Hochberg q-values are calculated
within each predeclared paper-by-family group for successful core-adjusted
models.

## Files

- Outcome data: `02_derived/w5_adult_outcomes.dta`
- Validity audit: `04_output/diagnostics/w5_outcome_validity_audit.csv`
- Merge audit: `04_output/diagnostics/w5_outcome_merge_audit.csv`
- Outcome support after analysis-frame restriction:
  `04_output/diagnostics/analysis_outcome_support.csv`
- Construction log: `04_output/logs/25_build_w5_adult_outcomes.log`

## Interpretation limit

These variables are outcome-family measures, not a validated multidimensional
development index. Coefficients are adjusted associations and should not be
read as causal effects, national losses, or validated mental-health scale
effects.
