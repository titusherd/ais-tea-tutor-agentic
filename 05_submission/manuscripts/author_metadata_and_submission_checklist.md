# Author metadata and submission checklist

Status: `OWNER_INPUT_REQUIRED`

This checklist separates what the technical package already provides from
fields that only the authors can confirm. Do not replace an open status with a
guess. Complete the checklist before changing the package status from internal
review to external submission.

## A. Author identity

| Field | Status | Required evidence |
|---|---|---|
| Lead author legal/publication name | `OWNER_INPUT_REQUIRED` | Author-confirmed spelling |
| Coauthor names and order | `OWNER_INPUT_REQUIRED` | Author-confirmed author list |
| Institutional affiliations | `OWNER_INPUT_REQUIRED` | Current institution and department |
| Corresponding author | `OWNER_INPUT_REQUIRED` | Name, institution, and confirmed email |
| ORCID IDs | `OWNER_INPUT_REQUIRED` | Author-confirmed ORCID, if applicable |
| Author contributions | `OWNER_INPUT_REQUIRED` | CRediT or journal-specific statement |

## B. Research declarations

| Field | Status | Required evidence |
|---|---|---|
| Data availability | `DRAFT_READY_OWNER_VERIFY` | Final wording plus official release/access record |
| IFLS source citation | `RAND_SOURCES_VERIFIED_RELEASE_MATCH_OPEN` | Wave-specific citations matched to the local release |
| Ethics statement | `OWNER_INPUT_REQUIRED` | Institutional wording and any required approval/reference details |
| Funding | `OWNER_INPUT_REQUIRED` | Grant or “no external funding” confirmation |
| Conflicts of interest | `OWNER_INPUT_REQUIRED` | Author-confirmed declaration |
| Acknowledgements | `OWNER_INPUT_REQUIRED` | Author-confirmed text and permissions |
| AI-use statement | `DRAFT_READY_OWNER_VERIFY` | Author acceptance and target-journal policy check |

The official RAND page records that the IFLS procedures were reviewed by IRBs,
but that source statement does not substitute for the authors' required
institutional or journal declaration. The project does not invent an ethics
approval number.

## C. Manuscript and journal package

| Item | Status | Check |
|---|---|---|
| Target journal and article type | `REGISTERED_VERIFY_CURRENT` | Confirm against the journal's current author guidelines |
| Title page | `TEMPLATE_READY_OWNER_INPUT` | Complete author identity and declarations |
| Cover note | `TEMPLATE_READY_OWNER_INPUT` | Add author-confirmed contribution and fit language |
| Main text | `INTERNAL_REVIEW_READY` | Owner reviews estimand, results, and limitations |
| Tables and figures | `TECHNICAL_PACKAGE_READY` | Confirm numbering, captions, and journal format |
| References | `PRIMARY_SOURCE_REVIEW_REQUIRED` | Verify all citations carried from planning materials |
| Supplementary material | `OWNER_DECISION_REQUIRED` | Decide whether diagnostics are submitted or archived |
| Final PDF/DOCX | `RENDERED_INTERNAL_DRAFT` | Re-render after all author edits |

## D. Data and evidence release gate

- [ ] Record the exact official IFLS release identifier used for the local
  extracted files.
- [ ] Record authorized access evidence without storing passwords, tokens, or
  private registration details.
- [ ] Reconcile the release identifier with `source_manifest.csv` and local
  hashes in the private working environment.
- [ ] Confirm that no raw IFLS file, restricted field, identifier, or linked
  derivative is attached to the journal package or GitHub repository.
- [ ] Confirm the adjusted-association interpretation and small-cell limits in
  the final manuscript.

## E. Final owner sign-off

The technical package contains an internal reviewer report and a numerical
reconciliation for all 14 headline rows. The owner must still confirm that the
conservative R1/R3 estimands, manuscript wording, author list, declarations,
and target-journal choice are acceptable. External peer review or journal
acceptance must never be represented as complete based on this checklist.
