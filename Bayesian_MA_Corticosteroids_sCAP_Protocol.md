# Protocol — Bayesian Meta-Analysis of Adjunctive Corticosteroids in Severe Community-Acquired Pneumonia

**A decision-focused Bayesian re-analysis incorporating the 2022–2025 trial wave, agent-level hierarchy, and formal prior-sensitivity analysis**


---

## 1. Rationale and positioning

Adjunctive corticosteroids in severe community-acquired pneumonia (sCAP) are a textbook case of conflicting randomized evidence. CAPE COD (Dequin, NEJM 2023) showed a 28-day mortality reduction with hydrocortisone; ESCAPe (Meduri, ICM 2022) found no 60-day mortality benefit with prolonged methylprednisolone; the REMAP-CAP hydrocortisone domain (Heming, ICM 2025) stopped for futility with the posterior odds ratio crossing 1 and a low probability of meaningful benefit; and a large pragmatic trial in Kenya (Lucinde, NEJM 2025) found a mortality reduction in a low-resource setting. Earlier trials (Confalonieri 2005, Torres 2015) and an individual-patient-data synthesis (Briel, CID 2018) frame the prior evidence.

A frequentist random-effects synthesis of this literature has been performed repeatedly, and at least two prior Bayesian meta-analyses exist (Chua, Ann Acad Med Singapore 2024; Pitre, ICM 2025). **This protocol is therefore deliberately scoped to the three questions those analyses leave open:**

1. **Currency.** Existing Bayesian syntheses predate REMAP-CAP and the Kenya pragmatic trial — the two results that most sharpen the controversy. We incorporate the complete 2022–2025 wave.
2. **The agent paradox.** Subgroup analyses repeatedly suggest hydrocortisone benefits while methylprednisolone/dexamethasone do not, but naive subgrouping cannot separate a true agent effect from confounding by dose, timing, and severity. We model corticosteroid agent as a *hierarchical* stratum with partial pooling rather than as fixed subgroups.
3. **Decision relevance.** No prior analysis reports a transparent ladder of priors (from enthusiastic to skeptical to harm-leaning) with the posterior probability of clinically meaningful benefit and a **tipping-point analysis** quantifying how skeptical a prior must be before the benefit disappears.

The deliverable is a synthesis that produces direct probability statements a clinician can use ("the probability that hydrocortisone reduces 30-day mortality by at least 1 absolute percentage point is X%"), a predictive distribution for a future trial, and an explicit account of how robust those statements are to prior beliefs.

## 2. Objectives

**Primary.** To estimate the effect of adjunctive systemic corticosteroids versus standard care/placebo on short-term all-cause mortality in adults with severe CAP, expressed as a posterior distribution and summarized by the posterior probability of benefit at pre-specified clinically meaningful thresholds.

**Secondary.**
- Quantify between-agent heterogeneity (hydrocortisone vs methylprednisolone vs dexamethasone vs prednisone/prednisolone) via a hierarchical agent model with partial pooling.
- Estimate effects on long-term (60–90 day) mortality, invasive mechanical ventilation, ICU admission, time to clinical stability, hospital and ICU length of stay, and key harms (hyperglycaemia requiring intervention, gastrointestinal bleeding, secondary infection).
- Characterize effect modification by severity stratum, prednisone-equivalent dose, timing of initiation, and care setting (high-income vs low-resource), each pre-specified and analysed one covariate at a time.
- Produce a predictive distribution for the treatment effect in a future trial/setting, and a tipping-point analysis over the prior space.

## 3. Review question (PICO)

- **Population.** Hospitalized adults (≥18 y) with severe CAP. *Severe* defined by the trial's own enrolment criterion mapped to a harmonized definition: ICU admission, IDSA/ATS major/minor-criteria severity, CURB-65 ≥3 / PSI IV–V, or need for respiratory/vasopressor support. Trials of unselected hospitalized CAP are included only if a severe subgroup can be extracted; otherwise reserved for a sensitivity analysis. COVID-19, *Pneumocystis*, and trials confined to viral/influenza pneumonia are excluded; influenza co-infection within bacterial-predominant sCAP trials is retained and recorded as a modifier.
- **Intervention.** Any systemic (IV/oral) corticosteroid as adjunct to antibiotics, any agent/dose/duration, initiated within 96 h of presentation.
- **Comparator.** Placebo or standard care without corticosteroid.
- **Outcomes.** Primary: short-term all-cause mortality (28–30 day preferred; in-hospital if 28–30 d unavailable — hierarchy pre-specified). Secondary as in §2.
- **Study design.** Randomized controlled trials, including adaptive-platform domains (e.g., REMAP-CAP) and pragmatic open-label trials. Observational studies excluded from the primary synthesis.

