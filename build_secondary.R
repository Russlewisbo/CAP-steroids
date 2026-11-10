# Build the secondary-outcome analysis dataset and the verification worklist for the second extractor.
#
# Rules R1-R7 and answers to Q1-Q6 in SECONDARY_OUTCOMES_PLAN.md (approved by the lead, 10 Nov 2026).
# Source: the outcomes_binary sheet of cap_steroids_extraction.xlsx (export of the extraction database).
# The selection is an explicit table (one line per trial x outcome) so that every choice can be read and
# checked against the plan; the script stops if a selected row is missing or duplicated in the source.
#
# Outputs (repository root):
#   analysis_secondary.csv                         one row per trial x outcome, with status and fit flags
#   verification_worklist_secondary_2026-11-10.xlsx / .csv   one row per trial x outcome for M. Annes
#
# Run from the repository root:  Rscript build_secondary.R
# Never edit the outputs by hand: change the database (and re-export) or this selection table, then re-run.

suppressPackageStartupMessages({ library(dplyr); library(tidyr); library(tibble) })

xlsx <- "cap_steroids_extraction.xlsx"
ob <- readxl::read_excel(xlsx, "outcomes_binary")
trials <- read.csv("trials.csv")
final_set <- setNames(trials$final_set, trials$trial_id)
study_label <- setNames(trials$study_label, trials$trial_id)

