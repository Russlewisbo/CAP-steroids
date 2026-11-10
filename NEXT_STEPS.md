# Next Steps to Finish the Analysis

**Date:** 10 November 2026 (replaces the 5 November version)
**Source:** condensed from `Status.md` (10 Nov update; item numbers refer to its §5) and `PRISMA_draft_2026-11-10.md`. `Status.md` remains the decisions log and is not replaced by this file.

## Where things stand

- The pipeline (`analysis/`, `targets`, Stan) and the draft web report (`docs/`) were re-run from scratch on 10 Nov on a new machine (R 4.6.1, CmdStan 2.40.0). All 56 main fits pass convergence checks, and `brms` agrees on 53 of 53 cross-checked parameters.
- D2 is decided and applied: REMAP-CAP enters every short-term set (F1, F3, F4) through its ICU-discharge contrast, and the day-90 contrast is used in F2 only. F1 (7 trials, reference prior): OR 0.67 (0.39–1.06), P(OR<1) 0.96. F3: 0.73 (0.50–1.01). F4: 0.73 (0.55–0.93).
- The interim REMAP-CAP SE now matters little (F1 P(OR<1) 0.96 to 0.97 for SE 0.40 to 0.60). What matters is whether, and through which contrast, REMAP-CAP enters (0.98 without it).
- Final set: 7 primary trials, 11 sensitivity trials, 9 studies excluded at full text, 1 pending (Wafy 2021), 4 ongoing.
- RoB 2: consensus recorded for the 7 primary trials and shown on the new Risk of bias page; the second assessor has not yet confirmed it.
- A draft PRISMA 2020 diagram exists with report-level counts; registers, citation searching and title/abstract exclusions are still TBD.
- All current numbers are provisional until D1, D3 and D4 are confirmed.

## Done since 5 November

| Was | Done | Status.md |
|---|---|---|
| Switch F1 to D2a in the pipeline and the report | 10 Nov; report text re-checked | 23 |
| RoB 2 page and Methods paragraph on the web report | 10 Nov (`analysis/risk_of_bias.qmd`) | 27 |
| REMAP-CAP contrast in F3 and F4 | Decided 10 Nov: ICU-discharge, as in F1 | 28 |
| SE sensitivity for the ICU-discharge contrast | Decided 10 Nov: SE 0.40 and 0.60 added | 29 |
| Reconcile the full-text count (55 vs 57) | 55 confirmed from the extraction workbook; Status §1 corrected | — |
| Per-reason full-text exclusion counts; studies vs reports in the PRISMA diagram | 10 reports of 9 studies excluded; 38 reports of 18 included studies | 30 |
| Commit `.gitignore` changes | Committed | — |
| Add the `quarto` R package to `renv.lock` | Added (1.5.1) | — |
| Update `ANALYSIS_INSTRUCTIONS.md` | Revised 10 Nov: D2a and how it is applied in code, RoB 2 data and S-ii, fits added since 29 Oct, pipeline as built | — |

## Critical path to a final analysis run

| Step | What is needed | Owner | Status.md item |
|---|---|---|---|
| 1 | Confirm D1 (ESCAPe row), D3 (prior-ladder centres/SDs), D4 (tau and omega priors) | Russ | 17 |
| 2 | Sign off the 29 Oct additions: meta-regression prior, timing covariate coding, pooled-baseline comparison, S-den, S-src | Russ | 17 |
| 3 | Decide Wafy 2021 (exclude on integrity vs sensitivity only); confirm Mikami 2007 mortality = not reported | Russ | 13 |
| 4 | Decide Nafae placebo denominator (19 vs 20; no effect on results) | Russ | 22 |
| 5 | Obtain the REMAP-CAP adjusted log-ORs and SEs from the investigators (both current SEs derived from the CrIs: ICU discharge 0.487, day 90 0.362) | Russ | 6 |
| 6 | Confirm or amend the RoB 2 consensus (note drafted 10 Nov; three judgements differ from hers: Confalonieri D5, REMAP-CAP D2 and D5). Any change: edit `consensus_overall` and `consensus_note` in `analysis/rob2_assessments.csv`, then `tar_make()` | Maria | 25 |
| 7 | Finish database verification sign-off: Tongyoo, subgroup-derived rows, REMAP-CAP contrasts; note Nafae and Snijders CURB-65 as "match with note" | Maria / Russ | 26 |
| 8 | RoB 2 for the 11 sensitivity trials (and Wafy if kept); at present only the assessor-1 draft is on the Risk of bias page | Maria | 24 |
| 9 | Update the methods text she is drafting for D2a (now applied to F1, F3 and F4) | Maria | 23 |
| 10 | Verify Pitre 2025 benchmark values against the PDF and supplement (Table S2 priors) | Student | 18 |
| 11 | Final `targets::tar_make()` in `analysis/`, run GRADE, human review of the report text | Assistant / Russ | - |

