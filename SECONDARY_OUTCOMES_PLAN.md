# Secondary outcomes: analysis plan and timepoint rules — APPROVED 10 Nov 2026

**Drafted:** 10 November 2026 · **Decision basis:** close-out checklist A5, lead decision 10 Nov: pool five binary outcomes (secondary infection, GI bleeding, hyperglycaemia, new invasive mechanical ventilation, new septic shock) across all included trials, with a severe-only version for new septic shock; report all other secondary outcomes descriptively (PROSPERO field 25).
**Status:** rules **R1–R7** and the proposed answers to **Q1–Q6** were approved by the lead on 10 Nov 2026. The dataset is built (see "Dataset and verification" at the end). No secondary-outcome row has been checked by the second extractor yet; the fits wait for that check.

Source of the counts below: the `outcomes_binary` sheet of `cap_steroids_extraction.xlsx`, restricted to the 18 included trials. `s` = steroid arm, `c` = control arm.

---

## General rules

- **R1. One row per trial per outcome.** Rows come from the primary report or supplement (source rank 1). Use the whole trial and the population the trial used for that outcome: ITT, mITT or safety population, as reported. Never take the row from a severity subgroup.
- **R2. Both arms required.** A row is pooled only if events and denominators are reported for both arms. Rows with one arm missing are listed in the descriptive table, never imputed.
- **R3. Timepoint for harms** (secondary infection, GI bleeding, hyperglycaemia). Take the window closest to day 28, in this order of preference:
  1. day 28 or day 30;
  2. in-hospital;
  3. end of study or end of treatment;
  4. any other window.

  Longer windows (day 90, day 180) are used only if nothing shorter is reported. Such rows are flagged, and a sensitivity fit drops them.
- **R4. Timepoint for progression outcomes** (new invasive ventilation, new septic shock). Take the latest window within 30 days, because these events build up over time and early windows undercount them. Use the patients at risk (free of the condition at baseline) as the denominator where reported, otherwise the trial's population, flagged.
- **R5. Hyperglycaemia definition.** Use each trial's own definition. Where a trial reports both "any hyperglycaemia" and "hyperglycaemia requiring treatment", use the treated definition (the one named in PROSPERO field 25). A sensitivity fit restricts the analysis to trials reporting the treated definition.
- **R6. Model.** The same Stan model as the mortality analysis, with all count trials on the binomial likelihood:
  - reference prior N(0, 1) on the log-OR;
  - τ ~ half-Normal(0, 0.5);
  - unpooled trial baselines;
  - trials with zero events in both arms kept, as for mortality.

  Report the OR with 95% CrI, P(OR > 1) (probability of harm), P(OR < 1), and the predictive OR for a new trial. No prior ladder, agent hierarchy or meta-regression. Run a fit only if at least 3 trials qualify.
- **R7. Verification.** Every selected row (both arms) is checked against the PDF by the second extractor before the fits are final, the same as for mortality.

---

## Proposed rows by outcome

### Secondary infection — 8 trials poolable (4 primary-set)

| Trial | Set | Rows available (s / c) | Proposed row | Note |
|---|---|---|---|---|
| Confalonieri 2005 | primary | end of study 0/23 vs 4/23 | end of study | only window |
| Dequin 2023 (CAPE COD) | primary | d28 39/400 vs 44/395 | d28 | |
| Heming 2024 (APROCCHSS) | primary | d180 101/283 vs 94/279 | d180, **flagged** | only window; long (R3) |
| Torres 2015 | primary | in-hospital 1/61 vs 0/59 | in-hospital | |
| Blum 2015 (STEP) | sensitivity | d30 13/392 vs 14/393; d180 62/361 vs 35/366 | d30 | |
| Meijvis 2011 | sensitivity | in-hospital 7/151 vs 5/153 | in-hospital | |
| Snijders 2010 | sensitivity | d30 10/104 vs 4/109 | d30 | |
| Tongyoo 2016 | sensitivity | d28 17/98 vs 19/99 | d28 | |
| Mikami 2007 | sensitivity | in-hospital 0/15 vs (missing) | descriptive only (R2) | |

### GI bleeding — 7 trials poolable (4 primary-set)

