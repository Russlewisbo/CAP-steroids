# Next steps

**Current as of the evening of 10 November 2026** (replaces the earlier 10 Nov version). `Status.md` is the dated decisions log; `THESIS_CLOSEOUT_CHECKLIST.md` is the full list (ids such as B7 or D2 below refer to it).

**The analysis is not closed.** The modelling is built and stable; the open items below decide the trial set, the final numbers and the registration. **"Number?"** says whether finishing an item could change a number in the analysis: **Yes** (could change data or the included set), **Rerun** (changes only Monte Carlo noise or wording of results), **No**.

## Done

| Date | What | Where |
|---|---|---|
| Jul–Oct 2026 | Protocol v1/v2, search v2.1; searches exported 19–20 Oct; title/abstract screening 20 Oct (single AI-assisted pass); first-pass extraction 22 Oct; second-extractor numeric check 27 Oct and row-by-row check 31 Oct; final set decided 27 Oct | Status.md |
| 29–30 Oct | Pipeline built and run (hybrid Stan model, prior ladder, tipping points, agent hierarchy, meta-regressions, sensitivity fits, leave-one-out); REMAP-CAP contrast decided (D2a); Meijvis count settled | Status.md |
| 4 Nov | RoB 2 by two assessors for the 7 primary trials; consensus recorded | Status.md |
| 10 Nov | Decisions: D1, D3, D4 as proposed; 29 Oct additions signed off; Wafy excluded, Mikami "not reported", Nafae denominator 19; D2a extended to F3/F4 with SE sensitivity; REMAP-CAP SEs frozen (0.487, 0.362); RoB 2 consensus amended to Maria's judgements (S-ii now 5 trials); tipping criteria and frequentist cross-check added | Status.md, Limitations page |
| 10 Nov | Wafy, Mikami and Nafae changes applied in the extraction database (backup, changelog) | `apply_decisions_2026-11-10.py` |
| 10 Nov | Cross-checks and run stability: brms agrees on 53 of 53 with 40,000 draws each side; Stan refits use the `adapt_delta` ladder; renv synced; reruns skip unchanged fits | Status.md |
| 10 Nov | Pitre 2025 values verified (43 of 43 rows, 21 of 21 trial rows; student sign-off) | `PITRE_VERIFICATION_CHECKLIST.md` |
| 10 Nov | Secondary outcomes: rules, dataset, second-extractor check, Torres supplement applied (Torres in all five outcomes), rows verified by MCA, page and labels updated | `SECONDARY_OUTCOMES_PLAN.md`, Secondary page |
| 10 Nov | Search and PRISMA: no re-export of line 28 or #5, registry searches declared not run, counts 3,836 / 1,038 / 2,798 confirmed, 53 reports classified, figure on the Methods page ("Study selection") | `PRISMA_draft_2026-11-10.md` |
| 10 Nov | Deviations recorded on the Limitations page (baseline risks, OR 0.833, sampling, registries, line 28) | Limitations page |
| 10 Nov | PROSPERO drafts: change log (items 1–10), fields 3, 4, 5, 26, 27, pre-submission list | `PROSPERO_*_2026-11-10.md` |
| 10 Nov | Mac set up and pinned (Quarto 1.9.35, R 4.5.1, CmdStan 2.40.0); full site rendered to a scratch directory and checked (13 pages, no NA or broken links) | `AGENTS.md`, Status.md |

## Open, by owner

### Maria

| Item | Closes | Number? |
|---|---|---|
| Finish the database sign-off: Tongyoo, subgroup-derived rows (APROCCHSS, Snijders/Santeon PSI, SONIA), REMAP-CAP contrasts (confirm her "Y" on the reported OR and interval, since the SE is derived); record Nafae and Snijders CURB-65 as "match with note" | B7 | **Yes** |
| Triage the 73 open extraction issues (16 high severity): resolve or "accepted, no effect" | B8 | **Yes** |
| RoB 2 for the 11 sensitivity trials (only the assessor-1 draft exists); RoB 2 for any trial added later | B9 | Rerun (S-ii only) |
| Update the methods text she is drafting for D2a (now F1, F3, F4) | D7 | No |

### Student