## Data still to obtain (Status.md item 9)

- Full texts, database arm: Fitzgerald 2022 STOPPE (current PDF is a Confalonieri duplicate), Michels 2026 (current PDF is a Nafae duplicate).
- Full texts, other methods (provenance to confirm against the screening log): El-Ghamrawy 2006, Li (Gang) 2016, Zhou 2015, Wagner 1956, Soboleva 2000, Dambrava 2006, Oh 2009, Kapisyzi 2012. Maharjan 2018 is still untraced.
- Supplements: CAPE COD, STEP appendix, Snijders E3, Santeon E-tables, SONIA S13, ESCAPe, DEXA-ARDS appendix, Smit 2025 appendix.
- Briel 2018 IPD group: 30-day severe-subgroup counts for Snijders, Meijvis, STEP.
- APROCCHSS NEJM protocol/SAP (optional; the design paper already covers RoB domain 5).
- Optional: author contact for CORTIFLU (26 randomised).
- Registry searches and PI contacts for registered but unpublished trials (RECORDS, ASTEROIDS, Hong 2022, COLOSSEUM, NCT04007328, NCT02552342).

## Search, screening and PRISMA (needed for registration and the flow diagram)

The draft diagram and its placeholder register are in `PRISMA_draft_2026-11-10.md` (Status.md item 30).

| Need | Detail |
|---|---|
| Re-export Ovid MEDLINE line 28 and PubMed #5, then re-run dedup | The 3,931 identified / 2,798 deduplicated counts may change (item 3) |
| Registry searches (ICTRP mandatory) | Not done; fills the Registers count (item 10) |
| Inclusion-list / citation search | Fills the Citation searching count; classify the 7 Pitre 2025 sepsis/ARDS trials |
| Second independent screener (T/A retained set + 10% of exclusions) | The protocol requires dual screening; the record shows one AI-assisted pass (item 2) |
| Locate `screening_log_all_records.csv` and add a copy (or a summary) to the repo | Fills the T/A exclusion count (2,743 if every report sought came from the screened set) and confirms the source of the 8 other-methods full texts |
| OCR Bernard 1987 | Confirms its provisional exclusion reason (item 15) |
| Document the Muhammad 2025 DOI check (date, failed references, what they resolved to) | PRISMA exclusion footnote (item 16) |
| Decide Wafy 2021 and whether ongoing studies get their own box | Both are a footnote on the draft figure (item 13) |

## Registration (blocks PROSPERO submission)

1. Supervisor sign-off on decisions A and C (item 1).
2. Reword PROSPERO field 5: screening and a first extraction pass have begun (item 5).
3. Add to the registered protocol: sensitivity fit (ix) short course < 48 h, the SONIA agent-mix rule, and D2a (REMAP-CAP ICU-discharge contrast in the short-term sets, with the SE sensitivity).
4. Public repository check; post hoc PRESS librarian review (items 4, 5).

## Housekeeping

- Decide when to publish `docs/` to GitHub Pages (item 20). The 10 Nov pushes updated `docs/` on `main`; if Pages is enabled, the draft site is already public.
- `.posit/assistant/settings.json` is listed in `.gitignore` but still tracked; run `git rm --cached .posit/assistant/settings.json` if it should leave the repository.
- `renv.lock` still records R 4.5.1 and the R 4.5 versions of the recommended packages, while the current outputs were produced under R 4.6.1; a full `renv::snapshot()` would align it.
- Running `tar_make()` outside RStudio: set `RSTUDIO_PANDOC` first so the PRISMA figure can be saved (Positron bundles pandoc under `resources/app/quarto/bin/tools/x86_64`).
- Zotero import of `records_to_retrieve_fulltext.ris` (item 11).
- Keep this repo's `Status.md` in sync with the Project-folder copy.

## Suggested order

1. Russ: steps 1-4 above (decisions only, no work needed from others); send the RoB 2 note to Maria; send the REMAP-CAP data request (step 5).
2. In parallel: Maria's steps 6-9; the data requests above; second screener, search re-exports and registry searches.
3. Assistant: re-run and re-check the report text as each decision or data item lands.
4. Then the final `tar_make()`, GRADE and review; finalise the PRISMA diagram once its placeholders are filled; registration.
