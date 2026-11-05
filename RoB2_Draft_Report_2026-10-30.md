# RoB 2 — draft assessor-1 judgements (all-cause mortality, effect of assignment)

**Date:** 30 Oct 2026 · **Source:** `rob2_signals` (126 quoted facts) → `rob2_judgements` (table + `csv/rob2_judgements.csv` + xlsx sheet) · **Status:** DRAFT. Protocol field 27 requires assessment *independently and in duplicate*; `assessor_2` and `consensus` are empty and must be filled by the two human assessors. Column `rob2_overall_draft` in `analysis_handoff/trials.csv` carries this draft; `rob2_overall_mortality` stays `PENDING` until consensus.

Backups before this change: `cap_steroids_extraction.sqlite.bak-2026-10-30`, `cap_steroids_extraction.xlsx.bak-2026-10-30`. Script: `apply_rob2_draft_2026-10-30.py` (idempotent). Changelog rows added for every `overall` value set.

## Summary (19 trials in primary / sensitivity / pending sets)

| Overall | Primary set | Sensitivity set | Pending |
|---|---|---|---|
| Low | CAPE COD (Dequin 2023), ESCAPe (Meduri 2022), Torres 2015 | Snijders 2010, STEP 2015, Tongyoo 2016, Santeon (Wittermans 2021) | — |
| Some concerns | APROCCHSS CAP subgroup, Confalonieri 2005, REMAP-CAP 2025 | Fernández-Serrano 2011, Hagman 2026, Meijvis 2011, SONIA 2025 | — |
| High | Marik 1993 | McHardy 1972, Mikami 2007, Nafae 2013 | Wafy 2021 |

Per-domain judgements and rationale are in `rob2_judgements.notes`. The 13 excluded/ongoing trials are marked "not assessed".

## Judgement calls the human assessors should look at first
1. **Marik 1993 → high** (D1/D2/D5 some concerns + n = 30). If assessors prefer *some concerns*, the S-ii fit changes.
2. **Fernández-Serrano 2011**: 20 % post-randomisation exclusion with unreported outcome in the excluded — *some concerns* vs *high*.
3. **Meijvis 2011 D5**: *some concerns* only because of the 11-vs-9 placebo-death discrepancy; resolve against Briel 2018 / authors, then downgrade to *low*.
4. **ESCAPe D5**: ad hoc non-binding futility interim before stopping for slow recruitment — kept *low*; confirm.
5. **Torres 2015 / Snijders 2010 D1**: baseline imbalances (septic shock 17 % vs 31 %; CRP, heart disease) treated as chance — confirm.
6. **REMAP-CAP D5**: futility threshold absent from 2020 design paper; sites chose which arms to offer — *some concerns*; confirm.

## What is still missing before the RoB assessment can be called complete
- **Second assessor + consensus** (protocol field 27). Nothing in the database identifies assessor 2 — decide whether that is Maria Clara or a co-author, and record disagreements in `notes`.
- **Signalling-question coverage gaps in `rob2_signals`** (judged from the paper's design, not from an extracted quote; verify against the PDF): no D4 row for APROCCHSS, Confalonieri, CAPE COD, Marik, Fernández-Serrano, Nafae, Tongyoo; no D2 row for Tongyoo; no D3 row for Wafy.
- **D5 subgroup pre-specification** (`d5_subgroup_prespecified`) is filled for APROCCHSS, Snijders, SONIA, STEP, Tongyoo, Santeon. Only Santeon stratified randomisation on the subgrouping variable. Tongyoo: confirm from the protocol (obtainable from the PI) whether the pneumonia-source subgroup was pre-specified.
- **Protocols / registry entries not yet checked** for D5: Confalonieri (none), Marik (none), Nafae (none), McHardy (none), Wafy (none) — nothing to retrieve; CAPE COD, ESCAPe, STEP, SONIA, Santeon, Meijvis, Snijders, Torres have protocols/registrations that the second assessor should open rather than rely on the extracted quotes.
- **Open data issues that feed RoB**: Meijvis 11 vs 9 deaths; REMAP-CAP investigator-supplied SE; STEP 30-day LTFU (1 vs 3 in 2015 report, 47 in 2023 report).
- **Wafy 2021 eligibility** still *pending*; its RoB is *high* with a data-integrity flag (reported p = 0.03 for 13/25 vs 15/25).
- Downstream: the `rob2_overall_mortality` column in `analysis_handoff/trials.csv` and the S-ii fit are wired to consensus; the handoff builder now writes `rob2_overall_draft` so the fit can be coded today and re-run unchanged once consensus exists.