## 4. Information sources and search

MEDLINE (PubMed), Embase, Cochrane CENTRAL, Web of Science, and Scopus from inception; ClinicalTrials.gov and WHO ICTRP for unpublished/ongoing trials; forward/backward citation chasing of included trials and of the six prior meta-analyses; contact with authors for severe-subgroup data where needed. No language restriction (translation for non-English reports). Search strings combining controlled vocabulary and free text for *community-acquired pneumonia*, *corticosteroid / glucocorticoid / hydrocortisone / methylprednisolone / dexamethasone / prednisone*, and an RCT filter. A draft PubMed strategy is appended (§12) for the information specialist to peer-review (PRESS).

## 5. Selection and data extraction

Two reviewers screen titles/abstracts then full texts independently in Covidence (or Rayyan); disagreements resolved by the supervisor. PRISMA 2020 flow diagram. Duplicate independent extraction into a piloted form capturing: trial identifiers, severity definition and case mix, agent, prednisone-equivalent total and daily dose, timing of initiation, duration/taper, antibiotic co-treatment (incl. macrolide use), baseline mortality risk, events and denominators per arm for each outcome, follow-up windows, and funding/conflicts. Prednisone-equivalent conversion documented in a standard table.

## 6. Risk of bias and certainty

Cochrane RoB 2 per outcome (open-label pragmatic trials flagged for performance/detection bias on subjective outcomes; mortality is objective). Certainty assessed with GRADE, adapted for the Bayesian framework by reporting how rating decisions (imprecision in particular) map onto posterior probability statements rather than p-values. Small-study effects examined visually and, given the modest k, interpreted cautiously rather than via formal regression-based tests.

## 7. Statistical analysis

All analyses in R (≥4.3) with `brms` (Stan backend); `metafor` for frequentist sensitivity checks; `cmdstanr` recommended for speed/diagnostics. Pre-registered code repository (GitHub) with a Quarto reproducible report.

### 7.1 Likelihood and base model

We avoid normal approximations to the log-OR (several trials have few deaths). We fit a **one-stage binomial–normal hierarchical model** on arm-level counts with exact binomial likelihood.

For trial *i*, arm *j*, with deaths `y_ij` of `n_ij`:

```
y_ij ~ Binomial(n_ij, p_ij)
logit(p_ij) = α_i + θ_i · (trt_ij − 0.5)
θ_i ~ Normal(d, τ²)
```

