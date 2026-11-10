# Checklist: verifying the Pitre 2025 values (Status.md item 18)

**Paper:** Pitre et al., *Intensive Care Med* 2025;51:917-929, DOI 10.1007/s00134-025-07912-2 (open access; supplement `134_2025_7912_MOESM1_ESM.docx`). **Our copy of the values:** `analysis/pitre2025_reported.csv` (43 rows below, in file order). **Date prepared:** 10 Nov 2026.

**How to check.** For each row, open the location given, compare value and interval with the paper, then tick the box. Write the page (or figure panel) in *Page*. If the paper disagrees, write the paper's value in *Notes*; do not edit the CSV. **Fig** = our value was read by eye from a figure image, so check it most carefully (to two decimals; say if the figure is too small to read). **Site** = the value is quoted on the Benchmark or Discussion page.

| # | Quantity | Our value | Source location | Flag | Page | OK | Notes |
|---|---|---|---|---|---|---|---|
| 1 | n trials total | 30 | Abstract |  | Abstract; Results (main text) | ☑ | |
| 2 | n patients total | 7519 | Abstract |  | Abstract; Results (main text) | ☑ | |
| 3 | short term mortality n trials | 29 | Results (All-cause mortality) / Table 2 | Site | Results, All-cause mortality; Table 2 | ☑ | |
| 4 | short term mortality n patients | 7494 | Results (All-cause mortality) / Table 2 |  | Results, All-cause mortality; Table 2 | ☑ | |
| 5 | short term mortality events | 1185 | Results (All-cause mortality) |  | Results, All-cause mortality; Table 2 | ☑ | |
| 6 | short term mortality RR | 0.82 (0.74 to 0.91) | Abstract / Table 2 | Site | Abstract; Table 2 | ☑ | |
| 7 | control risk per 1000 | 175 | Table 2 | Site | Table 2; Methods (median standard-care risk) | ☑ | |
| 8 | absolute effect per 1000 | -31 (-45 to -16) | Table 2 | Site | Table 2 | ☑ | |
| 9 | long term mortality RR | 0.89 (0.76 to 1.03) | Abstract |  | Abstract; Table 2 | ☑ | Abstract says 60–90 d; Table 2 says 90–180 d (4363 pts, 10 RCTs, control 278/1000). Value matches the abstract |
| 10 | bayes P OR lt 0.9 short term | 0.868 | Results (Subgroups and sensitivity analyses) | Site | Results, Subgroups and sensitivity analyses | ☑ | |
| 11 | bayes P OR lt 0.9 long term | 0.787 | Results (Subgroups and sensitivity analyses) |  | Results, Subgroups and sensitivity analyses | ☑ | Main text 78.7%; supplement gives 0.7802 (row 25). Paper is internally inconsistent |
| 12 | dose response best dose mg day prednisone equiv | 60 | Results |  | Results (dose-response); Suppl. p24 Table S20 | ☑ | |
| 13 | dose response RR at best dose | 0.78 (0.68 to 0.89) | Results |  | Results (dose-response); Suppl. p24 Table S20 | ☑ | |
| 14 | n trials severe CAP | 22 | Trial characteristics |  | Results (trial characteristics) | ☑ | |
| 15 | n patients severe CAP | 4730 | Trial characteristics |  | Results (trial characteristics) | ☑ | |
| 16 | bayes model | (text) | Supplement Table S2 |  | Suppl. p6, Table S2 (formulas are images) | ☑ | Formulas confirm OR = ratio of event proportions, SE = log-OR SE |
| 17 | bayes effect definition note | (text) | Supplement Table S2 |  | Suppl. p6, Table S2 (formulas are images) | ☑ | Formulas confirm OR = ratio of event proportions, SE = log-OR SE |
| 18 | bayes P OR lt 1 short term | 0.995 | Supplement Figure S25 (a table) | Site | Suppl. p29, heading 'Figure S25' (a table) | ☑ | Supplement calls it Figure S25; we call it Table S25 |
| 19 | bayes P OR gt 1 short term | 0.004 | Supplement Figure S25 (a table) |  | Suppl. p29, heading 'Figure S25' (a table) | ☑ | Supplement calls it Figure S25; we call it Table S25 |
| 20 | bayes P OR gt 1.11 short term | 0.0 | Supplement Figure S25 (a table) |  | Suppl. p29, heading 'Figure S25' (a table) | ☑ | Supplement calls it Figure S25; we call it Table S25 |
| 21 | bayes P OR lt 0.8 short term | 0.281 | Supplement Figure S25 (a table) |  | Suppl. p29, heading 'Figure S25' (a table) | ☑ | Supplement calls it Figure S25; we call it Table S25 |
| 22 | bayes P OR gt 1.25 short term | 0.0 | Supplement Figure S25 (a table) |  | Suppl. p29, heading 'Figure S25' (a table) | ☑ | Supplement calls it Figure S25; we call it Table S25 |
| 23 | bayes P OR lt 1 long term | 0.9842 | Supplement Figure S25 (a table) |  | Suppl. p29, heading 'Figure S25' (a table) | ☑ | Supplement calls it Figure S25; we call it Table S25 |
| 24 | bayes P OR gt 1 long term | 0.0158 | Supplement Figure S25 (a table) |  | Suppl. p29, heading 'Figure S25' (a table) | ☑ | Supplement calls it Figure S25; we call it Table S25 |
| 25 | bayes P OR lt 0.9 long term supplement | 0.7802 | Supplement Figure S25 (a table) |  | Suppl. p29, heading 'Figure S25' (a table) | ☑ | Supplement calls it Figure S25; we call it Table S25 |
| 26 | bayes P OR lt 0.8 long term | 0.2106 | Supplement Figure S25 (a table) |  | Suppl. p29, heading 'Figure S25' (a table) | ☑ | Supplement calls it Figure S25; we call it Table S25 |
| 27 | overall I2 percent | 4.09 | Supplement Figures S18-S24 (random-effects REML) | Fig | Suppl. Figures S21 p25, S22 p26, S24 p28 (Overall) | ☑ | Fig: tau2 0.00, Q(30)=35.70, p=0.22, 31 estimates |
| 28 | stratum pneumonia RR remap as ards | 0.75 (0.59 to 0.95) | Supplement Figure S22 | Fig Site | Suppl. p26, Figure S22 | ☑ | Fig: group-difference p=0.67, as in our CSV note |
| 29 | stratum pneumonia RR remap as pneumonia | 0.79 (0.62 to 1.01) | Supplement Figure S21 | Fig Site | Suppl. p25, Figure S21 | ☑ | Fig: group-difference p=0.59 |
| 30 | stratum ards RR remap as ards | 0.77 (0.52 to 1.13) | Supplement Figure S22 | Fig | Suppl. p26, Figure S22 | ☑ | Fig |
| 31 | stratum sepsis RR | 0.84 (0.74 to 0.96) | Supplement Figures S21-S22 | Fig | Suppl. p25-26, Figures S21/S22 | ☑ | Fig: identical in both |
| 32 | molecule hydrocortisone RR | 0.66 (0.43 to 1.01) | Supplement Figure S18 | Fig Site | Suppl. p22, Figure S18 | ☑ | Fig |
| 33 | molecule methylprednisolone RR | 0.88 (0.64 to 1.22) | Supplement Figure S18 | Fig | Suppl. p22, Figure S18 | ☑ | Fig |
| 34 | molecule dexamethasone RR | 0.69 (0.43 to 1.1) | Supplement Figure S18 | Fig | Suppl. p22, Figure S18 | ☑ | Fig |
| 35 | molecule prednisolone RR | 1.05 (0.76 to 1.45) | Supplement Figure S18 | Fig | Suppl. p22, Figure S18 | ☑ | Fig |
| 36 | molecule overall RR | 0.8 (0.67 to 0.96) | Supplement Figure S18 | Fig Site | Suppl. p22, Figure S18 | ☑ | Fig |
| 37 | rob high RR | 0.71 (0.46 to 1.1) | Supplement Figure S24 | Fig Site | Suppl. p28, Figure S24 | ☑ | Fig: group-difference p=0.59 |
| 38 | rob low RR | 0.8 (0.71 to 0.91) | Supplement Figure S24 | Fig Site | Suppl. p28, Figure S24 | ☑ | Fig: group-difference p=0.59 |
| 39 | dose response RR at 20 mg day | 0.92 (0.8 to 1.05) | Supplement Table S20 |  | Suppl. p24, Table S20 | ☑ | |
| 40 | dose response RR at 40 mg day | 0.84 (0.73 to 0.97) | Supplement Table S20 |  | Suppl. p24, Table S20 | ☑ | |
| 41 | dose response RR at 60 mg day | 0.78 (0.68 to 0.89) | Supplement Table S20 |  | Suppl. p24, Table S20 | ☑ | |
| 42 | dose response RR at 80 mg day | 0.71 (0.54 to 0.95) | Supplement Table S20 |  | Suppl. p24, Table S20 | ☑ | |
| 43 | dose response RR at 100 mg day | 0.66 (0.41 to 1.05) | Supplement Table S20 | Site | Suppl. p24, Table S20 | ☑ | |

