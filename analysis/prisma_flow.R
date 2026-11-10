# Draft PRISMA 2020 flow diagram (PRISMA2020 package, Haddaway et al.).
#
# Counting unit. Identification and screening boxes count records; every box from "Reports sought for
# retrieval" down counts REPORTS, derived here from the `records` sheet of the extraction workbook
# (one row per full-text record, 55 rows). The final box gives studies and reports separately.
#
# Block D (supplementary sepsis/ARDS search, protocol v2 decision A) is counted in the database arm only:
# it was run with the database searches. The screening log retained 21 Block D records (screen code I3), 9 of
# which are in the workbook. It is not counted again under "other methods".
#
# Screening counts (10 Nov 2026) come from the 20 Oct screening log, which lives outside the repository
# (CAP-steroids-resources/CAP_Search_Strategy/Screening_2026-10-20/: prisma_counts.json and
# screening_log_all_records.csv): 2,798 screened, 2,663 excluded, 135 retained = 105 reports to retrieve
# (I1 22 + I2 54 + I3 21 + I4 8) + 30 registered or ongoing trials without results (O1).
# Only 52 of the 105 are rows of the `records` sheet (plus 3 of the 30 O1 registrations = 55 rows). The other 53
# (8 candidate main reports never obtained, 12 Block D records, 33 companion reports) were classified on 10 Nov
# (option B): 39 not sought and 14 sought but not obtained count as "not retrieved" with the 2 wrong PDFs (55 in all),
# leaving 50 assessed.
#
# Studies neither included nor excluded (4 ongoing trials without results; any study still awaiting
# classification) are reported in a footnote, so assessed = included + excluded + awaiting + ongoing.
# Wafy 2021 was excluded on integrity grounds by lead decision on 10 Nov 2026 (trials.csv final_set).
#
# Counts that are not yet settled render as "TBD" (NA, or a sentinel where the package drops an NA line). Blockers: PRISMA_draft_2026-11-10.md.
#
# Wired into the targets pipeline (target `prisma_flow` in _targets.R). Paths are relative to analysis/.
# Output: output/figures/prisma_flow_draft.{png,pdf}

library(PRISMA2020)
library(dplyr)

SENTINEL <- 123454321L  # improbable count, rewritten to "TBD" after rendering

recs <- readxl::read_excel("../cap_steroids_extraction.xlsx", sheet = "records")
final_set <- with(utils::read.csv("../trials.csv"), setNames(final_set, trial_id))

# Records that are not trial reports but report data on included trials (Smit IPD synthesis:
# 2023 conference abstract and 2025 full report) count as reports of included studies.
ipd_synthesis <- c("R2299", "R2626")
ongoing <- c("RECORDS", "ASTEROIDS", "HONG2022", "COLOSSEUM2020")
no_cap_subgroup <- "No pneumonia/CAP subgroup with arm-level mortality"
excl_reason <- c(
  MUHAMMAD2025 = "Study integrity concerns", SABRY2011 = "Study integrity concerns",
  WAFY2021 = "Study integrity concerns",
  MEDURI1998 = no_cap_subgroup, LASRS2006 = no_cap_subgroup, CICARELLI2007 = no_cap_subgroup,
  DEXAARDS2020 = no_cap_subgroup, CORTICUS_BERLIN_KONIG2021 = no_cap_subgroup,
  CORTIFLU = "Design paper without arm-level results",
  BERNARD1987 = "No CAP subgroup expected (OCR check pending)")

recs <- recs |>
  mutate(set = unname(final_set[trial_id]),
         class = case_when(
           startsWith(file_status, "duplicate_of") ~ "not_retrieved",  # wrong PDF in folder
           record_id %in% ipd_synthesis ~ "included",
           set %in% c("primary", "sensitivity") ~ "included",
           set == "pending" ~ "awaiting",
           trial_id %in% ongoing ~ "ongoing",
           trial_id %in% names(excl_reason) ~ "excluded"),
         reason = unname(excl_reason[trial_id]))
stopifnot(!anyNA(recs$class), nrow(recs) == 55)

n_class <- \(k) sum(recs$class == k)
inc <- filter(recs, class == "included", !record_id %in% ipd_synthesis)
n_studies <- n_distinct(inc$trial_id)
stopifnot(n_studies == sum(final_set %in% c("primary", "sensitivity")))
excl <- count(filter(recs, class == "excluded"), reason, sort = TRUE)
assessed <- nrow(recs) - n_class("not_retrieved")
stopifnot(assessed == n_class("included") + sum(excl$n) + n_class("awaiting") + n_class("ongoing"))
# the workbook's non-O1 rows are the "assessed" reports plus the 2 wrong PDFs; the 3 O1 registrations are ongoing
stopifnot(sum(recs$screen_code == "O1" & recs$class == "ongoing") == 3L)

