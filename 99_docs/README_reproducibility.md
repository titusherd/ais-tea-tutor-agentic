# Reproducibility README

## Current state

This project uses Stata batch execution from the project root of an authorized
local checkout. The original IFLS source folder is preserved. Derived data
belong in `01_clean`, `02_derived`, and `03_analysis`; logs, diagnostics,
tables, and figures belong in `04_output`. The canonical scripts derive the
root from Stata's `c(pwd)` and fail fast if they are not run from that root.

## Current review gate

The latest execution stage is recorded in
`99_docs/execution_status_2026-09-05.md`,
`99_docs/review_gate_packet.md`, and
`99_docs/decision_defaults_2026-09-05.md`. Conservative defaults are locked
for first-pass construction and the first-pass technical gates have passed.
Local hashes are complete; the official source-release identity remains open.

The latest Stata audits are:

```text
dofiles/18_r1_treatment_baseline_audit.do
dofiles/19_r3_treatment_constructability_audit.do
dofiles/20_pce_monetary_gap_audit.do
dofiles/21_review_gate_artifact_audit.do
```

Each audit writes a text log under `04_output/logs` and machine-readable
diagnostics under `04_output/diagnostics`. Run them from the project root with
the verified Stata executable recorded in `99_docs/software_environment.txt`.

The locked first-pass construction and model stages are:

```text
dofiles/22_codebook_validity_audit.do
dofiles/23_build_r1_locked_treatment.do
dofiles/24_build_r3_locked_treatment.do
dofiles/25_build_w5_adult_outcomes.do
dofiles/26_build_w1_baseline_controls.do
dofiles/27_build_analysis_bases.do
dofiles/28_run_first_pass_models.do
dofiles/29_export_first_pass_outputs.do
dofiles/30_final_quality_gate.do
dofiles/31_finalize_local_source_hashes.do
```

## Current first-pass boundary

Paper 1 and Paper 3 first-pass data construction, descriptive analysis, and association models are in scope. Paper 2 modeling, IV, formal mediation, advanced attrition corrections, NPV, and manuscript claims remain post-first-pass until their own gates pass.

## Data-sharing boundary

Do not redistribute raw IFLS microdata, personal identifiers, sensitive fields, or restricted linked derivatives. A reproducibility package must contain do-files, control-document schemas, logs/diagnostics that do not expose sensitive data, output tables/figures, source-release metadata, and clear instructions for obtaining authorized raw data.

## Required final checks

- `00_master.do` runs the canonical first-pass chain from a clean output/derived directory.
- Every raw input has a manifest row and a locally computed file hash. The
  official source-release identity remains open and is required before a
  public reproducibility package is released; see
  `99_docs/source_manifest_hash_policy.md`.
- Every model variable has a codebook crosswalk row.
- Every output has a sample, specification, weight, cluster/PSU, and decision-lock label.
- The final package records omitted analyses and unresolved identification limits.
