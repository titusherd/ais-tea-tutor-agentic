# Review gate — IFLS Riset 1 dan Riset 3

Date: 2026-09-05  
Status: first-pass technical execution completed. Owner review rutin telah
dilewati atas instruksi pemilik proyek; review substantif sekarang diperlukan
sebelum mengubah estimand atau menulis klaim manuskrip.

## Objective proyek

Membangun analisis Stata yang dapat direproduksi untuk:

- Riset 1: asosiasi migrasi kerja internasional yang dipimpin ibu ketika anak
  masih kecil dengan outcome dewasa pada W5.
- Riset 3: asosiasi child labor berbayar/market berbasis jam pada usia 15
  dengan outcome dewasa pada W5.

Paper 2, IV, mediasi formal, koreksi attrition lanjutan, NPV, dan agregasi
nasional tetap diparkir sampai first pass dan gate identifikasi selesai.

## Keputusan default yang sekarang berlaku

| Area | Default yang dipakai |
|---|---|
| R1 treatment | Mother-led, international, work reason dan destination terverifikasi; anak tetap di household asal |
| R1 cohort | W1 primary; W2 supplementary |
| R1 baseline | Both parents linked/present dan tidak left-censored; status lain sensitivity |
| R3 age | Age 15 W2/W3 primary; younger bands descriptive/feasibility |
| R3 hours | Last-week total job1+job2; valid 0–168; age-15 >43 |
| Hazard/chores | Tidak masuk primary |
| IMDI | Tidak dipaksakan; outcome family terpisah |
| Missingness | Outcome-specific listwise primary; MICE sensitivity |
| Survey | Unweighted clustered association primary; official survey design sensitivity |
| Monetary | W5 within-wave earnings saja; PCE/NPV diparkir |
| Anomaly | Ambiguous lineage/HHID dikeluarkan primary dan dipertahankan sebagai flag |
| Interpretation | Adjusted association; bukan causal effect |

Rationale lengkap dan decision IDs ada di
`99_docs/decision_defaults_2026-09-05.md`,
`99_docs/primary_specification_lock.md`, dan
`99_docs/decision_log.csv`.

## Fakta yang sudah diaudit

- 10 area IFLS dan 1,171 file rows terinventaris; 41,425 variable rows
  terbaca.
- Shared person/roster/lineage keys pass; quality gate tetap
  `PASS_WITH_ANOMALY_FLAGS` karena anomalies tidak dihapus diam-diam.
- W1 parent-link status: both 8,418; one 966; known nonresident/dead 498;
  no-link 2; unknown/unresolved 7.
- W2 parent-link status: both 7,592; one 997; known nonresident/dead 593;
  no-link 53; unknown 0.
- R3 detail-hour support untuk age 10–11, 12–14, 15 adalah W2 0/5/139 dan
  W3 0/1/108; karena itu hanya age 15 yang inferential primary.
- W5 `b3b_vg.dta` tidak ada di ekstraksi lokal.
- Audit survey menemukan candidate fields tetapi tidak menemukan `svyset`
  project-level yang lengkap.
- PCE historical W1–W4 sebagian terbaca; output PCE W5 tidak teridentifikasi.

Angka-angka tersebut adalah audit coverage/support, bukan temuan substantif.

## Technical gate yang sudah dilewati

1. Exact codebook, unit, value-label, special-code, and observation-level
   crosswalk: pass.
2. R1 parent episode and child-origin-household linkage: pass.
3. R3 valid screen/hour recode: pass.
4. W5 outcome valid-code recode and outcome-family register: pass.
5. Merge, duplicate, attrition, sample-flow, and no-post-treatment-control
   checks: pass.
6. Stata rerun reproducibility through `00_master.do`: pass.

The final gate reports `FINAL_QUALITY_GATE_PASS_WITH_OPEN_PROVENANCE`: all
analysis contracts pass, while all 1,171 source-manifest rows retain an
explicit pending official-release field. Local SHA-256 hashes and byte sizes
are recorded for all 1,171 extracted files. Official release provenance is a
publication-package task, not a reason to broaden the analysis or invent
metadata.

## Required owner review now

Review the first-pass result memo and decide whether the conservative R1/R3
estimands are suitable for the narrative. No technical redefinition is
required before that review. Any next phase—Paper 2, survey weighting,
alternative treatment tiers, imputation/index construction, attrition
correction, causal identification, valuation, or manuscript claims—remains
parked until the owner makes that substantive choice.
