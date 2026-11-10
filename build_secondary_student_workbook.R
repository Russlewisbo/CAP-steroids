# Builds secondary_outcomes_verification_2026-11-10.xlsx, the student's checking workbook for the secondary outcomes,
# from verification_worklist_secondary_2026-11-10.csv (written by build_secondary.R) and the `records` sheet of
# cap_steroids_extraction.xlsx (PDF file names). Run from the repository root:  Rscript build_secondary_student_workbook.R
# The workbook is a view of the worklist; to change a selection edit build_secondary.R and re-run both scripts.
library(openxlsx)
library(readxl)

wl <- read.csv("verification_worklist_secondary_2026-11-10.csv", stringsAsFactors = FALSE, check.names = FALSE)
recs <- read_excel("cap_steroids_extraction.xlsx", sheet = "records")
wl$pdf_file <- recs$pdf_filename[match(wl$source_record_id, recs$record_id)]
stopifnot(nrow(wl) == 40, !anyNA(wl$pdf_file))

outcome_label <- c(secondary_infection = "Secondary infection", gi_bleeding = "GI bleeding",
                   hyperglycaemia = "Hyperglycaemia", imv_new = "New invasive mechanical ventilation",
                   septic_shock_new = "New septic shock")
status_label <- c(pooled = "Pooled", pooled_flagged = "Pooled (long window: flagged)",
                  pending_check = "PENDING: decides inclusion", descriptive = "Descriptive only (one arm missing)",
                  excluded = "Excluded (check why)")
tp_label <- c(d7 = "Day 7", d8 = "Day 8", d28 = "Day 28", d30 = "Day 30", d56 = "Day 56", d180 = "Day 180",
              in_hospital = "In hospital", end_of_study = "End of study", `72-120h` = "72 to 120 h", `<=72h` = "Up to 72 h")
num <- function(x) suppressWarnings(as.numeric(x))

# What we used and why, from SECONDARY_OUTCOMES_PLAN.md (no numbers where the number is what you must find)
treated <- c("DEQUIN2023", "STEP2015", "MEIJVIS2011", "SNIJDERS2010")
note_for <- function(trial, outcome, status) {
  n <- character()
  if (outcome == "hyperglycaemia")
    n <- c(n, if (trial %in% treated) "We used the version 'hyperglycaemia needing treatment'. If the paper also gives 'any hyperglycaemia', put those numbers in the comment."
              else "We used 'any hyperglycaemia' (no treated version found). If the paper also gives a version needing treatment, put those numbers in the comment.")
  if (outcome %in% c("imv_new", "septic_shock_new") && status %in% c("pooled", "pooled_flagged"))
    n <- c(n, "Denominator should be patients free of the condition at baseline (at risk), not everyone randomised, where the paper gives it; say which one the table uses.")
  if (trial == "APROCCHSS_CAP2024")
    n <- c(n, "APROCCHSS = the CAP subgroup paper (Heming 2024): use its CAP population, not the whole septic-shock trial. Say if the table is for something else.")
  if (trial == "STEP2015" && outcome == "secondary_infection")
    n <- c(n, "STEP reports a short and a long window; we used the day-30 one.")
  if (status == "pooled_flagged")
    n <- c(n, "LONG WINDOW: we used it because we thought nothing shorter exists. Is a shorter window reported? Give it in the comment.")
  if (status == "descriptive")
    n <- c(n, "One arm is not reported in our data. Check the text, tables and footnotes; if the arm is really absent, enter NR in its two number cells.")
  if (status == "pending_check")
    n <- c(n, "PENDING: see the 'Special cases' sheet. This row decides whether the trial is pooled.")
  if (status == "excluded")
    n <- c(n, "Currently excluded: see 'Special cases' (Q4).")
  paste(n, collapse = " ")
}
page_doubt <- c(V31 = "Page doubt: the topic appears on pages 6 and 8; use the table that matches.",
                V39 = "Page doubt: the sentence seems to be on page 4, not 3.")

