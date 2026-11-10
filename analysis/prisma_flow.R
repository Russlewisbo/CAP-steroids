# Draft PRISMA 2020 flow diagram (PRISMA2020 package, Haddaway et al.).
#
# Counting unit. Identification and screening boxes count records; every box from "Reports sought for
# retrieval" down counts REPORTS, derived here from the `records` sheet of the extraction workbook
# (one row per full-text record, 55 rows). The final box gives studies and reports separately.
#
# Block D (supplementary sepsis/ARDS search, protocol v2 decision A) is counted in the database arm only:
# it was run with the database searches, and its 9 retained records carry screening IDs from the same
# screening log (screen code I3). It is not counted again under "other methods".
#
# Studies neither included nor excluded (Wafy 2021, awaiting classification; 4 ongoing trials without
# results) are reported in a footnote, so assessed = included + excluded + awaiting + ongoing.
#
# Counts that are not yet settled are NA and render as "TBD"; Registers and Citation searching use a
# sentinel because the package drops an NA line there. Blockers: PRISMA_draft_2026-11-10.md.
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

# Other methods: full texts still to obtain that have no record in the database screening log
# (3 of the 8 are on the Pitre 2025 list). Provenance to be confirmed against the screening log.
other_to_obtain <- c("El-Ghamrawy 2006", "Li (Gang) 2016", "Zhou 2015", "Wagner 1956",
                     "Soboleva 2000", "Dambrava 2006", "Oh 2009", "Kapisyzi 2012")

tp <- utils::read.csv(system.file("extdata", "PRISMA.csv", package = "PRISMA2020"),
                      stringsAsFactors = FALSE)
setn <- function(df, key, val) { df$n[df$data == key] <- as.character(val); df }

counts <- list(
  previous_studies = 0, previous_reports = 0,          # no previous version of the review
  database_results = 3931,                             # incl. Block D; may change after re-export
  register_results = SENTINEL,                         # ICTRP search not yet run -> TBD
  website_results = 0, organisation_results = 0,       # not part of the search plan
  citations_results = SENTINEL,                        # inclusion-list / citation search -> TBD
  duplicates = 1133,                                   # 3,931 - 2,798
  excluded_automatic = 0, excluded_other = 0,
  records_screened = 2798,
  records_excluded = NA,                               # screening log not in repo -> TBD
  dbr_sought_reports = nrow(recs),
  dbr_notretrieved_reports = n_class("not_retrieved"),
  dbr_assessed = assessed,
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
  "Block D (supplementary sepsis/ARDS search, 9 retained records) is counted in the database arm only.",
  sprintf(paste("Of the %d reports assessed, %d are neither included nor excluded:",
                "%s (awaiting classification: integrity exclusion vs sensitivity set, lead decision pending)"),
          assessed, n_class("awaiting") + n_class("ongoing"),
          paste(sub(",.*", "", awaiting$first_author), awaiting$year)),
  sprintf("and %d ongoing trials without results (RECORDS, ASTEROIDS, Hong 2022, COLOSSEUM).", n_class("ongoing")),
  sprintf("Other methods: %d full texts to obtain (%s); provenance to confirm.",
          length(other_to_obtain), paste(other_to_obtain, collapse = ", ")))
fn_node <- sprintf(
  'fn [shape = plaintext, style = solid, height = 0.8, fontsize = 7, fontname = Helvetica, color = White, width = 16, pos = "8.25,-0.55!", label = "%s\\l"]',
  paste(gsub('"', "'", footnote), collapse = "\\l"))
close_at <- max(gregexpr("}", fd$x$diagram, fixed = TRUE)[[1]])  # brace closing the digraph
fd$x$diagram <- paste0(substr(fd$x$diagram, 1, close_at - 1), fn_node, "\n}")

dir.create("output/figures", showWarnings = FALSE, recursive = TRUE)
PRISMA_save(fd, "output/figures/prisma_flow_draft.png", filetype = "PNG", overwrite = TRUE)
PRISMA_save(fd, "output/figures/prisma_flow_draft.pdf", filetype = "PDF", overwrite = TRUE)
