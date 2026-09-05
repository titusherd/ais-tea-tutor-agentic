# IFLS Three Paper Research Program Stata Execution Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to execute this plan task by task, with a review checkpoint after each quality gate.

> **For the analyst:** execute this plan sequentially. Each gate must have a saved Stata output before the next analysis decision is made.

**Goal:** Produce a verified, reproducible first-pass Stata package for Paper 1 and Paper 3 from IFLS Wave 1–5, with Paper 2, full identification robustness, valuation, and publication preparation explicitly separated into post-first-pass phases.

**Architecture:** Keep source archives and raw `.dta` files unchanged. Create a canonical person–wave spine, a household lineage map, and a harmonized roster first. Freeze one documented primary specification per paper before reading model coefficients. Build paper-specific analytic datasets from those shared objects, then run first-pass analysis and later robustness/publication phases through a single master do-file.

**Tech Stack:** Stata; IFLS household and community files; official IFLS codebooks and user guides; local PCE/deflator materials; external data only after its source, release, license, and merge key are documented. Use built-in Stata commands unless a user-written command is explicitly approved, installed, and recorded.

**Spec:** `NORC_Working_paper_-_Fariza_Zahra_Kamilah_REVISI.pptx`, `Timeline_Riset1_Riset3.docx`, and `[FINAL] CN3_v3_Intuitif.docx` in `/Users/titus/Documents/ais-tea`.

## Global constraints

- Do not edit, overwrite, rename, or save derived data inside `00_raw`.
- Do not invent raw IFLS variable names. Every raw variable must be copied into `99_docs/variable_crosswalk.csv` only after checking the relevant wave codebook and data dictionary.
- Do not call an association causal until the relevant identification assumptions and diagnostics have been run and saved.
- Do not report a sample size before the actual Stata `count`/`tabulate` output is saved.
- Do not merge household records using household ID as the person identity key. Use the official person-link structure after verifying it in `ptrack`/`hhtrack`.
- Do not interpret a person missing from one roster as a migrant until death, non-work move, whole-family move, and survey attrition have been separated.
- Do not use post-treatment education, health, employment, marital status, or preferences as baseline controls in the adult-outcome main model.
- Do not treat the Paper 3 NPV or national aggregation as observed loss. It is a model-based scenario that comes only after the outcome estimates and assumptions are documented.
- Log the Stata version, OS, installed packages, data-release identifier, date, seed, and all decision changes before running stochastic procedures.
- Every output must be reproducible by running `00_master.do` from a clean analysis/output directory.
- Treat every unresolved choice as an explicit open decision with an owner, evidence required, deadline/gate, and affected estimand; do not fill it with an invented value.
- Keep the current first-pass sprint separate from post-first-pass work. A method listed in a later phase is not part of the first-pass Definition of Done unless the sprint lock says so.
- Do not treat the deck's journal fees, acceptance probabilities, or reviewer counters as current facts. Re-verify them from the target journal's official guidance before submission.

## Current sprint boundary

The supplied timeline defines the immediate work cycle as Paper 1 and Paper 3 only. The plan therefore has two release levels.

| Release | Included | Explicitly outside the release |
|---|---|---|
| **Current first-pass sprint** | Shared IFLS spine and roster; Paper 1 treatment, baseline, adult IMDI, first-pass models; Paper 3 treatment, cohort-age audit, prevalence, first-pass adult earnings/health models; logs, sample flows, and result memo | Paper 2 modeling; IV estimation; formal mediation; PSM/IPW/Heckman/Mundlak; public NPV or national aggregation; manuscript submission |
| **Post-first-pass program** | Paper 2 feasibility; identification and staggered-treatment robustness; alternative index/missing-data specifications; formal mediation; valuation scenarios; citation, journal, and reviewer package | Any method that has not passed its own data/provenance/estimand gate |

The immediate sprint is complete only when its own Definition of Done passes. Post-first-pass work must not be used to imply that the first-pass estimates are causal or publication-ready.

## Priority map

| Priority | Work | Release condition |
|---|---|---|
| **P0** | Source release, codebook crosswalk, person/household/roster spine, source-conflict register, primary specification lock, survey-design decision | No model can run until the relevant gate passes |
| **P1** | Paper 1 and Paper 3 first-pass treatment, outcome construction, descriptive outputs, association models, sample flows, and result memo | Current first-pass Definition of Done passes; unresolved methods are recorded |
| **P2** | Paper 2 feasibility, IV, staggered-treatment estimators, mediation, attrition corrections, alternative IMDI, NPV, citation/journal/reviewer package | Each method has its own estimand, provenance, support, diagnostic, and interpretation gate |

---

## 1. Research objective and scope

### 1.1 Overall objective

The project asks whether adverse family and childhood experiences observed in the IFLS panel are associated with later adult outcomes in Indonesia, and whether the magnitude is useful for policy discussion.

The analysis has three linked but separate papers:

1. **Paper 1 — Maternal migration and left-behind children:** estimate the difference in adult multidimensional development between individuals who experienced left-behind exposure and comparable individuals who did not, while examining age at onset, migrating parent, and caregiver.
2. **Paper 2 — Female migration and husbands’ labor supply:** estimate how a wife’s work migration relates to the husband’s market work, domestic work, time use, mental health, and later repeat migration. This paper must pass a sample and time-use feasibility gate before full execution.
3. **Paper 3 — Child labor and adult outcomes:** estimate whether work during childhood is related to adult earnings and health, allow the earnings effect to vary with age, and only then calculate a transparent, sensitivity-based foregone-earnings scenario.

### 1.2 Immediate milestone

The first milestone follows the supplied timeline:

- complete the shared data spine and roster quality gates;
- complete first-pass treatment and control construction for Paper 1;
- produce a first Paper 1 table, coefficient plot, and heterogeneity table;
- complete first-pass child-labor treatment and outcome mapping for Paper 3;
- produce a first Paper 3 earnings/health table and age-profile graph;
- record what could not be estimated and why.

The first milestone is not a publication-ready causal claim, a final NPV, or completion of every robustness method.

### 1.3 Estimands to register before coding

Write one row per estimand in `99_docs/estimand_register.md` using the following meaning. The exact sample size and raw variables are intentionally not supplied here; they must come from the data and codebooks.

| Paper | Primary estimand | Outcome time | Treatment time | Safe initial interpretation |
|---|---|---:|---:|---|
| Paper 1 | Conditional difference in adult IMDI between selected LBE treatment and control groups | W5 | W1–W4 history | Adjusted association; causal interpretation requires additional identification evidence |
| Paper 1 mechanism | Within-person change in a childhood outcome around LBE onset | W1–W3 | Time-varying roster/treatment history | Within-person association under panel-model assumptions |
| Paper 1 critical period | Within-origin-household difference in adult outcome by age at onset among siblings | W5 | First treatment interval | Family-adjusted comparison; not a test of ever-treated versus never-treated within the family |
| Paper 2 | Within-person change in husband outcome when wife is away for work | Multiple waves | Staggered wife-migration episode | FE/event-study estimate; causal language requires timing and instrument diagnostics |
| Paper 2 circular trap | Whether earlier husband labor-supply change predicts later wife repeat migration | Later wave | Prior wave labor response | Predictive/conditional relationship unless a credible design identifies it causally |
| Paper 3 | Conditional difference in adult earnings/health by age-specific childhood-labor treatment | W4/W5, with the primary outcome window explicitly fixed before estimation | W2/W3, with any W1 cohort treated as a separate sample | Adjusted association; causal interpretation requires validated IV or other design |
| Paper 3 valuation | Present value of model-estimated earnings differences under explicit assumptions | Projected working life | Child-labor estimate from the selected specification | Scenario estimate, not observed national income loss |

Do not change the estimand silently after looking at results. A change requires a dated entry in the decision log, the old and new definitions, the reason, and the affected sample count.

### 1.4 Primary specification lock

Create `99_docs/primary_specification_lock.md` before any outcome model runs. This file may contain decisions marked `open_pending_evidence`, but each such decision must name the evidence needed to close it. The lock must contain one completed primary row for each paper with:

