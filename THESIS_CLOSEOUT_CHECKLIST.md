# Close-out checklist: from current state to a thesis-ready analysis

**Prepared:** 10 November 2026 · **Sources:** `Status.md` (10 Nov; numbers in brackets are its §5 items), `PROSPERO_Protocol_v2.md` (fields 24–29), `Bayesian_MA_Corticosteroids_sCAP_Protocol.md` (§§5–9), `PRISMA_draft_2026-11-10.md`, the extraction workbook and the pipeline outputs.

**Definition of done.** The analysis is closed when:
- the trial set and data are frozen and tagged;
- every protocol-specified analysis has been run or its omission is documented as a deviation;
- the final pipeline run is reviewed and archived with a DOI;
- the PRISMA diagram, GRADE summary-of-findings table and deviation list are final;
- the student has a fixed set of tables, figures and text sources to write from.

After that, numbers in the thesis must come only from the tagged release.

**Critical path (in this order):** A (lead decisions) → B1–B3 (close the trial set) → B4–B9 (data complete) → B10 (freeze) → D (remaining analyses, final run) → F/G (reporting, archive). C (search and screening) and E (registration) run in parallel but must finish before F.

---

## A. Lead decisions (Russ) — no work needed from others

- [x] **A1** Confirm D1 (ESCAPe short-term row; default in-hospital), D3 (enthusiastic/reference/skeptical rungs), D4 (τ and ω hyperpriors) [17]. **Done 10 Nov:** all three as proposed; the reference rung gives the headline (Status log entry 8 of 10 Nov).
- [x] **A2** Sign off the 29 Oct additions: meta-regression prior b ~ N(0, 1), `timing_le24h` coding, pooled-baseline comparison, S-den, S-src [17]. **Done 10 Nov.**
- [x] **A3** Wafy 2021: exclude (integrity) or sensitivity set only; confirm Mikami 2007 mortality = not reported [13]. **Done 10 Nov:** Wafy excluded; Mikami not reported. Still to apply the `trials.csv` change in the extraction database.
- [x] **A4** Nafae placebo denominator, 19 or 20 (no effect on results) [22]. **Done 10 Nov:** 19 kept.
- [x] **A5** Scope of secondary outcomes (PROSPERO field 25): which outcomes get a Bayesian pooled analysis and which are descriptive only (see D1). **Decided 10 Nov:** as recommended; rules approved 10 Nov (`SECONDARY_OUTCOMES_PLAN.md`).
- [x] **A6** Is the frequentist REML/Hartung–Knapp cross-check required? It is in the earlier protocol (§7.7) but not in PROSPERO v2, and is not implemented. **Decided 10 Nov: yes; implemented** (Checks page, `frequentist_reml_hk.csv`).
- [x] **A7** Tipping-point criteria: the earlier protocol (§7.4) says "median crosses 0.90; P(OR<1) below 0.975"; the pipeline reports P(OR<1) below 0.90 and 0.80. Keep, add, or switch, and record as a deviation (F4). **Decided 10 Nov: report both protocol criteria; implemented** (median ≤ 0.90 down to SD 0.13; P(OR<1) ≥ 0.975 never reached).
- [x] **A8** Deadline for the REMAP-CAP investigator reply (B5), after which the interim SEs are frozen and reported as such. **Decided 10 Nov: 1 December 2026.**

## B. Close the trial set and complete the data

Closing the trial set (any change here changes the analysis sets):
- [ ] **B1** Obtain and assess the 2 database-arm full texts not retrieved: Fitzgerald 2022 STOPPE (wrong PDF), Michels 2026 (wrong PDF) [9].
- [ ] **B2** Obtain and assess the 8 other-methods full texts: El-Ghamrawy 2006, Li (Gang) 2016, Zhou 2015, Wagner 1956, Soboleva 2000, Dambrava 2006, Oh 2009, Kapisyzi 2012. El-Ghamrawy, Gang and Wagner are in Pitre's pneumonia stratum with mortality data, so they may be **eligible trials**. If eligible, extract (dual), add to `analysis_mortality.csv` via the database and `build_handoff.py`, and RoB-assess. Trace or formally drop Maharjan 2018 [9].
- [ ] **B3** Classify the 7 Pitre sepsis/ARDS trials (Annane 2006, Meduri 2007, Rezk 2013, VANISH, HYPRESS, ADRENAL, Annane 2018 main) under decision A: published CAP subgroup with arm-level mortality or not.

Completing the data:
- [ ] **B4** OCR Bernard 1987 and confirm the exclusion reason [15]; document the Muhammad 2025 DOI check [16].
- [ ] **B5** REMAP-CAP adjusted log-ORs and SEs (ICU discharge and day 90) from the investigators, or freeze the interim values at the A8 deadline [6]. Deadline 1 Dec 2026.
- [ ] **B6** Briel 2018 group: 30-day severe-subgroup counts (Snijders, Meijvis, STEP); supplements (CAPE COD, STEP, Snijders E3, Santeon, SONIA S13, ESCAPe, DEXA-ARDS, Smit 2025 appendix) [7, 9]. Decide which are needed and which are "attempted, not obtained".
- [ ] **B7** Verification sign-off in the database: Tongyoo, subgroup-derived rows, REMAP-CAP contrasts; Nafae and Snijders CURB-65 as "match with note" [26].
- [ ] **B8** Triage the open extraction issues. The database has 88 issues: 73 open (16 high severity overall), 1 open-action, 14 resolved. Every high-severity issue gets a resolution or an explicit "accepted, no effect" note [12].

