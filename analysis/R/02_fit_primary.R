# Fitting and summary functions (pure definitions; executed by _targets.R)
library(cmdstanr); library(posterior); library(dplyr); library(purrr)

# Acceptance gates from ANALYSIS_INSTRUCTIONS.md s5.1. Returns draws + diagnostics (serialisable).
fit_hma <- function(sd, stan_file, seed, adapt_delta = 0.99) {
  mod <- cmdstan_model(stan_file)
  fit <- mod$sample(data = sd, chains = 4, parallel_chains = 4, iter_warmup = 1000,
                    iter_sampling = 2000, adapt_delta = adapt_delta, max_treedepth = 12,
                    seed = seed, refresh = 0, show_messages = FALSE, show_exceptions = FALSE)
  s <- fit$summary(intersect(c("mu", "tau", "theta", "omega", "b"), fit$metadata()$stan_variables))
  dg <- fit$diagnostic_summary(quiet = TRUE)
  diag <- tibble(max_rhat = max(s$rhat), min_ess_bulk = min(s$ess_bulk), min_ess_tail = min(s$ess_tail),
                 divergences = sum(dg$num_divergent), max_treedepth_hits = sum(dg$num_max_treedepth),
                 min_ebfmi = min(dg$ebfmi),
                 pass = max_rhat < 1.01 & min_ess_bulk > 400 & min_ess_tail > 400 & divergences == 0)
  list(draws = as_draws_df(fit$draws()), sampler = fit$sampler_diagnostics(format = "df"), diag = diag,
       meta = attr(sd, "meta"), adapt_delta = adapt_delta, seed = seed)
}

hdi95 <- function(x, p = 0.95) {
  x <- sort(x); n <- length(x); m <- floor(p * n)
  i <- which.min(x[(m + 1):n] - x[1:(n - m)]); c(x[i], x[i + m])
}

# s5.5 summaries (quantile CrI and HDI both reported)
summarise_fit <- function(res, label) {
  dr <- res$draws
  or <- exp(dr$mu); h <- hdi95(or)
  pc <- res$meta$pooled_control_risk
  arr_pc <- pc - plogis(qlogis(pc) + dr$mu)
  nnt_cols <- grep("^NNT\\[", names(dr), value = TRUE)
  tibble(
    fit = label,
    OR_median = median(or), OR_q025 = quantile(or, .025), OR_q975 = quantile(or, .975),
    OR_hdi_lo = h[1], OR_hdi_hi = h[2],
    P_OR_lt_1 = mean(or < 1), P_OR_lt_0.9 = mean(or < 0.9), P_OR_lt_0.833 = mean(or < 1 / 1.2),
    P_OR_gt_1 = mean(or > 1), P_OR_gt_1.1 = mean(or > 1.1),
    tau_median = median(dr$tau), tau_q025 = quantile(dr$tau, .025), tau_q975 = quantile(dr$tau, .975),
    ORnew_median = median(dr$OR_new), ORnew_q025 = quantile(dr$OR_new, .025),
    ORnew_q975 = quantile(dr$OR_new, .975), P_ORnew_lt_1 = mean(dr$OR_new < 1),
    pooled_control_risk = pc,
    NNT_median_pooled = median(1 / arr_pc), ARR_pooled_median = median(arr_pc),
    ARR_pooled_q025 = quantile(arr_pc, .025), ARR_pooled_q975 = quantile(arr_pc, .975),
    NNT_median_10 = median(dr[[nnt_cols[1]]]), NNT_median_20 = median(dr[[nnt_cols[2]]]),
    NNT_median_30 = median(dr[[nnt_cols[3]]]),
    P_ARR_gt_1pt_at_pooled = mean(arr_pc > 0.01))
}

