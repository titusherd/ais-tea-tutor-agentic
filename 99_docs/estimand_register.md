# Estimand register

Status: primary first-pass estimands locked to the conservative default on
2026-09-05. All first-pass estimates are adjusted associations.

| ID | Paper | Estimand | Population/timing | Outcome | Treatment | Interpretation | Status |
|---|---|---|---|---|---|---|---|
| R1-MAIN | Paper 1 | Conditional W5 difference in predeclared adult outcome families associated with mother-led international work migration after W1 | W1 eligible children, both parents linked/present and uncontaminated, valid origin household, tracked to W5, W5 age 17–36 | Separate valid-code W5 labor, education, health, and social/behavioral outcomes | Verified mother-linked work migration with verified international destination and child remaining in origin household | Adjusted association; no causal wording | locked_conservative_default |
| R1-CRIT | Paper 1 | Difference in W5 adult outcome families by age-at-onset among verified R1 treated cases | R1-MAIN treated cases only; only if episode timing and support pass | Same predeclared W5 outcome families | Age-at-onset categories from verified episodes | Supplementary adjusted association; not automatically causal | post_first_pass |
| R1-PANEL | Paper 1 | Within-person change around a verified parent migration episode | Repeated W1–W3 outcome only where module comparability passes | Childhood health/education outcomes | Time-varying parent absence/migration | Post-first-pass panel association | parked |
| R2-FEAS | Paper 2 | Feasibility of within-husband change around wife work migration | Married men with verified spouse link and pre/post observations | Market/domestic work and time use | Wife work migration | Feasibility/descriptive | parked |
| R2-LABOR | Paper 2 | Within-person change in husband labor outcome when wife is away for work | Verified staggered episode panel | Market hours, domestic hours, leisure, participation | Wife work migration | Parked until separate design gate | parked |
| R3-MAIN | Paper 3 | Conditional W5 difference in adult outcome families associated with age-15 paid/market child labor | W2/W3 age-15 children with observed screen, valid treatment household, tracked to W5, W5 age 17–36 | Separate valid-code W5 labor/earnings, education, health, and social/behavioral outcomes | Last-week job1+job2 hours >43 with valid codebook rule | Adjusted association; age 10–14 not inferential primary | locked_conservative_default |
| R3-AGE | Paper 3 | Descriptive adult outcome profile by R3 age band | W2/W3 age 10–14 only where screen/module support exists; W4/W5 outcomes | Coverage and descriptive outcome profile | Candidate age-specific child-work evidence | Feasibility/descriptive only | locked_conservative_default |
| R3-NPV | Paper 3 | Present value of model-estimated earnings differences under explicit scenarios | Observed ages plus declared extrapolation | Earnings difference in common monetary unit | Selected R3 estimate | Scenario only; not observed national loss | parked |

## Lock rule

Any change to treatment, control, sample, outcome window, weight, cluster,
missingness, or interpretation requires a dated decision-log entry with the
old definition, new definition, evidence path, and affected N. No model may
silently use a parked estimand as a primary result.