```text
paper,estimand,population,treatment_definition,control_definition,
treatment_wave_or_history,outcome_wave,outcome_definition,
baseline_covariates,weight_rule,cluster_rule,missing_rule,
multiple_testing_family,causal_language,lock_status,decision_id
```

The lock must resolve, or explicitly defer with a stop condition, the following source-level conflicts:

| Conflict found in the supplied materials | Required resolution |
|---|---|
| The timeline makes Paper 1 and Paper 3 the current sprint, while the deck contains three papers | Keep Paper 2 outside the current first-pass release; run only the later feasibility gate unless the owner expands the sprint. |
| Paper 1 is described as maternal/international migration in some places and broader parental/domestic migration in others | Declare the primary tier and label the other definition as supplementary before estimating. |
| The timeline uses a cross-sectional first pass, while CN3 describes FE, IV, event-study, PSM, and mediation layers | Label the cross-section as the first-pass association model; register each later layer as a separate estimand and do not present it as already validated. |
| CN3 recommends MICE as a main IMDI specification, while the timeline parks MICE and uses listwise deletion for the week | Use listwise only for the current first-pass release; decide the final IMDI missing-data hierarchy after missingness diagnostics, with both rules documented. |
| The deck/CN3 list 14 IMDI indicators, while blood pressure appears only as a possible health measure in the broader plan | Do not add blood pressure to the 14-item IMDI unless the specification lock explicitly changes the indicator set; treat it as supplementary otherwise. |
| Paper 3 proposes W2/W3 treatment and a W1 extension cohort | Make W2/W3 the primary candidate only after the module and age audit; keep W1 as a separately labelled secondary cohort if its treatment measurement is verified. |

#### Baseline-treatment contamination gate for Paper 1

The Paper 1 model uses W1 baseline covariates but reconstructs treatment history from W1–W4. A parent already absent or already migrated at W1 may make the W1 covariates post-treatment or left-censored. Before the primary model, create and report:

- a baseline-parent-presence flag;
- a confirmed post-W1 treatment-onset flag;
- an unknown/left-censored treatment-status flag;
- counts and baseline differences for each group.

The primary specification must state whether baseline-absent cases are excluded, analysed as a separate historical-exposure group, or included under an explicitly different estimand. No W1 variable may be called pre-treatment for a case whose treatment predates or is unknown at W1.

---

## 2. What is already present locally, and what it does not prove

The current workspace inventory shows:

- extracted household data directories for `IFLS/hh93dta`, `IFLS/hh97dta`, `IFLS/hh00_all_dta`, and `IFLS/hh07_all_dta`;
- `IFLS/IFLS 5/hh14_all_dta (1).zip` and `IFLS/IFLS 5/cf14_all_dta (2).zip`;
- IFLS5 household and community codebooks under `IFLS/IFLS 5/IFLS5_all_doc (1)/IFLS5_hh_codebooks` and `IFLS5_cf_codebooks`;
- IFLS4 documentation under `IFLS/IFLS 4/hh07_all_doc`;
- community-file materials for earlier waves;
- local PCE/deflator do-files and data under `IFLS/IFLS pce-1993-1997_2000-2007`.

This inventory proves that materials exist in the workspace. It does not yet prove that:

- every paper variable is present in every required wave;
- raw variables have the same meaning or units across waves;
- all relevant files come from one consistent release;
- person links and household split-off links are complete;
- the treatment groups are large enough;
- the proposed instruments satisfy exclusion restrictions;
- the external national headcount needed for Paper 3 is available and definition-compatible.

Those are explicit verification tasks below.

---

## 3. File and do-file structure

Create this structure only inside the research project working directory. Preserve the existing source folder separately.

```text
00_raw/                         unchanged copies or read-only pointers to source data
01_clean/                       wave-level standardized files
02_derived/                    shared spines, roster, treatment, controls, indices
03_analysis/                   paper-specific analysis datasets and estimation inputs
04_output/
  tables/                      CSV/RTF/Excel-compatible table outputs
  figures/                     PNG/PDF graphs
  diagnostics/                 QA and estimation diagnostics
  logs/                        Stata log files
99_docs/
  source_manifest.csv
  variable_crosswalk.csv
  source_conflict_register.md
  risk_register.md
  estimand_register.md
  primary_specification_lock.md
  decision_log.csv
  sample_flow.csv
  cohort_age_matrix.csv
  survey_design_decision.md
  citation_audit.csv
  journal_target_register.md
  reviewer_evidence_matrix.csv
  README_reproducibility.md
  software_environment.txt
```

Create or maintain the following do-files. Each file should have one responsibility and should be called by `00_master.do` in numeric order.

```text
00_master.do
01_setup_paths_and_environment.do
02_inventory_and_codebook_audit.do
03_build_person_spine.do
04_build_household_lineage.do
05_build_roster_long.do
06_quality_gate_shared_spine.do
07_quality_gate_specification.do

10_r1_construct_treatment.do
11_r1_construct_baseline_and_outcomes.do
12_r1_construct_imdi.do
13_r1_descriptives_and_sample_flow.do
14_r1_main_models.do
15_r1_supplementary_models.do

20_r3_construct_treatment.do
21_r3_construct_baseline_and_outcomes.do
22_r3_descriptives_and_sample_flow.do
23_r3_main_models.do
24_r3_age_profile_and_crossover.do
25_r3_valuation_scenarios.do

30_r2_feasibility_and_sample.do
31_r2_construct_panel.do
32_r2_time_allocation.do
33_r2_circular_migration.do

90_robustness_and_inference.do
91_export_tables_and_figures.do
92_reproducibility_audit.do
93_publication_package_audit.do
```

Every do-file must:

1. open a dedicated log in `04_output/logs`;
2. record the input file paths and date;
3. check that required variables exist before using them;
4. save its output to a documented path;
5. fail loudly when a required key, variable, or sample condition is absent;
6. close its log cleanly.

---

## 4. Phase 0 — freeze the brief and decisions

### Task 0: Create the research control documents

**Files:**

- Create: `99_docs/estimand_register.md`
- Create: `99_docs/decision_log.csv`
- Create: `99_docs/source_manifest.csv`
- Create: `99_docs/variable_crosswalk.csv`
- Create: `99_docs/source_conflict_register.md`
- Create: `99_docs/risk_register.md`
- Create: `99_docs/primary_specification_lock.md`
- Create: `99_docs/survey_design_decision.md`
- Create: `99_docs/citation_audit.csv`
- Create: `99_docs/journal_target_register.md`
- Create: `99_docs/reviewer_evidence_matrix.csv`
- Create: `99_docs/software_environment.txt`
- Create: `99_docs/README_reproducibility.md`

**Steps:**

- [ ] Record the three paper questions exactly as they appear in the current concept notes.
- [ ] Record the current first-pass release as Paper 1 and Paper 3; mark all Paper 2 work as post-first-pass feasibility unless the owner explicitly expands the sprint.
- [ ] Record the primary outcome, treatment, control, population, time window, cluster level, weight decision, and estimand for each paper.
- [ ] Record every definition that can change the sample: international/domestic migration, duration, parent absence, whole-family move, child-labor threshold, hazardous work, chores, cohort, and outcome age range.
- [ ] Record that treatment signs are not predetermined conclusions. The analysis will report the estimated sign and uncertainty.
- [ ] Record the Stata edition/version and the list of installed packages before analysis.
- [ ] Record the source archive path, file size, date received, SHA-256 checksum when computable, and release identifier for each wave. If a checksum cannot be computed, record why instead of writing `verified`.
- [ ] Create the source-conflict register for disagreements between the deck, timeline, and CN3; link every resolution to a decision-log row.
- [ ] Create a risk register for source incompatibility, treatment-cell size, attrition, missingness, weak instruments, external-data access, and deadline/scope risk.
- [ ] Create the primary-specification lock and survey-design decision before any outcome model is run.
- [ ] Create a citation audit from the CN3 errata section and a journal/reviewer register from the deck. These are planning artifacts until the official journal pages and primary papers are checked.

**Quality gate:** no current-sprint model do-file is allowed to run until the estimand register has one completed row for each current-sprint primary and supplementary estimand, the source-conflict register has a resolution or blocking rule for every material disagreement, the primary-specification lock is complete for the current model, and the survey-design decision identifies the applicable weight/PSU/cluster rule. Post-first-pass estimands must pass the same gate before their own phase starts.