# Agent-level summary (F1-agent): per-cluster OR, omega, and P(hydrocortisone more favourable)
agent_summary <- function(res, rows, label) {
  agents <- res$meta$agents; dr <- res$draws
  ors <- sapply(seq_along(agents), \(j) dr[[sprintf("OR_agent[%d]", j)]])
  colnames(ors) <- agents
  n_tr <- table(factor(rows$agent_cluster, levels = agents))
  hc <- if ("hydrocortisone" %in% agents) ors[, "hydrocortisone"] else NULL
  tibble(fit = label, agent = agents, n_trials = as.integer(n_tr),
         OR_median = apply(ors, 2, median), OR_q025 = apply(ors, 2, quantile, .025),
         OR_q975 = apply(ors, 2, quantile, .975), P_OR_lt_1 = apply(ors, 2, \(x) mean(x < 1)),
         P_HC_more_favourable = if (is.null(hc)) NA_real_ else
           sapply(agents, \(a) if (a == "hydrocortisone") NA_real_ else mean(hc < ors[, a])),
         omega_median = median(dr$omega), omega_q025 = quantile(dr$omega, .025),
         omega_q975 = quantile(dr$omega, .975), omega_prior_median = 0.25 * qnorm(0.75))
}

# LOO-PSIS on the count trials: per arm, and per trial (both arms summed = leave-one-trial-out)
loo_tab <- function(res, label) {
  dr <- res$draws; kb <- length(res$meta$trials_b); ids <- res$meta$trials_b
  if (kb == 0) return(tibble(fit = character(), level = character(), unit = character(),
                             pareto_k = numeric(), elpd_loo = numeric(), p_loo = numeric()))
  nm <- sprintf("log_lik[%d]", seq_len(2 * kb))
  M <- as.matrix(as.data.frame(dr)[, nm, drop = FALSE])
  ch <- dr$.chain
  one <- \(m, unit, level) {
    l <- suppressWarnings(loo::loo(m, r_eff = loo::relative_eff(exp(m), chain_id = ch, cores = 1)))
    tibble(fit = label, level = level, unit = unit, pareto_k = l$diagnostics$pareto_k,
           elpd_loo = l$pointwise[, "elpd_loo"], p_loo = l$pointwise[, "p_loo"])
  }
  bind_rows(
    one(M, c(paste(ids, "control"), paste(ids, "steroid")), "arm"),
    one(M[, 1:kb, drop = FALSE] + M[, kb + 1:kb, drop = FALSE], ids, "trial"))
}

# Smallest prior SD at which a probability metric reaches `target` (linear interpolation).
# Metric rises with prior SD: skepticism shrinks it. NA = not reached / already above at smallest SD.
tip_thresholds <- function(tab, metric, targets = c(0.90, 0.80)) {
  tab <- arrange(tab, prior_sd)
  purrr::map_dfr(targets, \(t) {
    y <- tab[[metric]]; x <- tab$prior_sd
    i <- which(y >= t)[1]
    val <- if (is.na(i)) NA_real_ else if (i == 1) NA_real_ else
      x[i - 1] + (t - y[i - 1]) * (x[i] - x[i - 1]) / (y[i] - y[i - 1])
    tibble(metric = metric, target = t, prior_sd_at_crossing = val,
           note = if (is.na(i)) "never reached on grid" else if (i == 1) "already above at smallest SD" else "")
  })
}

# ---- Row selection for any fit spec ------------------------------------------------------
drop_flag <- \(rows, flag) filter(rows, !grepl(flag, coalesce(sensitivity_flags, ""), fixed = TRUE))

# S-IPD: replace rank-1 rows by the Smit 2025 IPD rank-2 rows for trials that have one (never merged)
swap_ipd <- function(rows, d) {
  ipd <- filter(d, fit_ipd_crosscheck == 1, trial_id %in% rows$trial_id)
  stopifnot(!anyDuplicated(ipd$trial_id))
  bind_rows(filter(rows, !trial_id %in% ipd$trial_id), ipd)
}

# S-iii: every count trial as log-OR + SE; 0.5 added to all four cells if any cell is zero;
# double-zero trials dropped (hard rule 5). Counts are kept in r*/n* for pooled control risk only.
to_contrast <- function(rows) {
  rows |>
    filter(!(data_type == "counts" & r1 == 0 & r0 == 0)) |>
    mutate(cc = data_type == "counts" & (r1 == 0 | r0 == 0 | r1 == n1 | r0 == n0),
           a = r1 + 0.5 * cc, b = n1 - r1 + 0.5 * cc, c = r0 + 0.5 * cc, d = n0 - r0 + 0.5 * cc,
           yi = if_else(data_type == "counts", log(a * d / (b * c)), yi),
           sei = if_else(data_type == "counts", sqrt(1 / a + 1 / b + 1 / c + 1 / d), sei),
           data_type = "contrast") |>
    select(-cc, -a, -b, -c, -d)
}

