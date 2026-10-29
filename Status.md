# Project Status — Bayesian Meta-Analysis of Adjunctive Corticosteroids in Severe CAP

**Status date:** 29 October 2026
**Phase:** Analysis pipeline built, validated on simulated data and run on the real data with the pre-specified defaults (29 Oct); results and a draft web report exist, but lead decisions D1–D4 and several data items are still open (§5), so no result is final. RoB 2, missing supplements and data requests remain the critical path for the final run. Protocol v2 locked; PROSPERO registration still pending (field 5 must say that screening and a first extraction pass have begun).
**Design scope:** Randomized controlled trials only. Adults. Severe CAP primary set; all-hospitalized CAP sensitivity set.

---

## 1. Where we are in one paragraph

The protocol passed methodological peer review on 5 July 2026 and the five must-fix items were resolved in protocol v1 (9 July). Protocol v2 and search document v2.1 were finalised on 16–20 October; the searches were run, exported and screened at title/abstract level in one pass on 20 October (3,931 records; 2,798 after de-duplication). On 22 October the 55 full-text records (21 primary reports, 22 companions, 9 Block D, 2 verify, 3 other) were extracted in a first pass into `cap_steroids_extraction.sqlite` (32 trial rows, 414 arm-level binary outcome rows, 218 subgroup rows, 116 effect estimates, 87 flagged issues), every data point carrying source record, PDF page, location and verbatim quote. On 27 October the second extractor (Maria Clara) reported that all numbers matched the PDFs except one baseline percentage (McHardy 1972) and a set of ESCAPe page indices; both were corrected, and the lead took the eight open set-assignment decisions (§3). The final set is now 7 primary trials, 11 sensitivity trials, 2 integrity exclusions and one trial (Wafy 2021) still pending. The critical path is now: RoB 2 → missing supplements and data requests → final analysis run.

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
| Primary analysis, prior ladder, first draft | Month 3 (Sep–Oct) | **Pipeline built and run 29 Oct on pre-specified defaults** (draft web report in `docs/`); final run waits for D1–D4, RoB 2 and data items in §5 |

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

---

## 4. Evidence base — final set (27 Oct 2026)

| Classification | Trials (mortality steroid vs control, primary timepoint) | Count |
|---|---|---|
| **Primary severe-CAP set** | Marik 1993 (ICU 1/14 vs 3/16; single bolus, `short_course_lt48h`) · Confalonieri 2005 (0/23 vs 7/23) · Torres 2015 (hosp 6/61 vs 9/59) · Meduri 2022 ESCAPe (d60 47/286 vs 50/277) · Dequin 2023 CAPE COD (d28 25/400 vs 47/395) · Heming 2024 APROCCHSS CAP subgroup (d90 109/283 vs 143/279; d28 85 vs 115; `subgroup_derived`) · REMAP-CAP 2025 (contrast OR 1.56, 0.80–3.31) | 7 |
| **Sensitivity set** — all-hospitalised | McHardy 1972 (3/40 vs 9/86; quasi-randomised) · Mikami 2007 (mortality not reported) · Snijders 2010 (d30 6/104 vs 6/109) · Meijvis 2011 (d30 9/151 vs 11/153; 9 in IPD sources) · Blum 2015 STEP (d30 16/392 vs 13/393) · Wittermans 2021 Santeon (4/203 vs 7/198) · Lucinde 2025 SONIA (246/1089 vs 284/1091; SpO2 <90% subgroup 110/404 vs 117/404 → broad-severe analysis) · Hagman 2026 (0/36 vs 0/34) | 8 |
| **Sensitivity set** — severity/CAP not established | Fernández-Serrano 2011 (1/23 vs 1/22) · Nafae 2013 (4/60 vs 6/19) · Tongyoo 2016 pneumonia-source subgroup (d28 11/49 vs 13/51) | 3 |
| **Pending lead decision** | Wafy 2021 (13/25 vs 15/25; agent unnamed, impossible P value) | 1 |
| Excluded at full text (reason) | Muhammad 2025, Sabry 2011 (study integrity concerns) · Annane 2012 CORTIFLU (design paper, no arm-level results; 26 randomised — consider author contact) · Meduri 1998, LaSRS 2006/2018, Cicarelli 2007, DEXA-ARDS 2020, CORTICUS-Berlin 2021 (no pneumonia subgroup) · Bernard 1987 (expected; OCR pending) | 9 |
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
| 6 | REMAP-CAP adjusted log-OR + SE (request; interim ≈0.36 from CrI) | Russ | Analysis |
| 7 | Briel 2018 group: 30-day severe-subgroup counts for Snijders, Meijvis, STEP (STEP has none at 30 d in any report; Lancet appendix first) **and the Meijvis 30-day placebo count (11 vs 9) — check Briel before writing to the Ovidius authors** | Student | Extraction |
| 8 | APROCCHSS SAP (CAP subgroup a priori exploratory, **not** stratified — confirm); obtain Annane 2018 NEJM | Student | RoB domain 5 |
| 9 | Obtain missing full texts (table above) incl. correct STOPPE PDF; supplements: CAPE COD, STEP appendix, Snijders E3, Santeon E-tables, SONIA S13, ESCAPe, DEXA-ARDS appendix, Smit 2025 appendix | Student | Extraction |
| 10 | Registry searches; PI contacts | Student | Completeness |
| 11 | Zotero housekeeping | Student | Hygiene |
| 12 | Second extractor: numeric rows checked 27 Oct (two corrections). Still to do: fill `verified` column row by row; work the remaining open high-severity issues (Wafy, REMAP-CAP Table 3 misprint, Snijders denominators, STEP PP/LTFU discrepancies, Tongyoo "Others" denominators) | Student / Russ | Analysis |
| 13 | **Lead decisions — done 27 Oct** except: Wafy 2021 (exclude vs sensitivity) and confirmation that Mikami 2007 mortality = not reported | Russ | Final set |
| 14 | ~~Sabry 2011: obtain Omar/Todary/Sabry 2010~~ — closed: trial excluded on integrity grounds | — | — |
| 15 | OCR Bernard 1987 (confirm the expected exclusion) | Student | Block D closure |
| 16 | Document the Muhammad 2025 DOI check (date, which references failed, what they resolved to) for the PRISMA exclusion footnote and the thesis methods | Student | PRISMA |
| 17 | **Lead decisions D1 to D4** (ESCAPe row, REMAP-CAP in F1, prior-ladder centres and SDs, τ and ω priors) and sign-off on the additions in the 29 Oct entry (meta-regression prior, timing coding, pooled-baseline comparison) | Russ | Final analysis run |
| 18 | Verify the Pitre 2025 values in `analysis/pitre2025_reported.csv` against the PDF and supplement (priors in Table S2) | Student | Benchmark table |
| 19 | Add IPD rows for Snijders and Santeon to the hand-off data if they exist in the Smit 2025 appendix, otherwise drop them from the S-IPD description | Student | S-IPD fit |
| 20 | Review the web report text; decide when to publish `docs/` (GitHub Pages) given that it contains unregistered, draft results | Russ | Sharing |
| 21 | ~~Lloyd 2019 (IMPROVe-GAP) check~~ **Resolved 29 Oct: deliberate exclusion, kept out.** The screening log (`screening_log_all_records.csv`, R1443, with the protocol record R1407) shows it was identified and excluded at title/abstract under code E4c (stepped-wedge trial of a bundled intervention, corticosteroid effect not isolable; note "cite in discussion"), as protocol v2 requires. Adding a trial after the fact would also break the analysis rule against adding trials, so it stays out of every fit. Pitre 2025 includes it (44/401 vs 43/415); this is reported on the benchmark page and in the Discussion. If the lead wants it, the only route is a clearly labelled post-hoc sensitivity analysis with its own extraction | Russ | Done (reopen only if the lead wants a post-hoc sensitivity) |
| 22 | **Denominator differences against Pitre's Fig. S22 counts** (candidates for the row-by-row `verified` check): Confalonieri control n 22 (Pitre) vs 23 (ours, mITT); Nafae control n 20 vs 19 (already flagged `denominator_discrepancy`); ESCAPe 47/297 vs 50/287 (Pitre, d60 events with randomised n) vs our d60 47/286 vs 50/277 and in-hospital 34/291 vs 28/281. Resolve against the primary reports and the Smit 2025 IPD | Student | Extraction |