# status:
#   pooled           enters the pooled fit(s)
#   pooled_flagged   enters the pooled fit(s); dropped in the R3/Q5 sensitivity fit (long window)
#   pending_check    not pooled until the source check named in `decision` is resolved
#   excluded         not pooled (reason in `decision`)
#   descriptive      reported in the descriptive table only (R2: one arm missing)
sel <- tribble(
  ~outcome,              ~trial_id,              ~timepoint,     ~source_outcome,          ~status,          ~decision,
  # Secondary infection (R3)
  "secondary_infection", "CONFALONIERI2005",     "end_of_study", "secondary_infection",    "pooled",         "R3: only window",
  "secondary_infection", "DEQUIN2023",           "d28",          "secondary_infection",    "pooled",         "R3",
  "secondary_infection", "APROCCHSS_CAP2024",    "d180",         "secondary_infection",    "pooled_flagged", "R3/Q5: only window; long window, flagged",
  "secondary_infection", "TORRES2015",           "in_hospital",  "secondary_infection",    "pooled",         "R3",
  "secondary_infection", "STEP2015",             "d30",          "secondary_infection",    "pooled",         "R3: d30 preferred over d180",
  "secondary_infection", "MEIJVIS2011",          "in_hospital",  "secondary_infection",    "pooled",         "R3",
  "secondary_infection", "SNIJDERS2010",         "d30",          "secondary_infection",    "pooled",         "R3",
  "secondary_infection", "TONGYOO2016",          "d28",          "secondary_infection",    "pooled",         "R3",
  "secondary_infection", "MIKAMI2007",           "in_hospital",  "secondary_infection",    "descriptive",    "R2: control arm not reported",
  # GI bleeding (R3)
  "gi_bleeding",         "CONFALONIERI2005",     "end_of_study", "gi_bleeding",            "pooled",         "R3: only window",
  "gi_bleeding",         "DEQUIN2023",           "d28",          "gi_bleeding",            "pooled",         "R3",
  "gi_bleeding",         "APROCCHSS_CAP2024",    "d28",          "gi_bleeding",            "pooled",         "R3",
  "gi_bleeding",         "TORRES2015",           "in_hospital",  "gi_bleeding",            "pooled",         "R3",
  "gi_bleeding",         "STEP2015",             "d30",          "gi_bleeding",            "pooled",         "R3",
  "gi_bleeding",         "NAFAE2013",            "d7",           "gi_bleeding",            "pooled",         "R3: only window",
  "gi_bleeding",         "TONGYOO2016",          "d28",          "gi_bleeding",            "pooled",         "R3",
  "gi_bleeding",         "FERNANDEZSERRANO2011", "in_hospital",  "gi_bleeding",            "descriptive",    "R2: control arm not reported",
  # Hyperglycaemia (R3, R5: treated definition where both are reported)
  "hyperglycaemia",      "DEQUIN2023",           "d7",           "hyperglycaemia_treated", "pooled",         "R5: treated",
  "hyperglycaemia",      "APROCCHSS_CAP2024",    "d7",           "hyperglycaemia",         "pooled",         "R5: any (only definition reported)",
  "hyperglycaemia",      "TORRES2015",           "in_hospital",  "hyperglycaemia",         "pooled",         "R5: any (only definition reported)",
  "hyperglycaemia",      "STEP2015",             "in_hospital",  "hyperglycaemia_treated", "pooled",         "R5: treated",
  "hyperglycaemia",      "HAGMAN2026",           "in_hospital",  "hyperglycaemia",         "pooled",         "R5: any; safety denominators 37/33 vs 36/34 randomised, check",
  "hyperglycaemia",      "MEIJVIS2011",          "in_hospital",  "hyperglycaemia_treated", "pooled",         "R5: treated preferred over any (67/151 vs 35/153)",
  "hyperglycaemia",      "NAFAE2013",            "d7",           "hyperglycaemia",         "pooled",         "R5: any (only definition reported)",
  "hyperglycaemia",      "SNIJDERS2010",         "in_hospital",  "hyperglycaemia_treated", "pooled",         "R5: treated",
  "hyperglycaemia",      "TONGYOO2016",          "d28",          "hyperglycaemia",         "pooled",         "R5: any (only definition reported)",
  "hyperglycaemia",      "WITTERMANS2021",       "in_hospital",  "hyperglycaemia",         "pooled",         "R5: any (only definition reported)",
  "hyperglycaemia",      "FERNANDEZSERRANO2011", "in_hospital",  "hyperglycaemia_treated", "descriptive",    "R2: control arm not reported",
  # New invasive mechanical ventilation (R4)
  "imv_new",             "DEQUIN2023",           "d28",          "imv_new",                "pooled",         "R4: at-risk denominator",
  "imv_new",             "TORRES2015",           NA,             "imv_new",                "pending_check",  "Q1: separate <=72 h (4/61 vs 5/59) and 72-120 h (1/61 vs 4/59) windows overlap; use a combined count if the supplement gives one, otherwise exclude",
  "imv_new",             "STEP2015",             "d30",          "imv_new",                "pooled",         "R4",
  "imv_new",             "FERNANDEZSERRANO2011", "in_hospital",  "imv_new",                "pooled",         "R4",
  "imv_new",             "HAGMAN2026",           "d56",          "imv_new",                "pooled_flagged", "R4/Q5: only window; beyond 30 days, flagged; zero events in both arms",
  "imv_new",             "NAFAE2013",            "end_of_study", "imv_new",                "pending_check",  "Q2: include only if the source shows newly ventilated patients; otherwise exclude",
  # New septic shock (R4)
  "septic_shock_new",    "CONFALONIERI2005",     "d8",           "septic_shock_new",       "pooled",         "R4/Q3: d8 used unless end-of-study follow-up is <=30 days (then end of study, 0/23 vs 10/23)",
  "septic_shock_new",    "DEQUIN2023",           "d28",          "septic_shock_new",       "pooled",         "R4: at-risk denominator",
  "septic_shock_new",    "MEDURI2022",           "in_hospital",  "septic_shock_new",       "pooled",         "R4",
  "septic_shock_new",    "TORRES2015",           NA,             "septic_shock_new",       "pending_check",  "Q1: separate <=72 h (2/61 vs 3/59) and 72-120 h (0/61 vs 4/59) windows overlap; use a combined count if the supplement gives one, otherwise exclude",
  "septic_shock_new",    "APROCCHSS_CAP2024",    "d180",         "septic_shock_new",       "excluded",       "Q4: all patients were in septic shock at enrolment; the row counts new episodes",
  "septic_shock_new",    "FERNANDEZSERRANO2011", "in_hospital",  "septic_shock_new",       "pooled",         "R4"
)

