# IFLS 90+ Quality Upgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Raise the reviewable technical project score above 90 by closing reproducibility, provenance, evidence-review, and handoff gaps without inventing author, data, or causal claims.

**Architecture:** Keep the existing Stata first-pass pipeline and submission package, then add a portable project-root contract, an evidence-backed provenance record, a formal scorecard, and an internal reviewer report. Each improvement is independently verified and committed before the next one; raw IFLS data and generated intermediate data remain local.

**Tech Stack:** Stata/SE 16, Markdown, static HTML, CSV, DOCX/PDF, Git.

**Spec:** `docs/superpowers/plans/2026-09-04-ifls-stata-research-execution-plan.md`, `99_docs/primary_specification_lock.md`, and `99_docs/review_gate_packet.md`.

## Global Constraints

- Do not commit or redistribute raw IFLS microdata, identifiers, restricted derivatives, source archives, logs, or intermediate DTA files.
- Report first-pass coefficients as adjusted associations; do not convert them into causal effects.
- Keep Riset 2 as a feasibility/parked workstream unless its own empirical gates pass.
- Do not fill author identity, affiliation, email, release identity, or substantive approval with guesses.
- Preserve the local-only HTML behavior and do not add download flows or quizzes.
- Use Stata/SE 16 and the existing seed `9042026` for canonical verification.
- Commit every logical change immediately with an English Conventional Commit message, then push the verified `main` branch to `origin`.

---

### Task 1: Establish the 90+ acceptance scorecard

**Files:**
- Create: `99_docs/scorecard_90plus.md`
- Modify: `05_submission/README_FINAL_DELIVERY.md`
- Test: `04_output/diagnostics/publication_quality_gate.csv`

- [ ] Define weighted criteria for pipeline integrity, data/method evidence, reproducibility, output completeness, and submission handoff.
- [ ] Map every criterion to an existing command, artifact, or explicit owner gate.
- [ ] Set the target at 90 for the technical/reviewable package and keep journal-final readiness separate.
- [ ] Add the scorecard link to the delivery README.
- [ ] Re-run the publication quality gate and record the evidence path.
- [ ] Commit with `docs(quality): add evidence-based 90-plus scorecard`.

### Task 2: Remove hardcoded machine paths from Stata execution

**Files:**
- Modify: `dofiles/00_master.do`
- Modify: `dofiles/01_setup_paths_and_environment.do`
- Modify: every `dofiles/*.do` file that hardcodes `/Users/titus/Documents/ais-tea`
- Modify: `99_docs/README_reproducibility.md`
- Modify: `05_submission/replication/README.md`

- [ ] Replace project-root literals with `local project = c(pwd)` for scripts run from the project root.
- [ ] Convert direct raw-root, path, root-list, and log literals in exploratory probes to use the same local root.
- [ ] Preserve all output locations, globals, and file names.
- [ ] Run a clean canonical Stata master from the project root and confirm exit code 0.
- [ ] Confirm no tracked do-file contains the workstation-specific root literal.
- [ ] Commit with `refactor(paths): make Stata scripts project-root portable`.

### Task 3: Close official source-provenance evidence

**Files:**
- Create: `99_docs/source_provenance_record.md`
- Modify: `99_docs/citation_audit.csv`
- Modify: `99_docs/source_manifest_hash_policy.md`
- Modify: `05_submission/manuscripts/paper1_working_paper.md`
- Modify: `05_submission/manuscripts/paper3_working_paper.md`

- [ ] Verify IFLS dataset and documentation claims against authoritative RAND/IFLS source pages or documents.
- [ ] Record URL, title, access date, supported claim, and unsupported claim boundary.
- [ ] Keep local hashes separate from official release identity; do not infer a release from a local filename or hash.
- [ ] Update manuscript data-source language only where the verified source supports it.
- [ ] Commit with `docs(provenance): record authoritative IFLS source evidence`.

### Task 4: Perform and record an internal manuscript reviewer pass

**Files:**
- Create: `99_docs/internal_reviewer_report.md`
- Modify: `05_submission/manuscripts/paper1_working_paper.md`
- Modify: `05_submission/manuscripts/paper3_working_paper.md`
- Modify: `05_submission/manuscripts/paper2_feasibility_memo.md`

- [ ] Check title, estimand, sample, treatment, outcome, model, interpretation, limitations, and references against the locked registers and exported tables.
- [ ] Check every headline numerical statement against the aggregate CSV outputs.
- [ ] Remove or qualify any sentence that exceeds the evidence boundary.
- [ ] Record each finding as fixed, retained limitation, or owner decision required; do not label an AI pass as external peer review.
- [ ] Commit with `docs(review): add internal manuscript evidence review`.

### Task 5: Complete the author-facing submission gate without guessing

**Files:**
- Create: `05_submission/manuscripts/author_metadata_and_submission_checklist.md`
- Modify: `05_submission/final_project_package.html`
- Modify: `05_submission/README_FINAL_DELIVERY.md`

- [ ] Add a single checklist for author names, affiliations, corresponding author, acknowledgements, data statement, ethics statement, funding, conflicts, cover note, and journal formatting.
- [ ] Mark unavailable fields as `OWNER_INPUT_REQUIRED` and identify the exact artifact needed to close them.
- [ ] Link the checklist from the local handoff hub.
- [ ] Ensure the package clearly distinguishes technical completion from final owner sign-off.
- [ ] Commit with `docs(submission): add owner completion checklist`.

### Task 6: Re-render, rerun, and recalculate the score

**Files:**
- Modify: `99_docs/execution_status_2026-09-05.md`
- Modify: `99_docs/final_project_delivery.md`
- Modify: `05_submission/README_FINAL_DELIVERY.md`

- [ ] Run `dofiles/00_master.do` with Stata/SE 16 from the project root.
- [ ] Verify `MASTER_PASS`, `FINAL_QUALITY_GATE_PASS_WITH_OPEN_PROVENANCE`, and the publication quality-gate row counts.
- [ ] Re-run static HTML link checks and confirm zero missing local links.
- [ ] Re-render both DOCX manuscripts and inspect page count, tables, references, and declarations.
- [ ] Recalculate the scorecard from observed evidence; report technical score and journal-final score separately.
- [ ] Commit with `docs(quality): record verified 90-plus handoff status`.

### Task 7: Push and verify GitHub handoff

**Files:**
- No source changes; verify repository state.

- [ ] Confirm `git status --short --branch` is clean and no restricted path is tracked.
- [ ] Push `main` to `origin` without force.
- [ ] Verify `origin/main` equals local `HEAD` with `git ls-remote --heads origin main`.
- [ ] Report the final commit list, scores, links, and remaining owner gates.
