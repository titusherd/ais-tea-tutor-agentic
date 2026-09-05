# IFLS first-pass research package

This repository contains the reviewable code, research documentation, and
submission handoff for an IFLS-based first-pass research project analyzed in
Stata.

## Public-safe boundary

Raw IFLS microdata, archives, intermediate datasets, Stata logs, and generated
diagnostics remain outside Git. They are required for local execution but are
not redistributed by this repository.

## Scope at handoff

- Riset 1 and Riset 3 have a locked first-pass analysis path and adjusted
  association outputs.
- Riset 2 is documented as a feasibility/parked workstream rather than being
  presented as a completed empirical paper.
- The package records estimands, treatment and outcome definitions, risks,
  reviewer evidence, and unresolved provenance items.
- Reported coefficients are adjusted associations, not causal effects.

## Local entry points

- Analysis chain: `dofiles/00_master.do`
- Final local handoff: `05_submission/final_project_package.html`
- Reproduction and data-boundary notes: `99_docs/README_reproducibility.md`

The Stata scripts use the verified local project path and an authorized local
copy of the source data. A third-party reproduction requires path
localization and lawful access to the underlying data.

## Handoff status

The submission package is ready for substantive review, author metadata,
source-provenance completion, and journal-specific formatting decisions. The
quality-gate artifacts preserve these open items explicitly; they should not be
read as evidence that external submission requirements have already been
completed.
