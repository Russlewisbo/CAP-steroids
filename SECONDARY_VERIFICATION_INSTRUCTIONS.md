# Instructions for checking the secondary outcomes against the PDFs

Prepared 10 November 2026 for the second extractor (student). Use together with `secondary_outcomes_verification_2026-11-10.xlsx`.
Background documents: `SECONDARY_OUTCOMES_PLAN.md` (rules R1 to R7 and questions Q1 to Q6, approved by the lead on 10 November 2026).

## 1. Why this check matters

The review pools five secondary outcomes across the included trials: secondary infection, gastrointestinal (GI) bleeding, hyperglycaemia, new invasive mechanical
ventilation and new septic shock. The numbers in the database were copied from the PDFs by a single AI-assisted extractor. Nobody has yet checked them against
the papers. A typing error or a wrong table (for example per-protocol instead of intention-to-treat) would flow straight into the pooled results, so every selected
row needs a second pair of eyes. You are the independent check: please do not assume the extracted value is right.

## 2. What you have

| Item | Where |
|---|---|
| Workbook to fill in | `secondary_outcomes_verification_2026-11-10.xlsx` (sheets: Read me, Worklist, Rules, Special cases, PDF index) |
| The 14 PDFs | `~/Desktop/CAP-steroids-resources/cap-steroids-fulltext/` (exact file name in column G of the Worklist and on the "PDF index" sheet) |
| Rules in full | `SECONDARY_OUTCOMES_PLAN.md` |

The Worklist has 40 rows: 14 of priority 1 (rows that decide inclusion, or enter the severe-only analysis), 22 of priority 2 (other pooled rows) and 4 of priority 3
(rows with one arm missing, or excluded). Start with priority 1. Allow roughly half a day for all 40; the priority 1 rows take about an hour.

## 3. The columns

| Columns | Colour | Meaning |
|---|---|---|
| A to I | grey | Row ID, priority, outcome, study, trial set, status, PDF file, PDF page, table or text where the extractor found the numbers |
| J | grey | The extracted quote, copied word for word from the PDF text |
| K to P | grey | What was extracted: timepoint, population, steroid events and N, control events and N |
| Q | grey | The specific question for that row |
| R to X | yellow | **What you find**: outcome definition, timepoint, population, and the four numbers |
| Y | formula | Compares your four numbers with the extracted ones: "same" or "DIFFERENT" |
| Z | yellow | Your verdict: Y, N or Unclear (drop-down) |
| AA to AC | yellow | Comment, your initials, date |

"PDF page (count from 1)" is the position of the page in the PDF file (the first page is 1), not the number printed on the page. Some journals start numbering at several hundred, so the two
differ. The table or text name in column I tells you what to look for on that page.

## 4. Step by step, for each row

1. Open the PDF in column G and go to the page in column H. Find the table or paragraph named in column I.
2. Before you look at the grey numbers, find the outcome yourself and read it as the paper presents it. Read the table title, column headings and footnotes: they tell you the population (intention-to-treat, modified, per-protocol, safety) and the timepoint.
3. Type into the yellow columns:
   - **R**: the paper's definition of the outcome, copied in its own words (for example "upper gastrointestinal bleeding requiring transfusion"). We need this for the methods text and GRADE.
   - **S, T**: the timepoint (day 28, in-hospital, end of study, and so on) and the population as the paper labels them.
   - **U to X**: steroid events, steroid N, control events, control N, as whole numbers. Use the number of patients, not a percentage. If the paper gives only a percentage and N, work out the events and say so in the comment (for example 4 of 23 is 17.4%, which a table may print as 18%).
4. Look at column Y. "same" means all four numbers agree. "DIFFERENT" means at least one differs: look again before you conclude, then write the correct numbers in U to X and explain in AA.
5. Choose a verdict in Z: **Y** if the numbers, timepoint and population all match the source; **N** if any of them is wrong (put the right values in the FOUND columns); **Unclear** if the paper does not let you decide. Say why in AA.
6. Add your initials and the date.

Check both arms every time. A common slip is swapping the steroid and control columns, or taking the number of non-events. Check the N as well as the events: the denominator is as easy to get wrong as the count.

## 5. Rules you need to know (short form)

