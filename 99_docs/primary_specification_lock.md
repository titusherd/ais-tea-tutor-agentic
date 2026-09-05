# Primary specification lock

Date locked: 2026-09-05  
Status: `locked_conservative_default`

Keputusan substantif dikunci karena pemilik proyek meminta keputusan terbaik
tanpa menunggu review rutin. Rincian alasan dan batas klaim ada di
`99_docs/decision_defaults_2026-09-05.md`.

Lock ini mengizinkan konstruksi teknis. Lock ini tidak mengizinkan asumsi
codebook baru: treatment, outcome, dan missing-value recode tetap harus lolos
audit sebelum model dijalankan.

## Primary estimands

| Paper | Estimand | Population | Treatment | Control | Outcome | Baseline controls | Weight/cluster | Missingness | Multiple testing | Lock status | Decision ID |
|---|---|---|---|---|---|---|---|---|---|---|---|
| R1 | Conditional W5 adult outcome-family difference associated with mother-led international work migration after W1 | W1 children in the approved age frame, both parents linked/present and uncontaminated at W1, valid W1 origin household, tracked to W5, W5 age 17–36 | Verified mother-linked parent migration after W1; work reason and international destination/country both verified; child remains in origin household; unresolved or incompatible episodes excluded | Same eligible population with no verified qualifying exposure and adequate migration observation; unresolved exposure status excluded | Separate predeclared W5 labor, education, health, and social/behavioral outcomes with valid-code rules; no forced IMDI | Verified W1 pre-treatment child, parent, household, and location covariates only | Unweighted primary association; robust VCE clustered at W1 origin household; official weighted/survey sensitivity only after design crosswalk | Outcome-specific listwise; no primary MICE | BH within each predeclared outcome family | locked_conservative_default | D-010/D-011/D-012/D-030/D-031/D-032/D-040/D-041 |
| R3 | Conditional W5 adult outcome-family difference associated with age-15 paid/market child labor | W2/W3 children age 15 with observed work screen, valid treatment-wave household, W1 link where required for baseline covariates, tracked to W5, W5 age 17–36 | Valid last-week total hours across job 1 + job 2 above 43 hours, with work screen and codebook-valid hours | Same age-15/wave population with observed screen and no qualifying treatment; unresolved hours/status excluded | Separate predeclared W5 labor/earnings, education, health, and social/behavioral outcomes; no CES-D-10 claim | Verified W1 pre-treatment controls where link and variable support pass | Unweighted primary association; robust VCE clustered at treatment-wave household; official weighted/survey sensitivity only after design crosswalk | Outcome-specific listwise; no primary MICE | BH within each predeclared outcome family | locked_conservative_default | D-020/D-022/D-030/D-031/D-032/D-041 |

## Supplementary, not primary

- R1 W2 cohort, domestic/any-parent migration, one-parent baseline cases,
  and unresolved roster cases: separate sensitivity or descriptive outputs.
- R3 age 10–11 and 12–14: descriptive/feasibility only because detailed-hour
  support is sparse.
- R3 normal-week hours, primary-job-only hours, hazardous-work mapping, and
  W1 chores: supplementary only after their own evidence gates pass.
- W4 outcomes, reduced non-monetary index, weighted estimates, and PCE
  harmonization: supplementary/post-first-pass.
- Paper 2, IV, formal mediation, PSM/IPW, Heckman, Mundlak/FE, NPV, and
  national aggregation: parked.

## Interpretation lock

First-pass estimates are adjusted associations. They are not causal estimates
and must not be written as causal effects. A treatment or outcome that fails
its technical gate is omitted from the affected primary model, not replaced
with a looser undocumented definition.

## Technical gates before model execution

1. Exact variable, unit, value-label, special-code, and observation-level
   crosswalk passes.
2. Parent migration episode and child-origin-household linkage pass.
3. R3 screen/hour treatment recode passes, including special codes and
   age-15 support.
4. W5 outcome recodes pass and every outcome has an explicit valid-value rule.
5. Spine, merge, duplicate, attrition, and sample-flow gates pass.
6. No post-treatment control enters the primary specification.
7. Stata rerun from the locked dofile sequence produces the same counts and
   diagnostic statuses.

## Change control

Any change to treatment, cohort, baseline contamination, age, outcome family,
missingness, weight, cluster, or interpretation requires a new dated
decision-log entry and an updated specification lock before rerunning primary
models.

## First-pass technical status

The gates required for the current first-pass models have now been executed:

- codebook metadata/value distributions: `CODEBOOK_VALIDITY_AUDIT_PASS`;
- R1 locked treatment: `R1_LOCKED_TREATMENT_PASS`;
- R3 locked treatment: `R3_LOCKED_TREATMENT_PASS`;
- W5 outcome recodes: `W5_ADULT_OUTCOMES_PASS`;
- analysis-base merges and uniqueness: `ANALYSIS_BASES_PASS`;
- model support/coefficient contract: `FIRST_PASS_MODELS_PASS`.

This changes the technical status from “not executable” to “first-pass
executable.” It does not turn the estimates into causal effects or make the
small treated cells representative. The primary results remain provisional
until the result memo and final quality gate are reviewed.
