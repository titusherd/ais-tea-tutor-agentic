# Riset 2 / Paper 2 feasibility memo

*Wife work migration, husband labour supply, and household work — not a
substantive results paper*

## Decision

Riset 2 is parked in the current release. The local analysis has not yet
passed a separate spouse-migration episode, observation-level, and outcome
comparability gate. No R2 coefficient, causal claim, sample estimate, or
policy conclusion is included in the final first-pass narrative.

## Intended question from the supplied research program

The supplied planning materials proposed studying whether a wife's work
migration is associated with changes in the husband's market work, domestic
work, or related household labour allocation. That question requires an
analytic panel in which the spouse link, migration episode, timing, marital
status, and pre/post husband outcomes are all independently verified.

## Why it is not released as a paper now

The current locked pipeline was built to close the R1 and R3 first-pass gates.
It does not yet contain a validated R2 treatment file or a model registry for
husband outcomes. The available source inventory is not enough to assume that
spouse migration episodes, circular migration, household presence, market
hours, domestic hours, and pre/post timing are comparable across waves.

Building a result from those assumptions would make the paper look complete
without establishing the unit of analysis or the exposure. That would be a
larger risk than delivering a clearly labelled feasibility memo.

## Required R2 gate before modeling

1. Define the unit: husband-person, couple, or household, and keep it constant
   across waves.
2. Resolve the wife link using the longitudinal roster and document spouse
   linkage, marital status, household presence, and nonresident status.
3. Define a wife work-migration episode with verified work reason, destination,
   timing, return/circular status, and child/household movement exclusions as
   applicable.
4. Verify that husband market-work participation, market hours, domestic work,
   and any leisure/time-use outcomes have the same observation level, units,
   reference period, and valid-code rules in every proposed wave.
5. Build a pre/post or staggered panel with explicit baseline availability and
   attrition statuses. Do not treat unresolved spouse or migration evidence as
   control.
6. Predeclare the estimand, comparison group, wave window, clustering, survey
   design, missingness, and multiplicity rules before reading model results.
7. Run support checks: number of couples, treated episodes, pre/post
   observations, return episodes, and distinct households.
8. Only after those checks pass, decide whether the design supports descriptive
   panel associations, fixed effects, or another identification strategy.

## Current deliverable

This memo is the complete R2 deliverable for the current package. Its status is
`PARKED_PENDING_SPOUSE_MIGRATION_FEASIBILITY_GATE`. The next R2 work should
start with a source-level audit and should not reuse the R1 or R3 treatment
definitions without a new decision-log entry.

## Reproduction boundary

The canonical Stata chain records R2 as parked and does not create a substantive
R2 model output. Raw IFLS files remain local and are not redistributed with
this memo.