### Task 1: Use the following decision-log schema

Create the CSV with these columns:

```text
date,paper,decision_id,topic,decision,alternative_rejected,reason,evidence_path,n_affected,status,locked_before_outcome,owner
```

Examples of decision topics that must be logged, without pre-deciding their values:

- source release and wave file;
- raw-to-canonical variable mapping;
- duplicate-person priority rule;
- date-of-birth priority rule;
- treatment tier;
- cohort inclusion;
- whole-family migration exclusion;
- missing-data rule;
- deflator and base year;
- cluster level;
- survey-weight rule;
- instrument role;
- primary versus secondary outcome;
- age window for Paper 3;
- NPV discount-rate scenario;
- external headcount definition;
- baseline-treatment contamination rule;
- IMDI weight universe and missing-data hierarchy;
- survey weight, PSU/stratum, and cluster rule;
- minimum subgroup support rule;
- citation correction and journal-target verification.

`status` must use one of `open_pending_evidence`, `locked`, `rejected`, or `superseded`. An `open_pending_evidence` row must block only the analyses that depend on it and must name the next evidence-producing task.

Use the following schemas so the control documents are executable rather than narrative-only:

```text
source_conflict_id,source_file,location,conflict,impact,temporary_rule,
evidence_required,resolution_decision_id,status
```

`survey_design_decision.md` must record, separately by estimand, the verified weight variable, PSU, stratum, finite-population correction if applicable, target population, `svyset` or non-survey VCE choice, cluster count, and interpretation limit.

Use this minimum `risk_register.md` schema:

```text
risk_id,paper,phase,trigger,impact,early_signal,mitigation,
contingency,owner,status,decision_id
```

### Task 1A: Enforce the pre-model scope and specification gate

**Files:**

- Create: `07_quality_gate_specification.do`
- Output: `04_output/diagnostics/specification_gate.txt`
- Output: `04_output/logs/07_quality_gate_specification.log`

**Steps:**

- [ ] Confirm that all current-sprint control documents exist before any paper-specific data construction begins.
- [ ] Confirm that the current phase is `first_pass` or `post_first_pass`; reject any unrecognised phase value.
- [ ] Read the decision-log status for the paper/model being run and stop if its primary specification, source conflict, survey design, or support rule is not locked.
- [ ] Write the specification-lock ID, decision-log version/date, source-release ID, Stata version, and phase to the diagnostic output.
- [ ] Fail with a non-zero Stata return code when a required document or locked decision is absent. Do not use `capture` to suppress this gate.

**Quality gate:** the diagnostic output says `SPECIFICATION_GATE_PASS` for the current model before `10_r1_*` or `20_r3_*` model do-files are called.

---

## 5. Phase 1 — inventory data and codebooks in Stata

### Task 2: Build the source manifest

**Files:**

- Create: `01_setup_paths_and_environment.do`
- Create: `02_inventory_and_codebook_audit.do`
- Output: `99_docs/source_manifest.csv`
- Output: `04_output/logs/02_inventory_and_codebook_audit.smcl`

**Steps:**

- [ ] Define project paths with local macros; keep raw paths separate from clean and output paths.
- [ ] Set `more off`, log output, and a fixed seed before any stochastic command.
- [ ] Record Stata version and `about` output in `software_environment.txt`.
- [ ] List each wave and book required by the plan: `ptrack`, `hhtrack`, roster/Book K, migration Book 3A, work Book 3A, education, health/behavior Book 3B, anthropometry Book US, cognitive Book EK, household Book 1, community Book 2, and any needed time-use files.
- [ ] For every `.dta` file, inspect `describe`, `count`, variable labels, value labels, storage types, and missing-value conventions.
- [ ] For each candidate key, run `isid` only after identifying the unit of observation from the codebook. Record whether the key is unique, one-to-many, or repeated.
- [ ] Record the raw filename, wave, book/module, unit, candidate key, observation count, codebook path, release identifier, file hash, and availability status in `source_manifest.csv`.
- [ ] Inspect archive member lists for Wave 5 and community files before extracting or using them.
- [ ] Compare the release/version naming across waves. Stop if the files are from incompatible releases.
- [ ] Save a raw-file inventory before any extraction and a post-extraction inventory after approved archives are opened. The two inventories must identify which files are byte-identical and which are derived copies.
- [ ] Record the official population/unit reconciliation target for every module used in a sample-flow denominator. Do not use one household-level N as the target for a person-level file.

Use these minimum `source_manifest.csv` columns:

```text
source_id,wave,archive_or_file,module,unit,candidate_key,observation_count,
release_id,file_size_bytes,sha256,codebook_path,official_n_target,
availability_status,read_only_location,checked_date,notes
```

**Stata QA patterns:**

```stata
use "IFLS/hh97dta/b3a_mg1.dta", clear
count
describe
codebook
misstable summarize
datasignature set
```

The file shown above is one real local archive member used only as an inventory example. The actual file for each module must come from the source manifest; do not infer a module’s observation unit from its filename.

**Quality gate:** all planned modules have a documented availability status, release identifier, and unit. Any module marked absent, ambiguous, or not comparable blocks the associated paper until the estimand is revised in the decision log.

### Task 3: Build the variable crosswalk

**File:** `99_docs/variable_crosswalk.csv`

Use these columns:

```text
paper,wave,book,module,concept,canonical_name,raw_name,unit,coding,missing_rule,
question_or_label,source_codebook,source_page,availability_status,
merge_role,verified_by,date_verified,notes
```

**Canonical names to use in derived files:**

```text
pidlink
wave
survey_year
interview_date
hhid_wave
origin_hh
present_roster
parent_mother_pid
parent_father_pid
parent_absence_reason
parent_destination
birth_date
sex
age_at_interview
```

Paper-specific canonical names should be created only after their raw source is verified. The proposed names are:

```text
r1_lbe
r1_tier1
r1_tier2
r1_mother_mig
r1_father_mig
r1_both_mig
r1_age_onset_low
r1_age_onset_high
r1_caregiver_type
r1_imdi
r1_imdi_econ
r1_imdi_health
r1_imdi_education
r1_imdi_social

r2_wife_migrant
r2_remittance
r2_market_hours
r2_domestic_hours
r2_leisure_hours
r2_repeat_migration

r3_cl_10_11
r3_cl_12_14
r3_cl_15
r3_hazardous_any
r3_chores_21
r3_work_hours
r3_work_sector
r3_work_paid
r3_adult_ln_wage
r3_adult_employed
r3_adult_formal
```

These names describe derived concepts. They do not imply that a corresponding raw variable exists. Each one must have a crosswalk row or an explicit `not_available` record.

**Quality gate:** no raw variable enters a model do-file unless its crosswalk row identifies its codebook location, unit, coding, and missing-value rule.

For every variable that affects a sample, treatment, outcome, weight, cluster, or deflator, the crosswalk must also identify the questionnaire wording or variable label and whether the value is reported per day, per week, per month, or for a reference period. A concept-only row is not sufficient for model use.

---

## 6. Phase 2 — shared person, household, and roster spine

### Task 4: Build the person–wave spine

**Files:**

- Create: `03_build_person_spine.do`
- Output: `02_derived/person_spine.dta`
- Output: `04_output/diagnostics/person_spine_reconciliation.dta`

**Steps:**

- [ ] Start from the official person tracking file and verify its observation unit.
- [ ] Create one canonical record per `pidlink` × `wave` for every tracked person, with interview/presence indicators and wave-specific household IDs.
- [ ] Preserve the original identifiers in separate variables; do not overwrite source identifiers.
- [ ] Construct `survey_year` from the wave register, not from a guessed filename.
- [ ] Construct age from verified date-of-birth and interview-date rules. Do not use reported age when the plan requires calculated age.
- [ ] If birth dates conflict across waves, compare the candidate rules and select one through the decision log.
- [ ] Check person uniqueness at each stage.
- [ ] Preserve a flag for the source and quality of `birth_date` and `interview_date`; do not replace a missing or conflicting date with an undocumented imputation.
- [ ] Save a person-wave cardinality report before and after every merge. Each merge must state the expected cardinality (`1:1`, `m:1`, or another justified form), the key, and the treatment of unmatched observations.

