# Replication handoff

## Scope

This handoff contains Stata do-files, aggregate outputs, diagnostics, figures,
and documentation. It does not authorize redistribution of IFLS raw files,
identifiers, restricted fields, or sensitive linked derivatives.

## Canonical command

From `/Users/titus/Documents/ais-tea`, use the Stata executable recorded in
`99_docs/software_environment.txt` and run:

```text
dofile dofiles/00_master.do
```

The chain ends with:

- `dofiles/32_publication_support_audit.do`
- `dofiles/33_publication_outputs.do`
- `dofiles/34_publication_quality_gate.do`

## Evidence levels

- Stata logs prove that the specified commands ran and gates returned pass.
- Aggregate CSV files prove the saved estimates and sample counts.
- Diagnostics prove construction and support decisions.
- None of these artifacts, by themselves, proves causal identification or
  external live/journal submission.

## Authorized data

The analyst or replication team must obtain authorized IFLS files from the
official data documentation and record the exact release identifier, local
file hashes, access terms, and any required ethics/data-use restrictions before
public release. The current local manifest has file hashes but retains the
release identifier as an open item.
