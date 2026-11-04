# RoB 2 reconciliation sheet: assessor 1 (AI draft) vs assessor 2 (M. Annes), 4 November 2026

**Outcome:** all-cause mortality at the primary-analysis timepoint, effect of assignment. **Scope:** the 7 primary-set trials (assessor 2 has not assessed the 11 sensitivity-set trials or Wafy). **Status:** consensus RECORDED on 4 November 2026 on the decision of R. Lewis (lead), adopting the proposals below (see "Consensus recorded"); confirmation by the second assessor (M. Annes) is pending. The "proposed" column below is what was adopted.

**Where the records are.** Assessor 1: `rob2_judgements` table (domain columns) and `analysis/rob2_assessments.csv` (`a1_*`). Assessor 2: `RoB2_assessor2_final2.xlsx` (Summary and one sheet per trial with signalling answers and quotes), `analysis/rob2_assessments.csv` (`a2_*`) and the `assessor_2` text field of `rob2_judgements`. The returned `rob2_judgements_assessor2.csv` still carries the assessor-1 values in its domain columns.

**How the consensus is recorded.** (Done 4 Nov.) `consensus_overall` (low, some concerns or high) and `consensus_note` for the 7 primary-set rows of `analysis/rob2_assessments.csv`. With all seven filled, `targets::tar_make()` added the consensus low-risk-of-bias fit (S-ii) to the pipeline and the sensitivity page, and the same entries are in the `consensus` column of `rob2_judgements` (`apply_rob2_consensus_2026-11-04.py`, logged in `changelog`).

## Agreement

Overall rating agrees for 5 of 7 trials (CAPE COD, ESCAPe, Torres: low in both; Marik: high in both; REMAP-CAP: some concerns in both). 27 of 35 domain judgements agree. The disagreements, by trial:

| Trial | Domain | Assessor 1 (AI) | Assessor 2 | Where the facts agree and where they differ | Proposed for discussion |
|---|---|---|---|---|---|
| **Confalonieri 2005** (overall: some concerns vs **low**) | D1 | some concerns | low | Both: central block randomisation, sealed envelopes (opacity not stated). Baseline differences in the hydrocortisone arm (NPPV 3 vs 8, p = 0.03; lower PaO2:FiO2, higher CRP) are judged chance by assessor 2; they run against the intervention. | Either rating is defensible; low is acceptable if the imbalance is judged chance. |
| | D5 | some concerns | low | No registration or published protocol (2000 to 2003 trial). Assessor 2 answered "probably yes" to a pre-specified plan, citing the sequential design; for Marik (same documentation situation) she answered "no information" and rated D5 some concerns. The trial also stopped at an interim analysis that crossed the efficacy boundary (46 patients). | Apply one rule to both trials: no registration or protocol means "no information", so D5 **some concerns**, and overall **some concerns**. |
| **APROCCHSS CAP subgroup** (overall: some concerns vs **low**) | D1 | some concerns | low | Both: computer-generated blocks of four with online concealment; randomisation not stratified on CAP. Assessor 2 found the CAP subgroup balanced at baseline. | Low is reasonable if the subgroup is balanced. |
| | D5 | some concerns | low | Both: the CAP subgroup is described as a priori (not stratified) and 28-day mortality is a pre-specified secondary outcome. Assessor 2's "probably yes" rests on the paper's wording; the statistical analysis plan of the main trial (Annane 2018 NEJM supplement) has not been retrieved (Status.md item 8). | Settled by the retrieved design paper (below): D5 and the overall rating **low**. |
| **Marik 1993** (overall: high in both) | D1 | some concerns | **high** | Both: random-number generator, no concealment described; placebo arm older and sicker (APACHE II 14.2 vs 11.2). By the RoB 2 algorithm, concealment "no information" plus a baseline imbalance that suggests a problem gives high. | Adopt **high** (assessor 2). |
| | D2 | some concerns | low | Blinding of personnel is not stated; saline placebo. Assessor 2 answered "probably no" to participants and carers being aware, which the algorithm maps to low. | Follow the algorithm: **low**. The overall rating stays high. |
| **REMAP-CAP 2025** (overall: some concerns in both) | D2 | some concerns | low | Open-label. Assessor 2's sheet does not mention that 28 of 122 control patients (23%) received a systemic corticosteroid (16 hydrocortisone), median 4 days, one at full dose (Heming 2025, intervention fidelity section). | Add this fact to the support and reconsider; **some concerns** is the cautious rating. |
| | D5 | some concerns | low | The comparison-specific analysis plan was posted after the arm stopped for futility; assessor 2 answered "probably yes" and also notes several model versions are reported. | **Some concerns** is the cautious rating. |
| | overall | some concerns | some concerns | Driven by D1 (response-adaptive allocation, 536 vs 122 imbalance, site choice of arms, data-labelling error). | Agreed: **some concerns**. |