# Severe-only (primary set) fits: new septic shock (A5) plus secondary infection and GI bleeding (Q6)
severe_fit_outcomes <- c("septic_shock_new", "secondary_infection", "gi_bleeding")

arm_of <- function(a) case_when(a == "STEROID" ~ "s", a == "CONTROL" ~ "c", TRUE ~ NA_character_)
src <- ob |>
  mutate(arm = arm_of(arm_id)) |>
  filter(!is.na(arm)) |>
  distinct(trial_id, outcome, timepoint, arm, .keep_all = TRUE)

pick <- sel |>
  left_join(src, by = c("trial_id", "source_outcome" = "outcome", "timepoint"), relationship = "one-to-many")
# Every selected (non-pending) row must exist in the source, and at most one row per arm
chk <- pick |> filter(!is.na(timepoint)) |> count(outcome, trial_id, arm)
stopifnot(!anyNA(chk$arm), all(chk$n == 1))

wide <- pick |>
  select(outcome, trial_id, timepoint, source_outcome, status, decision, arm, events, denominator,
         population, source_record_id, source_rank, page, location, quote, verified, notes) |>
  pivot_wider(names_from = arm, values_from = c(events, denominator, population, source_record_id, source_rank,
                                                page, location, quote, verified, notes)) |>
  select(-any_of(c("events_NA", "denominator_NA", "population_NA", "source_record_id_NA", "source_rank_NA",
                   "page_NA", "location_NA", "quote_NA", "verified_NA", "notes_NA")))

coalesce_chr <- \(a, b) ifelse(is.na(a) | a == "", as.character(b), as.character(a))
# Pending rows without a selected timepoint still need a place to look: take the source location of the
# rows that exist for that trial and outcome (all windows), for the worklist
hint <- src |>
  group_by(trial_id, outcome) |>
  summarise(h_record = first(source_record_id), h_rank = first(as.character(source_rank)),
            h_page = paste(unique(page), collapse = "; "),
            h_location = paste0(paste(unique(location), collapse = "; "), " (windows in source: ",
                                paste(unique(timepoint), collapse = ", "), ")"),
            .groups = "drop")
wide <- wide |>
  left_join(hint, by = c("trial_id", "source_outcome" = "outcome")) |>
  mutate(source_record_id_s = coalesce_chr(source_record_id_s, h_record),
         source_rank_s = coalesce_chr(source_rank_s, h_rank),
         page_s = coalesce_chr(page_s, h_page),
         location_s = ifelse(is.na(timepoint), h_location, location_s)) |>
  select(-starts_with("h_"))
out <- wide |>
  transmute(
    outcome, trial_id, study_label = unname(study_label[trial_id]), final_set = unname(final_set[trial_id]),
    timepoint, source_outcome,
    definition = case_when(outcome == "hyperglycaemia" & source_outcome == "hyperglycaemia_treated" ~ "treated",
                           outcome == "hyperglycaemia" ~ "any",
                           TRUE ~ "as reported"),
    population = coalesce_chr(population_s, population_c),
    r1 = events_s, n1 = denominator_s, r0 = events_c, n0 = denominator_c,
    status, decision,
    fit_all = as.integer(status %in% c("pooled", "pooled_flagged")),
    fit_severe = as.integer(status %in% c("pooled", "pooled_flagged") & final_set == "primary" &
                              outcome %in% severe_fit_outcomes),
    sensitivity_flags = paste0(ifelse(status == "pooled_flagged", "long_window;", ""),
                               ifelse(outcome == "hyperglycaemia" & source_outcome == "hyperglycaemia", "definition_any;", "")) |>
      sub(";$", "", x = _),
    source_record_id = coalesce_chr(source_record_id_s, source_record_id_c),
    source_rank = coalesce_chr(source_rank_s, source_rank_c),
    pdf_page_1based = coalesce_chr(page_s, page_c),
    location = coalesce_chr(location_s, location_c),
    quote = coalesce_chr(quote_s, quote_c),
    verified = coalesce_chr(verified_s, verified_c),
    extraction_notes = coalesce_chr(notes_s, notes_c)) |>
  arrange(match(outcome, unique(sel$outcome)), match(final_set, c("primary", "sensitivity")), study_label)

