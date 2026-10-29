<!-- Text of PROSPERO_Protocol_Bayesian_Corticosteroids_sCAP.docx (protocol v2, Project folder, 16 Oct 2026; header still reads "prepared 9 July 2026"). Converted to Markdown for the analysis hand-off; the .docx is authoritative. Per Status.md (27 Oct 2026) two additions are still to be written into the registered text: sensitivity fit (ix) short-course <48 h (Marik) and the SONIA agent-mix rule. -->

# PROSPERO Registration — Protocol

**A Bayesian Meta-Analysis of Adjunctive Corticosteroids in Severe Community-Acquired Pneumonia: Mortality, Agent-Level Effects, and a Decision-Focused Prior Ladder**

Registration-ready field template · prepared 9 July 2026 · [DRAFT — complete bracketed admin fields before submission]

*How to use: each numbered heading maps to a field on the PROSPERO online registration form. Paste the text beneath each heading into the corresponding field. Items in [brackets] require author/administrative input. PROSPERO enforces character limits on some fields; a fuller statistical analysis plan can be linked as a repository document where space is tight.*

## 1. Review title
A Bayesian meta-analysis of adjunctive corticosteroids for mortality in severe community-acquired pneumonia: agent-level effects and a decision-focused prior ladder.

## 2. Original language title
[Not applicable — English.]

## 3. Anticipated or actual start date
[27 July 2026] — the date the first database search is run (searches launched in Month 1, week 3–4 of the working plan).

## 4. Anticipated completion date
[31 March 2027] — allowing three months to first full draft (analysis complete ~8 October 2026) plus revision, GRADE, and manuscript finalization.

## 5. Stage of review at time of registration
The review has not yet started. No searches have been run, no records screened, and no data extracted at the time of registration. Protocol and analysis code (brms model skeleton) are drafted and version-controlled.

## 6–14. Named contact, affiliations, team, funding, conflicts, collaborators
[Administrative fields — bracketed in the .docx; not reproduced here.]

## 15. Review question
In adults with severe community-acquired pneumonia (sCAP), does adjunctive systemic corticosteroid therapy, compared with placebo or standard care without corticosteroids, reduce short-term (primarily 28–30 day, and where reported 90-day) all-cause mortality? Secondary questions: (i) does the mortality effect differ by corticosteroid agent (hydrocortisone, methylprednisolone, dexamethasone, prednisone/prednisolone) when modelled with partial pooling; (ii) how robust is the pooled conclusion to a transparent ladder of prior beliefs, from enthusiastic to skeptical to harm-leaning; and (iii) what is the predicted treatment effect for a future trial?

Structured (PICO): Population — adults with severe CAP. Intervention — adjunctive systemic corticosteroids. Comparator — placebo or no corticosteroid. Outcome — all-cause mortality (short-term primary). The review is explicitly decision-focused: it reports posterior probabilities of clinically meaningful benefit at pre-specified thresholds, an NNT distribution, a predictive interval for a new trial, and a prior-ladder tipping-point analysis, rather than a single dichotomized significance verdict.

## 16. Searches
We will search MEDLINE (via PubMed/Ovid), Embase, and the Cochrane Central Register of Controlled Trials (CENTRAL) from inception to the search date, with no language restriction at the search stage. We will also search ClinicalTrials.gov and the WHO ICTRP for completed and ongoing trials, screen reference lists of included studies and of recent relevant systematic reviews (including Pitre et al. 2025 and the Briel 2018 IPD synthesis), and perform forward citation searching of key trials. A full search will incorporate the 2022–2025 trial wave (including REMAP-CAP hydrocortisone and the SONIA/Kenya pragmatic trial). Search strategies combine controlled vocabulary and free-text terms for community-acquired pneumonia AND corticosteroids/glucocorticoids AND a randomized-trial filter. The search will be re-run prior to final analysis to capture newly published trials.

## 17. URL to search strategy
[Insert URL to the full MEDLINE/PubMed strategy in the public code/protocol repository, or paste the strategy here. To be added at registration.]

