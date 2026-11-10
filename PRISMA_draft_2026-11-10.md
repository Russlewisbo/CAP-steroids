# PRISMA 2020 flow diagram — DRAFT with placeholders

**Review:** Bayesian meta-analysis of adjunctive corticosteroids in severe CAP
**Drafted:** 10 November 2026
**Status:** DRAFT. Real counts are filled where `Status.md` settles them; every count that is
not yet settled is shown as `TBD` and listed in the [placeholder register](#placeholder-register)
below with its blocker. Do not submit this figure until the placeholders are resolved.

Sources for the settled numbers: `Status.md` §1 (search 20 Oct: 3,931 identified / 2,798
deduplicated; 55 full-text records) and §4 (final-set table, 27 Oct). The screening log
(`screening_log_all_records.csv`) that holds the title/abstract exclusion counts is **not in this
repository**, so the T/A exclusion and several downstream counts are placeholders (see
`NEXT_STEPS.md`, "Search, screening and PRISMA").

---

## Diagram

The figure is generated with the **`PRISMA2020`** R package (Haddaway et al.) — official PRISMA 2020
artwork — by [analysis/prisma_flow.R](analysis/prisma_flow.R), which is wired into the `targets`
pipeline as the `prisma_flow` target, so it regenerates with the rest of the outputs. Regenerate with
`targets::tar_make(prisma_flow)` (from `analysis/`); output is
`analysis/output/figures/prisma_flow_draft.{png,pdf}`. `PRISMA2020` is pinned in `analysis/renv.lock`.

![Draft PRISMA 2020 flow diagram](analysis/output/figures/prisma_flow_draft.png)

Notes on the rendering:

- The review has no previous version, so the "previous studies" arm is omitted (`previous = FALSE`).
- Registers and Citation searching are shown as `(n = TBD)` because those searches are planned but
  not yet run; the package drops a line whose value is `NA`, so the script forces them to display.
- Websites and Organisations are `(n = 0)` — not part of the search plan.
- The `(n = 18)` "new studies included" box excludes Wafy 2021 (pending) and the 4 ongoing trials.
- The supplementary **Block D** search (n = 9) is part of the other-methods arm but has no dedicated
  field in the template; count it under the other-methods identification box when it is reconciled.

---

## Placeholder register

| Mark | Box | Value | Why it is a placeholder / blocker |
|---|---|---|---|
| * | Databases identified | 3,931 | May change: Ovid MEDLINE line 28 and PubMed #5 to be re-exported and de-duplication re-run (`Status.md` item 3). |
| † | Registers; register/hand-search arm | TBD | Registry searches (ICTRP **mandatory**) not yet run; to be added as a separate identification arm (`Status.md` item 10). |
| ‡ | Citation searching / inclusion lists | TBD | Hand-search of named inclusion lists per protocol v2; the Pitre 2025 "other methods" list (7 records: Annane 2006, Meduri 2007, Rezk 2013, VANISH, HYPRESS, ADRENAL, Annane 2018 APROCCHSS main) was assessed but none were retrieved into any set — classify and count. |
| § | Records excluded at title/abstract | TBD | `screening_log_all_records.csv` is not in this repo; screening was a **single AI-assisted pass** and dual screening is pending (`Status.md` items 2, and open item). Per-reason T/A exclusion counts unavailable. Approx. 2,798 − (full-text sought) if no other-methods records, but do not report until the log is in hand. |
| ¶ | Reports sought for retrieval | 55 | `Status.md` §1 says 55, but the stated breakdown (21 primary + 22 companions + 9 Block D + 2 verify + 3 other) **sums to 57** — reconcile before use (`NEXT_STEPS.md`). |
| ‖ | Reports not retrieved | TBD | Full texts still outstanding: Fitzgerald 2022 STOPPE (wrong PDF), El-Ghamrawy 2006, Li (Gang) 2016, Zhou 2015, Wagner 1956, Soboleva 2000, Dambrava 2006, Oh 2009, Kapisyzi 2012, Michels 2026 (duplicate PDF); Maharjan 2018 still untraced. |
| S6 | Reports excluded, with reasons | per-reason TBD | 9 studies excluded at full text (see list below); per-reason counts need finalising, incl. the Muhammad 2025 DOI-check footnote (`Status.md` item 16). |
| ** | Reports of included studies | TBD | The extraction database holds 32 trial rows and 22 companion reports; the count of *reports per included study* must be tallied (`NEXT_STEPS.md`: "32 trial rows vs 19 trials; report studies and reports separately"). |

---

## Full-text exclusions (reasons) — settled list, 9 studies

From `Status.md` §4 (27 Oct). Per-reason counts for the diagram box:

| Reason | Studies | n |
|---|---|---|
| Study integrity concerns | Muhammad 2025, Sabry 2011 | 2 |
| No pneumonia / CAP subgroup with arm-level mortality | Meduri 1998, LaSRS 2006/2018, Cicarelli 2007, DEXA-ARDS 2020, CORTICUS-Berlin 2021 | 5 |
| Design paper, no arm-level results | Annane 2012 CORTIFLU (26 randomised; author contact optional) | 1 |
| Expected exclusion, OCR pending | Bernard 1987 | 1 |
| **Total excluded at full text** | | **9** |

Note: Fernández-Serrano 2011, Nafae 2013 and Tongyoo 2016 were **not excluded** — they were moved
to the sensitivity set (severity/CAP not established), so they are *included studies*, not
full-text exclusions.

---

## Included studies — settled counts (as of 27 Oct)

| Set | n | Trials |
|---|---|---|
| Primary (severe-CAP) | 7 | Marik 1993, Confalonieri 2005, Torres 2015, Meduri 2022 (ESCAPe), Dequin 2023 (CAPE COD), Heming 2024 (APROCCHSS CAP subgroup), REMAP-CAP 2025 |
| Sensitivity — all-hospitalised | 8 | McHardy 1972, Mikami 2007, Snijders 2010, Meijvis 2011, Blum 2015 (STEP), Wittermans 2021 (Santeon), Lucinde 2025 (SONIA), Hagman 2026 |
| Sensitivity — severity/CAP not established | 3 | Fernández-Serrano 2011, Nafae 2013, Tongyoo 2016 |
| **Included in review** | **18** | |
| Pending lead decision | 1 | Wafy 2021 (exclude on integrity vs sensitivity-only) |
| Ongoing / awaiting classification | 4 | RECORDS, ASTEROIDS, Hong 2022, COLOSSEUM |

---

## Checklist before this figure is final

1. Re-export MEDLINE line 28 / PubMed #5 and re-run de-duplication; confirm the 3,931 / 2,798 / 1,133 counts.
2. Add the registers identification arm (ICTRP) and the citation-searching / inclusion-list arm with real counts.
3. Add `screening_log_all_records.csv` (or a summary) to the repo; fill the T/A exclusion count (§).
4. Reconcile the full-text count (55 vs 57 breakdown).
5. Fill reports-not-retrieved and reports-assessed from the retrieval log.
6. Finalise per-reason full-text exclusion counts, including the Muhammad 2025 DOI-check footnote.
7. Decide the Wafy 2021 classification; it currently sits in no fit.
8. Tally reports-per-study for the "reports of included studies" box.