- **One row per trial per outcome, whole trial.** Use the whole randomised population the paper analysed for that outcome. If you find only a subgroup (for example "severe patients" or "PSI IV to V"), write that in the comment and do not copy it into the FOUND columns.
- **Both arms must be reported.** If a control (or steroid) count is missing from the paper, write "not reported" in the comment; never estimate it. These are the priority 3 rows.
- **Timepoint for harms** (secondary infection, GI bleeding, hyperglycaemia): the window closest to day 28 (day 28 or 30, then in-hospital, then end of study or treatment). If the paper reports several windows, list them all in the comment, with their numbers, so the lead can see the alternatives.
- **Timepoint for new ventilation and new septic shock:** the latest window within 30 days. The denominator should be patients who were free of the condition at the start (those "at risk"), where the paper gives it.
- **Hyperglycaemia:** use the trial's own definition. If the paper has both "any" and "requiring treatment", record both in the comment; the row we use is the one in the grey columns, and the plan names the treated definition as the preferred one.
- **"New" means new.** A patient already ventilated or in shock at enrolment does not count. If the paper does not say whether the count is of new events, say so.
- **Percentages are rounded.** A small difference between a percentage in the paper and one you compute from the counts is not an error. A different count is.

## 6. Special cases (also on the "Special cases" sheet)

These rows need an answer, not just a tick. Write the answer in the sheet's "Your answer" column and put the page in the comment on the Worklist.

| Case | Row | What to find out |
|---|---|---|
| Q1, Torres 2015, new invasive ventilation | V06 | The paper gives two separate windows (up to 72 h and 72 to 120 h). Is there a combined count anywhere (main text, tables, eTables)? Copy it with its page; if there is none, write "none". Do not add the two windows yourself. |
| Q1, Torres 2015, new septic shock | V14 | The same question for shock. |
| Q2, Nafae 2013, new ventilation (extracted 8/60 vs 5/20) | V05 | Does the paper say these are patients newly put on invasive ventilation? Quote the sentence. If it could mean any ventilation (including non-invasive or already ventilated), write "unclear". |
| Q3, Confalonieri 2005, new septic shock | V11 | The paper has "d8" (0/23 vs 9/23) and "end of study" (0/23 vs 10/23). How many days is "end of study"? If it is 30 or fewer we use end of study, otherwise day 8. |
| Q4, APROCCHSS (Heming 2024), new septic shock (row currently excluded) | V40 | Every patient was in septic shock at enrolment. What does the 55/283 vs 55/279 row (day 180) count: new episodes, recurrence, something else? Quote the definition. |
| Q5, long windows | V09 (APROCCHSS secondary infection, day 180), V31 (Hagman new ventilation, day 56) | Is a shorter window reported for the same outcome? If so give its numbers and page. |
| Hagman hyperglycaemia | V20 | The extracted denominators are 37 and 33, but 36 and 34 were randomised. Which does the safety table use, and why? |

## 7. Things that commonly go wrong

- **Wrong population:** per-protocol or completers instead of ITT; a table for a subgroup. Read the title and footnotes.
- **Wrong direction:** steroid and control swapped; the count of patients without the event.
- **Wrong denominator:** randomised instead of analysed, or the total instead of the at-risk group.
- **Wrong timepoint:** a table with several columns (for example day 7, day 28, end of study). Make sure you take the column that matches the extracted timepoint, and list the others in the comment.
- **A different outcome with a similar name:** "infection" can mean any infection, hospital-acquired infection or ventilator-associated pneumonia. Copy the definition into column R, even if the numbers match.
- **Counts of episodes rather than patients:** if the paper counts events (for example "number of infections"), say so.
- **Page not found or wrong paper:** if the page, table or even the paper is not what the extractor cited, write that in the comment. Do not look for numbers to fit.

## 8. What you must not do

- Do not change the grey columns, the column order or the row order.
- Do not edit the database, any CSV, or the extraction workbook. Corrections are applied by the lead from your sheet, so they are logged.
- Do not search the internet for numbers to replace what the PDF shows. If the PDF is missing a value, record that.
- Do not discuss the results with other reviewers before you finish; your check should be independent.

## 9. Returning the work

1. Save the workbook as `secondary_outcomes_verification_2026-11-10_<your initials>.xlsx` and send it to R. Lewis. Send a partial file after the priority 1 rows if you can; those decide what is pooled.
2. In your message, list anything you could not do (a missing PDF, an unreadable table) and any row where you disagree with the rules rather than with the numbers.

## 10. What happens next

The lead applies your answers to Q1 to Q4 and your corrections through the database and the selection table in `build_secondary.R`, then re-runs the pipeline. The secondary-outcomes
fits stay marked "unverified" on the site until your sheet is back.
