# Secondary outcomes (PROSPERO field 25; SECONDARY_OUTCOMES_PLAN.md, rules R1-R7 approved 10 Nov 2026).
# Rows come from ../analysis_secondary.csv, built by ../build_secondary.R; never edited by hand.
# PROVISIONAL: the rows have not yet been checked by the second extractor (Status item 31).

load_secondary <- function(path = "../analysis_secondary.csv") {
  readr::read_csv(path, show_col_types = FALSE, na = c("", "NA"))
}

sec_outcome_label <- c(secondary_infection = "Secondary infection", gi_bleeding = "GI bleeding",
                       hyperglycaemia = "Hyperglycaemia", imv_new = "New invasive ventilation",
                       septic_shock_new = "New septic shock")

# Rows for one secondary-outcome fit, in the format build_stan_data() expects (all count trials).
# set: "all" = all included trials (fit_all); "severe" = primary set (fit_severe).
# variant: "main"; "no_long" drops long-window rows (R3/Q5); "treated" keeps only the treated
# hyperglycaemia definition (R5).
secondary_rows <- function(sec, mortality, outcome, set = c("all", "severe"), variant = c("main", "no_long", "treated")) {
  set <- match.arg(set); variant <- match.arg(variant)
  flag_col <- if (set == "all") "fit_all" else "fit_severe"
  agents <- dplyr::distinct(mortality, trial_id, agent_cluster)
  rows <- sec |>
    dplyr::filter(.data$outcome == !!outcome, .data[[flag_col]] == 1) |>
    dplyr::mutate(data_type = "counts", yi = NA_real_, sei = NA_real_) |>
    dplyr::left_join(agents, by = "trial_id")
  if (variant == "no_long") rows <- dplyr::filter(rows, !grepl("long_window", dplyr::coalesce(sensitivity_flags, "")))
  if (variant == "treated") rows <- dplyr::filter(rows, definition == "treated")
  stopifnot(nrow(rows) >= 3, !anyNA(rows[c("r1", "n1", "r0", "n0", "agent_cluster")]),
            !anyDuplicated(rows$trial_id))
  rows
}
