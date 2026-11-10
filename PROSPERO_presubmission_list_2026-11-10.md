# PROSPERO pre-submission list (10 November 2026)

Every field of `PROSPERO_Protocol_v2.md` (the repo copy of the `.docx`, protocol v2, 16 Oct 2026) that still holds stale or bracketed text, what replaces it,
and what the author still has to supply. The `.docx` in the Project folder is authoritative and has **not** been edited; every "replacement" below is a draft to paste.
Files: **A** = `PROSPERO_fields_3_5_2026-11-10.md`, **B** = `PROSPERO_fields_4_26_27_2026-11-10.md`, **C** = `PROSPERO_protocol_amendment_2026-11-10.md` (change log),
**D** = `PROSPERO_Protocol_v2.md` (repo copy; the search amendment is already in field 16).

## Fields with drafted replacements

| Field | Problem in the current text | Replacement | You still supply |
|---|---|---|---|
| 3 Start date | "[27 July 2026]", the planned first search; searches were exported on 19 and 20 Oct | A | Confirm 19 October 2026; keep or drop the bracketed note on the July peer review |
| 4 Completion date | "[31 March 2027]", "analysis complete ~8 October 2026" | B | Confirm [30 June 2027] |
| 5 Stage of review | "has not yet started; no searches ... run" | A | Check the counts and dates; MCA's role is stated as second reviewer only |
| 16 Searches | Registries and Ovid MEDLINE line 28 | D (amendment paragraph already added) and C item 1 | Paste into the `.docx`. Decide whether "forward citation searching of key trials" stays: the record shows a hand-search of inclusion lists but no forward citation search |
| 26 Selection and extraction | Promises duplicate independent screening and extraction | B | Confirm wording on full-text assessment (RL, with MCA as second reviewer) |
| 27 Risk of bias | Promises independent duplicate RoB 2 for all trials | B | None beyond the second assessment of the 11 sensitivity-set trials, which is still planned |
| 38 Current review status | "Ongoing — the review has not yet started" plus a bracketed "to be reworded" | Not drafted; use "Ongoing: screening, a first extraction pass and RoB 2 are complete or under way; see field 5" | Approve |
| 39 Additional information | Does not mention the amendments | C (paste the change-log paragraph here) | Add C's missing items below |

## Fields with bracketed text and no draft

| Field | What is missing | You supply |
|---|---|---|
| Header | "[DRAFT — complete bracketed admin fields before submission]" and "prepared 9 July 2026" | Remove before submission; update the date |
| 6–14 Contact, affiliations, team, funding, conflicts, collaborators | Bracketed in the `.docx` and not in the repo copy | All administrative details (including MCA, RL and the supervisor) |
| 17 URL to search strategy | "[Insert URL ... To be added at registration.]" | The public repository URL (the report's `_quarto.yml` points to https://github.com/Russlewisbo/CAP-steroids). The repo's `Search_Strategies_Corticosteroids_sCAP.rtf` is the 9 July v1, not the 16 October v2.1 in the screening folder; deposit v2.1 and give its link |
| 31–36 Country, other registration, protocol URL | "[Country/registration/URL bracketed in the .docx.]" | Country, other registration IDs, protocol URL |
| 37 Existing reviews by the same authors | Bracketed, and it says the "marginal contribution ... is the inclusion of REMAP-CAP and SONIA" | Decide the text. **Correct it:** Pitre 2025 already includes REMAP-CAP (Angus 2024 in its Figures S18 and S22); SONIA is the one it lacks |
| 40 Final report | "[To be completed on review completion.]" | Leave as is |

## Text that is out of date but not bracketed

| Field | Stale statement | Fix |
|---|---|---|
| 28 Data synthesis | "implemented in R with brms/Stan" | The model is Stan via `cmdstanr`; `brms` is a cross-check only. State this as a deviation (also field 31–36, "Stan/brms code") |
| 28 Data synthesis | ω "estimated from only three to four clusters" | Two populated clusters in the primary set (hydrocortisone, methylprednisolone) |
| 29 Subgroups and sensitivity | Lists sensitivity analyses (i) to (v) only | Add (vi) drop subgroup-derived trials and (viii) drop the mineralocorticoid trial (decision A, 16 Oct); (ix) is in C. Also the common-effect fit (S-CE), the IPD cross-check (S-IPD), the denominator and source checks, and the frequentist REML/Hartung–Knapp cross-check, labelled as added after the first run |
| Change log (C) | Covers searches, (ix), the SONIA rule and D2a only | Add (vi) and (viii) and the post-first-run additions above; add the Stan versus brms deviation |

## Registration blockers (not text)

1. Supervisor sign-off on decisions A and C (`Status.md` item 1).
2. Public repository check, and the post hoc PRESS librarian review to mention (`Status.md` items 4 and 5).
3. Second screener: not a blocker for registering, but fields 5 and 26 say it is pending.
4. Edit the `.docx` in the Project folder (the repo copy is only a conversion), then regenerate or re-convert so the two agree.