**Stata QA:**

```stata
isid pidlink wave
duplicates report pidlink wave
by pidlink: assert sex == sex[1] if !missing(sex)
```

The sex-consistency assertion requires a documented missing-value strategy before it is run. Do not silently force conflicting values to the first observation.

**Quality gate:** `pidlink` × `wave` is unique; wave counts reconcile with the official user guide within the threshold stated in the timeline; all discrepancies have a diagnosis in the log; every merge audit has matched, master-only, and using-only counts.

### Task 5: Build household lineage and split-off mapping

**Files:**

- Create: `04_build_household_lineage.do`
- Output: `02_derived/household_lineage.dta`

**Steps:**

- [ ] Read the official household tracking file and map each wave-specific household to its predecessor/origin household.
- [ ] Preserve split-off indicators and ambiguous mappings.
- [ ] Construct `origin_hh` only where the mapping is documented and valid.
- [ ] Count households with no origin, multiple origins, or unresolved split-off status.
- [ ] Decide whether `origin_hh` or community is the primary cluster for each paper; record it before models.

**Quality gate:** every W5 household entering a paper has a documented lineage status. Unresolved households are either excluded by an explicit rule or retained with a sensitivity flag; they are not silently dropped.

### Task 6: Build and audit the long roster

**Files:**

- Create: `05_build_roster_long.do`
- Create: `06_quality_gate_shared_spine.do`
- Output: `02_derived/roster_long.dta`
- Output: `04_output/diagnostics/roster_quality.dta`
- Output: `99_docs/sample_flow.csv`

**Canonical roster fields:**

```text
pidlink,wave,survey_year,interview_date,hhid_wave,origin_hh,relation_to_krt,present_roster,
mother_pid,father_pid,mother_present,father_present,mother_location,
father_location,age_at_interview,sex
```

**Steps:**

- [ ] Standardize one row per person × wave after verifying the wave-level roster unit.
- [ ] Apply an explicit rule for a person appearing in more than one roster in one wave.
- [ ] Do not use a generic duplicate drop command without recording which observation wins and why.
- [ ] Code absence reasons separately: death, work migration, non-work move, whole-family move, and unknown attrition.
- [ ] Construct the five-wave presence pattern for each person, such as `1-0-1-1-1`.
- [ ] Check age progression, sex stability, and logical parent-child ages.
- [ ] Preserve separate flags for baseline presence, later confirmed absence, reappearance, unknown attrition, and whole-family movement. A gap in the roster is not itself a treatment event.
- [ ] Identify children who moved with the household when the parent left; exclude them from left-behind treatment unless the estimand explicitly changes.
- [ ] Identify people who joined or were born after baseline and therefore lack required baseline controls.
- [ ] Create a sample-flow record for every exclusion.

**Quality gate:** no duplicate person × wave; every roster absence used in a treatment variable has a coded reason or is explicitly classified as unknown; the reconciliation table and exclusion counts are saved.

---

## 7. Phase 3 — Paper 1: maternal migration and left-behind children

### Task 7: Freeze the Paper 1 cohort and treatment rule

**Files:**

- Create: `10_r1_construct_treatment.do`
- Output: `02_derived/r1_treatment.dta`
- Output: `04_output/tables/r1_treatment_counts.csv`

**Design decisions required before estimation:**

- The timeline prioritizes children aged 0–5 in W1 and 6–12 in W1 as the main cohorts; the W2 cohort is a structural/sensitivity cohort until its adult-outcome eligibility is verified.
- The concept note describes international and domestic migration, while the deck emphasizes international migration. The primary tier must be chosen from actual N and recorded; it cannot be changed after seeing coefficients.
- Tier 1 is international work migration of at least six months; Tier 2 adds domestic work migration across the defined administrative boundary. The exact boundary and duration coding must be supported by the codebook.
- Exclude weekly commuters, non-work moves, whole-family moves, and deaths from the treatment definition. Unknown attrition must not be coded as work migration.
- Cases in which the parent is already absent at W1, or whose onset is left-censored, must receive a separate status. The primary model cannot call W1 covariates pre-treatment for those cases.

**Steps:**

- [ ] Identify each child’s biological mother and father using the verified roster links.
- [ ] Determine the first interval in which a parent is absent and the absence reason/destination.
- [ ] Use the five-wave pattern and migration module together. A single missing roster entry is not sufficient evidence of migration.
- [ ] Construct baseline-parent-presence, confirmed-post-W1-onset, left-censored, and unknown-status flags before constructing `r1_lbe`, `r1_tier1`, and `r1_tier2`.
- [ ] Construct `r1_lbe`, `r1_tier1`, `r1_tier2`, migrating-parent indicators, caregiver type, and an onset-age interval only under the rule in `primary_specification_lock.md`.
- [ ] Because the parent’s exact departure date may fall between waves, store `r1_age_onset_low` and `r1_age_onset_high` rather than claiming false precision.
- [ ] Count treatment by tier, migrating parent, onset-age band, caregiver, sex, cohort, and tracking status.
- [ ] Count baseline-absent, post-W1-onset, reappearing, whole-family-move, and unknown cases separately. Report which status enters the primary sample and why.
- [ ] Record all exclusions in the sample flow.

**Quality gate:** treatment counts and support are known for each tier and key heterogeneity cell; baseline-treatment contamination is resolved; and any change from the timeline's Tier 1 candidate to Tier 2 is recorded before outcome results are read. If any primary cell is too small for the registered inference, stop and apply the pre-declared support rule.

### Task 8: Construct baseline and adult outcomes

**Files:**

- Create: `11_r1_construct_baseline_and_outcomes.do`
- Output: `03_analysis/r1_analysis_base.dta`

**Baseline variables from W1, subject to codebook verification:**

- child age, sex, birth order, siblings, height-for-age, enrollment/class, and pre-existing health;
- household real per-capita expenditure, assets, parental education, parental age/work, household size, dependency ratio, and land;
- community school/facility availability, infrastructure, local wage, and urban/rural status;
- birth-cohort indicators.

**Adult outcomes from W5, subject to availability:**

- earnings/wage, employment, formal work, and per-capita expenditure;
- CES-D, self-rated health, BMI, and chronic disease;
- final schooling and cognitive score;
- trust, smoking, age at first marriage, marriage stability, fertility, and preferences where defined in the concept note.

The current 14-item IMDI candidate set must be reconciled to the CN3 indicator table before construction. Blood pressure may be retained as a supplementary adult-health outcome if its coding, timing, and support pass the crosswalk, but it must not enter the 14-item IMDI silently.

**Steps:**

- [ ] Merge baseline and outcome files using verified person/household keys, not guessed keys.
- [ ] Inspect merge result codes and save counts of matched, master-only, and using-only records.
- [ ] Apply the same deflator rule to all project monetary variables after checking the local PCE materials and documenting the base year.
- [ ] For the current candidate rule, verify whether the local PCE materials support 2014 as the common base year and a spatial adjustment; if not, record the alternative and its affected variables before estimation.
- [ ] Keep raw and transformed monetary variables side by side.
- [ ] Do not add adult education, adult health, adult employment, marriage, or preferences to the main baseline control vector if they may be mediators/outcomes.
- [ ] Produce a baseline balance table before any model selection.

**Quality gate:** the analysis file has one row per eligible person, baseline covariates are demonstrably pre-treatment, and every merge has a saved audit.

### Task 9: Construct IMDI transparently

**File:** `12_r1_construct_imdi.do`

Use this 14-item candidate set from CN3 as the audit starting point, subject to codebook availability and the primary-specification lock:

| Dimension | Candidate indicators |
|---|---|
| Economic | real log wage/income, employment status, formal work, real log household per-capita expenditure |
| Health | CES-D 10, self-rated health, absolute distance of BMI from 22, absence of chronic disease |
| Education/cognitive | final years of schooling, verified cognitive score |
| Social/behavioural | social trust, not smoking, marriage at age 18 or later, marriage stability |

Do not silently substitute a different indicator, change polarity, or add blood pressure. A missing or unavailable candidate becomes a documented `not_available` or supplementary outcome decision.

