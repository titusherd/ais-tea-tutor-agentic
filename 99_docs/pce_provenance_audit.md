# PCE and monetary harmonization audit

Date: 2026-09-05  
Status: evidence complete for a review gate; monetary harmonization is not locked.

## What was audited

The audit used Stata to read the locally available historical PCE, deflator,
and W1 expenditure files. The old PCE do-files were read as provenance only.
They were not executed unchanged because they contain legacy Windows paths.
No new PCE variable was constructed.

## Facts

- Readable historical files include nominal PCE outputs for 1993, 1997, 2000,
  and 2007; real outputs were found for 1997 and 2000.
- The audited candidate household keys are present and unique within each
  readable file.
- The local source text inspected in pce97.do and pce00.do states a temporal
  deflator with December 2000 as the base and a spatial deflator with Jakarta
  as the base.
- No pce93 real file, pce07 real file, pce14 nominal/real file, or W5
  expenditure-derived PCE file was found at the expected local paths.
- The local IFLS5 archive inventory identified two price PDFs (market and
  warung). A price PDF is not a household PCE output and cannot by itself
  supply a W5 household-level PCE variable.

See:

- 04_output/diagnostics/pce_file_inventory.csv
- 04_output/diagnostics/pce_variable_inventory.csv
- 04_output/diagnostics/pce_specification_audit.csv
- 04_output/diagnostics/pce_monetary_gap.csv

## Implication

The historical rule is usable as a provenance lead, not as a completed
cross-wave variable. In particular, a nominal 2007 file cannot be mixed with
real 1997/2000 files as if they were already on one common monetary scale.
Before a monetary IMDI component or monetary control is used, the project
owner must choose one of these routes:

1. port and independently verify the historical PCE construction for every
   required wave, including W5;
2. restrict monetary components to a defensible common subset and change the
   estimand; or
3. omit household PCE from the primary index and register it as supplementary.

This choice is D-031 and remains open. The project has not reported any
monetary coefficient or national loss.