## 18. Condition or domain being studied
Severe community-acquired pneumonia (sCAP) in adults — acute lower respiratory tract infection acquired outside hospital, meeting a recognized severity definition (e.g., IDSA/ATS major/minor criteria, ICU admission, need for vasopressors or mechanical ventilation, or an equivalent severity threshold). The intervention domain is adjunctive systemic corticosteroid therapy.

## 19. Participants/population
Inclusion: adults (≥16 or ≥18 years, as defined by each trial) hospitalized with community-acquired pneumonia meeting a severe-CAP definition (ICU admission, IDSA/ATS criteria, or comparable severity markers). Where a trial enrolled a broader hospitalized-CAP population, it is eligible for the primary synthesis only if an extractable severe-CAP subgroup (mortality events and denominators by arm) is available; otherwise it is analysed in the all-hospitalized-CAP sensitivity set (see fields 22 and 29). Exclusion: paediatric-only populations; pneumonia from COVID-19 as the primary indication (distinct evidence base); Pneumocystis, aspiration, or chemical pneumonitis; corticosteroids given for an unrelated concurrent indication; and trials with no severe subgroup and no extractable severe data.

*SONIA/Kenya decision (peer review §3.3, resolved): SONIA enrolled general hospitalized CAP and enters the PRIMARY synthesis only if a severe subgroup is extractable; otherwise it is confined to the all-hospitalized sensitivity analysis. This is stated explicitly here to align inclusion criteria with the severe-only PICO.*

## 20. Intervention(s), exposure(s)
Adjunctive systemic (intravenous or oral) corticosteroid therapy given in addition to standard antimicrobial and supportive care for sCAP. Any agent, dose, and duration is eligible: hydrocortisone, methylprednisolone, dexamethasone, and prednisone/prednisolone are the anticipated agent clusters. Doses will be converted to prednisone-equivalents using a pre-specified, cited potency table; the conversion table and the known limitations (approximate potency ratios, differing mineralocorticoid activity, and dose–agent collinearity) will be documented and dose treated only as an exploratory across-trial covariate.

## 21. Comparator(s)/control
Placebo or standard care without adjunctive systemic corticosteroids. Trials with an active corticosteroid comparator in both arms (head-to-head with no steroid-free control) are not eligible for the primary mortality contrast.

## 22. Types of study to be included
Randomized controlled trials (including cluster-randomized and response-adaptive platform trials such as REMAP-CAP). Because included trials differ in how they report, a pre-specified hybrid likelihood is used (see field 28): trials reporting simple arm-level 2×2 counts enter through an exact binomial one-stage model; trials whose valid estimate is a covariate-adjusted or adaptive-design contrast (notably REMAP-CAP) enter through a contrast-based (log-OR + standard error) arm. This is a primary-analysis rule, not a sensitivity cross-check. Non-randomized studies, observational cohorts, case series, and conference abstracts without extractable randomized data are excluded from the primary synthesis.

## 23. Context
Adults hospitalized with severe CAP, in intensive care or high-dependency settings across high- and (for the sensitivity set) low-resource healthcare systems. The review updates the evidence base with the 2022–2025 trial wave and is framed to inform bedside and guideline decisions about whether, and with which agent, to give adjunctive corticosteroids in sCAP.

## 24. Main outcome(s)
Short-term all-cause mortality — the earliest of in-hospital, 28-day, or 30-day mortality as reported by each trial (the primary timepoint). Where trials report 90-day mortality (e.g., REMAP-CAP), that timepoint is analysed as a co-primary/secondary mortality outcome and kept distinct in the model. Effect measure: odds ratio (mortality), summarized as a posterior distribution with 95% credible interval, posterior probability of any benefit (OR<1), and posterior probability of clinically meaningful benefit at pre-specified thresholds, plus a distribution of the number-needed-to-treat and a predictive interval for a future trial.

*Measures of effect: odds ratio (primary). Timing: short-term (in-hospital/28–30 day) primary; 90-day where reported, kept as a separate timepoint rather than pooled across horizons.*

