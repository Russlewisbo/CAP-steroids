library(dplyr)
library(readr)

# Prior ladder (D3: enthusiastic/reference/skeptical are proposals; harm rungs protocol-fixed)
prior_ladder <- tibble::tribble(
  ~rung,            ~mu_mean,    ~mu_sd,
  "enthusiastic",   log(0.70),   0.20,
  "reference",      0,           1.0,
  "skeptical",      0,           0.35,
  "mild_harm",      log(1.10),   0.20,
  "remap_harm",     log(1.50),   0.35
)

# Hyperprior defaults (D4)
default_hyper <- list(tau_prior_sd = 0.5, omega_prior_sd = 0.25, alpha_prior_sd = 10)

load_mortality <- function(path = "../analysis_mortality.csv") {
  read_csv(path, show_col_types = FALSE, na = c("", "NA"))
}

fit_cols <- c(F1 = "fit_primary_short", F2 = "fit_primary_d90",
              F3 = "fit_broad_severe", F4 = "fit_all_hospitalised",
              IPD = "fit_ipd_crosscheck")

# Hard-coded expectations from ANALYSIS_INSTRUCTIONS.md s3.1; stops on any violation
check_membership <- function(d) {
  n_rows <- sapply(fit_cols[1:4], \(cl) sum(d[[cl]] == 1))
  n_tr   <- sapply(fit_cols[1:4], \(cl) n_distinct(d$trial_id[d[[cl]] == 1]))
  n_con  <- sapply(fit_cols[1:4], \(cl) sum(d[[cl]] == 1 & d$data_type == "contrast"))
  stopifnot(
    identical(unname(n_rows), c(7L, 3L, 10L, 17L)),
    identical(unname(n_tr),   c(7L, 3L, 10L, 17L)),
    all(n_con == 1L),
    d$trial_id[d$data_type == "contrast"] == "REMAPCAP2025",
    # no REMAP-CAP counts anywhere in a likelihood
    all(is.na(d$r1[d$data_type == "contrast"])),
    # rank-2 rows only in IPD cross-check
    all(d$source_rank[d$fit_ipd_crosscheck == 1] == 2),
    all(d$source_rank[rowSums(d[fit_cols[1:4]]) > 0] == 1),
    # timepoint class purity
    all(d$timepoint_class[d$fit_primary_short == 1 | d$fit_broad_severe == 1 |
                          d$fit_all_hospitalised == 1] %in% c("short_term", "d90")),
    all(d$timepoint_class[d$fit_primary_d90 == 1] == "d90" | d$data_type[d$fit_primary_d90 == 1] == "contrast")
  )
  hag <- d |> filter(trial_id == "HAGMAN2026")
  stopifnot(hag$r1 == 0, hag$r0 == 0, hag$fit_all_hospitalised == 1,
            hag$fit_primary_short == 0)
  invisible(tibble::tibble(fit = names(n_rows), rows = n_rows, trials = n_tr, contrast = n_con))
}

# Row selection: either a fit column name, or a data frame of rows (for swaps/drops)
select_rows <- function(d, fit, drop_trials = character(), swap = NULL) {
  rows <- if (is.character(fit)) filter(d, .data[[fit]] == 1) else fit
  rows <- filter(rows, !trial_id %in% drop_trials)
  if (!is.null(swap)) rows <- bind_rows(filter(rows, !trial_id %in% swap$trial_id), swap)
  rows
}

# Build the Stan data list. Contrast rows -> normal; counts -> binomial.
# double-zero rows are kept (binomial handles them).
build_stan_data <- function(rows, mu_mean = 0, mu_sd = 1, agent_hier = 0L,
                            hyper = default_hyper, r0grid = c(0.10, 0.20, 0.30),
                            prior_only = 0L, override_se = NULL, extra = list()) {
  b <- filter(rows, data_type == "counts")
  cc <- filter(rows, data_type == "contrast")
  if (!is.null(override_se) && !is.na(override_se)) cc$sei <- override_se
  agents <- sort(unique(rows$agent_cluster))
  # pooled control risk from every row that carries arm counts (S-iii rows keep their counts)
  has_ctrl <- !is.na(rows$r0) & !is.na(rows$n0)
  pooled_ctrl <- if (any(has_ctrl)) sum(rows$r0[has_ctrl]) / sum(rows$n0[has_ctrl]) else NA_real_
  sd <- c(list(
    K_b = nrow(b), r1 = as.array(b$r1), n1 = as.array(b$n1),
    r0 = as.array(b$r0), n0 = as.array(b$n0),
    K_c = nrow(cc), y_c = as.array(cc$yi), se_c = as.array(cc$sei),
    J = length(agents),
    agent_b = as.array(match(b$agent_cluster, agents)),
    agent_c = as.array(match(cc$agent_cluster, agents)),
    agent_hier = as.integer(agent_hier),
    mu_prior_mean = mu_mean, mu_prior_sd = mu_sd,
    N_r0grid = length(r0grid), r0grid = as.array(r0grid),
    prior_only = as.integer(prior_only)), hyper, extra)
  attr(sd, "meta") <- list(trials_b = b$trial_id, trials_c = cc$trial_id,
                           agents = agents, pooled_control_risk = pooled_ctrl)
  sd
}