- `α_i`: trial-specific baseline log-odds, estimated as **fixed** effects (study as a factor, no pooling of baselines — Senn's recommendation; avoids assuming exchangeable control risks across heterogeneous settings).
- `θ_i`: trial-specific log-OR of corticosteroid vs control; treatment centred at ±0.5 for a stable baseline interpretation.
- `d`: pooled mean log-OR (primary estimand).
- `τ`: between-trial SD (heterogeneity).

**Heterogeneity prior.** `τ ~ Half-Normal(0, 0.5)` as primary (weakly informative, places ~95% mass on τ < 1, i.e. excludes implausibly extreme heterogeneity on the log-OR scale); `τ ~ Half-Cauchy(0, 0.5)` and an empirical log-OR heterogeneity prior (Turner/Rhodes distributions for an all-cause mortality, pharmacological-vs-placebo setting) as sensitivity.

`brms` skeleton:

```r
library(brms)
df$trt_c <- df$trt - 0.5   # arm-level long data: study, agent, events, n, trt(0/1), covariates

f_base <- bf(events | trials(n) ~ 0 + factor(study) + trt_c + (0 + trt_c | study))

fit_base <- brm(
  f_base, data = df, family = binomial("logit"),
  prior = c(
    prior(normal(0, 10),    class = "b", coef = "factorstudy..."),  # vague baselines
    prior(normal(0, 0.355), class = "b", coef = "trt_c"),           # PRIMARY: skeptical (see ladder)
    prior(normal(0, 0.5),   class = "sd")                           # tau ~ Half-Normal(0,0.5)
  ),
  chains = 4, iter = 4000, warmup = 1000, seed = 1,
  control = list(adapt_delta = 0.99, max_treedepth = 12)
)
```

Convergence: R-hat < 1.01 on all parameters, bulk/tail ESS > 1000, zero post-warmup divergences, energy/BFMI checks. Posterior predictive checks against observed arm-level death proportions.

### 7.2 The prior ladder (core of the contribution)

The pooled effect `d` is fit under a transparent, pre-specified ladder of priors on the **OR scale**. The skeptical prior is primary; the rest are reported side by side.

| Prior | Specification (log-OR) | Implied 95% prior interval for OR | Interpretation |
|---|---|---|---|
| Reference / vague | Normal(0, 2.82) | ~0.004–250 | Minimal information |
| **Skeptical (primary)** | **Normal(0, 0.355)** | **~0.50–2.0** | A priori unlikely the OR is beyond a halving/doubling |
| Strongly skeptical | Normal(0, 0.18) | ~0.70–1.42 | Demands strong data to move |
| Enthusiastic | Normal(log 0.80, 0.20) | ~0.54–1.18 | Centred on CAPE COD–scale benefit |
| Harm-leaning | Normal(log 1.10, 0.20) | ~0.74–1.63 | Centred on the REMAP-CAP signal |
| Evidence-based (dynamic) | Posterior from pre-2022 IPD (Briel 2018) used as the prior, updated with the 2022–2025 trials | — | Sequential Bayesian updating; visualizes how the new wave shifts belief |

The evidence-based/dynamic prior is a clean narrative device: it shows precisely how REMAP-CAP, CAPE COD, ESCAPe, and the Kenya trial move the posterior off the prior established by the older literature.

### 7.3 Decision summaries

From posterior draws of `d`, report on OR, RR, and absolute scales (RR/ARR computed at a pre-specified baseline severe-CAP mortality, e.g. 10–12%, with sensitivity at 6% and 18%):

- Posterior median and 95% credible interval.
- **P(OR < 1)** — any benefit.
- **P(OR < 0.90)** and **P(OR < 0.82)** — clinically meaningful / guideline-relevant benefit.
- **P(OR > 1)** and **P(OR > 1.10)** — any / meaningful harm.
- **P(absolute risk reduction > 1%)** and implied NNT distribution.
- **Predictive interval** for `θ_new` in a future trial (`posterior_predict` with `allow_new_levels = TRUE, sample_new_levels = "gaussian"`), distinguishing the *mean* effect from the effect *one would expect in a new setting*.

### 7.4 Tipping-point (prior-threshold) analysis

Sweep the skeptical-prior SD continuously and locate the threshold at which (a) the posterior median crosses OR = 0.90 and (b) P(OR < 1) falls below 0.975. This answers the decision-maker's real question — *how much disbelief does it take to overturn the result?* — and is the analysis no existing synthesis reports.

### 7.5 Agent-level hierarchical model (the paradox)

To address hydrocortisone-vs-other without naive subgrouping, add a hierarchy over agents so that agent-specific effects are partially pooled toward the overall mean (shrinkage proportional to within-agent information):

```
θ_i ~ Normal(d_{agent(i)}, τ²)
d_{agent} ~ Normal(D, ω²)
```

```r
f_agent <- bf(events | trials(n) ~ 0 + factor(study) + trt_c +
                (0 + trt_c | agent) + (0 + trt_c | study))
```

Report each agent's posterior effect, the between-agent SD `ω` (is the agent signal real or shrinks to near-zero?), and the posterior probability that hydrocortisone's effect is more favourable than the others'. This reframes "hydrocortisone is special" as a quantified, shrinkage-corrected claim rather than a subgroup artefact.

### 7.6 Meta-regression (effect modification)

Given the modest number of trials, covariates are entered **one at a time**, pre-specified, and interpreted as exploratory:

- Severity stratum (ICU vs ward-level severe).
- Prednisone-equivalent daily dose (linear; a monotonic/spline form only if k permits — the dose–response signal around ~6 mg dexamethasone-equivalent from Pitre 2023/2025 is worth probing).
- Timing of initiation.
- Care setting (high-income vs low-resource), motivated directly by the Kenya result.

### 7.7 Sensitivity and secondary analyses

- Broaden inclusion to all hospitalized CAP (vs the severe-only primary set).
- Alternative heterogeneity priors (§7.1).
- Leave-one-out, with explicit attention to CAPE COD and REMAP-CAP as the two most influential trials.
- Contrast-based normal–normal model with continuity handling as a cross-check on the binomial model.
- Frequentist random-effects (REML, Hartung–Knapp) reported alongside for readers anchored to that framework.

## 8. Reporting

PRISMA 2020. Bayesian analyses reported per current Bayesian-reporting guidance: full prior specification and justification, software/sampler settings, convergence diagnostics, and posteriors summarized as probability statements rather than dichotomized "significance." Posterior and predictive distributions shown graphically; all priors visualized.

## 9. Registration, ethics, data

PROSPERO registration before screening begins. No ethics approval required (published aggregate data; author contact for severe-subgroup counts only). Data and code deposited publicly (OSF/GitHub) for reproducibility.

## 10. Feasibility note (from scoping)

A focused scoping search confirms an extractable severe-CAP RCT base on the order of 10–15 trials, with the pivotal recent results (CAPE COD 2023, ESCAPe 2022, REMAP-CAP hydrocortisone 2025, Kenya pragmatic 2025) all identified and reporting the primary mortality outcome. This is well-matched to a single 6th-year student over a thesis cycle: the screening volume is manageable, the model is a standard hierarchical binomial fit, and the novel contribution (currency + agent hierarchy + prior ladder/tipping-point) is achievable without individual-patient data — though author-supplied severe-subgroup counts would strengthen it.

## 11. Indicative timeline (- Dont pay attention to this-we Will compress it to be ready by December)

1. **Month 1** — Finalize protocol, PROSPERO registration, search build and peer-review, run searches.
2. **Month 2** — Title/abstract and full-text screening; begin extraction.
3. **Month 3** — Complete extraction, RoB 2, prednisone-equivalent harmonization, build analysis dataset.
4. **Month 4** — Base model + prior ladder + decision summaries; convergence/PPC.
5. **Month 5** — Agent hierarchy, meta-regression, tipping-point, sensitivity analyses; figures.
6. **Month 6** — GRADE, manuscript/thesis drafting, internal review.

## 12. Appendix — draft PubMed strategy (to be peer-reviewed)

```
("community-acquired pneumonia"[tiab] OR "community acquired pneumonia"[tiab]
   OR (pneumonia[mesh] AND community[tiab]))
AND
(corticosteroid*[tiab] OR glucocorticoid*[tiab] OR steroid*[tiab]
   OR hydrocortisone[tiab] OR methylprednisolone[tiab] OR dexamethasone[tiab]
   OR prednisone[tiab] OR prednisolone[tiab] OR adrenal cortex hormones[mesh])
AND
(randomized controlled trial[pt] OR randomised[tiab] OR randomized[tiab]
   OR placebo[tiab] OR "controlled trial"[tiab])
```

---

### Candidate trial inventory (illustrative — final set follows the formal search)

| Trial | Year | Agent | Severe-CAP population | Primary mortality finding |
|---|---|---|---|---|
| Confalonieri | 2005 | Hydrocortisone (infusion) | ICU sCAP | Lower mortality |
| Torres | 2015 | Methylprednisolone | sCAP + high CRP | Treatment failure ↓; mortality NS |
| Meduri (ESCAPe) | 2022 | Methylprednisolone (prolonged) | ICU/ward sCAP (VA) | 60-day mortality NS |
| Dequin (CAPE COD) | 2023 | Hydrocortisone | ICU sCAP | 28-day mortality ↓ |
| Heming (REMAP-CAP domain) | 2025 | Hydrocortisone (fixed 7-day) | ICU sCAP | Futility; 90-day OR crosses 1 |
| Lucinde (Kenya pragmatic) | 2025 | Oral low-dose glucocorticoid | Hospitalized CAP, low-resource | 30-day mortality ↓ |
| Nafae | 2013 | (mixed) | sCAP | Reported benefit |
| Wafy/El-Naser | 2021 | Systemic steroid | ICU sCAP | Mortality ↓ (small) |
| Li | 2016 | Methylprednisolone | sCAP + septic shock | Mortality NS |
| Maharjan | 2018 | Corticosteroid adjunct | sCAP (PSI IV–V) | No benefit |
| Singh | 2024 | Methylprednisolone | sCAP + high inflam. | Outcomes NS |

*NS = not statistically significant in the source trial.*
