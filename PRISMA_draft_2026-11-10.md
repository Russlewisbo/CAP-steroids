# PRISMA 2020 flow diagram — DRAFT with placeholders

**Review:** Bayesian meta-analysis of adjunctive corticosteroids in severe CAP
**Drafted:** 10 November 2026 (revised the same day: report-level counts, Block D placement, footnote)
**Status:** DRAFT. Counts that can be derived from the repository are filled; every count that is
not yet settled is shown as `TBD` and listed in the [placeholder register](#placeholder-register)
with its blocker. Do not submit this figure until the placeholders are resolved.

Sources: `Status.md` §1 (search 20 Oct: 3,931 identified / 2,798 after de-duplication), the
`records` sheet of `cap_steroids_extraction.xlsx` (one row per full-text record, 55 rows) and
`trials.csv` (`final_set`). The screening log (`screening_log_all_records.csv`) that holds the
title/abstract exclusion counts is **not in this repository**.

---

## Diagram

Generated with the **`PRISMA2020`** R package (Haddaway et al.) by
[analysis/prisma_flow.R](analysis/prisma_flow.R), target `prisma_flow` in the `targets` pipeline. The
target depends on the script, the extraction workbook and `trials.csv`, so a change to any of them
regenerates the figure. Regenerate with `targets::tar_make(prisma_flow)` from `analysis/`. Output:
`analysis/output/figures/prisma_flow_draft.{png,pdf}`. PNG/PDF export needs pandoc; outside RStudio set
`RSTUDIO_PANDOC` (Positron bundles it under `resources/app/quarto/bin/tools/x86_64`).

![Draft PRISMA 2020 flow diagram](analysis/output/figures/prisma_flow_draft.png)

### Counting rules used

- **Records vs reports.** Identification and screening boxes count records. Every box from "Reports
  sought for retrieval" downward counts **reports** (full-text records), computed from the `records`
  sheet; the included box gives both studies (18) and their reports (38).
- **Block D in the database arm only.** The supplementary sepsis/ARDS search (protocol v2, decision A)
  was run with the database searches and its 9 retained records carry screening IDs and screen code I3
  from the same screening log, so they sit inside the 3,931 / 2,798 / 55 database counts. They are not
  counted again under "other methods".
- **Smit IPD synthesis** (2023 conference abstract R2299, 2025 full report R2626) is counted among the
  reports of included studies: it reports per-trial data for 8 included trials and supplies the rank-2
  rows used in S-IPD.
- **Neither included nor excluded (footnote on the figure).** 4 ongoing trials without results (RECORDS,
  ASTEROIDS, Hong 2022, COLOSSEUM; 4 reports). Wafy 2021 was excluded on integrity grounds on 10 Nov (lead
  decision), so nothing is awaiting classification. Assessed 53 = included 38 + excluded 11 + ongoing 4; the
  script checks this.
- **Other methods arm.** The 8 full texts still to obtain have no record in the database screening log
  and 3 of them are on the Pitre 2025 list, so they are shown as sought through other methods and not
  retrieved (provisional, see register).

### Reconciliation of the full-text count (55)

`Status.md` §1 gave the 55 full-text records as 21 primary + 22 companions + 9 Block D + 2 verify +
3 other, which sums to 57. The `records` sheet has screen codes I1 = 20, I2 = 21, I3 = 9, I4 = 2,
O1 = 3, which sums to 55; the first two categories in `Status.md` were each one too high.

| Database-arm reports (55) | n | Records |
|---|---|---|
| Reports of included studies | 38 | 12 for the 7 primary trials, 24 for the 11 sensitivity trials, 2 Smit IPD records |
| Excluded at full text | 11 | see table below |
| Ongoing, no results | 4 | RECORDS, ASTEROIDS, Hong 2022, COLOSSEUM |
| Not retrieved | 2 | Fitzgerald 2022 STOPPE (PDF is a Confalonieri duplicate), Michels 2026 (PDF is a Nafae duplicate) |

---

## Full-text exclusions — 11 reports of 10 studies

| Reason (as on the figure) | Reports | Studies |
|---|---|---|
| No pneumonia/CAP subgroup with arm-level mortality | 6 | Meduri 1998; LaSRS (Steinberg 2006 and the Meduri 2018 reanalysis); Cicarelli 2007; DEXA-ARDS 2020; CORTICUS-Berlin 2021 |
| Study integrity concerns | 3 | Muhammad 2025, Sabry 2011, Wafy 2021 (lead decision 10 Nov) |
| Design paper without arm-level results | 1 | Annane 2012 CORTIFLU (26 randomised; author contact optional) |
| No CAP subgroup expected (OCR check pending) | 1 | Bernard 1987 (scanned PDF without a text layer) |

Fernández-Serrano 2011, Nafae 2013 and Tongyoo 2016 are **not** exclusions: they are in the
sensitivity set (severity or CAP not established), so they are included studies.

---

## Placeholder register

| Box | Value | Why it is a placeholder / blocker |
|---|---|---|
| Databases identified, duplicates, screened | 3,931 / 1,133 / 2,798 | May change: Ovid MEDLINE line 28 and PubMed #5 to be re-exported and de-duplication re-run (`Status.md` item 3). |
| Registers | TBD | Registry searches (ICTRP **mandatory**) not yet run (`Status.md` item 10). |
| Citation searching (records identified) | TBD | Hand-search of the named inclusion lists not finished; the Pitre 2025 sepsis/ARDS trials (Annane 2006, Meduri 2007, Rezk 2013, VANISH, HYPRESS, ADRENAL, Annane 2018 APROCCHSS main) still to be classified and counted. |
| Records excluded at title/abstract | TBD | Screening log not in this repo; single AI-assisted pass, second screener pending (`Status.md` item 2). If every report sought came from the screened set, the value is 2,798 − 55 = 2,743; confirm against the log before reporting. |
| Other methods: sought / not retrieved / assessed | 8 / 8 / 0 | Provisional: El-Ghamrawy 2006, Li (Gang) 2016, Zhou 2015, Wagner 1956, Soboleva 2000, Dambrava 2006, Oh 2009, Kapisyzi 2012. Confirm their source in the screening log; any found there moves to the database arm. Maharjan 2018 (untraced) is not counted. |
| Bernard 1987 exclusion reason | provisional | OCR the PDF to confirm (`Status.md` item 15). |
| Muhammad 2025 exclusion footnote | — | Document the DOI check (`Status.md` item 16). |

---

## Checklist before this figure is final

1. Re-export MEDLINE line 28 / PubMed #5 and re-run de-duplication; confirm 3,931 / 2,798 / 1,133.
2. Run the registry searches (ICTRP) and the inclusion-list / citation search; fill both identification counts.
3. Add `screening_log_all_records.csv` (or a summary) to the repo; fill the title/abstract exclusion count and confirm the provenance of the 8 other-methods reports.
4. Obtain the missing full texts (2 database-arm, 8 other-methods) and assess them.
5. OCR Bernard 1987; document the Muhammad 2025 DOI check.
6. Decide whether ongoing studies stay as a footnote or get their own box in the final figure.
