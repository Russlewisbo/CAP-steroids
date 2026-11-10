# Instructions for checking the secondary outcomes against the PDFs

Prepared 10 November 2026 for the second extractor (student). Use together with `secondary_outcomes_verification_2026-11-10.xlsx`.
Background: `SECONDARY_OUTCOMES_PLAN.md` (rules R1 to R7 and questions Q1 to Q6, approved by the lead on 10 November 2026).

## 1. Why this check matters

The review pools five secondary outcomes across the included trials: secondary infection, gastrointestinal (GI) bleeding, hyperglycaemia, new invasive mechanical
ventilation and new septic shock. The numbers in the database were copied from the PDFs by a single AI-assisted extractor, and nobody has checked them against the papers.
A typing error, or a wrong table (for example per-protocol instead of intention-to-treat), would flow straight into the pooled results. You are the independent check:
please do not assume an extracted value is right.

## 2. What you have

| Item | Where |
|---|---|
| Workbook to fill in | `secondary_outcomes_verification_2026-11-10.xlsx`: sheets Read me, Worklist, Rules, Special cases, Glossary, PDF index |
| The 14 PDFs | `~/Desktop/CAP-steroids-resources/cap-steroids-fulltext/` (exact file name in column G of the Worklist and on the "PDF index" sheet) |
| Rules in full | `SECONDARY_OUTCOMES_PLAN.md` |

The Worklist has 40 rows: 14 of priority 1 (rows that decide inclusion or enter the severe-only analysis), 22 of priority 2 (other pooled rows) and 4 of priority 3 (one arm
missing, or excluded). Do priority 1 first. Allow about half a day in all; priority 1 takes about an hour. Words you may not know are on the Glossary sheet.

## 3. The Worklist columns

| Columns | Colour | What they hold |
|---|---|---|
| A to F | grey | Row ID, priority, outcome, study, trial set, status |
| G | grey | PDF file name |
| H | grey | The PDF page we listed. It is the position of the page in the PDF (first page = 1), **not** the printed page number; journals often start at a few hundred, so the two differ |
| I | grey | The table or text we listed |
| J, K | grey | The timepoint and population we extracted |
| L | grey | What we used and why (for example "we used hyperglycaemia needing treatment") |
| M | grey | The question for that row |
| N to R | grey, **hidden** | The extracted quote (N) and the four extracted numbers (O to R): steroid events, steroid N, control events, control N |
| S | yellow | **FOUND**: the outcome definition, in the paper's words |
| T | yellow | **FOUND**: the PDF page where you actually found it |
| U, V | yellow | **FOUND**: the timepoint (the table column you used) and the population |
| W to Z | yellow | **FOUND**: steroid events, steroid N, control events, control N |
| AA | formula | Compares W to Z with O to R: "same" or "DIFFERENT" |
| AB | yellow | Verdict: Y, N or Unclear (drop-down) |
| AC to AE | yellow | Comment, your initials, date |

Columns N to R start hidden on purpose: please fill in the yellow cells first and only then click the small **+** above the column letters to open the group. That keeps the check independent.

## 4. Step by step, for each row

1. Open the PDF named in column G and go to the page in column H. Find the table or paragraph named in column I. If it is not on that page, look at the pages either side and write the page where you found it in column T. (We know of two doubtful pages: V39, Mikami, where the sentence seems to be on page 4, not 3; and V31, Hagman, where the topic is on pages 6 and 8.)
2. Read columns J to M (timepoint and population we extracted, what we used and why, the question).
3. Read the table title, column headings and footnotes: they tell you the population (intention-to-treat, modified, per-protocol, safety) and the timepoint.
4. Type into the yellow cells:
   - **S**: the paper's definition of the outcome, copied in its own words (for example "upper gastrointestinal bleeding requiring transfusion"). We need it for the methods text and GRADE, even when the numbers match.
   - **T**: the page you found it on.
   - **U, V**: the timepoint (the table column you used) and the population, as the paper labels them.
   - **W to Z**: steroid events, steroid N, control events, control N, as whole numbers. Use patients, not percentages. If the paper gives only a percentage and N, work out the events and say so in the comment.
   - If an arm is not reported, type **NR** in that arm's two number cells.
5. Open the hidden group (N to R) and read column AA. "same" means all four numbers agree. "DIFFERENT" means at least one differs: look again before you decide, keep **your** numbers in W to Z, and explain in AC.
6. Choose a verdict in AB:
   - **Y**: the numbers, timepoint and population we extracted match the paper.
   - **N**: something we extracted is wrong; your FOUND cells hold the correct values.
   - **Unclear**: the paper does not let you decide; say why.
   A better window, or a different table the rules would prefer, is **not** a reason for N. Answer Y or N for the row as extracted, and put the suggestion in the comment.
7. Add your initials (AD) and the date (AE).

Check both arms every time. A common slip is swapping steroid and control, or taking the patients without the event. Check the N as well as the events.

## 5. Rules you need (short form)