tp_readable <- ifelse(wl$timepoint %in% names(tp_label), tp_label[wl$timepoint], wl$timepoint)
tp_readable[tp_readable == ""] <- "(two windows: see the question)"
na_pop <- wl$population == ""
ids <- sprintf("V%02d", seq_len(nrow(wl)))
notes <- mapply(note_for, wl$trial_id, wl$outcome, wl$status)
notes <- ifelse(ids %in% names(page_doubt), paste(notes, page_doubt[ids]), notes)

d <- data.frame(
  ID = ids,
  Priority = as.integer(wl$priority),
  Outcome = unname(outcome_label[wl$outcome]),
  Study = wl$study_label,
  `Trial set` = wl$final_set,
  Status = unname(status_label[wl$status]),
  `PDF file (in the full-text folder)` = wl$pdf_file,
  `PDF page we listed (count from 1)` = num(wl$pdf_page_1based),
  `Table or text we listed` = wl$location,
  `Timepoint we extracted` = unname(tp_readable),
  `Population we extracted` = ifelse(wl$population == "", "(not extracted)", wl$population),
  `What we used and why` = unname(notes),
  `Question for you` = wl$check_question,
  `Extracted quote (hidden: open AFTER you fill the yellow cells)` = wl$quote,
  `Extracted: steroid events` = num(wl$steroid_events), `Extracted: steroid N` = num(wl$steroid_n),
  `Extracted: control events` = num(wl$control_events), `Extracted: control N` = num(wl$control_n),
  `FOUND: outcome definition (copy the paper's words)` = "",
  `FOUND: PDF page where you found it` = NA_real_,
  `FOUND: timepoint (the table column you used)` = "", `FOUND: population` = "",
  `FOUND: steroid events` = NA_real_, `FOUND: steroid N` = NA_real_,
  `FOUND: control events` = NA_real_, `FOUND: control N` = NA_real_,
  `Auto-check (numbers)` = "",
  Verdict = "", `Comment (page, table, anything unclear)` = "", `Checked by` = "", Date = "",
  check.names = FALSE, stringsAsFactors = FALSE)
L <- setNames(int2col(seq_along(d)), names(d))      # column letters, used in the text below
col <- function(pattern) unname(L[grep(pattern, names(d), fixed = TRUE)][1])
c_quote <- col("Extracted quote"); c_ex1 <- col("Extracted: steroid events"); c_ex4 <- col("Extracted: control N")
c_found1 <- col("FOUND: outcome definition"); c_foundN <- col("FOUND: control N")
c_fn1 <- col("FOUND: steroid events"); c_fn4 <- col("FOUND: control N")
c_auto <- col("Auto-check"); c_verd <- col("Verdict"); c_comm <- col("Comment")
c_by <- col("Checked by"); c_date <- col("Date"); c_page <- col("FOUND: PDF page")
c_q <- col("Question for you"); c_gpage <- col("PDF page we listed"); c_file <- col("PDF file"); c_loc <- col("Table or text we listed")
c_note <- col("What we used and why")

wb <- createWorkbook()
hdr <- createStyle(textDecoration = "bold", fgFill = "#1F3864", fontColour = "white", wrapText = TRUE, valign = "top")
hdr_in <- createStyle(textDecoration = "bold", fgFill = "#7F6000", fontColour = "white", wrapText = TRUE, valign = "top")
grey <- createStyle(fgFill = "#EDEDED", wrapText = TRUE, valign = "top")
yellow <- createStyle(fgFill = "#FFF2CC", wrapText = TRUE, valign = "top")
wrap <- createStyle(wrapText = TRUE, valign = "top")
title <- createStyle(textDecoration = "bold", fontSize = 14)

