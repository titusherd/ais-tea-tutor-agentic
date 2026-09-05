# Source manifest hash policy

Date: 2026-09-05

`99_docs/source_manifest.csv` contains one row for each local extracted `.dta`
file in `00_raw`. `31_finalize_local_source_hashes.do` records the local file
byte size and SHA-256 hash without changing any raw data.

The recorded hash proves the identity of the local extracted file at the time
of the audit. It does not prove the official IFLS release identifier,
download provenance, or license. Those fields remain explicitly pending until
the original release documentation is available. No release identity is
inferred from a filename or a hash.
