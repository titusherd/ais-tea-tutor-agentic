# W1 baseline controls

Date: 2026-09-05  
Status: `technical_gate_pass`  
Source: W1 roster/codebook and the shared IFLS person spine

## Baseline universe

`02_derived/w1_baseline_controls.dta` has one canonical row per W1
`pidlink` in the expanded person spine: 83,777 rows. This includes panel
persons with no usable W1 roster observation so that missingness and linkage
are visible. The observed W1 roster with a valid household ID has 33,067
rows. Analysis frames explicitly require an observed W1 origin household;
the expanded spine is not silently treated as observed baseline data.

The W1 child cohort used by R1 is age 0–12 and contains 9,891 persons.

## Verified variables

| Canonical variable | Raw/source basis | Rule |
|---|---|---|
| `w1_age` | W1 person spine age | valid nonmissing survey age in the shared spine |
| `w1_sex_spine`, `w1_child_female` | W1 roster/spine; AR07 codebook | AR07 `1=male`, `3=female`; only valid binary sex is recoded |
| `w1_hh_size` | W1 roster/spine | count of present W1 roster persons with the same valid W1 household ID |
| `w1_education_level_raw` | W1 AR16 | codebook-backed level categories retained raw; no forced numeric years |
| `w1_grade_completed_raw` | W1 AR17 | raw grade retained; codebook warns about inconsistent grade semantics |
| `w1_current_school` | W1 AR18 | `1=yes`, `3=no`; special codes are invalid/missing |
| `w1_primary_activity_raw` | W1 AR22 | `1=working/earning`, `2=job searching`, `3=school`, `4=housekeeping`, `5=retired`, `6=other`; special codes invalid |
| `mother_pidlink`, `father_pidlink` | W1 AR10/AR11 through roster relation | only within-household person IDs are linked; status codes such as living elsewhere/dead are not converted to parent IDs |
| `w1_mother_age`, `w1_father_age` | linked person-spine age | linked parent age is retained only when the explicit parent link resolves |
| parent education | linked W1 AR16 | linked parent education is retained raw and validity-flagged |

The W1 codebook records AR10/AR11 as within-household person references and
includes status codes for living elsewhere and dead. These statuses are part
of the baseline contamination gate; they are not treated as ordinary parent
links.

## Core controls used in first-pass models

R1 uses:

```text
c.w1_age i.w1_child_female c.w1_hh_size c.w1_mother_age c.w1_father_age
```

R3 uses the same controls plus `i.wave`. These are pre-treatment baseline
controls under the locked parent-link/origin rule. Education, health,
employment, marriage, trust, and other W5 variables are never used as
baseline controls.

## Completeness counts

Among the 9,891 W1 age 0–12 cohort members:

| Baseline condition | N |
|---|---:|
| linked mother | 9,239 |
| linked father | 8,563 |
| both linked parents | 8,418 |
| core controls complete | 8,417 |
| expanded controls complete | 6,886 |

For the full expanded baseline file, the audit reports valid values for
33,080 ages, 33,067 household sizes, 16,571 current-school responses,
32,993 education levels, 16,705 mother ages, and 14,520 father ages. These
are validity counts, not claims that missing applicable questions represent
random nonresponse.

## Files

- Baseline data: `02_derived/w1_baseline_controls.dta`
- Validity audit: `04_output/diagnostics/w1_baseline_validity_audit.csv`
- Sample flow: `04_output/diagnostics/w1_baseline_sample_flow.csv`
- Education distribution: `04_output/diagnostics/w1_education_distribution.csv`
- Construction log: `04_output/logs/26_build_w1_baseline_controls.log`

## Interpretation limit

W1 controls are verified data fields with explicit availability flags, not a
claim that all baseline characteristics are observed for every panel person.
The AR17 grade measure is retained for supplementary work but excluded from
the first-pass outcome family because its common scale is not secure.