# ---- Read me -----------------------------------------------------------------------------------------------
addWorksheet(wb, "Read me")
rm_lines <- c(
  "SECONDARY OUTCOMES: DOUBLE CHECK AGAINST THE PDFs (prepared 10 November 2026)",
  "",
  "What this is: 40 rows (one per trial and outcome) taken from the extraction database. Every value was typed in by a single AI-assisted extractor. Your job is to check each row against the original PDF, independently, before any fit is final.",
  "Full instructions: SECONDARY_VERIFICATION_INSTRUCTIONS.md (read it first). The 'Rules', 'Special cases' and 'Glossary' sheets here are the short version.",
  "",
  paste0("Where the PDFs are: ~/Desktop/CAP-steroids-resources/cap-steroids-fulltext/ (file name in column ", c_file, " of 'Worklist')."),
  "",
  paste0("BLIND CHECK: the extracted quote and the four extracted numbers are in grouped columns that start HIDDEN (columns ", c_quote, " to ", c_ex4,
         "). Fill in the yellow cells first. Then click the small + above the column letters to open the group and compare. The 'Auto-check' column (", c_auto, ") also compares them for you."),
  "",
  "For each row:",
  paste0("  1. Open the PDF in column ", c_file, ". Go to the page in column ", c_gpage, " (the PDF's own page count from 1; the printed page number can differ). The table or text is in column ", c_loc,
         ". If it is not on that page, look at the pages either side and write the page where you found it in column ", c_page, "."),
  paste0("  2. Read the columns for the timepoint and population we extracted, 'What we used and why' (", c_note, ") and the question (", c_q, ")."),
  paste0("  3. Find the outcome in the paper yourself. Type what you find in the yellow cells ", c_found1, " to ", c_fn4,
         ": the definition in the paper's words, the page, the timepoint (the table column you used), the population, and four numbers (steroid events, steroid N, control events, control N). Use whole numbers, not percentages. If an arm is not reported, type NR in its two number cells."),
  paste0("  4. Open the hidden group and read column ", c_auto, ": 'same' or 'DIFFERENT'. If different, look again, then keep YOUR numbers in the FOUND cells and explain in column ", c_comm, "."),
  paste0("  5. Choose a verdict in column ", c_verd, ". Put your initials in ", c_by, " and the date in ", c_date, "."),
  "",
  "Verdict: Y = the numbers, timepoint and population we extracted match the paper. N = something we extracted is wrong (your FOUND cells hold the correct values). Unclear = the paper does not let you decide (say why). A better window or a different table that the rules would prefer is NOT a reason for N: answer Y or N for the row as extracted and write the suggestion in the comment.",
  "Status labels: Pooled = used in the analysis. Pooled (long window: flagged) = a window longer than 30 days, used only because nothing shorter was found. PENDING = the row decides whether the trial is pooled. Descriptive only = one arm missing. Excluded = left out; check why.",
  "Priority: 1 first (14 rows), then 2 (22), then 3 (4).",
  "",
  "Do not change the grey columns, the column order or the row order, and do not edit the database or any CSV. Save the file as secondary_outcomes_verification_2026-11-10_<your initials>.xlsx and send it back.",
  "If a PDF is the wrong paper, unreadable, or does not contain the table, say so in the comment; do not guess.")
writeData(wb, "Read me", data.frame(x = rm_lines), colNames = FALSE)
addStyle(wb, "Read me", title, rows = 1, cols = 1)
addStyle(wb, "Read me", wrap, rows = 2:length(rm_lines), cols = 1, gridExpand = TRUE)
setColWidths(wb, "Read me", cols = 1, widths = 150)

