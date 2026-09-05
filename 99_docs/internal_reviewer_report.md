# Internal manuscript evidence review

Review date: 2026-09-05

## Review status

This is an internal technical evidence pass, not external peer review. The
review checked the Riset 1 and Riset 3 manuscripts and the Riset 2 feasibility
memo against the primary specification lock, treatment definitions, outcome
register, `headline_adjusted_results.csv`, `all_adjusted_primary_results.csv`,
`model_registry.csv`, quality-gate logs, and the official-source record.

## Headline numerical reconciliation

All 14 rows in the pre-labelled headline table were reconciled to the
machine-readable headline output. Binary estimates are percentage-point
associations; continuous estimates retain the scale declared in the output.

| Paper | Result ID | Outcome | Estimate | N / treated | BH q | Disposition |
|---|---:|---|---:|---:|---:|---|
| R1 | 8 | College attainment | -20.74 pp | 3,638 / 22 | <0.001 | Claim retained as adjusted association |
| R1 | 2 | Employment | +0.71 pp | 3,655 / 22 | 0.919 | No headline signal claimed |
| R1 | 4 | Log monthly salary | -1.441 | 1,795 / 13 | 0.540 | Wide-uncertainty limitation retained |
| R1 | 10 | Self-rated health | +0.092 | 3,644 / 23 | 0.309 | No headline signal claimed |
| R1 | 12 | Good self-rated health | +11.19 pp | 3,644 / 23 | 0.041 | Claim retained as adjusted association |
| R1 | 20 | Married/cohabiting | +1.66 pp | 2,402 / 19 | 0.122 | No headline signal claimed |
| R1 | 28 | Trust item 3 | +0.045 | 3,479 / 22 | 0.795 | No headline signal claimed |
| R3 | 42 | College attainment | -16.95 pp | 719 / 43 | <0.001 | Claim retained as adjusted association |
| R3 | 36 | Employment | +1.77 pp | 725 / 43 | 0.896 | No headline signal claimed |
| R3 | 38 | Log monthly salary | -0.051 | 342 / 17 | 0.896 | Wide-uncertainty limitation retained |
| R3 | 44 | Self-rated health | -0.141 | 721 / 42 | 0.263 | No headline signal claimed |
| R3 | 46 | Good self-rated health | -3.74 pp | 721 / 42 | 0.586 | No headline signal claimed |
| R3 | 54 | Married/cohabiting | +3.00 pp | 623 / 39 | 0.029 | Claim retained as adjusted association |
| R3 | 62 | Trust item 3 | +0.292 | 704 / 39 | 0.029 | Claim retained as adjusted association |

The R1 profit model is present in the model registry as result IDs 5 and 6
with `support_below_gate`, N = 678, and four treated observations; its
coefficient is correctly withheld from the headline results. The R3 profit
model is present in the full output as result IDs 39 and 40 with N = 168 and
11 treated observations; it remains a non-headline audit result.

## Checklist findings

| Check | Finding | Status |
|---|---|---|
| Estimand and population | Manuscripts match the locked R1/R3 conditional W5 outcome-family association estimands | pass |
| Treatment | R1 mother-led international work migration and R3 age-15 market-work threshold match the locked definitions | pass |
| Outcome and missingness | W5 outcome families, valid-code rules, outcome-specific listwise deletion, and unsupported CES-D/IMDI claims are bounded | pass |
| Model | Unweighted adjusted association, declared baseline controls, household-clustered robust VCE, wave indicator for R3, and BH q-values are stated consistently | pass |
| Interpretation | Headline sentences use association language and retain selection, support, attrition, survey-design, and provenance limits | pass |
| Numerical traceability | Headline values, sample sizes, treated counts, confidence intervals, p-values, q-values, and result IDs reconcile to the CSV/model registry | pass |
| Source citations | RAND design, access, data-notes, and IFLS5 field-report citations are now recorded in the provenance record and manuscripts | fixed |
| Author declarations | Funding, conflicts, ethics wording, acknowledgements, contributions, and correspondence details remain owner inputs | owner gate |
| External review | No claim of peer review or journal submission is made | bounded |

## Changes applied

1. Added a manuscript note that `N / treated` is outcome-specific after
   valid-code and listwise deletion, not the common analysis-frame count.
2. Added the authoritative RAND source set and the exact release/provenance
   boundary to both manuscripts.
3. Preserved the R2 feasibility-only status and the non-inferential R1 profit
   status.

## Remaining owner decisions

- Supply author names, affiliations, corresponding-author information, and
  declarations through the owner checklist.
- Match the local extracted files to the official release identifier and
  retain access evidence without storing credentials or tokens.
- Obtain substantive owner approval before changing any locked estimand or
  upgrading association language.
