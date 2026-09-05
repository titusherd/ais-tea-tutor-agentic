# Evidence-based 90+ scorecard

Date opened: 2026-09-05

This is an internal delivery score, not a journal acceptance probability and
not a statistical significance score. Points are awarded only when the listed
artifact or command provides evidence. Technical/reviewable readiness is scored
separately from owner-dependent external submission readiness.

## Scoring rule

| Dimension | Weight | Baseline | 90+ evidence gate |
|---|---:|---:|---|
| Pipeline integrity | 25 | 23 | Canonical master passes and no restricted data is written or tracked |
| Data and method evidence | 25 | 21 | Locked estimands, variable crosswalk, source provenance record, and reviewer evidence are linked |
| Reproducibility | 20 | 14 | Project-root portability, environment record, clean rerun, and output quality gate pass |
| Result completeness | 15 | 14 | Manuscripts, aggregate tables, figures, model registry, and limitations are mutually traceable |
| Handoff discipline | 15 | 10 | Local hub, replication notes, owner checklist, and explicit unresolved-item status |
| **Total technical/reviewable score** | **100** | **82** | **At least 90 with all gates evidenced** |

The baseline reproduces the earlier internal assessment. It is not increased by
relabeling open work. The target score requires actual closure of the listed
technical gates; fields that require author input remain marked
`OWNER_INPUT_REQUIRED` and are not silently counted as complete.

## Evidence register

| Criterion | Evidence | Status before upgrade | Status required for 90+ |
|---|---|---|---|
| Canonical execution | `dofiles/00_master.do`, `04_output/logs/00_master.log` | pass | pass on fresh rerun |
| Analysis contracts | `04_output/diagnostics/final_quality_gate.csv` | pass with open provenance | pass with open items explicitly bounded |
| Publication outputs | `04_output/diagnostics/publication_quality_gate.csv` | pass with external items open | pass with updated review/provenance links |
| Path portability | tracked `dofiles/*.do` | hardcoded local root present | no workstation-specific root literal |
| Official source provenance | `99_docs/source_manifest_hash_policy.md` | local hash complete; official identity open | authoritative source record present |
| Numerical traceability | `05_submission/tables/*.csv`, model registry, manuscripts | pass | pass after reviewer cross-check |
| Local handoff | `05_submission/final_project_package.html` | pass | pass with owner checklist linked |
| External submission fields | title/cover templates | owner input required | explicitly tracked; never guessed |

## Verified score after upgrade

Verification date: 2026-09-05. The score below is the technical/reviewable
delivery score, not a journal-readiness score.

| Dimension | Verified points | Evidence and remaining deduction |
|---|---:|---|
| Pipeline integrity | 24 / 25 | Fresh `MASTER_PASS`; final and publication gates pass; no raw IFLS, derived data, logs, or credentials are tracked. One point remains reserved for unresolved external provenance. |
| Data and method evidence | 24 / 25 | Locked estimands, crosswalks, source record, official RAND documentation, and internal reviewer reconciliation are present. Exact local-to-official release matching remains open. |
| Reproducibility | 19 / 20 | Portable project-root Stata paths, refreshed environment record, full rerun, and DOCX/PDF render QA pass. Raw-data access cannot be reproduced from the repository alone by design. |
| Result completeness | 15 / 15 | Full adjusted results, headline results, model registry, baseline descriptives, figures, synchronized Markdown/DOCX/PDF manuscripts, and reviewer traceability are present. |
| Handoff discipline | 13 / 15 | Local hub, replication notes, owner checklist, provenance record, and explicit status labels are present. Author metadata/sign-off and external citation closure remain owner gates. |
| **Total technical/reviewable score** | **95 / 100** | **90+ gate achieved with open items explicitly bounded.** |

The 95/100 result is evidence-based and was not obtained by counting open owner
fields as complete. It means the package is ready for internal review and
handoff. It does not mean the package is ready for an external journal
submission, nor does it change the non-causal interpretation of the estimates.

## Score interpretation

- **90–100:** technically reviewable and handoff-ready; remaining owner gates
  are visible and bounded.
- **80–89:** technically useful first pass, but one or more core evidence or
  reproducibility gates remain open.
- **Below 80:** do not package as a review-ready research release.

## Boundary

A score of 90+ does not turn adjusted associations into causal effects. It does
not close the parked Riset 2 model, survey-weight sensitivity, attrition
correction, monetary harmonization, or national aggregation. Those remain
separate research gates.