# ---- Worklist ----------------------------------------------------------------------------------------------
addWorksheet(wb, "Worklist")
writeData(wb, "Worklist", d)
n <- nrow(d)
i_q <- which(names(d) == "Question for you")
i_ext <- which(names(d) == "Extracted: steroid events"); i_ext4 <- which(names(d) == "Extracted: control N")
i_quote <- which(grepl("^Extracted quote", names(d)))
i_f1 <- which(names(d) == "FOUND: outcome definition (copy the paper's words)")
addStyle(wb, "Worklist", hdr, rows = 1, cols = 1:i_ext4, gridExpand = TRUE)
addStyle(wb, "Worklist", hdr_in, rows = 1, cols = i_f1:ncol(d), gridExpand = TRUE)
addStyle(wb, "Worklist", grey, rows = 2:(n + 1), cols = 1:i_ext4, gridExpand = TRUE)
addStyle(wb, "Worklist", yellow, rows = 2:(n + 1), cols = i_f1:ncol(d), gridExpand = TRUE)
ex <- int2col(i_ext:i_ext4); fn <- int2col(which(names(d) == "FOUND: steroid events"):which(names(d) == "FOUND: control N"))
for (i in seq_len(n)) {
  r <- i + 1
  cmp <- vapply(1:4, function(k) sprintf('IF(%s%d="",UPPER(%s%d&"")="NR",%s%d=%s%d)', ex[k], r, fn[k], r, fn[k], r, ex[k], r), "")
  f <- sprintf('IF(COUNTA(%s%d:%s%d)=0,"",IF(COUNTA(%s%d:%s%d)<4,"fill all four (NR if not reported)",IF(COUNTA(%s%d:%s%d)=0,"no extracted value: answer in the comment",IF(AND(%s),"same","DIFFERENT"))))',
               fn[1], r, fn[4], r, fn[1], r, fn[4], r, ex[1], r, ex[4], r, paste(cmp, collapse = ","))
  writeFormula(wb, "Worklist", f, startCol = which(names(d) == "Auto-check (numbers)"), startRow = r)
}
dataValidation(wb, "Worklist", cols = which(names(d) == "Verdict"), rows = 2:(n + 1), type = "list", value = '"Y,N,Unclear"')
conditionalFormatting(wb, "Worklist", cols = which(names(d) == "Auto-check (numbers)"), rows = 2:(n + 1),
                      rule = "DIFFERENT", type = "contains", style = createStyle(fontColour = "#9C0006", bgFill = "#FFC7CE"))
conditionalFormatting(wb, "Worklist", cols = 6, rows = 2:(n + 1), rule = "PENDING", type = "contains",
                      style = createStyle(fontColour = "#9C5700", bgFill = "#FFEB9C"))
w <- setNames(rep(12, ncol(d)), names(d))
w[c("ID", "Priority")] <- c(6, 8); w["Outcome"] <- 18; w["Study"] <- 22; w["Trial set"] <- 11; w["Status"] <- 22
w["PDF file (in the full-text folder)"] <- 38; w["PDF page we listed (count from 1)"] <- 9; w["Table or text we listed"] <- 22
w["Timepoint we extracted"] <- 12; w["Population we extracted"] <- 14; w["What we used and why"] <- 48; w["Question for you"] <- 50
w[i_quote] <- 55; w[i_ext:i_ext4] <- 9
w["FOUND: outcome definition (copy the paper's words)"] <- 40; w["FOUND: PDF page where you found it"] <- 9
w["FOUND: timepoint (the table column you used)"] <- 16; w["FOUND: population"] <- 14
w[which(names(d) %in% c("FOUND: steroid events", "FOUND: steroid N", "FOUND: control events", "FOUND: control N"))] <- 9
w["Auto-check (numbers)"] <- 14; w["Verdict"] <- 10; w["Comment (page, table, anything unclear)"] <- 45; w["Checked by"] <- 10; w["Date"] <- 11
setColWidths(wb, "Worklist", cols = seq_len(ncol(d)), widths = unname(w))
setRowHeights(wb, "Worklist", rows = 1, heights = 62)
groupColumns(wb, "Worklist", cols = i_quote:i_ext4, hidden = TRUE)
freezePane(wb, "Worklist", firstActiveRow = 2, firstActiveCol = 5)

