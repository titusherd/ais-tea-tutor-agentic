# IFLS Stata project execution status

Date: 2026-09-05  
Current state: conservative specification defaults locked; first-pass
construction and association models executed. No primary model has been
accepted as a final causal or publication claim.

## Completed evidence stages

1. Local source inventory and Stata-readability audit.
2. Stata environment and package audit.
3. Person spine, roster, household lineage, and parent-link construction.
4. Duplicate-key and anomaly diagnostics with raw-source preservation.
5. Selected module and outcome-variable inventory.
6. Adult-outcome age coverage audit.
7. Survey weight/geography candidate audit.
8. Paper 1 raw migration and baseline-parent-link audit.
9. Paper 3 child-work screen/hour-module audit, including locally available
   W2 detail files.
10. Historical PCE/deflator and W5 monetary-gap audit.
11. Crosswalk, decision log, risk register, specification lock, and
    conservative default decision record.
12. Exact codebook/value-validity audit for migration, child-work, and W5
    outcome variables.
13. Locked R1/R3 treatment files with explicit treated/control/unresolved
    states.
14. W1 baseline controls, W5 outcome-family files, analysis bases, and
    merge/sample-flow diagnostics.
15. First-pass unweighted adjusted-association models with household-clustered
    robust VCE, support gate, and BH q-values within outcome families.
16. Descriptive coefficient plots, R3 age-profile support outputs, and R1
    heterogeneity support counts.

## Locked first-pass boundary

- R1 primary: W1 cohort; mother-led international work migration after W1;
  both parents linked/present and uncontaminated at W1; W5 outcome families.
- R3 primary: W2/W3 age-15 cohort; valid last-week total job hours above 43;
  W5 outcome families.
- Primary inference: unweighted adjusted associations with household-clustered
  robust VCE and explicit non-national-representativeness limits.
- IMDI 14-item, chores, hazardous work, cross-wave PCE, W4 primary outcomes,
  and causal/valuation methods are supplementary or parked.

Full definitions are in `99_docs/primary_specification_lock.md` and
`99_docs/decision_defaults_2026-09-05.md`.

## Current quality gates

- Shared spine: `PASS_WITH_ANOMALY_FLAGS`; keys pass and anomalies remain
  documented.
- Paper 1 raw treatment/baseline evidence: audit pass; final treatment
  construction is now governed by D-010 through D-012 and D-033.
- Paper 3 raw treatment constructability: audit pass; final age-15 treatment
  construction is now governed by D-020 through D-023.
- Adult outcomes: W5 age 17–36 universe and outcome-specific valid-code audit
  pass; W5 b3b_vg is missing locally, so no CES-D-10 outcome is claimed.
- Survey design: conservative clustered primary rule is locked; official
  weighted sensitivity remains pending.
- Monetary harmonization: household PCE and NPV remain parked.

## Current first-pass result boundary

- R1 primary treatment frame: 3,909 children before outcome-specific
  missingness; 25 treated and 3,884 controls. The W5 outcome-linked frame is
  3,847, and many outcomes retain only 22–23 treated observations.
- R3 primary treatment frame: 1,131 age-15 person-wave observations before
  W1/W5 analysis-frame restrictions; the final W1-plus-W5 frame is 753, with
  44 treated and 709 controls.
- R1 profit fails the predeclared support gate and is labelled
  `support_below_gate`; it is not interpreted as an inferential result.
- All reported coefficients are adjusted associations, not causal effects;
  R3 W5 attrition and the small R1 treated cell remain material limitations.

## Stop point — owner review now

1. The canonical master do-file has completed with `MASTER_PASS`.
2. The final quality gate reports all analysis contracts passing, with only
   official source-release provenance still open.
3. Owner review is required before any post-first-pass expansion: Paper 2,
   weighting/survey design, alternative treatment tiers, imputation/index
   construction, attrition correction, causal identification, valuation, or
   manuscript claims.

If support collapses after these gates, the affected result becomes
feasibility/descriptive and the model is not broadened silently.