Risk of bias, then freeze:
- [ ] **B9** RoB 2: the second assessor confirms or amends the primary-set consensus (note drafted 10 Nov) [25]; second-assessor RoB 2 for the 11 sensitivity-set trials [24]; RoB 2 for any trial added in B2.
- [ ] **B10** **Data freeze:**
  1. Regenerate the CSVs from the database.
  2. Record the database and CSV hashes in `Status.md`.
  3. Commit and tag (e.g. `data-freeze-v1`).
  4. From here on, changes only through a logged, dated decision.

## C. Search and screening (protocol credibility; needed for PRISMA and registration)

- [ ] **C1** Second independent screener: title/abstract retained set plus 10% of exclusions, and full-text decisions; report agreement [2]. The protocol requires duplicate screening; at present there is one AI-assisted pass.
- [ ] **C2** ~~Re-export Ovid MEDLINE line 28 and PubMed #5~~ **Decided 10 Nov (R. Lewis): not re-exported.** Reason and evidence: line 28 was never exported and PubMed #5 holds 10 records, but the recall check (§7) passed and no retained record depended on MEDLINE or PubMed alone (Status.md, 10 Nov note on item 3). Counts confirmed 10 Nov: 3,836 identified / 1,038 duplicates / 2,798 screened (the 95-record pre-1995 file was counted twice), in the PRISMA figure [3]. The pre-analysis update search of the strategy document still applies.
- [ ] **C3** ~~Registry searches (ICTRP mandatory)~~ **Not run (lead, 10 Nov): the protocol text is amended in the repo copy; amend the Project-folder `.docx` before registration.** PI contacts for registered but unpublished trials (RECORDS, ASTEROIDS, Hong 2022, COLOSSEUM, NCT04007328, NCT02552342) [10].
- [ ] **C4** Finish the named inclusion-list / citation search and record its counts.
- [ ] **C5** Put `screening_log_all_records.csv` (or a summary) in the repository; fill the title/abstract exclusion count; confirm the source of the B2 records.
- [ ] **C6** PRESS peer review of the search (post hoc; report it as such) [4].
- [ ] **C7** Update the search to a final date close to submission, or state the search date as a limitation.

## D. Analyses still to run

- [ ] **D1** **Secondary outcomes (PROSPERO field 25), not yet analysed.** Scope decided (A5); rules approved and `analysis_secondary.csv` built 10 Nov; provisional fits on the Secondary outcomes page (marked unverified); waiting for second-extractor verification (`verification_worklist_secondary_2026-11-10.xlsx`), then re-run and the descriptive table [31]. Binary harms with data in several trials (all sets combined):

  | Outcome | Trials |
  |---|---|
  | Secondary infection | 10 |
  | GI bleeding | 9 |
  | New septic shock | 8 |
  | Hyperglycaemia | 7 |
  | New invasive ventilation | 6 |
  | Hyperglycaemia requiring treatment | 5 |
  | Neuromuscular weakness | 2 |

  Continuous outcomes (length of stay, ventilator- and organ-support-free days, time to stability) are sparse and inconsistently defined, so summarise them descriptively. Build a per-outcome analysis dataset with the same provenance rules, then fit Bayesian random-effects models where A5 says so.
- [ ] **D2** **GRADE**, adapted to the Bayesian framework (protocol §6), for short-term mortality (F1), 90-day mortality (F2) and the key harms. Rate imprecision on posterior probabilities and the predictive interval. Rate inconsistency on τ and the leave-one-out results. Indirectness covers APROCCHSS, the shock-only subgroup, and REMAP-CAP's ICU-discharge timepoint. Risk of bias uses the consensus RoB and S-ii. Produce a summary-of-findings table.
- [ ] **D3** Small-study effects examined visually (contour-enhanced funnel of trial log-ORs for F4; protocol §6), interpreted cautiously with k = 7–17; no regression test.
- [x] **D4** Frequentist REML/Hartung–Knapp cross-check, if A6 says yes (`metafor`; one table). **Done 10 Nov** (A6).
- [ ] **D5** Influenza/viral co-infection meta-regression (field 29) could not be fitted (1 trial with data in F1, 3 in F4). Report it as not estimable rather than drop it silently.
- [ ] **D6** Apply A1–A7 and B5 in the pipeline. Then run the **final** `targets::tar_make()` from an empty store, with a full `renv::snapshot()` first so the lockfile matches the R version used.
- [ ] **D7** Re-check every hand-written statement on the site against the final numbers, or replace it with computed text. Three were wrong after the 10 Nov runs.
- [ ] **D8** Human review of the full report text by Russ (and the supervisor) [20].

