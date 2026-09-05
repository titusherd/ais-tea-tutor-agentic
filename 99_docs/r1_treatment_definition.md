# R1 treatment definition

Date: 2026-09-05  
Status: `technical_gate_pass`  
Specification: `R1-MAIN-D010-D011-D012-D030-D031-D032-D033-D040-D041-D042`

## Research question implemented

The first-pass R1 estimand is the W5 adult-outcome difference associated
with a verified mother-led international work migration episode after W1,
among W1 children whose baseline parent links, origin household, and W5
follow-up satisfy the lock. This is an adjusted association, not a causal
effect.

## Primary treatment rule

An observation is `treated` only if all of the following are true:

1. the child is in the W1 age 0–12 cohort;
2. both W1 parent links are valid and the W1 origin household is clean;
3. the linked mother has an observed post-W1 migration screen or episode;
4. the episode has a verified work reason (`MG28==1`);
5. the destination country is verified as outside Indonesia using the
   wave-specific country rule;
6. the episode occurs after the W1 baseline window;
7. the child is observed in the origin household at the event wave; and
8. there is no incompatible whole-household/child-moved evidence.

The linked mother is the parent identified through the W1 within-household
mother reference. The primary treatment does not pool father migration,
any-parent migration, domestic migration, unresolved country codes, weekly
commuting, death, or non-work moves.

## Wave-specific country evidence

The country rule is deliberately not harmonised by guessing across waves:

- W2: `MG21E==0` is Indonesia and `MG21E==91` is the verified other-country
  code.
- W3: `MG21E==0` is Indonesia; the verified foreign indicator is the local
  `MG21EX==1` response.
- W4: `MG21E==100` is Indonesia and `MG21E==101–154` are named foreign
  countries in the local codebook; `MG21EX==1` is retained as supporting
  evidence.
- W5: `MG21E==62` is observed with the local status responses, but the local
  codebook does not enumerate all country meanings for the other observed
  values. W5 non-Indonesia candidates therefore remain unresolved and are
  not promoted to primary treatment.

## Status construction

Each W1 child receives one explicit status. `treated` and `control` are the
only statuses used in the primary frame. `unresolved_exposure` is never
forced into `control`.

| Status | Meaning | Primary use |
|---|---|---|
| `treated` | Verified mother-led international work migration after W1 | included with `r1_treatment=1` |
| `control` | Adequate migration observation and no qualifying exposure | included with `r1_treatment=0` |
| `unresolved_exposure` | Missing/ambiguous migration evidence or country/timing/roster status | excluded; sensitivity candidate |
| `incompatible_exposure` | Evidence that the child/household moved in a way inconsistent with the lock | excluded; sensitivity candidate |
| `baseline_excluded` | Parent-link, origin, or W5-tracking condition fails | excluded from primary |

## Observed counts

These counts are from `04_output/diagnostics/r1_treatment_sample_flow.csv` and
the locked treatment file, not from a planning assumption:

| Stage | N |
|---|---:|
| W1 child cohort age 0–12 | 9,891 |
| Both parents linked; clean origin; W5 tracked | 6,046 |
| Mother post-W1 migration evidence observed | 3,952 |
| Verified treated | 25 |
| Observed control | 3,884 |
| Incompatible exposure | 31 |
| Unresolved exposure | 2,106 |
| Primary treatment frame before W5 outcome missingness | 3,909 |
| R1 W1-plus-W5 analysis frame | 3,847 |

The final analysis frame has 25 treated and 3,822 controls. Outcome-specific
validity reduces the treated count to 19–23 for most estimable outcomes;
monthly profit has only 4 treated observations and fails the support gate.

## Files

- Treatment data: `02_derived/r1_mother_international_treatment.dta`
- Event evidence: `04_output/diagnostics/r1_migration_event_evidence.csv`
- Child-event linkage: `04_output/diagnostics/r1_child_migration_event_linkage.csv`
- Sample flow: `04_output/diagnostics/r1_treatment_sample_flow.csv`
- Treatment status summary: `04_output/diagnostics/r1_treatment_status_summary.csv`
- Construction log: `04_output/logs/23_build_r1_locked_treatment.log`

## Interpretation limit

The small treated cell, possible residual left-censoring, roster anomalies,
and selective W5 follow-up limit inference. The first-pass model reports an
adjusted association with W1 controls and origin-household clustered robust
VCE. It does not identify a causal migration effect.
