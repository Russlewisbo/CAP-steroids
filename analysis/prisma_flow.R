# Draft PRISMA 2020 flow diagram (PRISMA2020 package, Haddaway et al.).
# Settled counts are from Status.md (search 20 Oct; final set 27 Oct). Every count not yet
# settled is passed as NA and rendered as "TBD"; see PRISMA_draft_2026-11-10.md for the blockers.
# Registers and Citation searching are forced to show as TBD (planned but not yet run) via a
# sentinel that is rewritten to "TBD" — the package otherwise drops a line whose value is NA.
#
# Wired into the targets pipeline (target `prisma_flow` in _targets.R), so it regenerates with the
# rest of the outputs. Paths are relative to the pipeline root, analysis/.
# Regenerate:  targets::tar_make(prisma_flow)   (or source this file with the wd set to analysis/)
# Output:      output/figures/prisma_flow_draft.{png,pdf}  (i.e. analysis/output/figures/...)

library(PRISMA2020)

SENTINEL <- 123454321L  # improbable count, rewritten to "TBD" after rendering

tp <- utils::read.csv(system.file("extdata", "PRISMA.csv", package = "PRISMA2020"),
                      stringsAsFactors = FALSE)
setn <- function(df, key, val) { df$n[df$data == key] <- as.character(val); df }

counts <- list(
  previous_studies = 0, previous_reports = 0,          # no previous version of the review
  database_results = 3931,                             # Status.md: 3,931 identified (may change)
  register_results = SENTINEL,                         # ICTRP search not yet run -> TBD
  website_results = 0, organisation_results = 0,       # not part of the search plan
  citations_results = SENTINEL,                        # citation / inclusion-list search -> TBD
  duplicates = 1133,                                   # 3,931 - 2,798
  excluded_automatic = 0, excluded_other = 0,
  records_screened = 2798,
  records_excluded = NA,                               # screening log not in repo (single AI pass) -> TBD
  dbr_sought_reports = 55,                             # Status.md (breakdown sums to 57 - reconcile)
  dbr_notretrieved_reports = NA, dbr_assessed = NA,    # retrieval log pending -> TBD
  other_sought_reports = NA, other_notretrieved_reports = NA, other_assessed = NA,
  new_studies = 18,                                    # 7 primary + 11 sensitivity
  new_reports = NA, total_studies = 18, total_reports = NA)
for (k in names(counts)) tp <- setn(tp, k, counts[[k]])

# Full-text exclusions (settled list of 9, Status.md s4, 27 Oct)
tp <- setn(tp, "dbr_excluded", paste(
  "Study integrity concerns, 2",
  "No pneumonia/CAP subgroup, 5",
  "Design paper (no arm-level results), 1",
  "Expected exclusion (OCR pending), 1", sep = "; "))
tp <- setn(tp, "other_excluded", "To be determined, ")

fd <- PRISMA_flowdiagram(PRISMA_data(tp), interactive = FALSE, previous = FALSE, other = TRUE,
                         detail_databases = FALSE, detail_registers = FALSE, meta_analysis = FALSE)

# NA placeholders and the sentinel both read as "TBD"
fd$x$diagram <- gsub("(n = NA)", "(n = TBD)", fd$x$diagram, fixed = TRUE)
fd$x$diagram <- gsub(format(SENTINEL, big.mark = ","), "TBD", fd$x$diagram, fixed = TRUE)

dir.create("output/figures", showWarnings = FALSE, recursive = TRUE)
PRISMA_save(fd, "output/figures/prisma_flow_draft.png", filetype = "PNG", overwrite = TRUE)
PRISMA_save(fd, "output/figures/prisma_flow_draft.pdf", filetype = "PDF", overwrite = TRUE)