# The 8 full texts still to obtain (El-Ghamrawy 2006, Li (Gang) 2016, Zhou 2015, Wagner 1956, Soboleva 2000,
# Dambrava 2006, Oh 2009, Kapisyzi 2012) were found by the database searches (R0437, R1251, R1098, R0001, R0235,
# R0424, R0685, R0879; codes I1 and I4), so they are database-arm reports sought and not retrieved, not other methods.
# Other methods = the 7 trials found by hand-searching the inclusion lists and not retrieved by the databases
# (the Pitre 2025 sepsis/ARDS list: Annane 2006, Meduri 2007, Rezk 2013, VANISH, HYPRESS, ADRENAL, Annane 2018 main;
# prisma_counts.json). Provisional: none obtained or classified yet.
other_to_obtain <- c("Annane 2006", "Meduri 2007", "Rezk 2013", "VANISH", "HYPRESS", "ADRENAL", "Annane 2018 (APROCCHSS main)")

# Screening log counts (constants from prisma_counts.json; see above)
N_SCREENED <- 2798L; N_EXCLUDED_TA <- 2663L; N_RETAINED <- 135L
N_SOUGHT <- 105L; N_O1 <- 30L; N_CITATION <- 7L
stopifnot(N_SCREENED - N_EXCLUDED_TA == N_RETAINED, N_SOUGHT + N_O1 == N_RETAINED,
          length(other_to_obtain) == N_CITATION)
# Of the 105 sought, 52 are workbook rows (the 3 O1 registrations are outside the 105)
n_sought_in_wb <- sum(recs$screen_code != "O1")
n_wb_assessed <- sum(recs$screen_code != "O1" & recs$class != "not_retrieved")
n_unclassified <- N_SOUGHT - n_sought_in_wb          # 53 = 8 candidate main reports + 12 Block D + 33 companions
stopifnot(n_sought_in_wb == 52L, n_unclassified == 53L)

# Status of those 53, decided by the lead on 10 Nov 2026 (option B: keep the log's 105 as "sought"):
# one row per report in PRISMA_unclassified_reports_2026-11-10.csv (repo root).
unclass <- utils::read.csv("../PRISMA_unclassified_reports_2026-11-10.csv", stringsAsFactors = FALSE)
stopifnot(nrow(unclass) == n_unclassified, !any(unclass$proposed_status == "obtained but not entered"))
n_sought_nr <- sum(unclass$proposed_status == "sought and not retrieved")   # 14: not obtained
n_not_sought <- sum(unclass$proposed_status == "not sought")                # 39: no document to retrieve
stopifnot(n_sought_nr + n_not_sought == n_unclassified)
# not retrieved = not sought + sought but not obtained + the 2 wrong PDFs in the workbook; assessed = the rest
n_not_retrieved <- n_not_sought + n_sought_nr + n_class("not_retrieved")  # 55
n_assessed_db <- N_SOUGHT - n_not_retrieved                               # 50
stopifnot(n_assessed_db == n_wb_assessed,
          n_assessed_db == n_class("included") + sum(excl$n) + n_class("awaiting") +
            sum(recs$screen_code != "O1" & recs$class == "ongoing"))

tp <- utils::read.csv(system.file("extdata", "PRISMA.csv", package = "PRISMA2020"),
                      stringsAsFactors = FALSE)
setn <- function(df, key, val) { df$n[df$data == key] <- as.character(val); df }

counts <- list(
  previous_studies = 0, previous_reports = 0,          # no previous version of the review
  database_results = 3836,                             # incl. Block D; 3,931 minus the 95-record pre-1995 file counted twice (confirmed 10 Nov)
  register_results = 0,                                # ClinicalTrials.gov and ICTRP were not searched (protocol amended 10 Nov)
  website_results = 0, organisation_results = 0,       # not part of the search plan
  citations_results = N_CITATION,                      # 7 hand-searched trials not retrieved by the databases (provisional)
  duplicates = 1038,                                   # 3,836 - 2,798 (was 1,133 before the double count was removed)
  excluded_automatic = 0, excluded_other = 0,
  records_screened = N_SCREENED,
  records_excluded = N_EXCLUDED_TA,                    # from the screening log (10 Nov)
  dbr_sought_reports = N_SOUGHT,                       # reports to retrieve (I1 + I2 + I3 + I4)
  dbr_notretrieved_reports = n_not_retrieved,          # 55 = 39 not sought + 14 not obtained + 2 wrong PDFs
  dbr_assessed = n_assessed_db,                        # 50 = 36 included trial reports + 11 excluded + 1 ongoing (RECORDS) + 2 Smit IPD records
  other_sought_reports = length(other_to_obtain),
  other_notretrieved_reports = length(other_to_obtain), # none obtained yet
  other_assessed = 0,
  new_studies = n_studies, new_reports = n_class("included"),
  total_studies = n_studies, total_reports = n_class("included"))