# Alternative denominators used by Pitre 2025 (Supplement Fig. S22); numerators unchanged
alt_denominator <- function(rows, trial, n1 = NULL, n0 = NULL) {
  i <- rows$trial_id == trial; stopifnot(sum(i) == 1)
  if (!is.null(n1)) rows$n1[i] <- n1
  if (!is.null(n0)) rows$n0[i] <- n0
  stopifnot(rows$r1[i] <= rows$n1[i], rows$r0[i] <= rows$n0[i])
  rows
}

make_rows <- function(d, set, variant, drop_remap) {
  rows <- if (set == "F1" && variant %in% names(variant_labels)) f1_rows(d, variant)
          else if (variant == "S_den_escape") f1_rows(d, "D1a")
          else select_rows(d, fit_cols[[set]])
  rows <- switch(variant,
    S_den_confal = alt_denominator(rows, "CONFALONIERI2005", n0 = 22L),
    S_den_escape = alt_denominator(rows, "MEDURI2022", n1 = 297L, n0 = 287L),
    S_den_nafae = alt_denominator(rows, "NAFAE2013", n0 = 20L),
    S_vi = drop_flag(rows, "subgroup_derived"),
    S_viii = drop_flag(rows, "mineralocorticoid"),
    S_ix = drop_flag(rows, "short_course_lt48h"),
    S_IPD = swap_ipd(rows, d),
    S_iii = to_contrast(rows),
    rows)
  if (drop_remap) rows <- filter(rows, trial_id != "REMAPCAP2025")
  rows
}

# S-ii stub: low-RoB-only fit, parameterised by the judgements table (trial_id, rob2_overall_mortality)
rob_status <- function(trials) count(trials, rob2_overall_mortality)
s_ii_rows <- function(rows, trials) {
  rob <- distinct(trials, trial_id, rob2_overall_mortality)
  if (any(rob$rob2_overall_mortality[rob$trial_id %in% rows$trial_id] == "PENDING"))
    stop("S-ii not run: RoB 2 judgements are PENDING (hard-coded stub until the lead supplies them).")
  rows |> left_join(rob, by = "trial_id") |> filter(rob2_overall_mortality == "low")
}

# ---- Meta-regression (one covariate at a time) -------------------------------------------
# Coding of the covariates in trials.csv. timing_le24h is coded here by hand (rule below).
timing_coding <- tibble::tribble(
  ~trial_id, ~timing_le24h, ~timing_basis,
  "APROCCHSS_CAP2024", 1, "septic shock <24 h at enrolment (relative to shock onset, approximate)",
  "CONFALONIERI2005", NA, "at ICU study entry; window from admission not stated",
  "DEQUIN2023", 1, "within 24 h of severity onset; median 15 h from ICU admission",
  "MARIK1993", 1, "30 min before antibiotics, in ICU",
  "MEDURI2022", 0, "within 72-96 h of presentation; median 40 h",
  "REMAPCAP2025", 1, "<=24 h after ICU admission (median 8.2 h)",
  "TORRES2015", 0, "within 36 h of admission (stated maximum >24 h)",
  "FERNANDEZSERRANO2011", 1, "at diagnosis, 30 min before antibiotics",
  "HAGMAN2026", 0, "median 2 days to randomisation",
  "MCHARDY1972", 1, "on admission",
  "MEIJVIS2011", 1, "within 12 h of ED admission",
  "MIKAMI2007", 1, "on day of admission",
  "NAFAE2013", NA, "not stated",
  "SNIJDERS2010", 1, "within 24 h of admission",
  "SONIA2025", 0, "within 48 h of admission (stated maximum >24 h; hours not recorded)",
  "STEP2015", 1, "within 24 h of presentation (36 h at weekends)",
  "TONGYOO2016", 1, "within 12 h of meeting ARDS criteria",
  "WITTERMANS2021", 1, "within 24 h of ED presentation")