# ---- Rules -------------------------------------------------------------------------------------------------
addWorksheet(wb, "Rules")
rules <- data.frame(
  Rule = c("R1 One row per trial per outcome", "R2 Both arms needed", "R3 Harms: which timepoint",
           "R4 Progression outcomes: which timepoint", "R5 Hyperglycaemia definition", "R7 Why you are checking",
           "Which population", "What counts as 'new' ventilation or shock", "APROCCHSS", "Events, not percentages"),
  `In plain words` = c(
    "Each row is the WHOLE trial (never a severity subgroup), taken from the main report or its supplement, using the population the trial used for that outcome (ITT, mITT or safety population).",
    "A row is pooled only if events and the number of patients are reported for BOTH arms. If one arm is missing the row is descriptive only. Never fill in a missing arm.",
    "For secondary infection, GI bleeding and hyperglycaemia we take the window closest to day 28: day 28 or 30 first, then in-hospital, then end of study or treatment, then anything else. Day 90 or 180 only if nothing shorter exists (flagged).",
    "For new invasive ventilation and new septic shock we take the LATEST window within 30 days (these events build up over time). The denominator should be patients free of the condition at baseline (the 'at risk' group) where the paper gives it.",
    "Use the trial's own definition. If a trial reports both 'any hyperglycaemia' and 'hyperglycaemia requiring treatment', we use the treated one.",
    "The extraction was a single AI-assisted pass. A second person must confirm every selected row against the PDF before the numbers are used.",
    "Note the population exactly as the paper labels it (ITT, mITT, per-protocol, safety). Tell us if the table you find is per-protocol or a subgroup.",
    "Only patients who did NOT have the condition at the start. If the paper counts every episode, or all patients, say so in the comment.",
    "In this review the APROCCHSS trial is the community-acquired pneumonia subgroup reported by Heming 2024. Use that population. If the table you find is for the whole septic-shock trial or another subgroup, say so in the comment.",
    "Type the number of patients (events), not the percentage. If only a percentage and N are given, compute the events and say so. A table that prints 18% for 4 of 23 (17.4%) is rounding, not an error."),
  check.names = FALSE)
writeData(wb, "Rules", rules)
addStyle(wb, "Rules", hdr, rows = 1, cols = 1:2, gridExpand = TRUE)
addStyle(wb, "Rules", wrap, rows = 2:(nrow(rules) + 1), cols = 1:2, gridExpand = TRUE)
setColWidths(wb, "Rules", cols = 1:2, widths = c(38, 120))

# ---- Special cases -----------------------------------------------------------------------------------------
idof <- function(trial, outcome) d$ID[wl$trial_id == trial & wl$outcome == outcome]
sc <- data.frame(
  Case = c("Q1 Torres: new ventilation", "Q1 Torres: new septic shock", "Q2 Nafae: new ventilation",
           "Q3 Confalonieri: new septic shock", "Q4 APROCCHSS: new septic shock (currently excluded)",
           "Q5a APROCCHSS: secondary infection (d180)", "Q5b Hagman: new ventilation (d56)", "Hagman: hyperglycaemia denominators"),
  `Row` = c(idof("TORRES2015", "imv_new"), idof("TORRES2015", "septic_shock_new"), idof("NAFAE2013", "imv_new"),
            idof("CONFALONIERI2005", "septic_shock_new"), idof("APROCCHSS_CAP2024", "septic_shock_new"),
            idof("APROCCHSS_CAP2024", "secondary_infection"), idof("HAGMAN2026", "imv_new"), idof("HAGMAN2026", "hyperglycaemia")),
  `What to find out` = c(
    "The paper gives two separate windows (up to 72 h: 4/61 vs 5/59; 72 to 120 h: 1/61 vs 4/59; the text is on pages 6 and 7). They cannot simply be added, because a patient could appear in both. Is there a COMBINED count (main text, tables, or an eTable)? If yes, enter it in the four FOUND number cells, write 'combined' in the comment and give the page. If there is none, enter NR in all four cells and write both windows' numbers in the comment. If the paper points to an eTable that is not in this PDF, say so.",
    "Same question for new septic shock (up to 72 h: 2/61 vs 3/59; 72 to 120 h: 0/61 vs 4/59; pages 6 and 7). Combined count: enter it in the FOUND cells and write 'combined'. None: NR in all four cells and both windows in the comment.",
    "8/60 vs 5/20 is the extracted 'ventilation' count (steroid vs control). Find the sentence or table row that defines it. Does the paper say these are patients NEWLY put on invasive (mechanical) ventilation, as opposed to patients on any ventilation, non-invasive support or ventilation at admission? Copy the wording into the definition cell. Give your reading in the comment as one of: 'new invasive', 'any ventilation', 'unclear'. Enter the numbers you find either way. Note that this PDF is a printed article whose page numbers start at 439, so the PDF's own page 5 is a different number from the printed one.",
    "The paper has 'd8' (0/23 vs 9/23) and 'end of study' (0/23 vs 10/23). How many days does 'end of study' cover? If it is 30 days or fewer we use end of study; otherwise d8.",
    "Every APROCCHSS patient was in septic shock at enrolment. What does the 55/283 vs 55/279 row (day 180) actually count: new episodes, recurrence, or something else? Quote the definition.",
    "Confirm that no shorter window is reported for secondary infection (for example day 28 or in-hospital). If one exists, give its numbers and page.",
    "Confirm that no shorter window is reported for invasive ventilation. Note that both arms have zero events.",
    "The extracted denominators are 37 and 33, but 36 and 34 were randomised. Which denominators does the safety table use, and why do they differ?"),
  `Your answer` = "", check.names = FALSE)