for (k in names(counts)) tp <- setn(tp, k, counts[[k]])
tp <- setn(tp, "dbr_excluded", paste(excl$reason, excl$n, sep = ", ", collapse = "; "))
tp <- setn(tp, "other_excluded", "Not yet assessed, 0")

fd <- PRISMA_flowdiagram(PRISMA_data(tp), interactive = FALSE, previous = FALSE, other = TRUE,
                         detail_databases = FALSE, detail_registers = FALSE)

# NA placeholders and the sentinel both read as "TBD"
fd$x$diagram <- gsub("(n = NA)", "(n = TBD)", fd$x$diagram, fixed = TRUE)
fd$x$diagram <- gsub(format(SENTINEL, big.mark = ","), "TBD", fd$x$diagram, fixed = TRUE)

# Footnote node under the diagram (graphviz "\l" = left-justified line break)
awaiting <- filter(recs, class == "awaiting")
footnote <- c(
  "DRAFT. TBD = count not yet available (see PRISMA_draft_2026-11-10.md).",
  "Boxes from 'Reports sought' downward count reports (full-text records); the included box gives studies and their reports.",
  "Block D (supplementary sepsis/ARDS search, 21 retained records, 9 in the workbook) is counted in the database arm only.",
  "Databases 3,836: Ovid MEDLINE 349 (pre-1995 file counted once; the primary set, line 28, was not exported), PubMed 293, Embase 2,462, CENTRAL 732. ClinicalTrials.gov and WHO ICTRP were not searched.",
  sprintf("Of the %d reports sought (screening log), %d were not retrieved: %d with no document to retrieve (%d registry entries, 8 conference abstracts, 1 superseded preprint), %d sought but not obtained (8 candidate main reports, 3 Block D journal reports, 3 companion protocols or appendices) and %d wrong PDFs. %d were assessed.",
          N_SOUGHT, n_not_retrieved, n_not_sought, sum(unclass$proposed_status == "not sought" & grepl("registry", unclass$group)),
          n_sought_nr, n_class("not_retrieved"), n_assessed_db),
  sprintf("Of the %d assessed, %s%d is ongoing without results (RECORDS). Three further ongoing trials (ASTEROIDS, Hong 2022, COLOSSEUM) come from registrations outside the %d sought; the screening log lists %d registered or ongoing trials in all (O1).",
          n_assessed_db, if (nrow(awaiting) > 0) paste0(paste(sub(",.*", "", awaiting$first_author), awaiting$year, collapse = ", "), " awaiting classification and ") else "",
          sum(recs$screen_code != "O1" & recs$class == "ongoing"), N_SOUGHT, N_O1),
  sprintf("Other methods: %d hand-searched trials not retrieved by the databases (%s); provisional. The 8 texts still to obtain (El-Ghamrawy, Li (Gang), Zhou, Wagner, Soboleva, Dambrava, Oh, Kapisyzi) were found by the databases and are in the database arm.",
          length(other_to_obtain), paste(other_to_obtain, collapse = ", ")))
fn_node <- sprintf(
  'fn [shape = plaintext, style = solid, height = 0.8, fontsize = 7, fontname = Helvetica, color = White, width = 16, pos = "8.25,-0.55!", label = "%s\\l"]',
  paste(gsub('"', "'", footnote), collapse = "\\l"))
close_at <- max(gregexpr("}", fd$x$diagram, fixed = TRUE)[[1]])  # brace closing the digraph
fd$x$diagram <- paste0(substr(fd$x$diagram, 1, close_at - 1), fn_node, "\n}")

dir.create("output/figures", showWarnings = FALSE, recursive = TRUE)
# Full-text exclusions by reason, for the Methods page (published with the site)
excl_studies <- recs |>
  filter(class == "excluded") |>
  arrange(year) |>
  group_by(trial_id) |>
  summarise(reason = first(reason), study = paste(sub("[, ].*", "", first(first_author)), first(year)), .groups = "drop")
excl_tbl <- full_join(
  count(filter(recs, class == "excluded"), Reason = reason, name = "Reports"),
  excl_studies |> group_by(Reason = reason) |>
    summarise(Studies = n(), `Studies (author year)` = paste(sort(study), collapse = "; "), .groups = "drop"),
  by = "Reason") |>
  arrange(desc(Reports), Reason)
stopifnot(sum(excl_tbl$Reports) == sum(excl$n))
utils::write.csv(excl_tbl, "output/tables/prisma_exclusions.csv", row.names = FALSE)

PRISMA_save(fd, "output/figures/prisma_flow_draft.png", filetype = "PNG", overwrite = TRUE)
PRISMA_save(fd, "output/figures/prisma_flow_draft.pdf", filetype = "PDF", overwrite = TRUE)
