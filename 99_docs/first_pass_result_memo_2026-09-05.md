# First-pass result memo — R1 and R3

Date: 2026-09-05  
Status: `technical_first_pass_complete_pending_owner_interpretation_review`  
Specification: `R1-MAIN` and `R3-MAIN` under the dated decision lock

## Executive decision

The current first pass is technically executable and reproducible for the
locked R1 and R3 associations. It is not a final causal analysis. The next
review should decide whether these conservative estimands are suitable for
the paper narrative before any post-first-pass expansion.

## What was actually estimated

- **R1:** W1 children age 0–12 with verified mother-led international work
  migration after W1, both parent links/clean origin, and W5 outcome-universe
  linkage. The final analysis frame is 3,847 observations: 25 treated and
  3,822 controls.
- **R3:** W2/W3 age-15 person-wave observations with observed market-work
  screen and valid last-week total hours above 43 as treatment. After W1
  baseline and W5 outcome-universe restrictions, the analysis frame is 753
  observations: 44 treated and 709 controls.
- **Model:** unweighted linear adjusted association, outcome-specific
  listwise deletion, household-clustered robust VCE, and W3/W2 indicator for
  R3. Binary-outcome coefficients are percentage-point differences. BH
  q-values are computed within each predeclared paper-by-family group.

## Facts from the locked outputs

The source artifacts are:

- compact primary table:
  `04_output/tables/first_pass_primary_results.csv`;
- complete adjusted/unadjusted model table:
  `04_output/tables/first_pass_model_results.csv`;
- model support by outcome:
  `04_output/diagnostics/analysis_outcome_support.csv`;
- common-frame and merge flow:
  `04_output/diagnostics/analysis_sample_flow.csv` and
  `04_output/diagnostics/analysis_base_merge_audit.csv`;
- figures:
  `04_output/figures/first_pass_coefficients_R1.png`,
  `04_output/figures/first_pass_coefficients_R3.png`, and the two R3
  age-profile PNGs.
- local source hashes: `99_docs/source_manifest.csv`; all 1,171 extracted DTA
  files have a local SHA-256 and byte-size record, while the official release
  identifier remains open.

### R1 signals in the adjusted table

These are model outputs, not causal claims:

- `adult_college`: coefficient `-0.2074`, 95% CI approximately `[-0.3015,
  -0.1133]`, p `<0.001`, BH q `<0.001`; 22 treated observations.
- `adult_good_health`: coefficient `0.1119`, 95% CI approximately `[0.0266,
  0.1972]`, p `0.010`, BH q `0.041`; 23 treated observations.
- Other R1 adjusted outcomes have BH q-values above `0.05` in the current
  family grouping. Monthly profit is `support_below_gate` with only 4 treated
  observations and is not interpreted.

For the two binary outcomes above, the coefficients correspond mechanically
to approximately -20.7 percentage points for college attainment and +11.2
percentage points for the coded good-health indicator within this selected
sample. Their direction should be treated as provisional because the treated
cell is very small and the migration treatment is highly selected.

### R3 signals in the adjusted table

- `adult_college`: coefficient `-0.1695`, 95% CI approximately `[-0.2057,
  -0.1332]`, BH q `<0.001`; 43 treated observations.
- `adult_married`: coefficient `0.0300`, 95% CI approximately `[0.0097,
  0.0503]`, BH q `0.029`; 39 treated observations with valid marriage
  outcome.
- `adult_tr03_score`: coefficient `0.2918`, 95% CI approximately `[0.0820,
  0.5016]`, BH q `0.029`; 39 treated observations with valid item outcome.
- Salary and profit have wide uncertainty despite passing the mechanical
  support gate: 17 and 11 treated observations respectively.

These are the only current adjusted R3 rows with BH q-values below `0.05`.
They should be described as signals in a first-pass association table, not as
established adult effects of child labor.

## Treatment and outcome limitations that remain in force

1. R1 has 25 treated children before outcome-specific missingness and usually
   19–23 treated observations in the models.
2. R3 treatment classification is highly age-dependent in the source data:
   the age-10–11 screen is unresolved for all 3,296 observations across W2/W3;
   age 12–14 has only 51 classified W2 cases and 7 classified W3 cases.
3. R3 W5 follow-up is selective: 1,131 primary treatment rows reduce to 753
   in the W1-plus-W5 analysis frame.
4. The primary analysis is unweighted and is not a nationally representative
   estimate. The official survey-weight/PSU/stratum crosswalk remains open.
5. W5 outcomes are separate measures. No IMDI-14, complete mental-health
   scale, PCE harmonisation, NPV, national aggregation, IV, mediation,
   PSM/IPW, Heckman, or causal claim is part of this result.

## Decision boundary

The technical work can proceed to a substantive owner review now. Review is
needed before changing the primary treatment, adding weights, constructing an
index, correcting attrition, adding Paper 2, or writing manuscript-level
causal/policy claims. Until then, use the CSV tables and memo language above
as the only approved interpretation boundary.