| Item | Closes | Number? |
|---|---|---|
| Obtain and assess the 2 database-arm full texts (Fitzgerald 2022 STOPPE, Michels 2026; PDFs are duplicates) | B1 | **Yes** |
| Candidate reports: Wagner 1956 (not retrievable, not randomised), El-Ghamrawy 2006 and Li (Gang) 2016 (reviewed, insufficient data; Li by Annamaria) **resolved 10 Nov and in the PRISMA counts**. Still to obtain and assess: Zhou 2015, Soboleva 2000, Dambrava 2006, Oh 2009, Kapisyzi 2012 (mostly abstracts); trace or drop Maharjan 2018; save the El-Ghamrawy and Li full texts in the full-text folder (both are in the database as excluded records; `pdf_filename` to be filled in) | B2 | Possible (Zhou) |
| Classify the 7 Pitre sepsis/ARDS trials (CAP subgroup with arm-level mortality or not) and finish the inclusion-list search | B3, C4 | **Yes** |
| Briel 2018 severe-subgroup counts (Snijders, Meijvis, STEP) and the supplements; mark "attempted, not obtained" where needed | B6 | Possible |
| OCR Bernard 1987; document the Muhammad 2025 DOI check | B4 | No |
| PRESS review of the search (post hoc, say so) | C6 | No |
| Zotero import and clean-up of `records_to_retrieve_fulltext.ris` | F8 | No |

### Russ

| Item | Closes | Number? |
|---|---|---|
| Arrange the second independent screener (retained set plus 10% of exclusions, full-text decisions) | C1 | **Yes** |
| Save `torres_suppliment.pdf` in the full-text folder (the database rows cite it) | B6 | No |
| Decide the search date: run an update search before submission, or state the date as a limitation | C7 | Possible |
| Supervisor sign-off on decisions A and C | E1 | No |
| Edit the PROSPERO `.docx`: fields 3, 4, 5, 16, 26, 27, 38, 39 (drafts exist), admin fields 6–14, 31–36, URL (17), field 37 text; then submit | E2, E3 | No |
| Public repository: untrack `.posit/assistant/settings.json` and the student files, update `.gitignore`; decide whether anything must leave the public history (spreadsheets, the assessor's name); decide on GitHub Pages | E4, G3 | No |
| Confirm that the second extractor's initials (MCA in the database, "M. Annes" in older notes, "MA" on the Pitre checklist) are one person and use one form | records | No |
| Human review of the full report text (with the supervisor) | D8 | No |
| AI-use disclosure, after checking the university's rules | F7 | No |
| Data freeze: approve, record hashes, tag | B10 | Yes (fixes the data) |

### Assistant

| Item | Closes | Number? |
|---|---|---|
| Final `tar_make()` from an empty store on one machine with a clean `renv::status()`; record R, CmdStan and package versions | D6 | **Rerun** |
| Re-check every hand-written statement against the final numbers | D7 | No |
| GRADE for F1, F2 and the key harms, with a summary-of-findings table | D2 | No |
| Contour-enhanced funnel plot (F4); "not estimable" statement for viral co-infection | D3, D5 | No |
| Regenerate `analysis_handoff/` from the database at the freeze | B10 | Rerun |
| Final PRISMA figure once B1–B4 and C4 are filled; PRISMA 2020 checklist and PRISMA-S; Bayesian reporting checklist (BARG) | F1–F3 | No |
| Deviations-from-protocol table (collect from the Limitations page and the change log) | F4 | No |
| Thesis tables, figures at thesis resolution, supplementary material, hand-over note | F5, F6, F9, G5 | No |
| Regenerate `docs/` with Quarto 1.9.35 (commit it separately); tag the release; Zenodo/OSF deposit; final Status entry and sync of the Project-folder copy | G1, G2, G4 | No |

## Order

1. Maria's sign-offs and the full-text, supplement and classification items (B1–B3, B6, B7, B9): these decide the data.
2. Second screener, search date and PROSPERO edits and submission, in parallel.
3. Data freeze, then the final run, GRADE, D7 and D8, then the thesis outputs and archive.

*Not on this list because decided:* no re-export of line 28 or PubMed #5; ClinicalTrials.gov and ICTRP not searched; REMAP-CAP SEs frozen (investigator values would be a sensitivity analysis only).