## What the open ratings do to the low-risk-of-bias fit (S-ii, F1)

| Low-risk set | Trials | OR (95% CrI) | P(OR<1) | In the pipeline |
|---|---|---|---|---|
| Assessor 1 | CAPE COD, ESCAPe, Torres | 0.75 (0.40 to 1.47) | 0.84 | yes (S_ii_a1_F1) |
| Assessor 2 | adds Confalonieri, APROCCHSS | 0.62 (0.34 to 1.01) | 0.97 | yes (S_ii_a2_F1) |
| **Consensus (recorded)** | CAPE COD, ESCAPe, Torres, APROCCHSS | 0.69 (0.44 to 1.16) | 0.94 | yes (S_ii_cons_F1; needed `adapt_delta` 0.999, no divergences) |
| Mixed: adds Confalonieri only | 4 trials | 0.61 (0.28 to 1.16) | 0.94 | exploratory only |
| All 7 trials (reference) | F1 | 0.68 (0.38 to 1.10) | 0.95 | F1 default |

## APROCCHSS analysis plan: what was retrieved

The NEJM protocol and statistical analysis plan file (Annane 2018 supplement) could not be read (HTTP 403 from the publisher). The open-access design paper (Annane et al., Ann Intensive Care 2016;6:43, PMC4859323, the protocol reference cited by the CAP subgroup paper) states: a priori defined subgroups were non-responders to corticotropin, community-acquired pneumonia and ARDS; 28-day, ICU, hospital and day-180 mortality are secondary endpoints; randomisation was centralised and stratified by centre only, with the sequence concealed from patients, staff, investigators, the data safety board and the sponsor; the analysis plan was written by the statisticians (A. Renault, E. Bellissant) and the statistical analysis plan "will be revised after blind review of data and before access to randomization list", with the randomisation code never broken. The design and analysis plan were published after enrolment finished. This supports low for D1 and D5 and is the basis of the recorded APROCCHSS rating; the NEJM file itself would still be the primary document.

## Consensus recorded (4 November 2026)

| Trial | D1 | D2 | D3 | D4 | D5 | Overall |
|---|---|---|---|---|---|---|
| CAPE COD | low | low | low | low | low | **low** |
| ESCAPe | low | low | low | low | low | **low** |
| Torres | low | low | low | low | low | **low** |
| APROCCHSS CAP subgroup | low | low | low | low | low | **low** |
| Confalonieri | low | low | low | low | some concerns | **some concerns** |
| Marik | high | low | low | low | some concerns | **high** |
| REMAP-CAP | some concerns | some concerns | low | low | some concerns | **some concerns** |

Recorded by Claude on the lead's decision, not in a meeting with the second assessor: M. Annes should confirm or amend, and any change is a one-line edit of `consensus_overall` in `analysis/rob2_assessments.csv` followed by `tar_make()`.

## Still open

- Second-assessor ratings for the 11 sensitivity-set trials and Wafy (not needed for S-ii, which is F1 only).
- Signalling-question gaps in `rob2_signals` flagged in the assessor-1 draft report (for example D4 rows for several trials; protocols for CAPE COD, ESCAPe, STEP, SONIA, Santeon, Meijvis, Snijders, Torres still to be opened).
- The APROCCHSS statistical analysis plan (see above).