| Trial | Set | Rows available | Proposed row | Note |
|---|---|---|---|---|
| Confalonieri 2005 | primary | end of study 1/23 vs 1/23 | end of study | |
| Dequin 2023 (CAPE COD) | primary | d28 9/400 vs 13/395 | d28 | |
| Heming 2024 (APROCCHSS) | primary | d28 12/283 vs 20/279 | d28 | |
| Torres 2015 | primary | in-hospital 0/61 vs 1/59 | in-hospital | |
| Blum 2015 (STEP) | sensitivity | d30 3/392 vs 4/393 | d30 | |
| Nafae 2013 | sensitivity | d7 1/60 vs 1/20 | d7 | only window |
| Tongyoo 2016 | sensitivity | d28 3/98 vs 4/99 | d28 | |
| Fernández-Serrano 2011 | sensitivity | in-hospital 1/23 vs (missing) | descriptive only (R2) | |

### Hyperglycaemia (R5) — 10 trials poolable (3 primary-set); treated-definition subset 4 trials

| Trial | Set | Rows available | Proposed row | Definition |
|---|---|---|---|---|
| Dequin 2023 (CAPE COD) | primary | treated, d7 231/400 vs 177/395 | d7 | treated |
| Heming 2024 (APROCCHSS) | primary | any, d7 260/283 vs 234/279 | d7 | any |
| Torres 2015 | primary | any, in-hospital 11/61 vs 7/59 | in-hospital | any |
| Blum 2015 (STEP) | sensitivity | treated, in-hospital 76/392 vs 43/393 | in-hospital | treated |
| Hagman 2026 | sensitivity | any, in-hospital 6/37 vs 3/33 | in-hospital | any; denominators 37/33 vs 36/34 randomised, **check** |
| Meijvis 2011 | sensitivity | any 67/151 vs 35/153; treated 7/151 vs 5/153 (both in-hospital) | treated | R5 |
| Nafae 2013 | sensitivity | any, d7 19/60 vs 8/20 | d7 | any |
| Snijders 2010 | sensitivity | treated, in-hospital 5/104 vs 2/109 | in-hospital | treated |
| Tongyoo 2016 | sensitivity | any, d28 79/98 vs 67/99 | d28 | any |
| Wittermans 2021 | sensitivity | any, in-hospital 14/203 vs 1/198 | in-hospital | any |
| Fernández-Serrano 2011 | sensitivity | treated 1/23 vs (missing) | descriptive only (R2) | |

### New invasive mechanical ventilation (R4) — up to 6 trials poolable (2 primary-set)

| Trial | Set | Rows available | Proposed row | Note |
|---|---|---|---|---|
| Dequin 2023 (CAPE COD) | primary | d28 40/222 vs 65/220 (not ventilated at baseline) | d28 | at-risk denominator |
| Torres 2015 | primary | ≤72 h 4/61 vs 5/59; 72–120 h 1/61 vs 4/59 | **Q1** | the two windows are separate treatment-failure parts and cannot be added (a patient could be in both) |
| Blum 2015 (STEP) | sensitivity | d30 1/392 vs 6/393 | d30 | |
| Fernández-Serrano 2011 | sensitivity | in-hospital 0/23 vs 3/22 | in-hospital | |
| Hagman 2026 | sensitivity | d56 0/36 vs 0/34 | d56, flagged | only window; zero events in both arms |
| Nafae 2013 | sensitivity | end of study 8/60 vs 5/20 | **Q2** | unclear whether this counts new ventilation or any ventilation |

### New septic shock (R4) — up to 6 trials poolable; severe-only up to 5

| Trial | Set | Rows available | Proposed row | Note |
|---|---|---|---|---|
| Confalonieri 2005 | primary | d8 0/23 vs 9/23; end of study 0/23 vs 10/23 | **Q3** | R4 picks d8 unless "end of study" is ≤ 30 days |
| Dequin 2023 (CAPE COD) | primary | d28 55/359 vs 86/344 (no shock at baseline) | d28 | at-risk denominator |
| Meduri 2022 (ESCAPe) | primary | in-hospital 13/274 vs 12/271 | in-hospital | |
| Torres 2015 | primary | ≤72 h 2/61 vs 3/59; 72–120 h 0/61 vs 4/59 | **Q1** | same issue as for ventilation |
| Heming 2024 (APROCCHSS) | primary | d180 55/283 vs 55/279 | **Q4: exclude** (proposed) | every patient was in septic shock at enrolment, so this row must be a recurrence or a different outcome; check the source |
| Fernández-Serrano 2011 | sensitivity | in-hospital 1/23 vs 2/22 | in-hospital | |

Severe-only version (primary set): Confalonieri, CAPE COD, ESCAPe and Torres (4 trials, or 5 if APROCCHSS is kept).

---

## Reported descriptively (no pooling)