addWorksheet(wb, "Special cases")
writeData(wb, "Special cases", sc)
addStyle(wb, "Special cases", hdr, rows = 1, cols = 1:3, gridExpand = TRUE)
addStyle(wb, "Special cases", hdr_in, rows = 1, cols = 4)
addStyle(wb, "Special cases", wrap, rows = 2:(nrow(sc) + 1), cols = 1:3, gridExpand = TRUE)
addStyle(wb, "Special cases", yellow, rows = 2:(nrow(sc) + 1), cols = 4)
setColWidths(wb, "Special cases", cols = 1:4, widths = c(42, 8, 100, 60))

# ---- Glossary ----------------------------------------------------------------------------------------------
addWorksheet(wb, "Glossary")
gl <- data.frame(
  Term = c("ITT (intention to treat)", "mITT (modified ITT)", "Per-protocol (PP)", "Safety population", "At risk (denominator)",
           "IMV", "New invasive ventilation", "New septic shock", "Secondary infection", "Hyperglycaemia needing treatment",
           "In hospital", "End of study", "Day 28, Day 30, Day 180", "NR", "Events and N", "Steroid / control"),
  Meaning = c("All patients analysed in the group they were randomised to, whatever happened afterwards.",
              "Almost all randomised patients, excluding a few for stated reasons (for example never treated). The paper says which.",
              "Only patients who followed the protocol. We do not want these numbers unless nothing else is reported: flag them.",
              "Patients who received at least one dose of study treatment. Common for harms.",
              "Patients who could have had the event: for new ventilation, those not ventilated at baseline; for new shock, those not in shock at baseline.",
              "Invasive mechanical ventilation (a breathing tube), not oxygen masks or non-invasive support.",
              "Patients newly put on IMV after enrolment.",
              "Patients who developed septic shock after enrolment (not those already in shock).",
              "Any new infection during follow-up (hospital-acquired infection, ventilator-associated pneumonia and so on). Copy the paper's definition.",
              "Blood glucose high enough that the clinicians gave insulin or other treatment, as the paper defines it.",
              "Any time up to hospital discharge; the length is not fixed.",
              "The last follow-up point of that trial. Note how many days it is.",
              "Counted from randomisation (or admission, if the paper says so).",
              "Not reported. Type it in a number cell when the paper does not give that arm.",
              "Events = patients with the outcome. N = patients analysed in that arm.",
              "Steroid = the corticosteroid arm; control = placebo or usual care."),
  check.names = FALSE)
writeData(wb, "Glossary", gl)
addStyle(wb, "Glossary", hdr, rows = 1, cols = 1:2, gridExpand = TRUE)
addStyle(wb, "Glossary", wrap, rows = 2:(nrow(gl) + 1), cols = 1:2, gridExpand = TRUE)
setColWidths(wb, "Glossary", cols = 1:2, widths = c(34, 130))

# ---- PDF index ---------------------------------------------------------------------------------------------
addWorksheet(wb, "PDF index")
pi <- unique(wl[, c("study_label", "source_record_id", "pdf_file")])
names(pi) <- c("Study", "Record ID", "PDF file")
pi <- pi[order(pi$Study), ]
writeData(wb, "PDF index", pi)
addStyle(wb, "PDF index", hdr, rows = 1, cols = 1:3, gridExpand = TRUE)
setColWidths(wb, "PDF index", cols = 1:3, widths = c(32, 12, 110))

saveWorkbook(wb, "secondary_outcomes_verification_2026-11-10.xlsx", overwrite = TRUE)
cat("written:", nrow(d), "rows;", length(unique(wl$pdf_file)), "PDFs\n")