**Steps:**

- [ ] Freeze the indicator list and polarity in `variable_crosswalk.csv`.
- [ ] Report missingness per indicator before deletion or imputation.
- [ ] Apply the timeline's first-pass rule only after verification: exclude an indicator with more than 30% missingness, use listwise deletion for the first-pass IMDI, and record the actual percentage and affected N. This is a sprint rule, not automatically the final paper rule.
- [ ] Register the post-first-pass alternative separately: MICE with the number of imputations and imputation variables recorded. Do not silently promote it to the primary result.
- [ ] Apply the timeline's p1–p99 winsorization rule before min–max normalization for the first-pass candidate, unless the decision log records a data-based reason not to do so.
- [ ] Normalize each indicator with correct polarity and preserve the unnormalized source.
- [ ] Compute entropy, divergence, and indicator weights; save the full weight table.
- [ ] Compute the first-pass entropy weights on the pre-declared W5 analysis universe, pooled across treatment and control; do not calculate weights separately by treatment group. Register a pooled-panel fixed-weight variant only if an across-wave IMDI is actually constructed.
- [ ] Implement the two-stage aggregation proposed in the concept note: entropy within dimension, then equal dimension aggregation unless the specification lock records another rule.
- [ ] Store `r1_imdi` and four sub-indices with labels and construction notes.
- [ ] Compare the index distribution and weights between treatment and control without interpreting the difference as causal.

**Required diagnostics:**

- weight table with entropy/divergence/weight;
- missingness table;
- min/max and percentile table before/after winsorization;
- correlation matrix among indicators and sub-indices;
- distribution plot by treatment status;
- sensitivity index specification record.
- table showing the weight universe, missing-data rule, excluded indicators, and number of observations entering each dimension;
- generated-regressand uncertainty plan for the post-first-pass bootstrap, with the resampling level declared before it is run.

**Quality gate:** no near-zero/near-one weight is accepted without diagnosis; the index range, polarity, two-stage aggregation, 30% missingness rule, p1–p99 rule, and weight universe are mechanically verified; the current first-pass and final-candidate missing-data specifications are labelled separately.

### Task 10: Estimate Paper 1 first-pass models

**Files:**

- Create: `13_r1_descriptives_and_sample_flow.do`
- Create: `14_r1_main_models.do`
- Create: `15_r1_supplementary_models.do`
- Outputs: `04_output/tables/r1_main.csv`, `04_output/tables/r1_heterogeneity.csv`, `04_output/figures/r1_coefficient_plot.png`

**Main model:**

- Cross-section at W5.
- Treatment and history constructed from W1–W4.
- Controls measured at W1.
- Birth-cohort controls included according to the estimand register.
- Cluster level chosen before estimation and reported with a comparison cluster if planned.

**Stata command pattern after canonical variables exist:**

```stata
reg r1_imdi r1_lbe baseline_controls i.birth_cohort, vce(cluster cluster_id)
estimates store r1_imdi_main
```

`baseline_controls` and `cluster_id` are analyst-defined varlists built from the verified crosswalk. Do not replace them with post-treatment variables.

This command is a schematic unweighted clustered form, not a final instruction to ignore IFLS design information. The executable command must follow `survey_design_decision.md`: use the verified survey prefix/design or the documented non-survey alternative, with the target population and interpretation limit printed in the table metadata.

**First-pass outputs:**

- sample funnel from raw roster to analysis sample;
- baseline balance table;
- IMDI headline model;
- four sub-index models;
- indicator-level decomposition table/plot;
- limited heterogeneity by migrating parent, onset band, caregiver, child sex, and urban/rural status;
- raw p-values and Benjamini–Hochberg q-values for the pre-declared outcome families, unless the specification lock records a different correction before results are read;
- support table with N, number of clusters, and minimum-cell-rule status for every subgroup.

**Supplementary models:**

- sibling/household FE for age-at-onset comparisons only, with birth order handled explicitly;
- childhood panel FE for outcomes observed repeatedly in W1–W3;
- IV only after instrument construction and diagnostics pass.

**Quality gate:** first-pass outputs exist, every coefficient has an N, cluster count, weight rule, outcome family, and specification label; subgroup support passes the pre-declared rule; and the text distinguishes adjusted association from causal evidence.

---

## 8. Phase 4 — Paper 3: child labor, adult earnings, health, and valuation

### Task 11: Resolve cohort and age-window logic first

**Files:**

- Create: `cohort_age_matrix.csv`
- Modify: `99_docs/estimand_register.md`
- Output: `04_output/diagnostics/r3_cohort_age_audit.csv`

Build a matrix with one row per cohort and wave:

```text
cohort_definition,treatment_wave,treatment_age_low,treatment_age_high,
outcome_wave,outcome_age_low,outcome_age_high,eligible_for_primary,
reason,source_or_calculation
```

The timeline's candidate adult-age bands are 17–21, 22–25, 26–29, 30–33, and 34–36. Treat these as registered candidate bands to be checked against the verified age calculation and observed support, not as bands that may be changed after coefficients are seen.

**Steps:**

- [ ] Calculate ages from survey-year differences and verified birth dates.
- [ ] Separate the primary W2/W3 cohort from any W1 extension cohort.
- [ ] State whether W4 contributes to the main age-profile outcome or only to a supplementary trajectory.
- [ ] Ensure each age band has a known source sample and a documented observation wave.
- [ ] Reconcile the concept note’s W2/W3-to-W5 age range with the planned age bands and the claimed observed age range.
- [ ] Add calendar-year/wave and birth-cohort information needed to separate age, period, and cohort support. Do not interpret an age-band difference if it is only a wave or cohort composition difference.
- [ ] Do not run crossover or NPV code until the matrix has no unexplained age band.

**Quality gate:** every age band used in an output is supported by an explicit cohort/wave rule and actual observation counts.

### Task 12: Construct child-labor treatment variables

**Files:**

- Create: `20_r3_construct_treatment.do`
- Output: `02_derived/r3_treatment.dta`
- Output: `04_output/tables/r3_prevalence_by_definition.csv`

**Treatment concepts from the concept note:**

- `r3_cl_10_11`: at least 1 hour/week of economic activity for the observed 10–11 age part;
- `r3_cl_12_14`: at least 14 hours/week of economic activity;
- `r3_cl_15`: more than 43 hours/week of economic activity;
- `r3_hazardous_any`: hazardous sector/occupation regardless of hours, after mapping codes to the approved Indonesian list;
- `r3_chores_21`: unpaid household work above the proposed threshold only if the IFLS module actually records compatible hours.

**Steps:**

- [ ] Verify whether the hours field is per day, per week, usual, or reference-period hours.
- [ ] Verify whether market work, unpaid family work, and household chores are separately observed.
- [ ] Map sector and occupation codes using a versioned mapping file tied to the verified Indonesian hazardous-work reference, including Kepmenakertrans 235/2003 where that is the approved legal basis; do not classify hazardous work from memory.
- [ ] Construct continuous hours, sector, paid/unpaid status, and work continuation across W2/W3.
- [ ] Produce prevalence by definition × age × sex × wave before merging adult outcomes.
- [ ] Record impossible values, missing values, and unit corrections.
- [ ] Keep economic activity and unpaid household chores as separate treatment concepts. If chores are unavailable or incompatible, record the gender-estimand change instead of silently dropping it.

**Quality gate:** prevalence is plausible relative to the verified question wording and units; all thresholds are traceable to the crosswalk and decision log; unavailable chores data is reported rather than silently omitted.

### Task 13: Construct Paper 3 baseline and adult outcomes

**Files:**

- Create: `21_r3_construct_baseline_and_outcomes.do`
- Output: `03_analysis/r3_analysis_long.dta`
- Output: `03_analysis/r3_analysis_w5.dta`

**Steps:**

- [ ] Reuse the validated baseline construction from Paper 1 where concepts are identical, but do not assume the Paper 1 sample filters apply.
- [ ] Use W1 household poverty, parental education, assets, household size, and community conditions as pre-treatment controls where available.
- [ ] Construct an explicit long outcome file for W4/W5 only after the cohort-age matrix approves it.
- [ ] Construct a W5 outcome file for the main adult-outcome specification.
- [ ] Retain adult wage, employment, formality, mental health, self-rated health, BMI, and chronic disease fields only when their coding and comparability are verified.
- [ ] Keep education as a mediator or separate explanatory analysis if it may lie on the treatment pathway; do not treat it as an unqualified baseline control.