---

## 6. Next actions, in order

1. Russ: decisions D1 to D4, Wafy 2021 and Mikami; confirm protocol text for sensitivity fit (ix), the SONIA agent-mix rule and the 29 Oct additions.
2. Student: fill `verified` for the primary-set rows first; items 16, 7 (Briel/Meijvis), 9 (supplements) and 18 to 19.
3. Fix the two exports; second screener; register on PROSPERO (items 1–5).
4. RoB 2 in duplicate from `rob2_signals` → `rob2_judgements` (primary set first), then run S-ii.
5. Data requests (items 6–8). Regenerate the CSVs with `build_handoff.py`, then `targets::tar_make()` in `analysis/` re-runs only the affected fits and re-renders `docs/`.
6. Review the report text, then publish.

---

## 7. Risks

- **Sparse agent clusters in the severe-only set.** Primary set: hydrocortisone ×5 (Marik, Confalonieri, CAPE COD, APROCCHSS, REMAP-CAP) and methylprednisolone ×2 (Torres, ESCAPe); dexamethasone and prednisone clusters populated only via severe subgroups (Santeon, Snijders) or the all-hospitalised fit; SONIA contributes a "mixed" cluster only in the sensitivity/broad-severe fits.
- **Small, low-quality, possibly non-randomised trials** (Nafae, Wafy, McHardy) — integrity and design issues documented; Sabry and Muhammad now excluded outright; sensitivity analysis (ii) and GRADE will carry the rest.
- **REMAP-CAP:** crude counts unusable (RAR, site non-equipoise, 23% control crossover); SE must be requested or approximated; Table 3 IMV-subgroup probabilities misprinted.
- **Exchangeability of APROCCHSS** (shock-only, 96% ventilated, not stratified on CAP).
- **Result stability.** The pooled estimate is sensitive to the REMAP-CAP SE and to whether REMAP-CAP is in F1 (P(OR<1) 0.94 to 0.98), and the 90-day set (F2, 3 trials) is far more prior-sensitive than F3. Treat all current numbers as provisional.
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
| `Status.md` | 29 Oct 2026 | This document (copy in the GitHub repository; keep the Project-folder copy in sync) |
| `ANALYSIS_INSTRUCTIONS.md`, `analysis/` | 29 Oct 2026 | Analysis instructions and the `targets`/`renv` analysis pipeline (Stan models, tables, figures) |
| `docs/` | 29 Oct 2026 | Rendered Quarto website (draft report) served by GitHub Pages |

Working files on Russ's computer: screening in `CAP_Search_Strategy/Screening_2026-10-20/`; full texts and extraction in `Desktop/cap-steroids-fulltext/` (`_text/` pdftotext output; `_extraction/` database `.sqlite` + `.xlsx` + `csv/`, `README_extraction_database.md`, `EXTRACTION_SCHEMA.md`, `build_db.py`, `apply_decisions_2026-10-27.py`, `raw_batches/`; 22 Oct versions kept as `*.bak-2026-10-22`).
