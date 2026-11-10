# Next Steps to Finish the Analysis

**Date:** 10 November 2026 (replaces the 5 November version)
**Source:** condensed from `Status.md` (10 Nov update; item numbers refer to its §5) and `PRISMA_draft_2026-11-10.md`. `Status.md` remains the decisions log and is not replaced by this file. For the full list of what is needed to close the analysis for the thesis, including protocol items not tracked here (secondary outcomes, GRADE, small-study effects, deviations table), see `THESIS_CLOSEOUT_CHECKLIST.md`.

## Where things stand

- The pipeline (`analysis/`, `targets`, Stan) and the draft web report (`docs/`) were re-run from scratch on 10 Nov on a new machine (R 4.6.1, CmdStan 2.40.0). All 56 main fits pass convergence checks, and `brms` agreed on 53 of 53 cross-checked parameters in that run. The cross-check now compares 40,000-draw fits on both sides (10 Nov, Mac, R 4.5.1) and agrees on 53 of 53 (largest tail difference 0.095 SD against 0.20; the Stan refits use the `adapt_delta` ladder and have 0 divergences). With the earlier 8,000-draw reported fits it was 52 of 53, the exception being S-iii F1 μ 2.5% quantile at 0.207 SD, which was Monte Carlo error (Status.md notes).
- D2 is decided and applied: REMAP-CAP enters every short-term set (F1, F3, F4) through its ICU-discharge contrast, and the day-90 contrast is used in F2 only. F1 (7 trials, reference prior): OR 0.67 (0.39–1.06), P(OR<1) 0.96. F3: 0.73 (0.50–1.01). F4: 0.73 (0.55–0.93).
- The (now frozen, CrI-derived) REMAP-CAP SE matters little (F1 P(OR<1) 0.96 to 0.97 for SE 0.40 to 0.60). What matters is whether, and through which contrast, REMAP-CAP enters (0.98 without it).
- Final set: 7 primary trials, 11 sensitivity trials, 10 studies excluded at full text (Wafy 2021 added 10 Nov), 4 ongoing.
- RoB 2: consensus recorded for the 7 primary trials and shown on the new Risk of bias page; the second assessor has not yet confirmed it.
- A draft PRISMA 2020 diagram exists with report-level counts; registers, citation searching and title/abstract exclusions are still TBD.
- D1 to D4 are decided (D1, D3 and D4 on 10 Nov, each confirming the pre-specified option). Numbers remain provisional until the trial set and data are frozen (see `THESIS_CLOSEOUT_CHECKLIST.md`).

## Done since 5 November

| Was | Done | Status.md |
|---|---|---|
| Switch F1 to D2a in the pipeline and the report | 10 Nov; report text re-checked | 23 |
| RoB 2 page and Methods paragraph on the web report | 10 Nov (`analysis/risk_of_bias.qmd`) | 27 |
| REMAP-CAP contrast in F3 and F4 | Decided 10 Nov: ICU-discharge, as in F1 | 28 |
| SE sensitivity for the ICU-discharge contrast | Decided 10 Nov: SE 0.40 and 0.60 added | 29 |
| Reconcile the full-text count (55 vs 57) | 55 confirmed from the extraction workbook; Status §1 corrected | — |
| Per-reason full-text exclusion counts; studies vs reports in the PRISMA diagram | 11 reports of 10 studies excluded (after the Wafy decision); 38 reports of 18 included studies | 30 |
| Commit `.gitignore` changes | Committed | — |
| Add the `quarto` R package to `renv.lock` | Added (1.5.1) | — |
| Frequentist cross-check; protocol tipping criteria (close-out A6, A7) | REML/Hartung–Knapp on the Checks page; tipping criteria on the Priors page | — |
| Update `ANALYSIS_INSTRUCTIONS.md` | Revised 10 Nov: D2a and how it is applied in code, RoB 2 data and S-ii, fits added since 29 Oct, pipeline as built | — |

## Critical path to a final analysis run

| Step | What is needed | Owner | Status.md item |
|---|---|---|---|
| 1 | ~~Confirm D1, D3, D4~~ **Done 10 Nov** (in-hospital; ladder as proposed, reference headline; τ 0.5, ω 0.25) | Russ | 17 |
| 2 | ~~Sign off the 29 Oct additions~~ **Done 10 Nov** | Russ | 17 |
| 3 | ~~Decide Wafy 2021; confirm Mikami 2007~~ **Done 10 Nov:** Wafy excluded (integrity); Mikami mortality not reported. Apply the `trials.csv` change in the extraction database too | Russ | 13 |
| 4 | ~~Decide Nafae placebo denominator~~ **Done 10 Nov:** 19 kept (20 in S-den) | Russ | 22 |
| 5 | ~~Obtain the REMAP-CAP adjusted log-ORs and SEs from the investigators by 1 Dec 2026~~ **Frozen 10 Nov (lead decision, supersedes the 1 Dec deadline):** CrI-derived SEs (ICU discharge 0.487, day 90 0.362) are final and reported as approximations, with the SE sensitivity fits. Report wording relabelled 10 Nov (`index.qmd`, `discussion.qmd`); re-render still to do. Investigator values, if they ever arrive, become a sensitivity analysis | Russ / Assistant | 6 |
| 6 | ~~Confirm or amend the RoB 2 consensus~~ **Amended 10 Nov (lead decision): Maria's judgements accepted** for Confalonieri D5 (low; overall now low) and REMAP-CAP D2 and D5 (low; overall stays some concerns). `analysis/rob2_assessments.csv` updated. `tar_make()` run and report text updated 10 Nov (`discussion`, `risk_of_bias`, `sensitivity`, `index`, `limitations`); the consensus S-ii set now has 5 trials (same as assessor 2): OR 0.62 (0.34–1.01), P(OR<1) 0.97. Site not rendered | Assistant | 25 |
| 7 | Finish database verification sign-off: Tongyoo, subgroup-derived rows, REMAP-CAP contrasts; note Nafae and Snijders CURB-65 as "match with note" | Maria / Russ | 26 |
| 8 | RoB 2 for the 11 sensitivity trials; at present only the assessor-1 draft is on the Risk of bias page | Maria | 24 |
| 9 | Update the methods text she is drafting for D2a (now applied to F1, F3 and F4) | Maria | 23 |
| 10 | Verify Pitre 2025 benchmark values against the PDF and supplement (Table S2 priors) | Student | 18 |
| 11 | Secondary outcomes: rules approved and dataset built 10 Nov; **Maria** verifies `verification_worklist_secondary_2026-11-10.xlsx` (incl. Q1–Q3 source checks); then fits and a Secondary outcomes page | Maria / Assistant | 31 |
| 12 | Final `targets::tar_make()` in `analysis/`, run GRADE, human review of the report text | Assistant / Russ | - |

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
| Decide whether ongoing studies get their own box | A footnote on the draft figure (Wafy resolved 10 Nov) |

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

1. Russ: steps 1-4 above (decisions only, no work needed from others); send the RoB 2 note to Maria.
2. In parallel: Maria's steps 6-9; the data requests above; second screener, search re-exports and registry searches.
3. Assistant: re-run and re-check the report text as each decision or data item lands.
4. Then the final `tar_make()`, GRADE and review; finalise the PRISMA diagram once its placeholders are filled; registration.
