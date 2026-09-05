# Survey-design decision

Status: `primary_rule_locked_conservative_default`; official weighted
sensitivity remains technically pending.

## Primary rule

The first-pass R1 and R3 models are conditional association models without a
generic `svyset`. They use robust standard errors clustered at the household
where exposure/treatment is observed:

- R1: W1 origin household.
- R3: W2/W3 treatment-wave household.

The model output must state that this VCE handles within-household dependence
but does not by itself reproduce the full IFLS sampling design or establish a
nationally representative target population.

## Weighted sensitivity rule

Weighted descriptive or sensitivity estimates may be added only after the
following estimand-specific fields are verified from official IFLS design
documentation and matched to the exact module and target population:

~~~text
estimand_id,waves/modules,target_population,weight_variable,weight_type,
psu_variable,stratum_variable,fpc_variable,svyset_specification,
primary_vce,primary_cluster,comparison_cluster,cluster_count,
weight_justification,interpretation_limit,evidence_path,status,decision_id
~~~

Candidate weights, geography, province, urban/rural, community, or household
IDs must not be promoted to PSU/stratum/weight by naming similarity alone.

## Evidence basis

`04_output/diagnostics/survey_weight_variable_audit.csv` contains 172
candidate weight/geography rows and
`04_output/diagnostics/survey_geography_cluster_audit.csv` contains 49
geography/cluster candidates. The audit found no project-level `svyset`
specification. This is why the documented clustered non-survey model is the
primary rule and official survey inference is sensitivity only.

Decision: D-030. Interpretation boundary: D-042.
