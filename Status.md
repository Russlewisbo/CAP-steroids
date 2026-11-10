# Project Status — Bayesian Meta-Analysis of Adjunctive Corticosteroids in Severe CAP

**Status date:** 10 November 2026
**Phase:** Pipeline, draft web report and sensitivity analyses are in place. Since 4 Nov: F1 switched to D2a in the pipeline and the report, the full pipeline re-run from scratch on a new machine, and a draft PRISMA 2020 diagram built with report-level counts (§3, 10 Nov). Since 29 Oct: D2 decided (D2a), the second extractor's row-by-row verification and the second RoB 2 assessment returned (4 Nov), the RoB 2 consensus for the 7 primary-set trials recorded on the lead's decision (second assessor's confirmation pending), and the APROCCHSS plan checked through its open-access design paper. D1 to D4 all decided (D1, D3 and D4 on 10 Nov). Open before a final run: the second assessor's confirmation of the consensus, the REMAP-CAP investigator SE, remaining data requests, and PROSPERO registration (field 5 must say that screening and a first extraction pass have begun).
**Design scope:** Randomized controlled trials only. Adults. Severe CAP primary set; all-hospitalized CAP sensitivity set.

---

## 1. Where we are in one paragraph

The protocol passed methodological peer review on 5 July 2026 and the five must-fix items were resolved in protocol v1 (9 July). Protocol v2 and search document v2.1 were finalised on 16–20 October; the searches were run, exported and screened at title/abstract level in one pass on 20 October (3,931 records; 2,798 after de-duplication). On 22 October the 55 full-text records (20 primary reports, 21 companions, 9 Block D, 2 verify, 3 other; corrected 10 Nov from 21 and 22, which summed to 57) were extracted in a first pass into `cap_steroids_extraction.sqlite` (32 trial rows, 414 arm-level binary outcome rows, 218 subgroup rows, 116 effect estimates, 87 flagged issues), every data point carrying source record, PDF page, location and verbatim quote. On 27 October the second extractor (Maria Clara) reported that all numbers matched the PDFs except one baseline percentage (McHardy 1972) and a set of ESCAPe page indices; both were corrected, and the lead took the eight open set-assignment decisions (§3). The final set is now 7 primary trials, 11 sensitivity trials, 2 integrity exclusions and one trial (Wafy 2021) still pending. The critical path is now: RoB 2 → missing supplements and data requests → final analysis run.

On 29 October the analysis was built and run end to end (`analysis/`, §3 entry of that date): a Stan hybrid-likelihood model with `brms` cross-checks, simulation and recovery checks, all pre-specified fits (F1 to F4, agent hierarchy, prior ladders, tipping-point analyses, sensitivity fits, meta-regressions) and a Quarto website in `docs/`. These use the pre-specified defaults for D1 to D4 with the alternatives alongside; they are draft results for review, not final.

---

## 2. Timeline vs the July plan

| Milestone (July plan) | Planned | Actual / status |
|---|---|---|
| Resolve five peer-review must-fix items | Wk 1–2 (by ~22 Jul) | Done 9 Jul (protocol v1, §3.1 revision note) |
| Internal sign-off, PROSPERO registration | Wk 3 (~1 Aug) | **Not done.** Protocol v2 ready; supervisor sign-off on decisions A and C outstanding; field 5 wording must change |
| Push protocol + brms skeleton to public repo | Wk 3 | Status unknown — confirm |
| Run and document search; begin screening | Wk 3–4 (~8 Aug) | **Done 16–20 Oct** (single-pass T/A). MEDLINE line 28 and PubMed #5 to re-export |
| Full-text screening, dual extraction, RoB 2 | Month 2 (Aug–Sep) | **Extraction done 22 Oct; second-extractor check of numeric rows done 27 Oct; final set decided 27 Oct.** RoB 2 pending |
| Primary analysis, prior ladder, first draft | Month 3 (Sep–Oct) | **Pipeline built and run 29 Oct on pre-specified defaults** (draft web report in `docs/`); F1 switched to D2a 10 Nov; D1, D3, D4 decided 10 Nov; final run waits for RoB 2 confirmation and data items in §5 |

Realistic restatement: second screener + registration Nov 2026, RoB 2 Dec 2026, final analysis run Jan–Feb 2027 (pipeline already in place, so a data change is a re-run), first full draft Q2 2027.

---

## 3. Decisions log

### 9 July 2026 — protocol v1 (peer review §§3.1–3.5)
1. REMAP-CAP characterized accurately (adj. OR ≈ 1.5, 84–91% P(harm); futility = <5% probability of >20% RRR). Harm end of the prior ladder split into *mild harm-leaning* Normal(log 1.10, 0.20) and *REMAP-CAP harm* Normal(log 1.5, 0.35).
2. Hybrid likelihood (binomial on counts; contrast-based log-OR + SE for REMAP-CAP) pre-specified as the primary-analysis rule.
3. SONIA/Kenya: primary set only if a severe subgroup is extractable, otherwise sensitivity set.
4. Positioning vs Pitre 2025 stated explicitly.
5. Regularizing half-Normal prior on ω; agent hierarchy framed as estimation under shrinkage.

### 16 October 2026 — protocol v2 (seed-library gap review)
**A. Broader-indication trials with a published CAP subgroup — INCLUDE.** Sepsis/septic shock/ARDS RCTs are eligible when a peer-reviewed report gives CAP-subgroup mortality by arm (APROCCHSS CAP-septic-shock subgroup, Heming 2024). Safeguards: flagged; RoB 2 domain 5 records subgroup pre-specification; sensitivity analysis (vi) removes all subgroup-derived trials; "proportion in septic shock at enrolment" added as a covariate.
**B. Hydrocortisone + fludrocortisone — hydrocortisone cluster.** Classified by glucocorticoid component; fludrocortisone recorded as a trial characteristic; sensitivity fit (viii) drops the trial.
**C. Data-source hierarchy — four ranks.** (1) primary report/supplement/registry results; (2) published IPD synthesis (Briel 2018); (3) prior-review extraction tables → sensitivity only; (4) author-provided data → sought only for REMAP-CAP adjusted estimates and severe subgroups of broader-CAP trials. Unpublished CAP subgroups of sepsis/ARDS trials are **not** sought.
**Search consequences:** supplementary Block D; pre-1995 pneumonia set; ICTRP mandatory; named inclusion lists to hand-search; pre-specified recall check.

### 20 October 2026 — title/abstract screening (single AI-assisted pass; see `Screening_Report_Corticosteroids_sCAP_2026-10-20.docx`)
1. Screening operationalisation of protocol v2 at T/A level (COVID-primary, HAP/VAP-only, Pneumocystis, paediatric, inhaled-only, bundles, no steroid-free arm excluded; non-COVID viral CAP eligible; pneumonia-unspecified carried to full text).
2. Severity applied at full text, not at T/A.
3. Block D records kept as I3, excluded at full text unless a published CAP subgroup exists.
4. Registrations without results reported as "ongoing / awaiting classification".

### 22 October 2026 — first-pass extraction (see `Extraction_Report_2026-10-22.md`)
1. **Extraction database built** (`cap-steroids-fulltext/_extraction/`): tables records · trials · arms · outcomes_binary · outcomes_continuous · effect_estimates · subgroups · rob2_signals · rob2_judgements (empty template) · record_roles · issues; view `v_mortality`. Schema = protocol field 26 + v2 (shock %, mineralocorticoid, subgroup pre-specification, data-source rank per data point). Rank-2 rows (Smit 2025 IPD) stored alongside rank-1 rows, never merged.
2. **REMAP-CAP:** all posterior ORs recorded; the pooled full-borrowing estimate OR 1.56 (95% CrI 0.80–3.31), P(harm) 90%, P(>20% RRR) 3.4% is the proposed contrast for the normal–normal likelihood; SE not published (≈0.36 from the CrI pending item 6).
3. **Block D at full text:** only Tongyoo 2016 (sepsis-ARDS) reports a pre-specified pneumonia-source subgroup with arm-level mortality (d28 11/49 vs 13/51; d60 18/49 vs 19/51) — but pneumonia not characterised as community-acquired. All other Block D records excluded (no pneumonia subgroup / protocol / design paper).
4. **Severe subgroups recovered from all-hospitalised trials (rank 1):** Snijders 2010 PSI IV–V 5/48 vs 5/45 and CURB-65 3–5 4/28 vs 3/26 (30 d); Santeon 2021 PSI IV–V 3/77 vs 5/79 (30 d; pre-specified, stratified); STEP PSI IV–V only at 180 d (29/187 vs 21/173); SONIA SpO2 <90% 110/404 vs 117/404 (30 d). Ovidius: none published.

### 27 October 2026 — second-extractor check and lead decisions on the final set (applied by `_extraction/apply_decisions_2026-10-27.py`; every changed cell logged in the new `changelog` table)

**Second-extractor corrections (Maria Clara, verified against the PDFs):**
1. McHardy 1972, STEROID arm: `pct_male` 55 → 45 (Table I: 9/20 men in each prednisolone group; 55% was the female proportion). Pooled control 43/86 = 50% confirmed.
2. ESCAPe (Meduri 2022, R2113): 15 page indices re-verified against the pdftotext form-feed map (Results-text rows p.3 → p.4; Table 1 continuation rows p.6 → p.7; Fig. 3 issue p.10 → p.12). Convention restated in the README: `page` = PDF page index, 1-based, not the printed journal page. No data values changed.

**Lead decisions (new `trials` columns `final_set`, `final_set_reason`, `sensitivity_flags`, `decision_date`; analyses key on `final_set`, `provisional_set` kept for history):**
1. **Marik 1993 — primary set.** Single 10 mg/kg hydrocortisone bolus accepted; `duration_days` = 1. New pre-specified sensitivity fit: drop trials with < 48 h of treatment (currently Marik only). Rationale: every prior synthesis includes it, it carries almost no weight (1/14 vs 3/16), and inventing a duration threshold post hoc that removes one trial would look worse than including and testing.
2. **Muhammad 2025 — excluded** on study-integrity grounds (reference DOIs do not resolve or point to unrelated papers, confirmed by the second extractor; contradictory methods; mortality as % only). PRISMA full-text reason: "study integrity concerns". Not used in any analysis, including sensitivity.
3. **Sabry 2011 — excluded** on study-integrity grounds (methods/results near-verbatim from Confalonieri 2005; analysis section describes an exposed-vs-unexposed comparison; mortality only as survival %; possible duplicate of Omar/Todary/Sabry 2010, which could not be obtained). Same PRISMA reason. Item 14 closed.
4. **Fernández-Serrano 2011 and Nafae 2013 — sensitivity set** (`severity_not_met`). Thesis must state that this diverges from Siemieniuk 2015 / Pitre 2025, which counted Fernández-Serrano as severe.
5. **Tongyoo 2016 — sensitivity set**, labelled "pneumonia-source, CAP unconfirmed" (`subgroup_derived;cap_unconfirmed`). No CAP/HAP split requested from the authors (decision C).
6. **SONIA 2025 — sensitivity (all-hospitalised) set.** SpO2 < 90% at admission is a single minor criterion in a ward-based pragmatic trial and does not meet the severity definition; the hypoxaemic subgroup (110/404 vs 117/404, 30 d) enters a secondary "broad-severe" analysis. **Agent-mix rule:** the SONIA steroid arm is its own "mixed" agent cluster compared with the whole control arm; sub-arms are not split against a shared control.
7. **REMAP-CAP 2025 — primary set, contrast-based only** (confirms protocol v1 decision 2): pooled full-borrowing posterior OR 1.56 (95% CrI 0.80–3.31) enters the normal likelihood; SE ≈ 0.36 from the CrI until the investigators supply the adjusted log-OR and SE (item 6). Crude counts never used.
8. **Meijvis 2011 (11 vs 9 placebo deaths at 30 d):** both counts kept with page locations; primary-report 11/153 used meanwhile. Next step is to check Briel 2018 IPD (rank 2) and write to the authors only if that does not settle it.
9. **Wafy 2021 — still pending** (exclude on integrity vs sensitivity-only). **Mikami 2007 mortality = not reported** — recommended, still to confirm.

Resulting final set: **primary 7** (Marik, Confalonieri, Torres, ESCAPe, CAPE COD, APROCCHSS CAP subgroup, REMAP-CAP) · **sensitivity 11** (McHardy, Mikami, Snijders, Meijvis, STEP, Santeon, SONIA, Hagman, Fernández-Serrano, Nafae, Tongyoo) · **excluded 9** (Muhammad, Sabry, CORTIFLU, Bernard 1987, Meduri 1998, LaSRS, Cicarelli, DEXA-ARDS, CORTICUS-Berlin) · **ongoing 4** (RECORDS, Hong 2022, COLOSSEUM, ASTEROIDS) · **pending 1** (Wafy). `issues` table now carries `status` / `resolution` / `resolved_date`: 14 resolved, 1 "open – action" (Meijvis), 73 open.

### 29 October 2026 — analysis pipeline built and run (no new lead decisions)

Facts only; decisions D1 to D4 were **not** taken and every number below uses the pre-specified default with the alternatives alongside. Code: `analysis/` (Stan models, `targets` pipeline, `renv` lockfile); rendered report: `docs/` (Quarto website for GitHub Pages).

1. **Model and checks.** Hybrid likelihood in Stan via `cmdstanr` (binomial on counts, normal on REMAP-CAP's contrast, unpooled baselines). Prior-predictive and recovery checks on simulated data came first. `brms` reproduces the Stan results for the pure-count and pure-contrast cases (53 of 53 parameters within a criterion fixed beforehand; largest tail difference 0.19 SD against a 0.20 limit). Deviation from protocol v2, which names `brms`: `brms` cannot fit a binomial and a contrast likelihood under one shared effect. All fits: 4 chains × 2000 draws, `adapt_delta` 0.99, seed 7291, zero divergences.
2. **Draft results under the reference prior N(0, 1), pooled OR (95% CrI).** F1 (7 severe-CAP trials): 0.68 (0.38–1.10), P(OR<1) 0.95. F2 (90-day): 0.74 (0.45–1.46). F3 (broad-severe): 0.74 (0.49–1.05). F4 (all-hospitalised): 0.74 (0.55–0.95). Between-trial SD and the agent SD ω are weakly identified; the agent hierarchy is estimation under strong shrinkage, not a test of an agent effect.
3. **D1 and D2 alternatives run.** ESCAPe in-hospital (default), d60 and IPD 30-day; REMAP-CAP d90 contrast (default), ICU-discharge contrast, excluded, and SE 0.30/0.45. F1 P(OR<1) ranges from 0.94 to 0.98 across these. Note that Status §4 lists ESCAPe at d60 while the default used is the in-hospital row (protocol field 24).
4. **D3 and D4 values used are the proposals** in the analysis instructions: enthusiastic N(log 0.70, 0.20), reference N(0, 1), skeptical N(0, 0.35), mild-harm and REMAP-CAP-harm rungs as fixed by protocol; τ ~ half-Normal(0, 0.5), ω ~ half-Normal(0, 0.25). The REMAP-CAP-harm rung is also run without the REMAP-CAP row.
5. **Additions not in protocol v2, flagged in the report for confirmation:** meta-regression prior b ~ Normal(0, 1) and the binary timing covariate coding (first dose ≤24 h; Torres and SONIA coded 0); a pooled-baseline comparison model (comparison only; primary baselines stay unpooled); exact leave-one-trial-out refits, because PSIS-LOO is unreliable with unpooled baselines.
6. **Data issues found while building the analysis.** (a) The S-IPD fit can only swap the trials that have an IPD row in `analysis_mortality.csv`: Snijders and Santeon, listed in the instructions, have none. (b) SE for REMAP-CAP is still the interim 0.362 and the result is sensitive to it. (c) Pitre 2025 benchmark values were transcribed from the PubMed Central full text (main text only; supplement not examined) and need checking against the PDF; Pitre's short-term mortality horizon is described inconsistently in the paper.
7. **Not done:** S-ii (low-RoB-only fit; stub until RoB 2 exists), GRADE, human review of the report text.
8. **Pitre 2025 supplement read (29 Oct).** Their Bayesian analysis is a common-effect normal model with a vague prior that drops zero-event trials, so its probabilities (P(OR<1) 0.995) are not comparable with our random-effects ones. A common-effect sensitivity fit (S-CE: same exact likelihood, between-trial SD forced near zero; F1, F3, F4) and a re-analysis of our count trials with their method were added to the pipeline: F1 common-effect OR 0.70 (0.56–0.88), P(OR<1) 0.999. See items 21 and 22 in §5 for the trial-overlap findings. Pitre's agent subgroups (hydrocortisone RR 0.66, methylprednisolone 0.88) and pneumonia stratum (RR 0.75, 0.59–0.95) are consistent with our agent and F4 results.
9. **Convergence page added to the web report**: trace, rank, energy, funnel and autocorrelation plots, prior against posterior, posterior-predictive and recovery checks; all fits pass the acceptance rules with no divergences.
10. **Items 19 and 22 resolved (29 Oct)** against the primary reports and the Smit 2025 trial table: all of our counts are confirmed (Confalonieri 7/23, ESCAPe 47/286 and 34/291, Snijders and Santeon identical in Smit); Pitre's different Confalonieri and ESCAPe denominators and the Nafae 19/20 ambiguity do not change any result.
11. **Meijvis 2011 30-day placebo deaths (11 vs 9) settled for the analysis (30 Oct).** Evidence: the primary report (Table 2) gives 11/153 placebo and 9/151 dexamethasone; Wittermans 2022 Table 6 (Ovidius arms by class) gives 9/153 and 9/151 (4+5 and 7+2) and agrees with the primary report on every other outcome (in-hospital 8 and 8, ICU 7 and 10); Smit 2025 Table 1 gives 9/153 and 9/151. The discrepancy is therefore two post-discharge deaths in the placebo arm, and the documents in hand cannot show whether it is a different 30-day window, a corrected dataset or a typo (Briel 2018 IPD is not in the folder). Decision: the rank-1 primary-report count (11/153) stays in all main fits under the source hierarchy (decision C) and `analysis_mortality.csv` is unchanged; the IPD count is shown as sensitivity fit S-src (F4 only, the trial is in no other set): OR 0.744 to 0.751, P(OR<1) 0.988 to 0.985, so no conclusion depends on it. Contacting the Ovidius authors is optional and not needed for the analysis. The open `issues` row in the extraction database (R0786) is not edited here; if the lead prefers 9 as the default, change the rank-1 value through the database changelog and re-export.

### 30 October 2026 — lead decision on D2

1. **D2 decided: option D2a.** REMAP-CAP enters the primary short-term fit (F1) through its adjusted **ICU-discharge** contrast (log-OR 0.399, SE 0.487; OR 1.49, 95% CrI 0.62–4.18), the earliest adjusted mortality contrast it reports. Its day-90 pooled contrast (log-OR 0.445, SE 0.362, interim) is analysed in the 90-day analysis (F2) only. The former default (day-90 contrast in F1) and D2b (REMAP-CAP excluded from F1) are reported as sensitivity analyses. Rationale: keeps the protocol rule that short-term and 90-day mortality are separate analyses (the former default was the one exception), keeps a major trial in the primary analysis, and changes the result very little (F1 OR 0.67, 95% CrI 0.39–1.05 under D2a against 0.68, 0.38–1.10 under the former default). REMAP-CAP still enters only as a contrast, never through its crude counts.
2. **Pipeline and report not yet switched.** At this date the pipeline, the web report and the abstract still show the day-90 contrast as the F1 primary. Re-pointing F1 to D2a changes F1, F1-agent, the F1 ladder, the tipping-point analyses, the meta-regressions and the leave-one-out refits, and requires re-checking the hand-written statements in the report (item 23).

### 4 November 2026 — returns from the second extractor and the second RoB 2 assessor (no lead decisions)

1. **Row-by-row verification returned (M. Annes, 31 Oct).** All 34 worklist rows are marked "matches source", with no number changed. Two comments are correct and both rest on inferred denominators: Nafae (placebo N = 20 but the outcome table accounts for 19) and the Snijders CURB-65 3–5 row (printed 4/48 vs 3/45 is the PSI row's denominator; the text and percentages give 4/28 vs 3/26, which is what we use; the row feeds no fit). Her returned worklist xlsx has the REMAP-CAP log-OR and SE cells mangled by Excel (repository files are unaffected); the reported ORs and intervals are intact. Imported into the database: the `verified` flag on 50 `outcomes_binary` rows (15 trials; `apply_verification_2026-11-04.py`, every change in `changelog`), and a new empty `verified` column on `subgroups` and `effect_estimates`. Not yet signed off in the database: Tongyoo, the subgroup-derived rows (Snijders and Santeon PSI IV–V, SONIA SpO2 < 90%) and the REMAP-CAP adjusted contrasts (item 26).
2. **Database repair.** The live `cap_steroids_extraction.sqlite` had a hot rollback journal left from 30 Oct; any read-write open would have rolled it back to the state before the RoB 2 draft. It was recovered by re-applying `apply_rob2_draft_2026-10-30.py` to a copy; the recovered tables are byte-identical to the 30 Oct CSV exports. Everything as received is in `_extraction/backup_2026-11-04_as_received/` (including the journal), and `cap_steroids_extraction.sqlite.bak-2026-11-04` is the recovered state before the import. The journal is no longer in the live folder; csv/ and the xlsx were regenerated (`build_xlsx_2026-11-04.R`).
3. **Second RoB 2 assessment (7 primary-set trials).** Overall rating agrees for 5 of 7 (27 of 35 domain judgements). Disagreements: Confalonieri (draft some concerns, assessor 2 low), APROCCHSS (some concerns vs low), Marik (D1 some concerns vs high; D2 some concerns vs low; overall high in both), REMAP-CAP (D2 and D5 some concerns vs low; overall some concerns in both). Her `rob2_judgements_assessor2.csv` still carries the draft values in its domain columns; her judgements are in the xlsx Summary sheet and are now in `analysis/rob2_assessments.csv`. **No consensus recorded.** `RoB2_reconciliation_2026-11-04.md` lists each disagreement with proposals for the discussion. The pipeline runs the low-risk-of-bias fit (S-ii, F1) once per assessor: OR 0.75 (0.40–1.47), P(OR<1) 0.84 with assessor 1's three low-risk trials, and OR 0.62 (0.34–1.01), P(OR<1) 0.97 with assessor 2's five; a consensus fit is added automatically when `consensus_overall` is filled in for the 7 primary-set rows.
4. **renv library restored.** The project's renv cache had been emptied (115 of 116 package links in `analysis/renv/library` were dead and Quarto could not load rmarkdown); restored from the lockfile, which is unchanged.
5. **Consensus recorded and APROCCHSS plan retrieved (4 Nov, lead decision).** Consensus: CAPE COD, ESCAPe, Torres, APROCCHSS low; Confalonieri some concerns (no registration or protocol, the same rule as Marik); Marik high; REMAP-CAP some concerns. APROCCHSS moved to low on the evidence of the open-access design paper (item 8). Entered in `analysis/rob2_assessments.csv` and in `rob2_judgements.consensus` (`apply_rob2_consensus_2026-11-04.py`, 7 changelog rows, database now 254 changelog rows; backup `.bak-2026-11-04-consensus`). Recorded without a meeting with the second assessor; her confirmation is open (item 25). The pipeline's sampler now raises `adapt_delta` automatically when a fit has divergences; only the consensus S-ii fit needed it (0.999, no divergences); all 54 main fits pass.

### 10 November 2026 — F1 switched to D2a, pipeline re-run on a new machine, draft PRISMA diagram (no lead decisions)

1. **D2a applied (item 23).** Code (commit `241f7a5`): `02_fit_primary.R` builds every F1 row set on a D2a base that swaps REMAP-CAP's day-90 contrast for its ICU-discharge contrast, so the primary fit, F1-agent, the F1 ladder, both tipping-point analyses, the leave-one-trial-out refits, the F1 meta-regressions and all F1 sensitivity fits use D2a. The former default is kept as fit `F1_D2_d90`; the D2c SE variants still apply to the day-90 contrast. Report text updated today: home page (abstract, decisions callout and table, D2 bullet, state-of-inputs table), Sensitivity (former default shown as S-REMAPd90 and counted in the F1 sensitivity range), Methods (fit inventory, model text) and Discussion (REMAP-CAP section, timepoint list; the harm-prior probabilities are now computed rather than written as "about three in four"). The pages had referred to a fit id `F1_D2a` that no longer existed and would have rendered as empty text.
2. **Results under D2a** (reference prior, OR with 95% CrI): F1 0.67 (0.39–1.06), P(OR<1) 0.96, P(OR<0.833) 0.85; former default 0.68 (0.38–1.09), P 0.95; D2b (REMAP-CAP excluded) 0.61 (0.33–0.94), P 0.98. F2 0.74 (0.45–1.49); F3 0.74 (0.50–1.04); F4 0.74 (0.54–0.95). Across the 14 F1 sensitivity fits the median OR is 0.61 to 0.71 and P(OR<1) 0.85 to 1.00. Consensus S-ii 0.69 (0.43–1.15).
3. **Re-run from scratch on a new machine** (Linux, R 4.6.1; the lockfile was written under R 4.5.1). `renv` restored from the unchanged lockfile, except that the R-recommended packages (Matrix, mgcv, nlme, lattice, foreign) are at their R 4.6 versions and the `quarto` R package (needed by `tar_quarto`, not in the lockfile) was installed into the project library; CmdStan 2.40.0 installed. Full `tar_make()` from an empty store: 577 targets in 10.5 min. All 54 main fits pass with zero divergences; one leave-one-out fit (unpooled, ESCAPe left out) needed `adapt_delta` 0.999 and the consensus S-ii fit no longer does. Against the 4 Nov outputs results differ only by Monte Carlo variation (same seed, different platform; largest change 0.07 in an upper 97.5% quantile, S-ii assessor 1). The hard-coded sentence on which fit needed a higher `adapt_delta` is now computed on the Convergence page. Exporting the PRISMA figure to PNG/PDF needs pandoc: outside RStudio set `RSTUDIO_PANDOC` before `tar_make()` (Positron bundles pandoc under `resources/app/quarto/bin/tools/x86_64`).
4. **Questions raised by the switch, not decided here.** (a) F3 and F4 still take REMAP-CAP's day-90 contrast, although the 30 Oct decision says the day-90 contrast is analysed "in the 90-day analysis (F2) only"; read literally, F3 and F4 would use the ICU-discharge contrast too (item 28). (b) The SE sensitivity (D2c) exists only for the day-90 contrast; the ICU-discharge SE 0.487 is also derived from the credible interval and has no sensitivity fit (item 29).
5. **Draft PRISMA 2020 diagram** (`analysis/prisma_flow.R`, target `prisma_flow`; notes in `PRISMA_draft_2026-11-10.md`). Boxes from "Reports sought" down count reports, derived from the `records` sheet of the extraction workbook: 55 sought, 2 not retrieved (STOPPE and Michels 2026, wrong PDFs), 53 assessed, 10 reports of 9 studies excluded, 38 reports of 18 included studies (including the two Smit IPD records). Wafy 2021 (awaiting classification) and the 4 ongoing trials are in a footnote. Block D is counted in the database arm only. The §1 full-text breakdown summed to 57; the records sheet gives I1 20, I2 21, I3 9, I4 2, O1 3 = 55 (§1 corrected). Still TBD: registers, citation searching and title/abstract exclusions; the other-methods arm (8 full texts to obtain) is provisional (item 30).
6. **Risk of bias page added to the web report** (item 27) and a RoB 2 section in Methods. A sentence on the Sensitivity page said Confalonieri and APROCCHSS were "the two trials with the strongest raw benefit"; that was wrong (raw ORs in F1: Confalonieri 0.05, Marik 0.33, CAPE COD 0.49, Torres 0.61, APROCCHSS 0.61) and is corrected.
7. **Lead decisions on items 28 and 29 (R. Lewis), applied and re-run.** (a) **D2a extended to F3 and F4:** every short-term set (F1, F3, F4) takes REMAP-CAP's ICU-discharge contrast; the day-90 contrast is used only in F2, as the 30 Oct decision states. Rationale: F3 and F4 are short-term analyses, and the protocol keeps short-term and 90-day mortality apart. Result (reference prior): F3 0.73 (0.50–1.01), P(OR<1) 0.97 (was 0.74, 0.49–1.05, P 0.96); F4 0.73 (0.55–0.93), P 0.99 (was 0.74, 0.55–0.95, P 0.99); every F3/F4 sensitivity fit, the F3 ladder, the F4 meta-regressions and the F4 brms cross-check are refitted on the same basis. (b) **SE sensitivity for the ICU-discharge contrast added** (fits `F1_D2a_se040`, `F1_D2a_se060`): its 95% CrI (0.62–4.18) is asymmetric on the log scale (half-width SEs 0.45 and 0.53), and 0.40 to 0.60 has the same relative span as D2c. F1 gives 0.67 (0.38–1.07), P 0.96 at SE 0.40 and 0.65 (0.39–1.03), P 0.97 at SE 0.60, against 0.67 (0.39–1.06), P 0.96 at 0.487. All 56 main fits pass (one, S-den Nafae F4, needed `adapt_delta` 0.999); brms agrees on 53 of 53 parameters. Report text updated (home page, Methods, Sensitivity, Discussion); a Priors-page sentence saying F3 "lies between F1 and F2" under the harm-leaning priors was no longer true and now says that F3 moves least.
8. **Lead decisions D1, D3 and D4 (R. Lewis), each confirming the pre-specified option; no fit changes.**
   - **D1: ESCAPe short-term row = in-hospital** (34/291 vs 28/281). Rationale: this is what the protocol rule gives (field 24, earliest of in-hospital, 28-day, 30-day); day 60 is outside the short-term window; the IPD 30-day row is rank 2; and choosing a more favourable row after seeing the results would be outcome selection. D1a (day 60, F1 P(OR<1) 0.98) and D1b (IPD 30-day, 0.98) stay as sensitivity fits. Thesis caveat: ESCAPe does not define the length of the in-hospital window.
   - **D3: prior ladder as proposed**, with the reference rung N(0, 1) giving the headline result. The other rungs are enthusiastic N(log 0.70, 0.20) and skeptical N(0, 0.35); mild-harm and REMAP-CAP-harm stay as protocol-fixed. Thesis caveat: the enthusiastic rung derives from earlier syntheses that share trials with ours.
   - **D4: τ ~ half-Normal(0, 0.5), ω ~ half-Normal(0, 0.25)**; τ 0.25 / 1.0 and ω 0.5 stay as sensitivity fits. The ω posterior (median 0.18) sits on its prior (0.17), so the agent comparison is reported as prior-driven by design.
   - Report text updated (home page, Priors, Discussion). Item 17 now covers only the sign-off of the 29 Oct additions.
9. **Lead decisions A2–A4 of the close-out checklist (R. Lewis).**
    - **29 Oct additions signed off** (item 17 closed): meta-regression prior b ~ N(0, 1); `timing_le24h` coding (ESCAPe, Torres, SONIA, Hagman coded 0; Confalonieri and Nafae missing); pooled-baseline comparison (comparison only; leave-one-out predictive score difference 0.54, SE 0.29); S-den; S-src.
    - **Wafy 2021 excluded on study-integrity grounds** (item 13): agent unnamed, impossible P value (0.03 for 52% vs 60% with 25 per arm), no randomisation method, internal inconsistencies. This is the same rule as Muhammad 2025 and Sabry 2011. It was in no fit, so no result changes.
      - `trials.csv` `final_set` = `excluded` and `analysis/rob2_assessments.csv` updated.
      - PRISMA: 11 reports of 10 studies excluded at full text (3 for integrity); the footnote now lists only the 4 ongoing trials.
      - Risk of bias page: the Wafy row is dropped.
    - **Mikami 2007: mortality "not reported"** confirmed; it stays in the sensitivity set with no mortality row, and is not imputed as 0/0.
    - **Nafae 2013: placebo denominator 19 kept** (what the outcome table supports), with 20 shown in S-den (F4 OR 0.734 either way).
    - **Apply in the extraction database too.** The CSVs were edited directly in this repository, so the `trials.final_set` change for WAFY2021 and the Mikami and Nafae notes must also go into `cap_steroids_extraction.sqlite` through its changelog. Otherwise `build_handoff.py` will revert them on the next export.
10. **`quarto` R package added to `analysis/renv.lock`** (1.5.1; `tar_quarto` needs it and it was missing, so a fresh restore could not render the site). Only that entry was added; the lockfile still records R 4.5.1 and the R 4.5 versions of the recommended packages, while the current outputs were produced under R 4.6.1.
11. **Lead decisions A5–A8 of the close-out checklist (R. Lewis); A6 and A7 implemented.**
    - **A5, secondary outcomes.**
      - Pool five binary outcomes across all included trials: secondary infection, GI bleeding, hyperglycaemia, new invasive ventilation, new septic shock. New septic shock also gets a severe-only fit.
      - Report everything else descriptively.
      - Draft timepoint rules and per-trial rows are in `SECONDARY_OUTCOMES_PLAN.md` (R1–R7) for approval. They include six questions (Q1–Q6): Torres' separate ≤72 h and 72–120 h windows, Nafae ventilation, Confalonieri's shock window, APROCCHSS "new septic shock" in an all-shock population, long windows, and extra severe-only fits.
      - None of these rows is second-extractor verified yet (item 31).
    - **A6, frequentist cross-check, added.** REML with Hartung–Knapp (and Wald REML) via `metafor` on the F1 and F4 rows; target `freq_tab`, table `frequentist_reml_hk.csv`, Checks page. F1 0.71 (0.40–1.23), τ 0.34, I² 48%; F4 0.75 (0.59–0.96), τ 0.19, I² 25%. Bayesian: 0.67 (0.39–1.06) and 0.73 (0.55–0.93). `metafor` 5.2-1 and its new dependencies (mathjaxr, metadat, pbapply) were added to `renv.lock`; the recorded R version is unchanged.
    - **A7, protocol tipping criteria reported as primary.** The posterior median OR stays at or below 0.90 for skeptical-prior SD ≥ 0.13. P(OR<1) never reaches 0.975 on the grid (maximum 0.96 at SD 1), so the protocol's second criterion is met without any skepticism. The 0.90 and 0.80 thresholds are kept as labelled additions (SD 0.22 and 0.12). The threshold table now has a `basis` column, and pages look thresholds up by criterion, not by row position (`thr_sd()` in `_helpers.R`). Priors page, Discussion and the 1-D tipping figure (0.975 line) updated. This removes the tipping-criteria deviation.
    - **A8, REMAP-CAP deadline: 1 December 2026.** If the investigators have not supplied adjusted log-ORs and SEs by then, the CrI-derived SEs (ICU discharge 0.487, day 90 0.362) are frozen and reported as approximations, with the SE sensitivity fits.
12. **Secondary-outcome rules approved and dataset built (lead decision 10 Nov).** R1–R7 and the proposed answers to Q1–Q6 in `SECONDARY_OUTCOMES_PLAN.md` are approved. The answers:
    - Q1: Torres combined count if the supplement gives one, else exclude.
    - Q2: Nafae ventilation only if the patients are confirmed as newly ventilated.
    - Q3: Confalonieri end of study if ≤ 30 days, else day 8.
    - Q4: exclude APROCCHSS new septic shock.
    - Q5: long windows included, flagged.
    - Q6: severe-only fits also for secondary infection and GI bleeding.

    `build_secondary.R` produced `analysis_secondary.csv`: 40 rows; 33 pooled, 3 pending a source check, 3 descriptive, 1 excluded. Trials per fit, all included / severe-only:

    | Outcome | All included | Severe-only |
    |---|---|---|
    | Secondary infection | 8 | 4 |
    | GI bleeding | 7 | 4 |
    | Hyperglycaemia | 10 | – |
    | New ventilation | 4 | – |
    | New septic shock | 4 | 3 |

    The script also produced `verification_worklist_secondary_2026-11-10.xlsx` for M. Annes (40 rows; 14 priority 1). The fits and the Secondary outcomes page wait for her check (item 31).
13. **Secondary-outcome fits added, marked unverified (10 Nov).**
    - **Pipeline:** `R/08_secondary.R` and target group `sec_*`. Same model and priors as mortality; 12 fits: the five outcomes, severe-only fits for three of them, the long-window and treated-hyperglycaemia sensitivity fits. All pass (no divergences).
    - **Outputs:** table `secondary_outcomes_UNVERIFIED.csv`; new site page Secondary outcomes, with an "unverified data" warning. The 3 pending-check rows stay out of every fit.
    - **Provisional results**, all included trials, OR (95% CrI):

      | Outcome | Trials | OR (95% CrI) | Note |
      |---|---|---|---|
      | Secondary infection | 8 | 1.01 (0.72–1.41) | P(OR>1) 0.54 |
      | GI bleeding | 7 | 0.63 (0.36–1.12) | |
      | Hyperglycaemia | 10 | 1.87 (1.43–2.46) | treated definition only: 1.76 (1.17–2.58) |
      | New invasive ventilation | 4 | 0.44 (0.18–0.87) | |
      | New septic shock | 4 | 0.53 (0.24–1.06) | severe-only, 3 trials: 0.53 (0.21–1.14) |

    - **Not to be cited** until M. Annes has verified the rows (item 31). The descriptive table for the continuous and sparse outcomes is still to be added.

---

## 4. Evidence base — final set (27 Oct 2026)

| Classification | Trials (mortality steroid vs control, primary timepoint) | Count |
|---|---|---|
| **Primary severe-CAP set** | Marik 1993 (ICU 1/14 vs 3/16; single bolus, `short_course_lt48h`) · Confalonieri 2005 (0/23 vs 7/23) · Torres 2015 (hosp 6/61 vs 9/59) · Meduri 2022 ESCAPe (d60 47/286 vs 50/277) · Dequin 2023 CAPE COD (d28 25/400 vs 47/395) · Heming 2024 APROCCHSS CAP subgroup (d90 109/283 vs 143/279; d28 85 vs 115; `subgroup_derived`) · REMAP-CAP 2025 (contrast OR 1.56, 0.80–3.31) | 7 |
| **Sensitivity set** — all-hospitalised | McHardy 1972 (3/40 vs 9/86; quasi-randomised) · Mikami 2007 (mortality not reported) · Snijders 2010 (d30 6/104 vs 6/109) · Meijvis 2011 (d30 9/151 vs 11/153; 9 in IPD sources) · Blum 2015 STEP (d30 16/392 vs 13/393) · Wittermans 2021 Santeon (4/203 vs 7/198) · Lucinde 2025 SONIA (246/1089 vs 284/1091; SpO2 <90% subgroup 110/404 vs 117/404 → broad-severe analysis) · Hagman 2026 (0/36 vs 0/34) | 8 |
| **Sensitivity set** — severity/CAP not established | Fernández-Serrano 2011 (1/23 vs 1/22) · Nafae 2013 (4/60 vs 6/19) · Tongyoo 2016 pneumonia-source subgroup (d28 11/49 vs 13/51) | 3 |
| Pending lead decision | None (Wafy 2021 excluded 10 Nov, see below) | 0 |
| Excluded at full text (reason) | Muhammad 2025, Sabry 2011, Wafy 2021 (study integrity concerns; Wafy added 10 Nov) · Annane 2012 CORTIFLU (design paper, no arm-level results; 26 randomised — consider author contact) · Meduri 1998, LaSRS 2006/2018, Cicarelli 2007, DEXA-ARDS 2020, CORTICUS-Berlin 2021 (no pneumonia subgroup) · Bernard 1987 (expected; OCR pending) | 10 |
| Ongoing / awaiting classification | RECORDS, ASTEROIDS, Hong 2022, COLOSSEUM (protocols, no results) | 4 |
| Still to obtain / not yet extracted | **Fitzgerald 2022 STOPPE** (folder PDF is a Confalonieri duplicate) · El-Ghamrawy 2006 · Li (Gang) 2016 · Zhou 2015 · Wagner 1956 · Soboleva 2000 · Dambrava 2006 · Oh 2009 · Kapisyzi 2012 · Michels 2026 (I2; duplicate PDF) | 10 |
| Companion reports | 22 I2 records read; data contributed logged per record (STEP 180-day, APROCCHSS abstract, Smit 2025 IPD per-trial counts, latent-class counts) | 22 |
| Other methods (Pitre 2025 list; not retrieved by any set) | Annane 2006 · Meduri 2007 · Rezk 2013 · VANISH · HYPRESS · ADRENAL · Annane 2018 APROCCHSS main | 7 |

Pre-specified sensitivity fits now keyed to `sensitivity_flags`: (ii) low-quality/quasi-randomised out; (vi) `subgroup_derived` out (APROCCHSS, Tongyoo); (viii) `mineralocorticoid` out (APROCCHSS); **new (ix) `short_course_lt48h` out (Marik)**; plus all-hospitalised and broad-severe (SONIA SpO2 <90%, Snijders, Santeon severe subgroups) fits.

**Rank-2 source now in hand:** Smit 2025 IPD (8 trials) 30-day per-trial counts and PSI IV–V test-cohort counts (ESCAPe + CAPE COD: 62/567 vs 79/559) — Table 1 reconstructed from a rotated PDF table, verify.

**Recall check (§7): passed** (20 Oct). **Still untraced:** Maharjan 2018.

**Registered, possibly unpublished (contact PIs):** NCT04007328; NCT02552342; NCT03745664 COLOSSEUM (protocol paper only, Violi 2020); Hong 2022 ChiCTR2100045056; plus the ChiCTR/CTRI/TCTR registrations listed in the screening report.

Zotero: import `records_to_retrieve_fulltext.ris`; library housekeeping still pending.

---

## 5. Open items and blockers

| # | Item | Owner | Blocking |
|---|---|---|---|
| 1 | Supervisor sign-off on decisions A and C | Russ / supervisor | Registration |
| 2 | Second independent screener (T/A retained set + 10% exclusions) | Russ | Registration, PRISMA |
| 3 | Re-export Ovid MEDLINE line 28; re-run PubMed #5; re-run dedup | Student | PRISMA record table |
| 4 | PRESS librarian review (post hoc) | Student | Search documentation |
| 5 | Public repository; reword PROSPERO field 5 (screening + first extraction pass have begun); add sensitivity fit (ix) short-course < 48 h and the SONIA agent-mix rule to the registered protocol before submission | Student / Russ | Registration |
| 6 | REMAP-CAP adjusted log-ORs + SEs (request; interim SEs from the CrIs: ICU discharge 0.487, day 90 0.362). **Deadline 1 Dec 2026** (lead decision 10 Nov); after it, the interim values are frozen | Russ | Analysis |
| 7 | Briel 2018 group: 30-day severe-subgroup counts for Snijders, Meijvis, STEP (STEP has none at 30 d in any report; Lancet appendix first) **(the Meijvis 30-day placebo count 11 vs 9 is settled for the analysis, see log entry 11 of 30 Oct)** | Student | Extraction |
| 8 | APROCCHSS SAP (CAP subgroup a priori exploratory, **not** stratified — confirm); obtain Annane 2018 NEJM | Student | RoB domain 5 | **Partly resolved 4 Nov:** the open-access design paper (Annane 2016, Ann Intensive Care 6:43) confirms the CAP subgroup as a priori defined, 28-day mortality as a secondary endpoint, stratification by centre only, adequate concealment and a blinded analysis plan; the NEJM protocol/SAP file itself could not be read (HTTP 403), obtain it through the library if the primary document is wanted
| 9 | Obtain missing full texts (table above) incl. correct STOPPE PDF; supplements: CAPE COD, STEP appendix, Snijders E3, Santeon E-tables, SONIA S13, ESCAPe, DEXA-ARDS appendix, Smit 2025 appendix | Student | Extraction |
| 10 | Registry searches; PI contacts | Student | Completeness |
| 11 | Zotero housekeeping | Student | Hygiene |
| 12 | Second extractor: numeric rows checked 27 Oct (two corrections). Still to do: fill `verified` column row by row; work the remaining open high-severity issues (Wafy, REMAP-CAP Table 3 misprint, Snijders denominators, STEP PP/LTFU discrepancies, Tongyoo "Others" denominators) | Student / Russ | Analysis |
| 13 | ~~Lead decisions — done 27 Oct except Wafy and Mikami~~ **Done 10 Nov:** Wafy 2021 excluded (study integrity); Mikami 2007 mortality = not reported (log entry 9 of 10 Nov). Database update still to be applied | Russ | Done |
| 14 | ~~Sabry 2011: obtain Omar/Todary/Sabry 2010~~ — closed: trial excluded on integrity grounds | — | — |
| 15 | OCR Bernard 1987 (confirm the expected exclusion) | Student | Block D closure |
| 16 | Document the Muhammad 2025 DOI check (date, which references failed, what they resolved to) for the PRISMA exclusion footnote and the thesis methods | Student | PRISMA |
| 17 | ~~Lead decisions D1 to D4~~ **Decided** (D2a 30 Oct; D1 in-hospital, D3 and D4 as proposed, 10 Nov; log entry 8 of 10 Nov). The additions in the 29 Oct entry (meta-regression prior, timing coding, pooled-baseline comparison, S-den, S-src) **signed off 10 Nov** (log entry 9 of 10 Nov) | Russ | Done |
| 18 | Verify the Pitre 2025 values in `analysis/pitre2025_reported.csv` against the PDF and supplement (priors in Table S2) | Student | Benchmark table |
| 19 | ~~Add IPD rows for Snijders and Santeon~~ **Resolved 29 Oct:** Smit 2025 Table 1 (PDF p. 6, rotated; read from the text layer) gives 30-day deaths 6/104 vs 6/109 (Snijders) and 4/203 vs 7/198 (Wittermans/Santeon), identical to the rank-1 rows, so no IPD row is needed and S-IPD is unaffected. The same table confirms 9/151 vs 9/153 (Meijvis, i.e. 9 placebo deaths at 30 days, supporting the IPD side of the open 11 vs 9 question in item 7) | Student | Done |
| 20 | Review the web report text; decide when to publish `docs/` (GitHub Pages) given that it contains unregistered, draft results | Russ | Sharing |
| 21 | ~~Lloyd 2019 (IMPROVe-GAP) check~~ **Resolved 29 Oct: deliberate exclusion, kept out.** The screening log (`screening_log_all_records.csv`, R1443, with the protocol record R1407) shows it was identified and excluded at title/abstract under code E4c (stepped-wedge trial of a bundled intervention, corticosteroid effect not isolable; note "cite in discussion"), as protocol v2 requires. Adding a trial after the fact would also break the analysis rule against adding trials, so it stays out of every fit. Pitre 2025 includes it (44/401 vs 43/415); this is reported on the benchmark page and in the Discussion. If the lead wants it, the only route is a clearly labelled post-hoc sensitivity analysis with its own extraction | Russ | Done (reopen only if the lead wants a post-hoc sensitivity) |
| 22 | ~~Denominator differences against Pitre's Fig. S22 counts~~ **Resolved 29 Oct against the primary reports and Smit 2025; our extraction stands in all three cases, no data changed.** (a) Confalonieri: 23 per arm analysed (two excluded after randomisation), hospital deaths 7/23 vs 0/23 (Table 4), Smit 8/23 vs 0/23 at 30 days; Pitre's 22 is not the paper's denominator. (b) Nafae: the report is internally inconsistent (placebo N = 20 throughout but the outcome table accounts for 19: 13 improved + 6 died, 31.6% = 6/19); we use 19, Pitre 20; the lead may choose either, the effect is nil (F4 OR 0.744 either way). (c) ESCAPe: day-60 deaths 47/286 vs 50/277 are complete-case (21 participants lacked the primary outcome after early withdrawal); Pitre and Smit use ITT n 297/287; our d60 alternative (D1a) is unchanged with the ITT denominators (OR 0.663 either way). Re-fits with Pitre's denominators (pipeline group S-den) changed no result to two decimals | Student / Russ | Done (Nafae: 19 kept by lead decision 10 Nov) |
| 23 | ~~Switch the F1 primary to D2a~~ **Done 10 Nov** in the pipeline and the web report (log entry of 10 Nov). Remaining: Maria to update the methods text she is drafting | Maria | Methods text |
| 24 | ~~Weekend work plan for Maria (30 Oct)~~ **Returned 3 Nov** (verification of the 34 rows; RoB 2 for the 7 primary-set trials): see log entry of 4 Nov. Remaining: RoB 2 for the 11 sensitivity-set trials and Wafy if wanted | Maria | Done for the primary set |
| 25 | ~~RoB 2 consensus for the 7 primary-set trials~~ **Recorded 4 Nov on the lead's decision** (APROCCHSS low, Confalonieri some concerns; see `RoB2_reconciliation_2026-11-04.md`); consensus S-ii fit run (OR 0.69, 95% CrI 0.44–1.16). **Still to do: M. Annes to confirm or amend**; any change is one edit of `consensus_overall` in `analysis/rob2_assessments.csv` plus `tar_make()` | Maria / Russ | Confirmation |
| 26 | **Finish the verification sign-off in the database**: Tongyoo, subgroup-derived rows and the REMAP-CAP contrasts (new `verified` columns on `subgroups` and `effect_estimates`); ask Maria to confirm her "Y" on the three REMAP-CAP rows referred to the reported OR and interval, since the SE is derived; record Nafae 19/20 and Snijders CURB-65 as "match with note" | Maria / Russ | Verification record |
| 27 | ~~Put the RoB 2 results on the web report~~ **Done 10 Nov**: new Risk of bias page (`analysis/risk_of_bias.qmd`: rating grid and per-trial domain table for assessor 1, assessor 2 and consensus; agreement 5 of 7 overall, 27 of 35 domains; disagreement table; consensus basis; assessor-1 draft for the sensitivity set; S-ii fits) and a RoB 2 section in Methods. Consensus domain ratings are parsed from `consensus_note` and checked against `consensus_overall` at render time | Assistant | Done |
| 28 | ~~REMAP-CAP contrast in F3 and F4 under D2a~~ **Decided 10 Nov: ICU-discharge contrast in F1, F3 and F4; day-90 in F2 only.** Applied and re-run (log entry 7 of 10 Nov) | Russ | Done |
| 29 | ~~SE sensitivity for the ICU-discharge contrast~~ **Decided 10 Nov: add SE 0.40 and 0.60** (F1). Applied and re-run (log entry 7 of 10 Nov) | Russ | Done |
| 30 | **PRISMA placeholders** (checklist in `PRISMA_draft_2026-11-10.md`): registers and citation-search counts, title/abstract exclusions from the screening log, provenance of the 8 other-methods full texts, Bernard 1987 OCR (item 15), Muhammad 2025 DOI footnote (item 16); decide whether ongoing studies get their own box (Wafy resolved 10 Nov) | Student / Russ | PRISMA |
| 31 | **Secondary outcomes (A5).** Rules and Q1–Q6 **approved 10 Nov**; `analysis_secondary.csv` and the worklist **built** (log entry 12). Still to do: second-extractor verification (worklist to M. Annes, incl. Q1–Q3 source checks); provisional fits and the Secondary outcomes page are in place (log entry 13) and must be re-run after verification; then the descriptive table and GRADE | Maria / Assistant | Thesis results |

---

## 6. Next actions, in order

1. **Russ:** D1 to D4, the 29 Oct additions, Wafy, Mikami and Nafae are decided (10 Nov). A5–A8 decided 10 Nov. Still to do: approve the secondary-outcome rules and Q1–Q6 (item 31); confirm the protocol text for sensitivity fit (ix) and the SONIA agent-mix rule; apply the 10 Nov `trials.csv` changes to the extraction database.
2. **Assistant:** re-run and re-check the report text whenever a lead decision or data item lands (items 23, 27, 28 and 29 are done).
3. **Maria:** confirm or amend the recorded RoB 2 consensus (item 25); finish the database sign-off for Tongyoo, the subgroup rows and the REMAP-CAP contrasts (item 26); RoB 2 for the 11 sensitivity-set trials and Wafy if wanted; update the methods text for D2a.
4. **Data:** REMAP-CAP investigator log-OR and SE (item 6); APROCCHSS NEJM protocol/SAP file if the primary document is wanted (item 8); missing full texts and supplements (item 9); verify the Pitre values against the PDF and supplement (item 18).
5. **Registration and PRISMA:** second screener, re-export of the two search lines, public repository checks, PROSPERO registration (items 1 to 5); PRISMA placeholders (item 30).
6. **After the above:** `targets::tar_make()` in `analysis/` re-runs only the affected fits and re-renders `docs/`; run GRADE; review the report text; publish.

---

## 7. Risks

- **Sparse agent clusters in the severe-only set.** Primary set: hydrocortisone ×5 (Marik, Confalonieri, CAPE COD, APROCCHSS, REMAP-CAP) and methylprednisolone ×2 (Torres, ESCAPe); dexamethasone and prednisone clusters populated only via severe subgroups (Santeon, Snijders) or the all-hospitalised fit; SONIA contributes a "mixed" cluster only in the sensitivity/broad-severe fits.
- **Small, low-quality, possibly non-randomised trials** (Nafae, Wafy, McHardy) — integrity and design issues documented; Sabry and Muhammad now excluded outright; sensitivity analysis (ii) and GRADE will carry the rest.
- **REMAP-CAP:** crude counts unusable (RAR, site non-equipoise, 23% control crossover); SE must be requested or approximated; Table 3 IMV-subgroup probabilities misprinted.
- **Exchangeability of APROCCHSS** (shock-only, 96% ventilated, not stratified on CAP).
- **Result stability.** The pooled estimate depends on whether and through which contrast REMAP-CAP enters F1 (P(OR<1) 0.95 with the day-90 contrast, 0.96 under D2a, 0.98 without REMAP-CAP); under D2a the interim SE matters little (0.96 to 0.97 for SE 0.40 to 0.60). The 90-day set (F2, 3 trials) is far more prior-sensitive than F3. Treat all current numbers as provisional.
- **Completeness vs Pitre 2025**; **publication bias** from registered-but-unpublished trials; **single-pass screening** — must be reported and duplicated. Extraction has now had a second-extractor numeric check but not yet a row-by-row `verified` sign-off.

---

## 8. Document inventory (Project folder `~/main/Bayesian corticosteroids`)

| Document | Version | Notes |
|---|---|---|
| `PROSPERO_Protocol_Bayesian_Corticosteroids_sCAP.docx` + `build_prospero.py` | v2, 16 Oct 2026 | Field 5 must be reworded; add sensitivity fit (ix) and SONIA agent-mix rule |
| `Search_Strategies_Corticosteroids_sCAP.docx` / `.rtf` + `build_search.py` | v2.1, 20 Oct 2026 | |
| `Screening_Report_Corticosteroids_sCAP_2026-10-20.md` | 20 Oct 2026 | T/A screening report |
| `Extraction_Report_2026-10-22.md` | 22 Oct 2026 | First-pass extraction report; §3 decisions now taken (see Status §3, 27 Oct) |
| `Thesis_Outline_Bayesian_Corticosteroids_sCAP.docx` + `build_outline.py` | v2, 16 Oct 2026 | |
| `Protocol_Revision_Note_3.1_REMAP-CAP_prior.docx` | 9 Jul 2026 | |
| `Peer_Review_Bayesian_Corticosteroids_Protocol.docx` | 5 Jul 2026 | |
| `Corticosteroid_MA_3month_plan.docx` | 9 Jul 2026 | Superseded |
| `make_ris.py` | — | Seed-library RIS builder |
| `Status.md` | 10 Nov 2026 | This document (copy in the GitHub repository; keep the Project-folder copy in sync) |
| `NEXT_STEPS.md` | 5 Nov 2026 | Condensed to-do list derived from this document |
| `PRISMA_draft_2026-11-10.md`, `analysis/prisma_flow.R` | 10 Nov 2026 | Draft PRISMA 2020 diagram, counting rules and placeholder register |
| `ANALYSIS_INSTRUCTIONS.md`, `analysis/` | 29 Oct 2026 (pipeline re-run 10 Nov) | Analysis instructions and the `targets`/`renv` analysis pipeline (Stan models, tables, figures) |
| `docs/` | 10 Nov 2026 | Rendered Quarto website (draft report) served by GitHub Pages |

Working files on Russ's computer: screening in `CAP_Search_Strategy/Screening_2026-10-20/`; full texts and extraction in `Desktop/cap-steroids-fulltext/` (`_text/` pdftotext output; `_extraction/` database `.sqlite` + `.xlsx` + `csv/`, `README_extraction_database.md`, `EXTRACTION_SCHEMA.md`, `build_db.py`, `apply_decisions_2026-10-27.py`, `raw_batches/`; 22 Oct versions kept as `*.bak-2026-10-22`).
