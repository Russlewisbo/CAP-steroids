# Bayesian meta-analysis of adjunctive corticosteroids in severe CAP — analysis instructions for the R/RStudio assistant

**Prepared:** 29 October 2026 · **Revised:** 10 November 2026 (D2 decided and applied; RoB 2 for the primary set done; pipeline as built) · **For:** the LLM assistant working with Russ Lewis (project lead) · **Status of inputs:** extraction verified by a second extractor for numeric rows (27 Oct) and row by row (31 Oct; database sign-off incomplete for subgroup rows and the REMAP-CAP contrasts); RoB 2 done by two assessors for the 7 primary-set trials with a consensus recorded 4 Nov (second assessor's confirmation pending), assessor-1 draft only for the sensitivity set; D1 to D4 all decided (D2a 30 Oct; D1, D3, D4 on 10 Nov, each confirming the pre-specified option); PROSPERO registration pending.

> **What changed on 10 November.** §2 rule 8 and §4: D2 is decided (D2a), so REMAP-CAP enters the short-term fits through its ICU-discharge contrast. §3.1 and §3.2: the CSV still flags the day-90 row for F1, F3 and F4, and the pipeline swaps in the ICU-discharge row. §3.3 and §5.4: S-ii is implemented from `analysis/rob2_assessments.csv`. §5.1: the sampler settings are the ones used. §5.4: the fits added since 29 Oct are listed. §6: the layout is the one built. §7: the report statements are updated.

Read this whole file before writing any code. The files that travel with it are in the same folder:

| File | What it is |
|---|---|
| `analysis_mortality.csv` | **The analysis dataset.** One row per trial × timepoint × data source for all-cause mortality, with `fit_*` columns that say which pre-specified fit each row belongs to. 34 rows. |
| `trials.csv` | One row per trial in the final set (7 primary, 11 sensitivity, plus Wafy 2021 marked `excluded` on 10 Nov): design, severity, agent, regimen, covariates for meta-regression, set assignment and flags. |
| `mortality_long.csv` | Full provenance: every mortality row in the extraction database for these trials (all timepoints, all sources, all severity subgroups, all REMAP-CAP posterior ORs), with PDF page and location. Use it to answer "where does this number come from?" — do not re-select rows from it unless the lead asks. |
| `build_handoff.py` | Script that generated the three CSVs from `cap_steroids_extraction.sqlite` (lives one folder up). Regenerate rather than hand-edit if the database changes. |
| `PROSPERO_Protocol_v2.md` | Text of the registered-protocol draft v2 (authoritative .docx in the Project folder). |
| `analysis/rob2_assessments.csv` | RoB 2 for all-cause mortality: domain and overall ratings by assessor 1 (`a1_*`, AI draft, all 19 trials) and assessor 2 (`a2_*`, primary set), and the consensus (`consensus_overall`, with domain ratings and basis in `consensus_note`) for the primary set. Drives S-ii and the Risk of bias page. |
| `cap_steroids_extraction.xlsx` | Export of the extraction database; its `records` sheet (55 full-text records) drives the report-level PRISMA counts in `analysis/prisma_flow.R`. |
| `Status.md` | Project status and decisions log, updated 10 Nov 2026 — the most recent decisions; wins over the protocol where they differ. |
| `NEXT_STEPS.md`, `PRISMA_draft_2026-11-10.md` | Condensed to-do list; PRISMA counting rules and placeholder register. |

---

## 1. Project in one paragraph

A PROSPERO-registered (pending) systematic review and **Bayesian** random-effects meta-analysis of randomized controlled trials of adjunctive systemic corticosteroids versus placebo/no corticosteroid in **adults with severe community-acquired pneumonia (sCAP)**. Primary outcome: short-term all-cause mortality (earliest of in-hospital, 28-day or 30-day), odds-ratio scale. The review is explicitly decision-focused: it reports posterior probabilities of benefit at pre-specified thresholds, an NNT distribution, a predictive interval for a future trial, an agent-level partial-pooling hierarchy (hydrocortisone / methylprednisolone / dexamethasone / prednis(ol)one), and a transparent **prior ladder with a tipping-point analysis** running from enthusiastic to REMAP-CAP-harm. It is positioned against Pitre et al. 2025 (frequentist/Bayesian dose-response MA) and Briel et al. 2018 (IPD): the marginal contribution is the 2022–2025 trial wave (ESCAPe, CAPE COD, APROCCHSS CAP subgroup, REMAP-CAP, SONIA), the shrinkage-based agent hierarchy, and the prior-ladder/tipping-point layer. Everything is implemented in R; Stan via `cmdstanr` for the hybrid-likelihood model, `brms` for cross-checks; Quarto for the report; code to be public.

The lead (Russ Lewis, PharmD) is a Bayesian-literate pharmacologist who works routinely in `brms`, `cmdstanr`, `ggplot2`, `tidybayes`/`posterior`, Quarto. Write code at that level: no tutorials, no hedging, no `set.seed` without a reason, no silent data edits.

---

## 2. Hard rules (do not violate; ask the lead instead)

1. **Never modify the numbers in `analysis_mortality.csv`.** If a value looks wrong, say so and stop; the database and PDFs are the source of truth, not your judgement. Never derive counts from percentages, never impute missing arms, never add a trial.
2. **REMAP-CAP enters only as a contrast (log-OR + SE).** Its crude 90-day counts (78/521 vs 12/122) are *in `mortality_long.csv` for the record only* and must never enter a binomial likelihood (response-adaptive randomisation, site non-equipoise, 23% control crossover). The row in `analysis_mortality.csv` has `data_type = "contrast"`.
3. **Timepoints are never pooled across horizons.** Short-term (`timepoint_class = short_term`) and 90-day (`d90`) are separate analyses. `d60_other` rows are reported descriptively, never pooled with d90. Under D2a this now holds for REMAP-CAP too: its ICU-discharge contrast is in the short-term fits (F1, F3, F4) and its day-90 contrast only in F2. The day-90 contrast appears in a short-term fit only in the labelled sensitivity fits D2_d90 and D2c.
4. **Source rank 1 only in the main fits.** Rank-2 rows (Smit 2025 IPD reconstruction, `fit_ipd_crosscheck = 1`) are a cross-check fit only, never merged with rank-1 rows for the same trial.
5. **Exact binomial likelihood for count trials** — no continuity corrections, no normal approximation — except in the pre-specified contrast-based cross-check (sensitivity iii), where you add 0.5 to all four cells of any trial with a zero cell and drop double-zero trials, and say so.
6. **Trial baseline log-odds are unpooled fixed effects** (Senn), one per count trial, with a diffuse prior. Do not fit exchangeable baselines in the primary model.
7. **Every fit is run on simulated data first** (prior-predictive and a recovery check with known parameters) before the real data. Keep that script.
8. **Report, don't adjudicate.** Decisions marked **D1–D4** below belong to the lead. For an open decision, run the pre-specified default *and* the alternative, present both, and flag them at the top of the output. For a decided one (all of D1–D4 as of 10 Nov), use the decision and report the former default and alternatives as labelled sensitivity fits. Record every decision in `Status.md` as the lead's, with its date.
9. Fix seeds, record `cmdstanr`/`brms`/Stan/R versions (`sessionInfo()`), and use `renv`.

---

## 3. The data

### 3.1 `analysis_mortality.csv` — column dictionary

| Column | Meaning |
|---|---|
| `trial_id` | Key, matches `trials.csv` and the extraction database |
| `study_label` | For plots/tables, e.g. "Dequin 2023 (CAPE COD)" |
| `final_set` | `primary` (severe-CAP set) / `sensitivity` (all-hospitalised or severity/CAP not established) |
| `data_type` | `counts` → binomial likelihood on `r1,n1,r0,n0`; `contrast` → normal likelihood on `yi` with SD `sei` |
| `agent_cluster` | Cluster for the agent hierarchy: `hydrocortisone`, `methylprednisolone`, `dexamethasone`, `prednisone/prednisolone`, `mixed` (SONIA), `other_betamethasone` (Hagman) |
| `timepoint`, `timepoint_class` | As reported; class ∈ `short_term`, `d90`, `d60_other` |
| `population` | ITT / mITT / as reported / adjusted (contrast) |
| `subgroup` | Empty for whole-trial rows; otherwise the severity subgroup the counts refer to |
| `r1,n1` / `r0,n0` | Deaths / denominator, steroid / control |
| `yi`, `sei` | log-OR and its SE (contrast rows only). Both REMAP-CAP SEs are **interim**, derived from the published 95% CrI: day 90 (ln 3.31 − ln 0.80)/3.92 = 0.362; ICU discharge (ln 4.18 − ln 0.62)/3.92 = 0.487. The ICU-discharge CrI is asymmetric on the log scale (half-width SEs 0.45 and 0.53) |
| `reported_OR`, `reported_CrI_*` | The published posterior OR the contrast was derived from |
| `fit_primary_short` (F1) | 1 = row belongs to the **primary short-term analysis** (7 trials) |
| `fit_primary_d90` (F2) | 1 = row belongs to the **90-day analysis** (3 trials) |
| `fit_broad_severe` (F3) | 1 = row belongs to the **broad-severe analysis** (F1 + published severe subgroups of all-hospitalised trials; 10 trials) |
| `fit_all_hospitalised` (F4) | 1 = row belongs to the **all-hospitalised CAP sensitivity analysis** (F1 + whole-trial rows of the sensitivity set; 17 trials) |
| `fit_ipd_crosscheck` | 1 = Smit 2025 IPD (rank-2) row, cross-check fit only |
| `source_rank`, `source_record_id`, `pdf_page`, `location` | Provenance (PDF page index is 1-based, not the printed page) |
| `sensitivity_flags` | Semicolon-separated trial flags that drive the pre-specified sensitivity fits (see §5.4) |
| `notes` | Read every one of them |

Membership check (must hold after you load the file; enforced by `check_membership()` in `R/00_load_data.R`): F1 = 7 rows/7 trials; F2 = 3/3; F3 = 10/10; F4 = 17/17; exactly one `contrast` row in each of F1–F4 (REMAP-CAP); Hagman 2026 is 0/36 vs 0/34 (double-zero) and only in F4.

**D2a is applied in code, not in the CSV.** The `fit_*` flags still mark REMAP-CAP's day-90 contrast row for F1, F3 and F4; its ICU-discharge row (`timepoint = ICU`) has all flags 0. `R/02_fit_primary.R` swaps the ICU-discharge row in for every F1, F3 and F4 fit (`f1_base()`, `remap_icu_row()`), so the membership check above still holds on the CSV. Do not change the flags by hand; if the lead wants D2a in the data file, regenerate it with `build_handoff.py` and update the swap and the check together.

### 3.2 The seven primary-set rows (F1) as they stand

| Trial | Agent | Row used | Steroid | Control |
|---|---|---|---|---|
| Marik 1993 | HC single 10 mg/kg bolus | ICU mortality | 1/14 | 3/16 |
| Confalonieri 2005 | HC 240 mg/d infusion × 7 d | in-hospital (= d28), mITT | 0/23 | 7/23 |
| Torres 2015 | MP 0.5 mg/kg q12h × 5 d | in-hospital, ITT | 6/61 | 9/59 |
| Meduri 2022 (ESCAPe) | MP 40 mg/d + 20-d taper | **in-hospital, ITT (decision D1)** | 34/291 | 28/281 |
| Dequin 2023 (CAPE COD) | HC 200 mg/d, 8–14 d + taper | d28, mITT | 25/400 | 47/395 |
| Heming 2024 (APROCCHSS CAP subgroup) | HC 200 mg/d + fludrocortisone × 7 d | d28, ITT | 85/283 | 115/279 |
| REMAP-CAP 2025 | HC 50 mg q6h × 7 d, open-label | ICU-discharge adjusted contrast (**decision D2a**, 30 Oct; swapped in by code, see §3.1) | log-OR 0.399, SE 0.487 (OR 1.49, 0.62–4.18) | — |

### 3.3 `trials.csv` — covariates available for meta-regression (one at a time, exploratory)

`pct_septic_shock_baseline`, `pct_imv_baseline`, `pct_influenza_viral` (mostly missing — report how many trials contribute), `prednisone_equiv_mg_day` (missing for the two weight-based regimens, Marik and Torres), `duration_days`, `timing_from_admission` (free text — code a binary "≤24 h of admission/ICU" yourself and show the coding), `resource_level`, `setting`, `blinding`, `severity_population`, `mineralocorticoid`, `age_central_trial`, `pct_psi_4_5_trial`. `rob2_overall_mortality` in `trials.csv` is still `PENDING` for every trial and is **not used**. RoB 2 judgements live in `analysis/rob2_assessments.csv` (see the file table above), which drives S-ii. The `timing_le24h` coding is in `timing_coding` in `R/02_fit_primary.R` and is shown on the meta-regression page.

---

## 4. Analysis decisions D1–D4 (all decided as of 10 Nov 2026; alternatives run as labelled sensitivity fits)

| ID | Question | Pre-specified default (use this) | Alternative(s) to run alongside |
|---|---|---|---|
| **D1** — **decided 10 Nov: in-hospital** | ESCAPe short-term row. Protocol field 24 says "earliest of in-hospital, 28-day, 30-day"; the trial's primary endpoint is d60 and there is no d28/d90 in the paper. In-hospital (34/291 vs 28/281) leans toward harm; d60 (47/286 vs 50/277) is neutral. | **in-hospital, rank 1** | (a) d60 47/286 vs 50/277; (b) Smit 2025 IPD 30-day 40/297 vs 40/287 (rank 2) |
| **D2** — **decided** | REMAP-CAP has no valid short-term contrast. **Decided 30 Oct (D2a): ICU-discharge adjusted contrast in F1**; extended 10 Nov to F3 and F4 (Status item 28). Day-90 contrast in F2 only. | **D2a:** ICU-discharge contrast (log-OR 0.399, SE 0.487) in F1, F3, F4 | Sensitivity fits: `F1_D2_d90` (former default, day-90 contrast in F1); `F1_D2b` (F1 without REMAP-CAP); `F1_D2a_se040` / `_se060` (ICU-discharge SE 0.40 / 0.60, Status item 29); `F1_D2c_se030` / `_se045` (day-90 SE 0.30 / 0.45) |
| **D3** — **decided 10 Nov: as proposed, reference rung = headline** | Prior ladder: the harm rungs are fixed by protocol; the enthusiastic / reference / skeptical rungs are proposed in §5.3 and need the lead's sign-off on centre and SD. | Values in §5.3 | — |
| **D4** — **decided 10 Nov: as proposed** | τ and ω hyperpriors: proposed in §5.2; the protocol fixes the *family* (half-Normal) not the scale. | Values in §5.2 | The sensitivity grid in §5.4 (iv) |

Open data issues that may change numbers later (do not resolve yourself):
- REMAP-CAP investigator-supplied adjusted log-ORs and SEs, which would replace 0.487 and 0.362.

Settled since 29 Oct:
- Meijvis 2011 placebo deaths: the rank-1 count of 11 stays, and the IPD count of 9 is sensitivity fit S-src (30 Oct).
- Denominator differences against Pitre: our extraction stands, shown in S-den (29 Oct).
- Wafy 2021 excluded on study-integrity grounds; Mikami 2007 mortality = not reported; Nafae placebo denominator 19 (10 Nov, lead decisions). Write the pipeline so that swapping one row and re-running is trivial (a single `targets` or `make`-style script, parameterised by the CSV).

---

## 5. Models

### 5.1 Core model: one-stage random-effects with a hybrid likelihood

Notation: trial k; count trials k ∈ B with deaths r_{k0}, r_{k1} out of n_{k0}, n_{k1}; contrast trials k ∈ C with y_k, s_k.

```
r_k0 ~ Binomial(n_k0, inv_logit(alpha_k))                      k in B
r_k1 ~ Binomial(n_k1, inv_logit(alpha_k + theta_k))            k in B
y_k  ~ Normal(theta_k, s_k)                                     k in C
theta_k ~ Normal(mu, tau)                                       all k     (or Normal(beta_{a[k]}, tau) with the agent layer)
beta_a  ~ Normal(mu, omega)                                     agent clusters a (agent-hierarchy model only)
alpha_k ~ Normal(0, 10)        diffuse, unpooled baseline (Senn); sensitivity v: Normal(0, 2)
mu      ~ prior-ladder rung (see 5.3)
tau     ~ half-Normal(0, 0.5)  (see 5.2)
omega   ~ half-Normal(0, 0.25) (see 5.2)
```

`brms` cannot combine a binomial response and an `se()` normal response under *one* shared `theta_k` cleanly, so **write the hybrid model in Stan and fit with `cmdstanr`.** Use `brms` only for (a) the pure-count fits (all trials binomial, `events | trials(n) ~ 0 + trial + arm + (0 + arm | trial)` style, or `bf(... , nl = TRUE)`) and (b) the pure-contrast cross-check (`yi | se(sei) ~ 1 + (1 | trial)`), as independent checks that the Stan model reproduces them when the other likelihood is switched off.

Stan skeleton (non-centred; `agent_hier` switches the agent layer on/off; pass hyperprior scales as data so the ladder and the sensitivity grid are loops over `data`, not separate programs):

```stan
data {
  int<lower=0> K_b;  array[K_b] int r1; array[K_b] int n1; array[K_b] int r0; array[K_b] int n0;
  int<lower=0> K_c;  vector[K_c] y_c;   vector<lower=0>[K_c] se_c;
  int<lower=1> J;    array[K_b] int<lower=1,upper=J> agent_b; array[K_c] int<lower=1,upper=J> agent_c;
  int<lower=0,upper=1> agent_hier;
  real mu_prior_mean; real<lower=0> mu_prior_sd;
  real<lower=0> tau_prior_sd; real<lower=0> omega_prior_sd; real<lower=0> alpha_prior_sd;
  int<lower=0> N_r0grid; vector<lower=0,upper=1>[N_r0grid] r0grid;   // baseline risks for NNT
}
parameters {
  vector[K_b] alpha;  real mu;  real<lower=0> tau;  real<lower=0> omega;
  vector[J] z_a;  vector[K_b + K_c] z_t;
}
transformed parameters {
  vector[J] beta = mu + (agent_hier == 1 ? omega : 0) * z_a;
  vector[K_b + K_c] theta;
  for (k in 1:K_b) theta[k]       = (agent_hier == 1 ? beta[agent_b[k]] : mu) + tau * z_t[k];
  for (k in 1:K_c) theta[K_b + k] = (agent_hier == 1 ? beta[agent_c[k]] : mu) + tau * z_t[K_b + k];
}
model {
  alpha ~ normal(0, alpha_prior_sd);
  mu    ~ normal(mu_prior_mean, mu_prior_sd);
  tau   ~ normal(0, tau_prior_sd);
  omega ~ normal(0, omega_prior_sd);
  z_a ~ std_normal();  z_t ~ std_normal();
  r0 ~ binomial_logit(n0, alpha);
  r1 ~ binomial_logit(n1, alpha + theta[1:K_b]);
  if (K_c > 0) y_c ~ normal(theta[(K_b + 1):(K_b + K_c)], se_c);
}
generated quantities {
  real OR = exp(mu);
  real theta_new = normal_rng(mu, tau);            // predictive for a new trial
  real OR_new = exp(theta_new);
  vector[J] OR_agent = exp(beta);
  vector[N_r0grid] ARR;  vector[N_r0grid] NNT;
  for (g in 1:N_r0grid) { real p1 = inv_logit(logit(r0grid[g]) + mu); ARR[g] = r0grid[g] - p1; NNT[g] = 1 / ARR[g]; }
  array[K_b] int r1_rep = binomial_logit_rng(n1, alpha + theta[1:K_b]);   // PPC
  array[K_b] int r0_rep = binomial_logit_rng(n0, alpha);
}
```

Sampling (as implemented in `fit_hma()`): 4 chains × 1000 warmup + 2000 post-warmup (8000 draws), `adapt_delta = 0.99`, `max_treedepth = 12`, seed 7291. Accept a fit only if all R-hat < 1.01, bulk/tail ESS > 400 for `mu`, `tau`, `omega`, every `theta`, and zero divergences. If a fit has divergences, `adapt_delta` is raised automatically (0.999, then 0.9999) and the value used is stored; the Convergence page lists those fits. As of 10 Nov, all 56 main fits pass, and two fits needed 0.999: `S_den_nafae_F4` and the leave-one-out fit without ESCAPe. With one trial per cluster the agent layer is weakly identified — expect `omega` to sit on its prior; that is the pre-specified interpretation ("estimation under strong shrinkage"), not a bug.

### 5.2 Hyperpriors (D4)

- τ (between-trial SD, log-OR scale): primary **half-Normal(0, 0.5)** (prior median ≈ 0.34, 95th percentile ≈ 0.82). Sensitivity: half-Normal(0, 0.25) and half-Normal(0, 1).
- ω (between-agent SD): primary **half-Normal(0, 0.25)** — a deliberate regulariser; with 2 populated clusters in F1 (HC × 5, MP × 2) the data cannot estimate it. Sensitivity: half-Normal(0, 0.5).
- α_k baseline: Normal(0, 10) primary; Normal(0, 2) sensitivity (v).
- Report prior-predictive distributions of OR and of τ-implied I² analogues (Rhodes/Turner-style) in the supplement.

### 5.3 Prior ladder on μ (log-OR) — D3

| Rung | Prior on μ | Motivation / label in the report |
|---|---|---|
| Enthusiastic | Normal(log 0.70, 0.20) | Centred on the pre-2022 severe-CAP syntheses (Siemieniuk 2015 / Pitre 2025 severe stratum ≈ RR/OR 0.6–0.75); 95% OR ≈ 0.47–1.04 |
| Reference (weakly informative) | Normal(0, 1.0) | 95% OR ≈ 0.14–7.1; lets the data dominate |
| Skeptical | Normal(0, 0.35) | Spiegelhalter-style: P(OR < 0.5) ≈ 2.5%; 95% OR ≈ 0.50–1.99 |
| Mild harm-leaning | **Normal(log 1.10, 0.20)** | Protocol-fixed; modest general prior toward harm, not tied to a trial |
| REMAP-CAP harm | **Normal(log 1.50, 0.35)** | Protocol-fixed; centred on the REMAP-CAP adjusted OR ≈ 1.5, SD calibrated so P(harm) ≈ 88%, matching its reported 84–91% |

Note the double-counting caveat for the REMAP-CAP-harm rung: REMAP-CAP is also in the likelihood. Report that rung **with and without** the REMAP-CAP contrast row; the "without" version is the clean "what if you walked in believing REMAP-CAP" analysis.

**Tipping point.** (1) 1-D: skeptical prior Normal(0, sd) over sd ∈ {0.05, 0.10, …, 1.0}; report P(OR < 1) and P(OR < 0.833) vs sd. Primary (protocol §7.4) criteria: the sd at which the posterior median OR crosses 0.90 and at which P(OR < 1) falls below 0.975; P(OR < 1) below 0.90 and 0.80 are reported as additions (lead decision 10 Nov, A7). Look thresholds up by criterion (`thr_sd()`), never by row position. (2) 2-D surface: centre ∈ log{0.70, 0.80, 0.90, 1.00, 1.10, 1.25, 1.50, 1.75} × sd ∈ {0.10, 0.20, 0.35, 0.50, 0.75, 1.0}; heat map of P(OR < 1) and of posterior median OR. Cache fits; this is 48 + 20 fits of a small model — fine with `cmdstanr` in parallel.

### 5.4 Fit inventory

| # | Fit | Rows | Notes |
|---|---|---|---|
| F1 | **Primary short-term**, reference prior | `fit_primary_short == 1` (7), REMAP-CAP ICU-discharge row swapped in (D2a) | The headline result; also under every ladder rung (§5.3). Every F1-based fit (agent, ladder, tipping points, leave-one-out, meta-regression, sensitivity) uses the same D2a base |
| F1-agent | F1 + agent hierarchy | same | Report OR per cluster with shrinkage; clusters in F1: hydrocortisone (Marik, Confalonieri, CAPE COD, APROCCHSS, REMAP-CAP), methylprednisolone (Torres, ESCAPe) |
| F2 | 90-day | `fit_primary_d90 == 1` (3) | CAPE COD d90, APROCCHSS d90, REMAP-CAP **day-90** contrast. ESCAPe d60 reported alongside, not pooled |
| F3 | Broad-severe (secondary) | `fit_broad_severe == 1` (10), REMAP-CAP ICU-discharge row swapped in (D2a) | F1 + Snijders PSI IV–V, Santeon PSI IV–V, SONIA SpO2 < 90% (`agent_cluster = mixed`). Agent model now has 4–5 clusters |
| F4 | All-hospitalised CAP (sensitivity i) | `fit_all_hospitalised == 1` (17), REMAP-CAP ICU-discharge row swapped in (D2a) | Whole-trial rows; Hagman double-zero kept (binomial only); SONIA whole trial as `mixed` |
| S-ii | Low-RoB only | F1 restricted to trials rated low overall in `analysis/rob2_assessments.csv` | Run per assessor (`S_ii_a1_F1`, `S_ii_a2_F1`) and for the consensus (`S_ii_cons_F1`, added automatically once `consensus_overall` is filled for all primary-set rows). Provisional until the second assessor confirms the consensus |
| S-iii | Contrast-based for all trials | F1 with every trial as log-OR + SE | Add 0.5 to all four cells where any cell is zero (Confalonieri); drop double-zero; compare with F1 |
| S-iv | Alternative τ, ω priors | F1, F1-agent | Grid in §5.2 |
| S-v | Tight baseline prior | F1 with α ~ N(0, 2) | |
| S-vi | Drop `subgroup_derived` | F1 minus APROCCHSS (6) | In F4 also drop Tongyoo |
| S-viii | Drop `mineralocorticoid` | F1 minus APROCCHSS (6) | Identical to S-vi in F1; keep both labels for the protocol |
| S-ix | Drop `short_course_lt48h` | F1 minus Marik (6) | New pre-specified fit (27 Oct) |
| D1a/b, D2 sensitivity fits | Decision alternatives | §4 | `F1_D1a`, `F1_D1b`, `F1_D2a_se040`, `F1_D2a_se060`, `F1_D2_d90`, `F1_D2b`, `F1_D2c_se030`, `F1_D2c_se045` |
| S-IPD | Smit 2025 IPD cross-check | rank-1 rows replaced by `fit_ipd_crosscheck == 1` rows for Confalonieri, Torres, ESCAPe, CAPE COD (+ Meijvis, STEP in F4) | Rank 2, cross-check only. Snijders and Santeon have no IPD row: Smit's 30-day counts equal our rank-1 rows |
| S-CE | Common-effect (τ ~ half-Normal(0, 0.001)) | F1, F3, F4 | Added 29 Oct; the assumption behind Pitre 2025's Bayesian probabilities |
| S-src | Meijvis placebo 30-day deaths 9 (IPD sources) instead of 11 | F4 | Added 30 Oct |
| S-den | Pitre 2025 denominators (Confalonieri control 22; ESCAPe d60 ITT 297/287; Nafae control 20) | F1, F1 with the D1a row, F4 | Added 29 Oct; benchmark page |
| Exact LOTO | Leave-one-trial-out refits, unpooled vs pooled baselines | F1 | Added 29 Oct, because PSIS-LOO is unreliable with unpooled baselines |
| Pooled-baseline comparison | a0 ~ N(0, 2), σ_a ~ half-N(0, 1) | F1 | Comparison only; primary baselines stay unpooled |
| Frequentist cross-check | REML + Hartung–Knapp (and Wald REML), `metafor` | F1, F4 | Added 10 Nov (close-out A6); 0.5 continuity correction for zero-cell trials, double-zero dropped; comparison only |
| Secondary outcomes | Five pooled binary outcomes + descriptive table | all included trials; severe-only for new septic shock | Scope decided 10 Nov (A5); rules in `SECONDARY_OUTCOMES_PLAN.md`, not yet built |
| S-noREMAP | F1 without REMAP-CAP | (6) | Also the companion to the REMAP-CAP-harm rung |
| MR | Meta-regressions, one covariate at a time | F1 and F4 | `theta_k = mu + b * x_k + u_k`; covariates in §3.3; centre/scale continuous x; b ~ Normal(0, 1) (29 Oct addition, signed off 10 Nov); fitted only with ≥ 4 trials with data and variation; report b with 95% CrI and say in the text these are across-trial, ecological, and underpowered |

The 29 Oct additions (meta-regression prior, timing coding, pooled-baseline comparison, S-den, S-src) are run, shown in the report and signed off by the lead on 10 Nov (Status item 17).

### 5.5 Quantities to report for every fit

Posterior median OR with 95% CrI (quantile and HDI — state which); P(OR < 1); P(OR < 0.9); P(OR < 1/1.2 = 0.833) (REMAP-CAP's futility threshold, ≥ 20% odds reduction); P(OR > 1); P(OR > 1.1); τ (median, 95% CrI); predictive interval for a new trial (`OR_new`); NNT distribution at baseline risks 10%, 20%, 30% and at the pooled control mortality of the fit (compute it from the control arms of the count trials in that fit); for agent fits, per-cluster OR and P(OR_a < 1); shrunken vs raw per-trial estimates (forest plot with both). Benchmark F1 against Pitre 2025 in one table.

Diagnostics for every fit: R-hat, ESS, divergences, energy; prior-predictive check; posterior-predictive check of per-arm deaths (`r1_rep`, `r0_rep`) as a dot plot of observed vs replicated; LOO-PSIS Pareto k for the count trials (`log_lik` per arm — add to generated quantities when you get to it).

---

## 6. Deliverables and structure

As built (the 29 Oct plan had separate `03_`–`05_` scripts; their content is in `02_fit_primary.R` and `_targets.R`):

```
analysis/
  renv.lock                        pinned packages (R 4.5.1 recorded; outputs of 10 Nov produced under R 4.6.1)
  _targets.R                       single entry point: fit specs (tar_map over F1-F4, D1/D2 variants, ladders,
                                   sensitivity, S-ii), tipping-point grids, LOTO, meta-regressions, tables,
                                   figures, PRISMA, and the Quarto site (tar_quarto)
  R/00_load_data.R                 reads the CSVs, membership checks (§3.1), row selection, Stan data lists
  R/01_simulate.R                  prior-predictive + parameter recovery on simulated data
  R/02_fit_primary.R               sampler wrapper and acceptance rule, summaries, row sets (incl. the D2a swap),
                                   sensitivity variants, S-ii, meta-regression coding, exact LOTO
  R/06_tables_figures.R            forest, PPC, ladder, tipping heat maps, convergence and LOTO figures
  R/07_crosschecks.R               brms cross-checks and the Pitre 2025 benchmark
  stan/hybrid_ma.stan, hybrid_ma_mr.stan, hybrid_ma_pooled.stan
  prisma_flow.R                    draft PRISMA 2020 diagram (report-level counts from the extraction workbook)
  rob2_assessments.csv             RoB 2 by assessor and consensus
  output/tables/*.csv, output/figures/*.png|pdf
  *.qmd, _quarto.yml               Quarto website rendered to ../docs (Home, Methods, Risk of bias, Results,
                                   Priors, Sensitivity, Meta-regression, Checks, Convergence, Benchmark,
                                   Discussion, Limitations); every number is read from the targets store
```

Running it on a new machine:
1. Run `renv::restore()` in `analysis/`.
2. Install CmdStan 2.40.0 with `cmdstanr::install_cmdstan(version = "2.40.0")`.
3. Run `targets::tar_make()`. The full run from an empty store is about 10 minutes (577 targets); after that, only affected targets re-run.
4. Outside RStudio, set `RSTUDIO_PANDOC` to a pandoc directory first; the PRISMA PNG/PDF export needs it.

Figures in `ggplot2`; ORs on a log axis; label trials with `study_label`; mark the contrast-based trial and the subgroup-derived trials visibly in every forest plot. Hand-written statements in the report must be checked against the numbers after every re-run, or replaced by computed text.

---

## 7. Things to say in the report (so the writing matches the analysis)

- The severe-only set is small (7 trials, one of them contrast-based, one a subgroup of a septic-shock trial); the agent hierarchy has two populated clusters and is reported as estimation under shrinkage, explicitly under-powered to confirm or refute an agent effect; agent and trial are confounded (one agent per trial).
- Fernández-Serrano 2011 is in the sensitivity set here although Siemieniuk 2015 / Pitre 2025 counted it as severe; Muhammad 2025 and Sabry 2011 were excluded on study-integrity grounds; Mikami 2007 mortality is treated as not reported, not 0/0.
- Screening was a single AI-assisted pass with a second screener pending. Extraction had a second-extractor numeric check and a row-by-row verification; the database sign-off is incomplete for the subgroup-derived rows and the REMAP-CAP contrasts.
- RoB 2 status:
  - The primary-set trials were rated independently by two assessors: assessor 1 is an AI draft, assessor 2 is M. Annes.
  - They agreed on 5 of 7 overall ratings and 27 of 35 domain ratings.
  - The consensus was recorded on 4 Nov on the lead's decision, without a meeting, and is provisional until the second assessor confirms it.
  - The sensitivity-set trials have only the AI draft.
  - GRADE is not done.
- REMAP-CAP enters short-term fits through its ICU-discharge contrast (D2a). Its result is harm-leaning under a futility rule (< 5% probability of a > 20% reduction in the odds of death), not null.
- Both REMAP-CAP SEs are approximated from the credible intervals until the investigators supply them. Under D2a the SE matters little: F1 P(OR<1) is 0.96 to 0.97 for SE 0.40 to 0.60. Whether REMAP-CAP is included, and through which contrast, matters more: 0.95 with the day-90 contrast, 0.98 without REMAP-CAP.

If anything here conflicts with the protocol or the status document, those win and you should say which clause you followed. Copies travel with this package: `PROSPERO_Protocol_v2.md` (text of `PROSPERO_Protocol_Bayesian_Corticosteroids_sCAP.docx`, v2, 16 Oct 2026, in the Project folder `~/main/Bayesian corticosteroids`) and `Status.md` (updated 10 Nov 2026; a copy is in this repository, keep the two in sync). Precedence: Status.md decisions log (latest entry) > protocol v2 > this file. Ignore any other protocol-like file you find elsewhere in `_extraction/` (`EXTRACTION_SCHEMA.md`, `README_extraction_database.md`, `Extraction_Report_2026-10-22.md` are extraction documents, not the analysis protocol).