**Quality gate:** W4/W5 outcome ages, missingness, and sample counts are printed by treatment definition; the main cross-section and age-profile samples are clearly distinguished.

### Task 14: Estimate Paper 3 first-pass models

**Files:**

- Create: `22_r3_descriptives_and_sample_flow.do`
- Create: `23_r3_main_models.do`
- Create: `24_r3_age_profile_and_crossover.do`
- Outputs: `04_output/tables/r3_earnings_health.csv`, `04_output/figures/r3_age_profile.png`

**Main model:**

- Cross-section W5 with treatment measured in W2/W3 and baseline controls from W1.
- Run treatment definitions separately; do not collapse different age thresholds into one indicator without an estimand decision.
- Report earnings and health outcomes in a structured table, with outcome family and treatment definition recorded for every row.
- Include the verified age, calendar-wave, and birth-cohort terms required by the cohort-age matrix; do not use adult age alone as a substitute for cohort support.

**Age profile:**

- Estimate effects by the approved age bands from `cohort_age_matrix.csv`.
- Use W4/W5 only as approved by the cohort-age audit.
- Plot coefficient estimates with confidence intervals and show the N in each band.
- If W4 and W5 are pooled, include an outcome-wave indicator and the approved cohort/age terms, preserve one row per person × outcome wave, and cluster at a level that accounts for repeated observations of the same person.

**Parametric complement:**

```stata
reg r3_adult_ln_wage r3_child_labor c.r3_child_labor#c.adult_age adult_age_controls baseline_controls, vce(cluster cluster_id)
```

Use the exact canonical outcome and treatment variables only after the crosswalk is complete. Do not interpret `-b1/b2` as a valid crossover age unless the interaction model, support, functional form, and confidence interval are acceptable.

The formula is a model template. The actual age-profile specification must carry the approved wave/cohort terms and the survey/cluster rule; it must not use an unverified `adult_age_controls` shortcut.

**IV candidates:** the concept note proposes local commodity-price shocks, rainfall shocks, and community shocks. Each candidate needs:

- an actual data source and merge key;
- timing that predates the treatment measurement;
- a first-stage result;
- an argument and tests for no direct adult-outcome path;
- a placebo test on children too young for the treatment definition;
- an overidentification result only if multiple valid instruments are actually available.

**Quality gate:** first-pass earnings/health outputs and age-profile graph exist with sample counts, but causal wording is withheld until instrument and selection diagnostics are complete.

### Task 15: Build the foregone-earnings and NPV module last

**File:** `25_r3_valuation_scenarios.do`

This task belongs to the post-first-pass program. It must not delay or redefine the current Riset 1–Riset 3 first-pass release.

**Preconditions:**

- the primary treatment definition is frozen;
- the adult earnings specification is frozen;
- observed age support is documented;
- the age profile is estimated and diagnosed;
- the wage unit and deflator are verified;
- the external national child-labor headcount source is provided and definition-compatible.

**Steps:**

- [ ] Calculate observed age-specific earnings differences from the selected estimates.
- [ ] Define the projection rule after observed support ends; save it in the decision log.
- [ ] Define the base discount-rate scenario and sensitivity range before looking at the national number. The documents mention public-policy discount scenarios and higher household-financing scenarios; the final rates require an explicit decision.
- [ ] Calculate individual/scenario NPV with the same wage unit and deflator used in the outcome analysis.
- [ ] Report per-child NPV and uncertainty separately from national aggregation.
- [ ] Propagate uncertainty from the earnings coefficients and declared valuation parameters using a documented simulation or bootstrap procedure; do not report uncertainty only for the mean wage input.
- [ ] Multiply by an external headcount only when age, definition, reference year, and population concept match; otherwise report no national aggregate.
- [ ] Report scenario tables rather than one apparently precise trillion-rupiah number.
- [ ] Keep health-cost calculations separate to avoid double counting earnings effects.

**Quality gate:** every NPV table states observed versus projected ages, discount rate, projection rule, headcount source, and whether the value is a scenario or an observed quantity.

---

## 9. Post-first-pass Phase 5 — Paper 2 feasibility before full analysis

Paper 2 is intentionally parked during the current five-day Riset 1–Riset 3 sprint. Execute this phase only after the first-pass release has been reviewed or after the owner explicitly expands the scope.

### Task 16: Count the feasible Paper 2 sample

**Files:**

- Create: `30_r2_feasibility_and_sample.do`
- Output: `04_output/tables/r2_feasibility.csv`
- Output: `99_docs/r2_feasibility_memo.md`

**Steps:**

- [ ] Identify married men in the approved baseline age range.
- [ ] Verify spouse linkage and the rule for a wife being absent for work.
- [ ] Count first wife-migration episodes, retained husbands, pre-migration observations, post-migration observations, and repeat-migration transitions.
- [ ] Count the sample separately for international and domestic definitions.
- [ ] Check whether time-use variables distinguish domestic work, leisure, self-care, and market work, and whether all adult household members are covered.
- [ ] Record missingness and attrition by treatment timing.

**Quality gate:** commit to full Paper 2 modeling only if the sample supports the registered estimands and the time-use variables support at least the intended binary or continuous distinction. If not, revise the research question explicitly.

### Task 17: Construct and estimate Paper 2

**Files:**

- Create: `31_r2_construct_panel.do`
- Create: `32_r2_time_allocation.do`
- Create: `33_r2_circular_migration.do`
- Outputs: `04_output/tables/r2_labor_supply.csv`, `04_output/tables/r2_time_allocation.csv`, `04_output/tables/r2_repeat_migration.csv`

**Steps:**

- [ ] Build one husband–wave file with wife-migration status, remittance, labor outcomes, time-use outcomes, household controls, and wave indicators.
- [ ] Set the panel only after person–wave uniqueness is confirmed.

```stata
xtset pidlink wave
xtreg r2_market_hours r2_wife_migrant r2_remittance time_varying_controls i.wave, fe vce(cluster cluster_id)
```

- [ ] Estimate market-work and domestic-work outcomes separately.
- [ ] Test the closed time-budget implication only if all relevant time categories are observed and compatible.
- [ ] Use event-study timing only after the treatment onset and comparison group are defined; do not rely on a generic TWFE event-study if treatment effects are heterogeneous across timing.
- [ ] Estimate repeat migration as a later transition, preserving the temporal order.
- [ ] Label results as consistent with a circular trap unless a stronger causal design is actually validated.
- [ ] Use Susenas/Sakernas only if their microdata, documentation, linkage limitations, and permissions are supplied; their presence in the concept note is not evidence that the files are available here.

**Quality gate:** Paper 2 outputs state exactly which estimand is supported by IFLS and which is only descriptive or predictive.

---

## 10. Phase 6 — identification, attrition, missingness, and inference

### Task 18: Establish the identification ledger

**File:** `90_robustness_and_inference.do`

Create one row per main model:

```text
paper,estimand,source_of_variation,main_threat,diagnostic,pass_rule,result,interpretation_limit
```

For each paper, document:

- baseline selection and observable balance;
- time-varying shocks and whether they are controls, mediators, or instruments;
- attrition and tracking loss;
- treatment measurement error;
- treatment timing heterogeneity;
- spillovers and community-level effects;
- weak instruments;
- multiple outcomes;
- generated-index uncertainty;
- support and extrapolation for age-profile/NPV analysis.

### Task 19: Run IV diagnostics only for instruments with a complete provenance record

**Stata command pattern:**

```stata
ivregress 2sls outcome baseline_controls (treatment = instrument), vce(cluster cluster_id)
estat firststage
estat endogenous
estat overid
```

Run these only when the instrument, timing, merge, and exclusion argument are documented. Save first-stage coefficients, strength statistics, sample counts, and failures. A failed instrument is a result about the design; do not replace it silently.

The instrument register must distinguish the candidates proposed in CN3:

- lagged, leave-one-out community migration prevalence, with the construction universe and excluded household documented;
- a country-destination shift-share exposure, only if historical destination shares and destination shocks are actually available;
- Paper 3 local commodity-price, rainfall, or community shocks, with treatment timing and direct-path threats documented.

For each candidate, save the merge coverage, first-stage coefficient and strength statistic, weak-instrument-robust inference where the installed Stata tools support it, placebo/falsification results, and the interpretation as LATE or another estimand. `estat overid` is valid only when there are multiple excluded instruments and the overidentifying restrictions are meaningful.

### Task 20: Handle staggered treatment carefully

If an event-study or staggered-treatment design is used:

- [ ] Diagnose whether treatment timing is staggered and whether effects can vary by cohort or time since treatment.
- [ ] Do not present a conventional TWFE coefficient as automatically valid under heterogeneous staggered effects.
- [ ] Use an estimator supported by the installed Stata version and package record, such as a documented heterogeneity-robust alternative, only after verifying syntax and dependencies.
- [ ] Compare never-treated/not-yet-treated comparison definitions.
- [ ] Save event-study pre-period coefficients and support counts.
- [ ] If the robust estimator cannot be run, report the limitation rather than presenting the TWFE result as definitive.

### Task 21: Attrition and missing data

**Steps:**

- [ ] Produce a flow from original wave sample to each paper’s final sample.
- [ ] Compare treatment/control tracking rates and baseline characteristics.
- [ ] Mark whether missingness is structural (module not asked), item nonresponse, or non-observation due to attrition.
- [ ] Use the first-pass missing-data rule registered before estimation.
- [ ] Add MICE only as a separately documented specification, with imputation variables and number of imputations recorded.
- [ ] Do not impute a structurally unavailable adult outcome at childhood age.

### Task 22: Weights, clustering, and multiple testing

- **File:** `99_docs/survey_design_decision.md`

- [ ] Identify the verified IFLS weight, stratum, and primary sampling unit fields for every wave/module used. Do not infer them from a filename or copy a weight across waves without a crosswalk row.
- [ ] Decide whether IFLS survey weights apply to each estimand and whether the target is descriptive population representation or a conditional relationship.
- [ ] If a survey design is used, document and test the corresponding `svyset` specification in Stata. If a non-survey clustered model is used instead, document why and which target population it represents.
- [ ] Decide the cluster level before reading significance results; record number of clusters and whether treatment is assigned or correlated at a higher level.
- [ ] Report the chosen primary cluster and a planned comparison cluster only where justified.
- [ ] Define outcome families and the correction method before the final table. The current first-pass default is Benjamini–Hochberg within pre-declared families; Romano–Wolf is a post-first-pass alternative, not an after-the-fact replacement.
- [ ] Keep the IMDI headline separate from indicator-level decomposition in the interpretation.
- [ ] If IMDI weights are estimated from the analysis data, quantify uncertainty from index construction in a separate bootstrap specification after the first-pass result is stable.
- [ ] Register the minimum number of observations and clusters required for subgroup reporting, and record an ex-ante power/MDE calculation or explain why it cannot be computed from the available design inputs.

**Quality gate:** every reported p-value has a declared model, sample, cluster/PSU rule, weight rule, outcome family, multiple-testing method, and support/power status.

### Task 22A: Run post-first-pass publication robustness

**Files:**

- Modify: `90_robustness_and_inference.do`
- Create: `04_output/tables/robustness_registry.csv`
- Create: `04_output/results_memo_robustness.md`

This task is not part of the current first-pass release. Add a row for every method before running it, including its estimand, sample, required assumptions, and reason for inclusion.

- [ ] Run propensity-score matching only as an observable-balance sensitivity, with overlap/common-support diagnostics and the same pre-treatment covariate universe as the primary model.
- [ ] Run KHB or another documented mediation decomposition only after the mediator timing, link function, and nested samples are verified. Report it as a mechanism decomposition, not proof of causal mediation.
- [ ] Run IPW/attrition correction only after the response/attrition model, positivity, stabilized weights, and trimming rule are recorded.
- [ ] Run Heckman wage selection only if an exclusion or selection structure is defensible; do not use it merely because wages are missing for non-workers.
- [ ] Run Mundlak/correlated-random-effects only when its time-varying panel structure and interpretation are appropriate.
- [ ] Run the appropriate heterogeneity-robust staggered-treatment estimator only for a genuinely staggered panel estimand. Do not force it onto the Paper 1 W5 cross-section.
- [ ] Report which proposed robustness methods were not estimable and why.

**Quality gate:** no robustness result is called confirmatory unless its estimand, assumptions, support, and implementation are documented in `robustness_registry.csv`.

---

## 11. Phase 7 — results, reproducibility, and writing package

### Task 23: Export tables and figures

**Files:**

- Create: `91_export_tables_and_figures.do`
- Output: `04_output/tables/`
- Output: `04_output/figures/`

**Required first-pass package:**

- shared sample-reconciliation table;
- paper-specific sample-flow tables;
- Paper 1 baseline balance, IMDI/sub-index table, coefficient plot, and limited heterogeneity table;
- Paper 3 prevalence table, earnings/health table, age-profile graph, and crossover output only if age support passes;
- a model registry with command, sample, variables, fixed effects, cluster/PSU, weight, outcome family, specification-lock ID, and output path.

Paper 2 feasibility is a post-first-pass deliverable. It must not be listed as a current-sprint output unless the owner explicitly changes the scope lock.

Use stable filenames that identify paper, outcome, specification, and date. Do not overwrite an earlier result without a decision-log entry.

### Task 24: Write the result memo

**File:** `04_output/results_memo.md`

Use four separate labels for every important finding:

1. **Observed in data:** sample count, prevalence, means, merge rate, coefficient, confidence interval.
2. **Model interpretation:** what the coefficient means under the specified model.
3. **Inference:** what assumptions are needed for a causal interpretation.
4. **Not established:** what the data/design cannot show.

The memo must include:

- sample changes at every filter;
- treatment definitions used;
- the primary specification and every deviation;
- diagnostics that failed;
- results with unexpected signs;
- results that are too imprecise to support a claim;
- next decisions supported by evidence.

### Task 25: Run the reproducibility audit

**File:** `92_reproducibility_audit.do`

**Steps:**

- [ ] Start from a clean output directory.
- [ ] Run `00_master.do` without manual edits or GUI transformations.
- [ ] Run a preflight/smoke pass that confirms the root path, Stata version, required source files, crosswalk status, and primary-specification lock before any long model run.
- [ ] Confirm every required input path exists.
- [ ] Confirm every output is recreated with the same observation counts and decision-log version.
- [ ] Check logs for errors, ignored return codes, missing-variable warnings, and unexpected observations.
- [ ] Re-run selected key models and compare stored estimates.
- [ ] Save the final software/data manifest and a list of installed user-written commands.
- [ ] Compare source-file hashes/signatures and derived-data signatures against the manifest; record any intentional change as a new release entry.
- [ ] Back up do-files, crosswalk, logs, and derived-data metadata outside the machine as required by the timeline.

**Definition of Done:** the project is ready for internal review only when raw data are untouched, the master run completes, all quality gates have evidence, the sample flow is complete, and unresolved items are visibly listed. It is not ready for external causal claims when an identification gate is still open.

### Task 26: Audit citations, journal fit, and reviewer evidence

**Files:**

- Create: `99_docs/citation_audit.csv`
- Create: `99_docs/journal_target_register.md`
- Create: `99_docs/reviewer_evidence_matrix.csv`
- Create: `93_publication_package_audit.do`

The deck contains target-journal comparisons and possible reviewer questions, while CN3 contains citation errata. These items are part of the publication package, not evidence that the current analysis is already publishable.

**Citation audit columns:**

```text
claim_id,citation_as_written,source_title,author_year,doi_or_url,
primary_source_checked,claim_supported,correction_needed,status,checked_date
```

**Reviewer matrix columns:**

```text
paper,reviewer_question,threat,diagnostic_or_analysis,
required_output,current_evidence,remaining_gap,claim_limit,status
```

**Steps:**