# Pooled rows need both arms and only rank-1 sources (R1, R2); fits need at least 3 trials (R6)
pooled <- filter(out, fit_all == 1)
stopifnot(!anyNA(pooled[c("r1", "n1", "r0", "n0")]), all(pooled$source_rank == "1"),
          all(pooled$r1 <= pooled$n1), all(pooled$r0 <= pooled$n0))
n_fit <- out |> group_by(outcome) |> summarise(all = sum(fit_all), severe = sum(fit_severe))
stopifnot(all(n_fit$all >= 3), all(n_fit$severe[n_fit$outcome %in% severe_fit_outcomes] >= 3))

readr::write_csv(select(out, -quote), "analysis_secondary.csv", na = "")

# ---- Verification worklist (same layout as verification_worklist_2026-10-30) ----------------------------
question <- function(o, t, st, dec) case_when(
  st == "pending_check" ~ paste("DECIDES INCLUSION.", dec),
  o == "septic_shock_new" & t == "CONFALONIERI2005" ~ "Q3: how many days is 'end of study' follow-up? If <=30, the end-of-study row (0/23 vs 10/23) replaces d8. Also check the counts below",
  st == "descriptive" ~ "Confirm that the control-arm count is really not reported (row stays descriptive); check the steroid-arm count",
  st == "excluded" ~ paste("Confirm what the row counts (row excluded).", dec),
  st == "pooled_flagged" ~ "Confirm that no shorter window is reported for this outcome; check the counts",
  grepl("Hagman|HAGMAN", t) & o == "hyperglycaemia" ~ "Check the safety denominators 37/33 (36/34 randomised) and the counts",
  TRUE ~ "Check counts, denominators, timepoint and population against the PDF")
wl <- out |>
  mutate(priority = case_when(status == "pending_check" ~ 1L,
                              fit_severe == 1 ~ 1L,
                              fit_all == 1 ~ 2L,
                              TRUE ~ 3L),
         used_in_fits = case_when(fit_severe == 1 ~ "all included; severe-only",
                                  fit_all == 1 ~ "all included",
                                  TRUE ~ "none"),
         check_question = question(outcome, trial_id, status, decision)) |>
  transmute(priority, outcome, trial_id, study_label, final_set, status, used_in_fits, timepoint, population,
            definition, steroid_events = r1, steroid_n = n1, control_events = r0, control_n = n0,
            source_record_id, source_rank, pdf_page_1based, location, quote, check_question,
            `definition_as_reported (fill in)` = NA_character_, verified_by = NA_character_,
            verified_date = NA_character_, `matches_source (Y/N)` = NA_character_,
            value_found_if_different = NA_character_, comment = NA_character_) |>
  arrange(priority, outcome, study_label)

stem <- "verification_worklist_secondary_2026-11-10"
readr::write_csv(wl, paste0(stem, ".csv"), na = "")
writexl::write_xlsx(list(worklist = wl,
                         read_me = tibble(note = c(
                           "Secondary-outcome rows selected under SECONDARY_OUTCOMES_PLAN.md (rules R1-R7, Q1-Q6 approved 10 Nov 2026).",
                           "One row per trial x outcome; both arms in one row. Check every number against the PDF page given.",
                           "Priority 1: rows that decide inclusion (pending_check) or enter a severe-only fit. Priority 2: other pooled rows. Priority 3: descriptive or excluded rows.",
                           "Fill in: definition_as_reported (how the trial defined the outcome, verbatim if short), verified_by, verified_date, matches_source (Y/N), value_found_if_different, comment.",
                           "Rows marked pending_check stay out of the analysis until the question in check_question is answered.",
                           "Do not edit the other columns; corrections go in value_found_if_different."))),
                    paste0(stem, ".xlsx"))

message(sprintf("analysis_secondary.csv: %d rows (%d pooled, %d pending check, %d descriptive, %d excluded)",
                nrow(out), sum(out$fit_all), sum(out$status == "pending_check"),
                sum(out$status == "descriptive"), sum(out$status == "excluded")))
print(as.data.frame(n_fit))
