# Final delivery package

## Open first

Open [final_project_package.html](final_project_package.html). Semua tautan di
portal diarahkan ke file lokal dalam folder proyek; tidak ada tautan unduhan
eksternal yang diperlukan untuk membaca paket.

## Package contents

- `manuscripts/paper1_working_paper.pdf` / `.docx` — rendered and editable R1 draft
- `manuscripts/paper1_working_paper.md` — auditable R1 source
- `manuscripts/paper3_working_paper.pdf` / `.docx` — rendered and editable R3 draft
- `manuscripts/paper3_working_paper.md` — auditable R3 source
- `manuscripts/paper2_feasibility_memo.md` — R2 parked feasibility memo
- `final_results_memo.md` — narasi hasil Indonesia dan batas klaim
- `tables/` — full/headline aggregate tables, baseline descriptives, model registry
- `figures/` — copied publication figures
- `replication/` — reproduction and data-sharing instructions
- `manuscripts/title_page_template.md` — author metadata still required
- `manuscripts/cover_note_template.md` — internal handoff/submission checklist
- `manuscripts/author_metadata_and_submission_checklist.md` — explicit owner and submission gates
- `../99_docs/scorecard_90plus.md` — evidence-based technical readiness scorecard
- `../99_docs/internal_reviewer_report.md` — internal numerical and claim reconciliation

## One-line status

`READY_FOR_INTERNAL_REVIEW_WITH_OPEN_EXTERNAL_SUBMISSION_ITEMS`

The package is ready to send for internal review. It is not labelled as an
external journal submission, acceptance, or causal evidence package.

## Re-run

From the project root of an authorized local checkout, run the verified Stata
executable described in `99_docs/software_environment.txt` with:

```text
dofile dofiles/00_master.do
```

The master chain preserves raw IFLS files and regenerates the derived data,
diagnostics, tables, figures, publication exports, and quality gates.