**Extra items in the same pass**

- Rows 16 and 17 are text: check that Table S2 gives a common-effect normal model on the log scale, vague Normal(0, precision 0.0001) prior, no between-trial variance, rjags 3 chains, 1000 burn-in, 10000 samples, zero-event trials dropped, and that it defines OR as the ratio of event proportions while using a log-OR standard error. Our argument on the Benchmark page depends on this.
- Row 25 (0.7802, Table S25) differs from the 78.7% in the main text (row 11): confirm which the supplement gives.
- Rows 12 and 13 vs row 41: the best dose (60 mg/day) and its RR 0.78 (0.68 to 0.89) should match Table S20.
- Separate file `analysis/pitre2025_trials.csv` (21 trial rows, Figure S22 counts, not in the 43 above): check the three differences already resolved (Confalonieri control 22, ESCAPe 297/287, Nafae 20) and tick the remaining rows against Figure S22.

**Result of the check (10 Nov 2026, by the assistant, not yet by the student).** All 43 rows were compared with the PMC full text (PMC13508155, fetched through NCBI) and the supplement (`134_2025_7912_MOESM1_ESM.docx`; figure images viewed directly, values read to two decimals). **No value mismatches.** ☑ means the assistant found the value at the stated location; the student's independent tick is still wanted, in particular on the 12 **Fig** rows. Two minor findings: the supplement labels the probability table "Figure S25" (we say "Table S25"), and the paper's two long-term P(OR<0.9) values differ (row 11 vs row 25). Page numbers for the main text are not available from the PMC text, so sections are given; supplement pages are from its table of contents.

**Trial rows (`analysis/pitre2025_trials.csv`, 21 rows).** Each was compared with Figures S21 and S22 (our n = the figure's Yes + No). All 21 match: the 19 pneumonia-stratum estimates (STEP to Wittermans* , including the Confalonieri control denominator 22, ESCAPe 297/287 and Nafae 20 that differ from our extraction), Angus (REMAP-CAP, 45/337 vs 9/116; in the pneumonia stratum in S21 and the ARDS stratum in S22) and Heming (APROCCHSS, 85/283 vs 115/279; sepsis). The file does not list the 7 ARDS and 4 other sepsis estimates of Figure S22, which we do not use.

**Checked by:** ___MA_________   **Date:** __10/11/2026__________