# Rule: 1 = stated maximum window to first dose <=24 h from admission/ED/ICU/severity onset; 0 = stated
# maximum or median >24 h; NA = no window reported.

mr_covariates <- tibble::tribble(
  ~covariate,           ~type,
  "pct_septic_shock_baseline", "continuous",
  "pct_imv_baseline",   "continuous",
  "pct_influenza_viral", "continuous",
  "prednisone_equiv_mg_day", "continuous",
  "duration_days",      "continuous",
  "age_central_trial",  "continuous",
  "pct_psi_4_5_trial",  "continuous",
  "timing_le24h",       "binary",
  "high_income",        "binary",
  "icu_setting",        "binary",
  "double_blind",       "binary",
  "mineralocorticoid",  "binary",
  "severe_population",  "binary")

code_covariates <- function(trials) {
  trials |>
    left_join(timing_coding, by = "trial_id") |>
    transmute(trial_id, pct_septic_shock_baseline, pct_imv_baseline, pct_influenza_viral,
              prednisone_equiv_mg_day, duration_days, age_central_trial, pct_psi_4_5_trial,
              timing_le24h,
              high_income = as.numeric(grepl("^(predominantly )?high-income", resource_level)),
              icu_setting = as.numeric(setting == "ICU"),
              double_blind = if_else(blinding == "unclear", NA_real_, as.numeric(blinding == "double-blind placebo")),
              mineralocorticoid = as.numeric(mineralocorticoid != "none"),
              severe_population = as.numeric(severity_population == "severe"))
}

# Returns one row; status "ineligible" if <4 trials with data or no variation (nothing is fitted)
mr_run <- function(rows, cov_tbl, set, covariate, type, stan_file_mr, seed, b_prior_sd = 1) {
  r <- rows |> left_join(select(cov_tbl, trial_id, x_raw = all_of(covariate)), by = "trial_id") |>
    filter(!is.na(x_raw))
  n_tr <- nrow(r); n_dist <- n_distinct(r$x_raw)
  base <- tibble(set = set, covariate = covariate, type = type, n_trials = n_tr, n_distinct_x = n_dist,
                 n_group1 = if (type == "binary") sum(r$x_raw == 1) else NA_integer_)
  if (n_tr < 4 || n_dist < 2)
    return(mutate(base, status = "ineligible",
                  reason = if (n_tr < 4) sprintf("only %d trials with data", n_tr) else "no variation in covariate"))
  r <- bind_rows(filter(r, data_type == "counts"), filter(r, data_type == "contrast"))
  x <- if (type == "continuous") (r$x_raw - mean(r$x_raw)) / sd(r$x_raw) else r$x_raw - mean(r$x_raw)
  sd_list <- build_stan_data(r, mu_mean = 0, mu_sd = 1, extra = list(x = as.array(x), b_prior_sd = b_prior_sd))
  res <- fit_hma(sd_list, stan_file_mr, seed)
  dr <- res$draws
  mutate(base, status = "fitted", reason = "",
         b_median = median(dr$b), b_q025 = quantile(dr$b, .025), b_q975 = quantile(dr$b, .975),
         P_b_lt_0 = mean(dr$b < 0),
         OR_at_mean_median = median(exp(dr$mu)), OR_at_mean_q025 = quantile(exp(dr$mu), .025),
         OR_at_mean_q975 = quantile(exp(dr$mu), .975), tau_median = median(dr$tau),
         divergences = res$diag$divergences, max_rhat = res$diag$max_rhat,
         min_ess_bulk = res$diag$min_ess_bulk, pass = res$diag$pass,
         x_sd_or_unit = if (type == "continuous") sd(r$x_raw) else 1)
}

# F1 row sets: default plus D1 alternatives (ESCAPe swapped) and D2 alternatives (REMAP-CAP handling)
f1_rows <- function(d, variant = c("default", "D1a", "D1b", "D2a", "D2b", "D2c_se030", "D2c_se045")) {
  variant <- match.arg(variant)
  base <- \(...) select_rows(d, "fit_primary_short", ...)
  switch(variant,
    default = , D2c_se030 = , D2c_se045 = base(),
    D1a = base(swap = one_row(filter(d, trial_id == "MEDURI2022", timepoint == "d60"))),
    D1b = base(swap = one_row(filter(d, trial_id == "MEDURI2022", fit_ipd_crosscheck == 1))),
    # ICU-discharge adjusted contrast (log-OR 0.399, SE 0.487), from analysis_mortality.csv
    D2a = base(swap = one_row(filter(d, trial_id == "REMAPCAP2025", timepoint == "ICU", data_type == "contrast"))),
    D2b = base(drop_trials = "REMAPCAP2025"))
}
one_row <- function(x) { stopifnot(nrow(x) == 1); x }