## E. Registration and protocol

- [ ] **E1** Supervisor sign-off on decisions A and C [1].
- [ ] **E2** PROSPERO submission with field 38 reworded. Screening, extraction and analysis have begun, so the registration is retrospective; say so in the thesis [5].
- [ ] **E3** Add to the registered protocol (or to the deviation list if registration is not amended):
  - sensitivity fit S-ix (single bolus < 48 h);
  - the SONIA agent-mix rule;
  - D2a (REMAP-CAP ICU-discharge contrast in F1, F3 and F4, with the SE sensitivity);
  - the 29 Oct additions [5].
- [ ] **E4** Public repository check (no publisher supplements or other third-party files; licence; README) [5].

## F. Reporting outputs for the thesis

- [ ] **F1** Final PRISMA 2020 flow diagram, with all placeholders filled (C2–C5, B1–B4), ongoing studies placed [30].
- [ ] **F2** PRISMA 2020 checklist (27 items) and PRISMA-S (search reporting) completed, with the thesis page for each item.
- [ ] **F3** Bayesian reporting checklist (BARG; Kruschke 2021): priors with justification, prior-predictive checks, sampler settings, convergence, sensitivity to priors. Most of the material is on the site already; map it.
- [ ] **F4** **Deviations-from-protocol table** (one row each, with date and reason):
  - Stan via `cmdstanr` instead of `brms` for the hybrid model;
  - D2a and its extension to F3/F4;
  - S-ix; the SONIA rule;
  - tipping-point criteria (A7);
  - exact leave-one-out instead of PSIS-LOO; pooled-baseline comparison; S-CE, S-src, S-den;
  - meta-regression prior;
  - single-pass screening, if C1 is not completed;
  - retrospective registration;
  - anything from A5/A6.
- [ ] **F5** Tables for the thesis:
  - characteristics of included studies (from `trials.csv`);
  - excluded studies with reasons (10 studies / 11 reports, plus B1–B3 outcomes);
  - ongoing studies;
  - RoB 2 per trial (exists on the Risk of bias page);
  - main results;
  - GRADE summary of findings;
  - secondary outcomes.
- [ ] **F6** Figures at thesis resolution (PDF/PNG, fixed sizes): PRISMA, forest F1, prior ladder, tipping 1-D and 2-D, agent hierarchy, RoB grid, funnel (D3), secondary-outcome forests. Export from the tagged run only.
- [ ] **F7** **AI-use disclosure.** Covers: title/abstract screening (single AI-assisted pass), first-pass extraction, RoB 2 assessor 1 (AI draft), and analysis code and report text generated with AI under human direction. Check the university's thesis rules on AI assistance and describe how each AI step was verified by a human.
- [ ] **F8** References: Zotero import and clean-up (`records_to_retrieve_fulltext.ris`) [11]; one cited source for each included and excluded study.
- [ ] **F9** Supplementary material: full search strategies (v2.1), screening log summary, extraction dataset (`analysis_mortality.csv`, `mortality_long.csv`, `trials.csv`), RoB 2 workbooks, the site or a PDF of it, and code.

## G. Archive and hand-over

- [ ] **G1** Tag the final analysis release (e.g. `v1.0-thesis`) after D6–D8; record the commit hash and the R, CmdStan and package versions in `Status.md`.
- [ ] **G2** Deposit code and data with a DOI (Zenodo via the GitHub integration, or OSF), as the protocol commits to.
- [ ] **G3** Decide GitHub Pages publication of `docs/` (it may already be public) [20].
- [ ] **G4** Final `Status.md` entry ("analysis closed"); sync the Project-folder copy.
- [ ] **G5** Hand-over note for the student: where each thesis section draws from:
  - Methods: protocol v2, `ANALYSIS_INSTRUCTIONS.md`, the Methods and Risk of bias pages, F4;
  - Results: the tagged `output/tables` and `output/figures`;
  - Discussion: the Discussion and Limitations pages, the benchmark page;
  - Appendices: F2, F3, F9.

---

## Already done (for orientation)

These need no further work unless a decision above reopens them:
- Protocol v1/v2 and search v2.1.
- Searches run (20 Oct) and first-pass extraction (22 Oct).
- Second-extractor numeric check (27 Oct) and row-by-row check (31 Oct).
- Final set decided (27 Oct).
- Analysis pipeline, simulation and recovery checks, brms cross-checks, all pre-specified mortality fits, prior ladder, tipping points, agent hierarchy, meta-regressions, sensitivity fits and leave-one-out.
- D2 decided and applied to F1, F3 and F4, with SE sensitivity (30 Oct, 10 Nov).
- RoB 2 by two assessors for the primary set, consensus recorded (4 Nov).
- Risk of bias page.
- Draft PRISMA diagram with report-level counts.
- Benchmark against Pitre 2025.
- Re-run from scratch on a second machine (10 Nov).
