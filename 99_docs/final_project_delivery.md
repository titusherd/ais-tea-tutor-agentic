# Final project delivery decision

Date: 2026-09-05  
Project: IFLS three-paper research program  
Software: Stata 16-compatible do-files

## What is being delivered now

This package delivers a technically reproducible first-pass release for:

1. **Riset 1 / Paper 1:** mother-led international work migration after W1
   and W5 adult outcome families.
2. **Riset 3 / Paper 3:** age-15 market child labor in W2/W3 and W5 adult
   outcome families.
3. **Riset 2 / Paper 2:** a feasibility memo only. No substantive Paper 2
   model or conclusion is claimed.

The primary estimates are unweighted adjusted associations with
household-clustered robust VCE and outcome-specific listwise deletion. They
are not causal effects.

## Verified technical score

After the 5 September 2026 full Stata rerun, artifact render QA, link checks,
and repository safety checks, the technical/reviewable delivery score is
**95/100**. The score is documented in `99_docs/scorecard_90plus.md` and
reflects reproducibility, traceability, result completeness, and handoff
discipline. It is not a journal acceptance probability and does not close the
owner-dependent submission items below.

## Definition of ready

The package is ready to send to a supervisor or internal reviewer when:

- the reader opens `05_submission/final_project_package.html`;
- the reader can open both anonymized working-paper drafts;
- every headline result is traceable to the aggregate CSV and Stata log;
- the full results table, baseline descriptives, diagnostics, and figures are
  present;
- unresolved support, attrition, survey-design, and provenance issues are
  visibly disclosed; and
- no raw IFLS file is redistributed as part of the handoff instructions.

## What is not yet a responsible external journal submission

The following items are deliberately open:

- the exact official IFLS source-release identifier and authorized-access
  provenance are not fully recorded in the local manifest;
- author names, affiliations, ORCID IDs, corresponding-author contact, funding,
  ethics wording, and acknowledgements must be supplied by the authors;
- R1 has only 25 treated observations in the common frame; R3 has 44;
- W5 attrition and outcome-specific missingness are not corrected in this
  first pass;
- survey weighting/design sensitivity is not yet closed;
- R1 IMDI/mental-health index, R2 substantive model, and R3 NPV/national
  aggregation remain outside the primary release;
- all external literature citations from the supplied planning documents need
  primary-source verification before submission.

## Canonical reproduction

Run from the project root with the verified Stata executable listed in
`99_docs/software_environment.txt`:

```text
dofile dofiles/00_master.do
```

The canonical master now runs the publication-support audit, publication
exports, and publication quality gate after the first-pass analysis chain.

## Handoff level

**READY_FOR_INTERNAL_REVIEW_WITH_OPEN_EXTERNAL_SUBMISSION_ITEMS**

This is the highest evidence-supported handoff level available from the
current files and locked analysis. It should not be labelled “accepted” or
“submitted to a journal.”