- [ ] Verify every high-risk CN3 citation against the primary paper or authoritative bibliographic record; record corrections instead of silently changing the prose.
- [ ] Separate measurement sources, theory sources, empirical precedents, and policy sources in the citation audit.
- [ ] Re-verify target journal scope, author guidelines, word limits, table/figure rules, fees, and waiver policy from official journal pages at the time of submission; treat the deck's values as historical planning notes.
- [ ] Map each reviewer question in the deck to an actual output, an interpretation limit, or an explicit unresolved gap. A rhetorical counter without a test does not close the reviewer issue.
- [ ] Run the publication audit after the result memo and before any manuscript claim is labelled final.

**Quality gate:** no manuscript paragraph may claim that a reviewer concern has been resolved unless the matrix points to saved data/diagnostic evidence and a bounded interpretation.

### Task 27: Apply data governance and disclosure checks

**File:** `99_docs/README_reproducibility.md`

- [ ] Record IFLS public-use permissions and any restrictions on redistribution, backups, and derived files.
- [ ] Keep personal identifiers and sensitive raw fields out of tables, figures, logs, and reviewer packages unless explicitly permitted.
- [ ] Record which external files may be linked, their license/permission, release date, merge key, and whether the linked derivative can be shared.
- [ ] State what another analyst receives to reproduce the results when raw data cannot be redistributed.

**Quality gate:** the reproducibility README has a data-sharing boundary and an artifact list that does not expose restricted microdata.

---

## 12. Execution order and gates

### Current first-pass work cycle from the supplied timeline

| Urutan | Focus | Must exist before moving on |
|---:|---|---|
| 1 | Source/codebook inventory, source-conflict register, primary-specification lock, person spine, household lineage, roster | key checks, source-release/hash manifest, official-N reconciliation, module availability memo |
| 2 | Paper 1 treatment/cohort/baseline/outcome | baseline-treatment contamination report, tier counts, heterogeneity-cell support, balance table |
| 3 | Paper 1 IMDI and first estimates | weight diagnostics, missingness rule, main table, coefficient plot, heterogeneity table |
| 4 | Paper 3 treatment/cohort/outcome mapping | cohort-age matrix, prevalence by definition/age/sex, hazardous-work mapping |
| 5 | Paper 3 first estimates and closure | age-profile output, results memo, decision log, backup |

### Post-first-pass work cycle

| Urutan | Focus | Must exist before moving on |
|---:|---|---|
| 1 | Paper 2 feasibility | sample and time-use counts before full model commitment |
| 2 | Identification and robustness | instrument provenance, survey-design decision, IV/event-study/attrition/missingness diagnostics, robustness registry |
| 3 | Valuation | frozen earnings model, observed-support audit, projection assumptions, uncertainty simulation, compatible headcount source |
| 4 | Publication package | reproducible rerun, citation audit, current journal register, reviewer-evidence matrix, bounded manuscript claims |

### Stop conditions

Stop the next stage and log the blocker when:

- a required key is not unique;
- official reconciliation differs beyond the registered threshold without explanation;
- a treatment definition relies on an unverified raw field;
- the primary specification lock is incomplete for the model being run;
- baseline variables are labelled pre-treatment despite left-censored or unknown treatment timing;
- a treatment cell is too small for the registered inference;
- an outcome is absent or structurally incomparable;
- the survey weight/PSU/cluster rule is undocumented for a weighted or clustered result;
- an instrument has no documented source/timing/merge;
- a national headcount is not definition-compatible;
- a model output cannot be reproduced from `00_master.do`.

---

## 13. Additional brief needed from the project owner

The three documents are enough to understand the research idea, but not enough to finalize an executable Stata specification. Before analysis begins, provide these inputs.

### A. Priority and delivery

1. Confirm that the current release is Paper 1 and Paper 3 first-pass analysis in the stated order, with Paper 2 parked for a later feasibility phase.
2. What is the actual deadline and what counts as the current deliverable: cleaned dataset, descriptive table, first regression, presentation, or manuscript section?
3. If Paper 2 must enter the current cycle, identify which Paper 1/Riset 3 output is removed and record the scope change.
4. What language and citation style must the result memo and eventual paper use?

### B. Stata environment

1. Stata edition and exact version: IC, SE, or MP.
2. Operating system and whether Stata can read the current `.dta` files without conversion.
3. Whether installing user-written packages is allowed; if yes, which packages are already installed.
4. Maximum runtime/storage constraints.
5. Whether the analysis must run on this workspace only or another machine too.

### C. Data and provenance

1. Confirm whether the local files are the complete, consistent release intended for the project.
2. Identify which Wave 5 ZIP archives may be extracted and where the read-only raw copy must live.
3. Provide or approve the exact user guides/codebooks to treat as authoritative for each wave.
4. Confirm whether external climate, commodity, minimum-wage, PODES, Susenas, Sakernas, BPS, or BPJS files are available and legally usable. None should be assumed from the concept note alone.
5. State whether any personal/sensitive fields must be excluded from derived outputs or backups.

### D. Identification and estimand choices

1. For Paper 1, choose the intended primary migration population: international only or the tiered international-plus-domestic design.
2. For Paper 1, confirm the primary cohort: W1 only, W1 plus W2, or a pre-registered split.
3. For Paper 1, decide how cases already absent at W1 or left-censored before W1 are treated; this decision is required before W1 covariates can be labelled pre-treatment.
4. For Paper 3, confirm whether W1 is a secondary treatment cohort and exactly which wave supplies each age-band outcome.
5. For Paper 3, confirm whether household chores are in scope if the IFLS module supports them; otherwise approve a revised gender estimand.
6. State whether the primary claim is descriptive/associational or causal conditional on IV/other diagnostics.
7. Choose the primary instrument candidates only after the data sources and merge keys are identified.
8. Confirm whether the document’s suggested staggered/event-study methods are mandatory or exploratory.

### E. Statistical conventions

1. Survey weights: use, do not use, or decide separately by estimand, including the target population and whether a `svyset` design is required.
2. Verified PSU, stratum, and weight variables for every wave/module used; do not provide only a generic word such as “weights”.
3. Primary cluster level: community, origin household, or another verified level.
4. Monetary base year and deflator rule.
5. Missing-data rule for the first pass and whether multiple imputation is required immediately.
6. Outlier and top-code rules for earnings, hours, anthropometrics, and expenditure.
7. Primary outcome families and multiple-testing correction.
8. Minimum cell size or minimum number of clusters required before reporting a subgroup estimate, plus the preferred power/MDE convention.

### F. Paper 3 valuation brief

1. Whether NPV is required in the first milestone or only after causal estimates are reviewed.
2. Approved base and sensitivity discount rates.
3. Working-life endpoint and retirement-age assumption.
4. Projection rule after the observed age range.
5. Authoritative national child-labor headcount, reference year, definition, and population unit.
6. Whether the policy comparison should use PKH/PIP budgets, another program, or no budget comparison until external figures are verified.

### G. Publication, reviewer, and data-governance brief

1. Which journal is the first target for each paper, and which alternatives should remain in the register?
2. Which reviewer questions are highest priority for the internal review?
3. Which claims require current external verification before they can appear in a manuscript or policy brief?
4. What are the restrictions on storing, backing up, sharing, and publishing IFLS-derived data and external linked data?
5. Which fields must be excluded from logs, tables, figures, backups, and reviewer packages?

### H. Definition of completion

Please define “selesai” separately for the current first-pass release and the post-first-pass program.

**Current first-pass release:**

```text
[ ] data inventory and codebook crosswalk complete
[ ] person/household/roster spine passes quality gates
[ ] Paper 1 first-pass table and graph complete
[ ] Paper 3 first-pass table and graph complete
[ ] result memo complete
[ ] Paper 2, IV, formal mediation, valuation, and manuscript claims explicitly marked parked or blocked
```

**Post-first-pass program:**

```text
[ ] Paper 2 feasibility memo complete
[ ] IV/robustness complete
[ ] formal mediation and attrition sensitivity complete where estimable
[ ] valuation and uncertainty scenarios complete
[ ] citation audit, journal register, and reviewer-evidence matrix complete
[ ] manuscript draft complete
```

Until these choices are supplied or verified from the data, the plan can be executed through inventory, spine construction, and the evidence-producing first-pass gates, but a final model specification should not be pretended to be settled.