## 25. Additional outcome(s)
Secondary outcomes, where reported: (i) need for and duration of invasive mechanical ventilation; (ii) ICU and hospital length of stay; (iii) time to clinical stability; (iv) treatment failure / progression to shock; (v) harms of corticosteroids — hyperglycaemia requiring treatment, gastrointestinal bleeding, secondary/nosocomial infection, and neuromuscular weakness. Secondary outcomes are summarized descriptively and, where data permit, with the same Bayesian framework; they are not used to override the primary mortality conclusion. Influenza/viral co-infection status is pre-specified as a potential effect modifier on mortality (see field 29).

## 26. Data extraction (selection and coding)
Records are de-duplicated and screened by title/abstract, then full text, independently and in duplicate by two reviewers, with disagreements resolved by discussion or a third reviewer; the process is reported in a PRISMA 2020 flow diagram. Two reviewers independently extract data into a piloted, locked extraction template: study identifiers, design, setting/resource level, severity definition, population characteristics (including age and influenza/viral prevalence where available), corticosteroid agent, dose (converted to prednisone-equivalents), timing relative to admission, duration, arm-level mortality events and denominators at each reported timepoint, and — for trials reporting adjusted or adaptive estimates — the adjusted log-OR and its standard error with the adjustment model. Discrepancies are reconciled against the source. For REMAP-CAP and any adaptive/adjusted trial, the adjusted contrast and its SE are extracted (crude arm counts are recorded but not used as the primary input for that trial). Study authors are contacted for missing severe-subgroup data where a broader-CAP trial might qualify for the primary synthesis.

## 27. Risk of bias (quality) assessment
Risk of bias is assessed independently and in duplicate with the Cochrane RoB 2 tool for randomized trials, across the five domains (randomization, deviations from intended interventions, missing outcome data, measurement of the outcome, and selection of the reported result), with an overall judgement per trial for the mortality outcome. Open-label trials (e.g., pragmatic designs) are flagged for performance/detection bias on subjective secondary outcomes, though all-cause mortality is objective. Small and heterogeneously reported inventory trials are scrutinized for indexing, severe-CAP eligibility, and reporting completeness. Risk-of-bias judgements inform a pre-specified sensitivity analysis restricted to low-risk trials and feed the GRADE certainty assessment.

## 28. Strategy for data synthesis
Synthesis is Bayesian throughout, implemented in R with brms/Stan; code is version-controlled and public. The core model is a one-stage random-effects meta-analysis of the mortality odds ratio with a pre-specified HYBRID LIKELIHOOD: an exact binomial likelihood on arm-level 2×2 counts for trials reporting simple counts (avoiding the normal approximation and continuity corrections for sparse/zero-event arms), and a contrast-based normal–normal likelihood (log-OR + SE) for trials whose valid estimate is adjusted or adaptive (REMAP-CAP). Trial-specific baseline (control) log-odds are treated as unpooled fixed effects (Senn), rather than assuming exchangeable baseline risks across heterogeneous settings. Between-trial heterogeneity uses a weakly-informative half-Normal prior on the between-study SD (τ); a prior-sensitivity check on τ is reported.

Agent-level structure: a hierarchical (partial-pooling) layer places trial treatment effects within agent clusters (hydrocortisone, methylprednisolone, dexamethasone, prednisone/prednisolone) with a between-agent SD (ω). Because ω is estimated from only three to four clusters, some represented by a single trial, a regularizing, explicitly-justified half-Normal prior is placed on ω and a prior-sensitivity check is run; the agent analysis is framed as estimation under strong shrinkage, explicitly under-powered to confirm or refute a true agent effect, and we note that agent and study effects are partially confounded because each trial uses essentially one agent.