- **One row per trial per outcome, whole trial.** Use the population the paper analysed for that outcome. If you find only a subgroup (for example "severe patients"), say so in the comment and do not copy it into the FOUND cells.
- **APROCCHSS is the CAP subgroup.** In this review the APROCCHSS trial is the community-acquired pneumonia subgroup reported by Heming 2024. Use that population; if the table is for the whole septic-shock trial, say so.
- **Both arms must be reported.** If one arm is missing, enter NR in its cells and write "not reported" in the comment; never estimate it. These are the priority 3 rows.
- **Timepoint for harms** (secondary infection, GI bleeding, hyperglycaemia): the window closest to day 28 (day 28 or 30, then in-hospital, then end of study or treatment). If the paper reports several windows, list them in the comment with their numbers.
- **Timepoint for new ventilation and new septic shock:** the latest window within 30 days. The denominator should be patients free of the condition at baseline (at risk), where the paper gives it; say which denominator the table uses.
- **Hyperglycaemia:** column L says whether we used "needing treatment" or "any". If the paper also gives the other version, put those numbers in the comment.
- **"New" means new.** A patient already ventilated, or already in shock, at enrolment does not count. If the paper does not say whether the count is of new events, say so.
- **Percentages are rounded.** A table that prints 18% for 4 of 23 (17.4%) is not an error. A different count is.

## 6. Special cases (also on the "Special cases" sheet)

These rows need an answer, not only a tick. Write it on the "Special cases" sheet and refer to the page in the Worklist comment.

| Case | Row | What to find out |
|---|---|---|
| Q1, Torres 2015, new invasive ventilation | V06 | The paper gives two separate windows (up to 72 h and 72 to 120 h, pages 6 and 7). They cannot be added, because a patient could appear in both. Is there a **combined** count (main text, tables, or an eTable)? If yes, enter it in W to Z, write "combined" in the comment and give the page. If not, enter NR in all four cells and give both windows' numbers in the comment. If the paper points to an eTable that is not in this PDF, say so. |
| Q1, Torres 2015, new septic shock | V14 | The same question for shock. |
| Q2, Nafae 2013, new ventilation (extracted 8/60 steroid vs 5/20 control) | V05 | Find the sentence or table row that defines the count. Does the paper say these are patients **newly** put on invasive ventilation, rather than any ventilation, non-invasive support or ventilation at admission? Copy the wording into S and give your reading in the comment as "new invasive", "any ventilation" or "unclear". Enter the numbers you find either way. This PDF's printed page numbers start at 439, so the PDF's own page 5 is printed page 443. |
| Q3, Confalonieri 2005, new septic shock | V11 | The paper has "day 8" and "end of study". How many days is "end of study"? If it is 30 or fewer we use end of study, otherwise day 8. Enter both rows' numbers in the comment. |
| Q4, APROCCHSS (Heming 2024), new septic shock (row currently excluded) | V40 | Every patient was in septic shock at enrolment. What does the day-180 row count: new episodes, recurrence, something else? Quote the definition. |
| Q5, long windows | V09 (APROCCHSS secondary infection, day 180), V31 (Hagman new ventilation, day 56) | Is a shorter window reported for the same outcome? If so, give its numbers and page. |
| Hagman hyperglycaemia | V20 | The extracted denominators are 37 and 33, but 36 and 34 were randomised. Which does the safety table use, and why do they differ? |

## 7. Things that commonly go wrong

- **Wrong population:** per-protocol or completers instead of intention-to-treat; a subgroup table. Read the title and footnotes.
- **Wrong direction:** steroid and control swapped; the count of patients without the event.
- **Wrong denominator:** randomised instead of analysed, or the total instead of the at-risk group.
- **Wrong timepoint:** a table with several columns (day 7, day 28, end of study). Take the column that matches the extracted timepoint (column J) and list the others in the comment.
- **A different outcome with a similar name:** "infection" can mean any infection, hospital-acquired infection or ventilator-associated pneumonia. Copy the definition into S even when the numbers match.
- **Episodes instead of patients:** if the paper counts events (for example "number of infections"), say so.
- **Wrong page, table or paper:** if what the extractor cited is not there, write that in the comment. Do not look for numbers to fit.

## 8. What you must not do

- Do not change the grey columns, the column order or the row order.
- Do not edit the database, any CSV, or the extraction workbook. Corrections are applied by the lead from your sheet, so they are logged.
- Do not search the internet for numbers to replace what the PDF shows. If the PDF lacks a value, record that.
- Do not discuss your results with other reviewers until you have finished; your check should be independent.

## 9. Returning the work

1. Save the workbook as `secondary_outcomes_verification_2026-11-10_<your initials>.xlsx` and send it to R. Lewis. If you can, send a partial file after the priority 1 rows; they decide what is pooled.
2. In your message, list anything you could not do (a missing PDF, an unreadable table) and any row where you disagree with the rules rather than the numbers.

## 10. What happens next

The lead applies your answers to Q1 to Q4 and your corrections through the database and the selection table in `build_secondary.R`, then re-runs the pipeline. The secondary-outcomes
fits stay marked "unverified" on the site until your sheet comes back.