| Outcome | Trials | Why not pooled |
|---|---|---|
| Hospital length of stay | 12 | continuous; reported as means or medians with different summaries and definitions |
| ICU length of stay | 9 | as above |
| Ventilator-free days; ventilation duration; time to clinical stability; IV antibiotic duration | 3–5 each | continuous, few trials, definitions differ |
| Readmission; ICU admission | 5 each | ICU admission is meaningless in ICU populations; readmission windows differ |
| ARDS; delirium; neuromuscular weakness; serious adverse events; treatment failure | 1–3 each | too few trials |
| Rows missing one arm (Mikami secondary infection; Fernández-Serrano GI bleeding and hyperglycaemia) | 3 rows | R2 |

The descriptive table gives, for each trial: definition, timepoint, steroid and control values as reported, and the source location.

---

## Questions for the lead (answered 10 Nov 2026: every proposal below approved)

- **Q1. Torres 2015, new ventilation and new shock.** The paper reports separate ≤72 h and 72–120 h windows. Options:
  - (a) use a combined count if the paper or its supplement gives one (check eTables);
  - (b) use the ≤72 h window only;
  - (c) exclude Torres from these two outcomes.

  **Proposal:** (a) if available, otherwise (c).
- **Q2. Nafae 2013, ventilation (8/60 vs 5/20).** Include only if the source shows these are newly ventilated patients. **Proposal:** check the source; exclude if unclear.
- **Q3. Confalonieri, new septic shock.** Use d8 (0/23 vs 9/23) or end of study (0/23 vs 10/23). **Proposal:** end of study if it is ≤ 30 days, otherwise d8; the conclusion is the same either way.
- **Q4. APROCCHSS, new septic shock (55/283 vs 55/279).** **Proposal:** exclude from this outcome; check what the row measures.
- **Q5. Long windows** (APROCCHSS secondary infection d180; Hagman ventilation d56). **Proposal:** include, flagged, with a sensitivity fit without them (R3).
- **Q6. Severe-only versions.** The A5 decision gives a severe-only fit for new septic shock only. Secondary infection and GI bleeding each have 4 primary-set trials. **Proposal:** add severe-only fits for these two as well. They are cheap and answer the more relevant question for severe CAP.

---

## Dataset and verification (built 10 Nov 2026)

`build_secondary.R` (repository root) builds the dataset from the `outcomes_binary` sheet of the extraction workbook. Each trial × outcome choice is an explicit line in its selection table. The script stops if a selected row is missing or duplicated, if a pooled row lacks an arm or is not rank 1, or if any fit would have fewer than 3 trials.

- **`analysis_secondary.csv`:** 40 trial × outcome rows.
  - 33 pooled, of which 2 are flagged long windows (APROCCHSS secondary infection d180; Hagman ventilation d56).
  - 3 pending a source check (Torres ventilation and shock, Q1; Nafae ventilation, Q2).
  - 3 descriptive (one arm missing).
  - 1 excluded (APROCCHSS new septic shock, Q4; the extraction note confirms that every patient was in shock at enrolment and that the row counts new episodes).
- **Trials per fit**, all included / severe-only: secondary infection 8 / 4; GI bleeding 7 / 4; hyperglycaemia 10 / –; new ventilation 4 / –; new septic shock 4 / 3. Torres would add one primary-set trial to ventilation and shock if Q1 finds a combined count.
- **`verification_worklist_secondary_2026-11-10.xlsx` (and `.csv`)** for M. Annes: one row per trial × outcome, with both arms, PDF page, location, the extracted quote and a specific check question. Priority 1 (14 rows) covers rows that decide inclusion or enter a severe-only fit; priority 2 (22) other pooled rows; priority 3 (4) descriptive or excluded rows. She also fills in each trial's definition of the outcome, which the methods text and GRADE need.

To change a selection: edit the database (and re-export) or the selection table in `build_secondary.R`, then re-run it. Never edit the CSV by hand.

## Work after verification

1. ~~Build `analysis_secondary.csv`~~ done 10 Nov.
2. Second-extractor verification of every selected row (R7): worklist sent to M. Annes. Apply her answers to Q1–Q3 and any corrections through the database and the selection table, then re-run `build_secondary.R`.
3. Pipeline: add fits for each outcome, in all included trials and severe-only where approved, plus the R3 and R5 sensitivity fits.
4. Add a Secondary outcomes page to the site (pooled results and the descriptive table), and a methods paragraph.
5. Include these outcomes in GRADE (close-out D2).