# SE sensitivity for the default d90 contrast (D2c); NULL keeps the CSV value (0.362)
se_override <- c(D2c_se030 = 0.30, D2c_se045 = 0.45)

variant_labels <- c(
  default = "F1 default (ESCAPe in-hospital; REMAP-CAP d90 contrast SE 0.362)",
  D1a = "D1a (ESCAPe d60 47/286 v 50/277)",
  D1b = "D1b (ESCAPe IPD d30 40/297 v 40/287, rank 2)",
  D2a = "D2a (REMAP-CAP ICU-discharge contrast, log-OR 0.399, SE 0.487)",
  D2b = "D2b (REMAP-CAP excluded)",
  D2c_se030 = "D2c (REMAP-CAP d90 SE 0.30)",
  D2c_se045 = "D2c (REMAP-CAP d90 SE 0.45)")

# ---- Exact leave-one-trial-out predictive check -----------------------------------------
# Held-out trial k, hyperparameters from the fit WITHOUT k. Predictive log density of the
# treatment arm GIVEN the control arm (counts), p(r1 | r0, D_-k), via
#   E_phi[ p(r0, r1 | phi) ] / E_phi[ p(r0 | phi) ],  alpha_k integrated on a grid.
# (Joint p(r0, r1) is dominated by the unidentified held-out baseline, so we condition on r0.)
# Contrast trial: y ~ Normal(mu, sqrt(tau^2 + se^2)), averaged over draws.
loto_elpd <- function(res, rows, trial, model = c("unpooled", "pooled"), n_theta = 4, seed = 3819L,
                      chunk = 500L, alpha_prior_sd = 10) {
  model <- match.arg(model)
  set.seed(seed)
  dr <- res$draws; mu <- dr$mu; tau <- dr$tau
  h <- filter(rows, trial_id == trial); stopifnot(nrow(h) == 1)
  if (h$data_type == "contrast") {
    lp <- log(mean(dnorm(h$yi, mu, sqrt(tau^2 + h$sei^2))))
    return(tibble(trial = trial, model = model, type = "contrast", elpd = lp))
  }
  grid <- seq(-12, 12, length.out = 961); dx <- grid[2] - grid[1]
  lik0 <- dbinom(h$r0, h$n0, plogis(grid))
  nd <- length(mu); idx <- split(seq_len(nd), ceiling(seq_len(nd) / chunk))
  num <- 0; den <- 0
  for (ii in idx) {
    n <- length(ii)
    prior <- if (model == "unpooled") matrix(dnorm(grid, 0, alpha_prior_sd) * dx, n, length(grid), byrow = TRUE)
             else dnorm(matrix(grid, n, length(grid), byrow = TRUE), mean = dr$a0[ii], sd = dr$sigma_a[ii]) * dx
    w0 <- sweep(prior, 2, lik0, `*`)
    den <- den + sum(rowSums(w0))
    for (t in seq_len(n_theta)) {
      th <- rnorm(n, mu[ii], tau[ii])
      lik1 <- matrix(dbinom(h$r1, h$n1, plogis(outer(th, grid, `+`))), n, length(grid))
      num <- num + sum(rowSums(w0 * lik1))
    }
  }
  tibble(trial = trial, model = model, type = "counts",
         elpd = log(num / (nd * n_theta)) - log(den / nd))
}

# Wide table of LOTO ELPDs per trial (columns unpooled, pooled)
elpd_wide <- function(long) {
  u <- long |> filter(model == "unpooled") |> select(trial, unpooled = elpd)
  p <- long |> filter(model == "pooled") |> select(trial, pooled = elpd)
  inner_join(u, p, by = "trial") |> mutate(diff_pooled_minus_unpooled = pooled - unpooled)
}