Decision-focused prior ladder: the primary pooled effect is reported under a transparent ladder of priors on the mean log-OR, each labelled with the belief or trial that motivates its centre — an enthusiastic (pro-benefit) rung, a reference/weakly-informative rung, a skeptical (mean-zero) rung, a MILD HARM-LEANING rung [Normal(log 1.10, 0.20); a modest general prior toward harm, not tied to any trial], and a REMAP-CAP HARM rung [Normal(log 1.5, 0.35); centred on the REMAP-CAP hydrocortisone adjusted OR ≈1.5, with SD calibrated so the implied probability of harm (~88%) reproduces REMAP-CAP's reported 84–91% posterior probability of harm]. A tipping-point analysis reports how much prior skepticism (and, on a 2-D surface, how much shift of the prior centre toward harm) is required to overturn a benefit conclusion.

Reporting: for each prior we report the posterior OR with 95% credible interval, the posterior probability of any benefit and of clinically meaningful benefit at pre-specified thresholds (e.g., ≥10% and ≥20% relative mortality reduction, mirroring REMAP-CAP's futility threshold), an NNT distribution, and a posterior-predictive interval for a future trial. Convergence and fit are checked with R-hat, effective sample size, divergences, and prior- and posterior-predictive checks. As a face-validity benchmark, the pooled estimate is compared against Pitre et al. (2025).

## 29. Analysis of subgroups or subsets
Pre-specified, exploratory, one-covariate-at-a-time meta-regressions (aggregate/across-trial level, interpreted with ecological-bias caution): severity of pneumonia; corticosteroid agent (also handled by the hierarchy); prednisone-equivalent dose; timing of initiation; care setting/resource level; and influenza/viral co-infection prevalence (a plausible effect modifier, added explicitly). Pre-specified sensitivity analyses: (i) severe-only primary set versus an all-hospitalized-CAP set that adds broader-population trials — SONIA/Kenya enters the primary set only if a severe subgroup is extractable, otherwise only here; (ii) exclusion of high-risk-of-bias trials; (iii) the contrast-based likelihood applied to all trials as a cross-check on the hybrid; (iv) alternative τ and ω priors; and (v) a tighter weakly-informative baseline prior [Normal(0, 1.5–2.5)] versus the diffuse baseline. Subgroup/covariate findings are reported as exploratory and across-trial, not patient-level.

## 30. Type and method of review
Systematic review with Bayesian meta-analysis (aggregate-data, one-stage, random-effects) including hierarchical agent-level modelling, meta-regression, and a decision-analytic prior-ladder/tipping-point layer.

## 31–36. Language, country, other registration details, protocol URL, dissemination, keywords
English (no language restriction at the search stage). [Country/registration/URL bracketed in the .docx.] Dissemination: peer-reviewed publication, postgraduate thesis, and a public reproducibility package (Quarto report, data, and Stan/brms code). Keywords: community-acquired pneumonia; severe pneumonia; corticosteroids; glucocorticoids; hydrocortisone; dexamethasone; methylprednisolone; mortality; Bayesian meta-analysis; hierarchical model; prior sensitivity; REMAP-CAP.

## 37. Details of any existing review of the same topic by the same authors
[None, or cite. Note the relationship to recent syntheses by other groups: Pitre et al. (2025) Bayesian meta-analysis/dose–response, and Briel et al. (2018) IPD synthesis — the marginal contribution of this review over Pitre 2025 is the inclusion of REMAP-CAP and SONIA, the shrinkage-based agent hierarchy, and the prior-ladder/tipping-point decision layer.]

## 38. Current review status
Ongoing — the review has not yet started (registration precedes screening). [To be reworded before submission: screening and a first extraction pass have begun — Status.md item 5.]

## 39. Any additional information
The review's distinctive contributions are: (i) currency, incorporating the 2022–2025 trial wave; (ii) an agent-level partial-pooling hierarchy replacing naive subgrouping, framed honestly as under-powered estimation under shrinkage; and (iii) a decision-focused prior ladder with tipping-point analysis. REMAP-CAP is characterized accurately: its day-90 hydrocortisone result favoured harm (adjusted OR ≈1.5; 84–91% posterior probability of harm), and enrolment stopped under a futility rule defined as <5% probability of a >20% relative mortality reduction — not because the effect was null. This motivates both the dedicated REMAP-CAP-harm prior rung and the contrast-based likelihood arm for that trial.

## 40. Details of final report/publication(s)
[To be completed on review completion.]
