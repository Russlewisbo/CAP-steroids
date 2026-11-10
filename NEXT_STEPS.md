# Next Steps to Finish the Analysis

**Date:** 5 November 2026
**Source:** condensed from `Status.md` (4 Nov update; item numbers refer to its §5) plus a repo review for the PRISMA diagram. `Status.md` remains the decisions log and is not replaced by this file.

## Where things stand

- The pipeline (`analysis/`, `targets`, Stan) and the draft web report (`docs/`) run end to end on the pre-specified defaults. All 54 main fits pass convergence checks.
- Final set: 7 primary trials, 11 sensitivity trials, 2 integrity exclusions, 1 pending (Wafy 2021).
- RoB 2: consensus recorded for the 7 primary trials, but the second assessor has not confirmed it.
- All current numbers are provisional. Pooled estimates are sensitive to the REMAP-CAP SE and to whether REMAP-CAP is in F1.

## Critical path to a final analysis run

| Step | What is needed | Owner | Status.md item |
|---|---|---|---|
| 1 | Confirm D1 (ESCAPe row), D3 (prior-ladder centres/SDs), D4 (tau and omega priors) | Russ | 17 |
| 2 | Sign off the 29 Oct additions: meta-regression prior, timing covariate coding, pooled-baseline comparison, S-den, S-src | Russ | 17 |
| 3 | Decide Wafy 2021 (exclude on integrity vs sensitivity only); confirm Mikami 2007 mortality = not reported | Russ | 13 |
| 4 | Decide Nafae placebo denominator (19 vs 20; no effect on results) | Russ | 22 |
| 5 | Switch F1 to D2a (REMAP-CAP ICU-discharge contrast) in `_targets.R` and the report; re-check abstract, plain-language summary, Discussion, D1/D2 table wording | Assistant / Russ | 23 |
| 6 | Obtain REMAP-CAP adjusted log-OR and SE from the investigators (interim SE 0.36 from CrI; D2a uses SE 0.487) | Russ | 6 |
| 7 | Confirm or amend the RoB 2 consensus (any change: edit `consensus_overall` in `analysis/rob2_assessments.csv`, then `tar_make()`) | Maria | 25 |
| 8 | Finish database verification sign-off: Tongyoo, subgroup-derived rows, REMAP-CAP contrasts; note Nafae and Snijders CURB-65 as "match with note" | Maria / Russ | 26 |
| 9 | RoB 2 for the 11 sensitivity trials (and Wafy if kept); needed for the sensitivity-set risk-of-bias statements | Maria | 24 |
| 10 | Add RoB 2 page/section and Methods paragraph to the web report | Assistant | 27 |
| 11 | Verify Pitre 2025 benchmark values against the PDF and supplement (Table S2 priors) | Student | 18 |
| 12 | `targets::tar_make()` in `analysis/`, run GRADE, human review of report text | Assistant / Russ | - |

## Data still to obtain (Status.md item 9)

- Full texts: Fitzgerald 2022 STOPPE (current PDF is a Confalonieri duplicate), El-Ghamrawy 2006, Li (Gang) 2016, Zhou 2015, Wagner 1956, Soboleva 2000, Dambrava 2006, Oh 2009, Kapisyzi 2012, Michels 2026 (current PDF is a duplicate). Maharjan 2018 is still untraced.
- Supplements: CAPE COD, STEP appendix, Snijders E3, Santeon E-tables, SONIA S13, ESCAPe, DEXA-ARDS appendix, Smit 2025 appendix.
- Briel 2018 IPD group: 30-day severe-subgroup counts for Snijders, Meijvis, STEP.
- APROCCHSS NEJM protocol/SAP (optional; the design paper already covers RoB domain 5).
- Optional: author contact for CORTIFLU (26 randomised); OCR Bernard 1987 to confirm exclusion.
- Registry searches and PI contacts for registered but unpublished trials (RECORDS, ASTEROIDS, Hong 2022, COLOSSEUM, NCT04007328, NCT02552342).

## Search, screening and PRISMA (needed for registration and the flow diagram)

| Need | Detail |
|---|---|
| Re-export Ovid MEDLINE line 28 and PubMed #5, then re-run dedup | The 3,931 identified / 2,798 deduplicated counts may change (item 3) |
| Registry searches (ICTRP mandatory) | Not done; add registry counts as a separate PRISMA identification arm (item 10) |
| Second independent screener (T/A retained set + 10% of exclusions) | The protocol requires dual screening; the record shows one AI-assisted pass (item 2) |
| Locate `screening_log_all_records.csv` and add a copy (or a summary) to the repo | Needed for T/A exclusion counts; Status.md cites it (R1443 and R1407) but it is not in this repo |
| Per-reason full-text exclusion counts | Currently only trial names are listed |
| Reconcile the full-text count | Status.md says 55 but the breakdown (21 + 22 + 9 + 2 + 3) sums to 57 |
| Document the Muhammad 2025 DOI check (date, failed references, what they resolved to) | PRISMA exclusion footnote (item 16) |
| Decide the "included" figure for the diagram | 32 trial rows in the database vs 19 trials in `trials.csv` (7 + 11 + 1); report studies and reports separately |

## Registration (blocks PROSPERO submission)

1. Supervisor sign-off on decisions A and C (item 1).
2. Reword PROSPERO field 5: screening and a first extraction pass have begun (item 5).
3. Add sensitivity fit (ix), short course < 48 h, and the SONIA agent-mix rule to the registered protocol.
4. Public repository check; post hoc PRESS librarian review (items 4, 5).

## Housekeeping

- Update `ANALYSIS_INSTRUCTIONS.md` (it still says RoB 2 is not done and cites the 27 Oct status).
- Decide when to publish `docs/` to GitHub Pages, since it holds unregistered draft results (item 20).
- Zotero import of `records_to_retrieve_fulltext.ris` (item 11).
- Commit the uncommitted changes to `.gitignore` and `.posit/assistant/settings.json`.
- Keep this repo's `Status.md` in sync with the Project-folder copy.

## Suggested order

1. Russ: steps 1-4 above (decisions only, no work needed from others).
2. Assistant: step 5 (switch F1 to D2a) and step 10 (RoB 2 report page), which can start as soon as decision 1 is made.
3. In parallel: Maria's steps 7-9; data requests (step 6 and the list above); second screener and search re-exports.
4. Then run the final `tar_make()`, GRADE, and review. Build the PRISMA diagram once the counts above are settled. A draft with placeholders can be built earlier.
