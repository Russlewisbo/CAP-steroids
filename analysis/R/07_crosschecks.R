# brms cross-checks of the Stan hybrid model (other likelihood switched off) and the Pitre 2025 benchmark
library(dplyr); library(tibble); library(posterior)

brms_diag <- function(fit) {
  d <- posterior::as_draws_df(fit)
  s <- posterior::summarise_draws(d, "rhat", "ess_bulk", "ess_tail")
  s <- s[!grepl("^(lp__|lprior|Intercept)", s$variable), ]
  np <- brms::nuts_params(fit)
  tibble(max_rhat = max(s$rhat, na.rm = TRUE), min_ess_bulk = min(s$ess_bulk, na.rm = TRUE),
         min_ess_tail = min(s$ess_tail, na.rm = TRUE),
         divergences = sum(np$Value[np$Parameter == "divergent__"]))
}

# Pure-count model: same priors as the Stan model (alpha N(0,10), mu N(0,1), tau half-N(0,0.5)).
# trt = 0/1 so that trial coefficients are control-arm log-odds (unpooled baselines).
brms_count <- function(rows, seed, iter = 3000, warmup = 1000) {
  b <- filter(rows, data_type == "counts")
  long <- bind_rows(transmute(b, trial = trial_id, trt = 0, events = r0, n = n0),
                    transmute(b, trial = trial_id, trt = 1, events = r1, n = n1)) |>
    mutate(trial = factor(trial))
  pri <- c(brms::prior(normal(0, 10), class = "b"),
           brms::prior(normal(0, 1), class = "b", coef = "trt"),
           brms::prior(normal(0, 0.5), class = "sd"))
  fit <- brms::brm(brms::bf(events | trials(n) ~ 0 + trial + trt + (0 + trt | trial)),
                   data = long, family = binomial("logit"), prior = pri, chains = 4, cores = 4,
                   iter = iter, warmup = warmup, control = list(adapt_delta = 0.99, max_treedepth = 12),
                   seed = seed, backend = "cmdstanr", refresh = 0, silent = 2)
  list(draws = posterior::as_draws_df(fit), diag = brms_diag(fit), kind = "count")
}

# Pure-contrast model: yi ~ Normal(theta_k, sei), theta_k ~ Normal(mu, tau)
brms_contrast <- function(rows, seed, iter = 3000, warmup = 1000) {
  cc <- filter(rows, data_type == "contrast") |> transmute(trial = trial_id, yi, sei)
  pri <- c(brms::prior(normal(0, 1), class = "Intercept"), brms::prior(normal(0, 0.5), class = "sd"))
  fit <- brms::brm(brms::bf(yi | se(sei) ~ 1 + (1 | trial)), data = cc, family = gaussian(), prior = pri,
                   chains = 4, cores = 4, iter = iter, warmup = warmup,
                   control = list(adapt_delta = 0.99, max_treedepth = 12),
                   seed = seed, backend = "cmdstanr", refresh = 0, silent = 2)
  list(draws = posterior::as_draws_df(fit), diag = brms_diag(fit), kind = "contrast")
}

# Posterior agreement, in units of the pooled posterior SD of each quantity.
# Pre-stated criterion: |mean diff| and |median diff| < 0.10 SD; |2.5% diff| and |97.5% diff| < 0.20 SD
# (Monte Carlo error alone is ~0.02-0.05 SD at these ESS values).
compare_fits <- function(stan, brm, label) {
  ids <- c(stan$meta$trials_b, stan$meta$trials_c)
  sd_ <- stan$draws; bd <- brm$draws
  nm <- if (brm$kind == "count") c(mu = "b_trt", tau = "sd_trial__trt", slope = "trt") else
    c(mu = "b_Intercept", tau = "sd_trial__Intercept", slope = "Intercept")
  bmu <- bd[[nm["mu"]]]
  pairs <- list(mu = list(stan = sd_$mu, brms = bmu), tau = list(stan = sd_$tau, brms = bd[[nm["tau"]]]))
  for (k in seq_along(ids))
    pairs[[paste0("theta: ", ids[k])]] <- list(
      stan = sd_[[sprintf("theta[%d]", k)]],
      brms = bmu + bd[[sprintf("r_trial[%s,%s]", ids[k], nm["slope"])]])
  purrr::imap_dfr(pairs, \(p, par) {
    q <- \(x) quantile(x, c(.025, .5, .975), names = FALSE)
    qs <- q(p$stan); qb <- q(p$brms); psd <- sqrt((sd(p$stan)^2 + sd(p$brms)^2) / 2)
    tibble(comparison = label, parameter = par,
           stan_mean = mean(p$stan), brms_mean = mean(p$brms), stan_sd = sd(p$stan), brms_sd = sd(p$brms),
           stan_q025 = qs[1], brms_q025 = qb[1], stan_median = qs[2], brms_median = qb[2],
           stan_q975 = qs[3], brms_q975 = qb[3],
           d_mean_sd = (mean(p$stan) - mean(p$brms)) / psd, d_median_sd = (qs[2] - qb[2]) / psd,
           d_q025_sd = (qs[1] - qb[1]) / psd, d_q975_sd = (qs[3] - qb[3]) / psd,
           agree = abs(d_mean_sd) < 0.10 & abs(d_median_sd) < 0.10 & abs(d_q025_sd) < 0.20 & abs(d_q975_sd) < 0.20)
  })
}

# Benchmark against Pitre 2025 (reported values in pitre2025_reported.csv; ORs derived by us are labelled)
rr_to_or <- \(rr, p0) rr * (1 - p0) / (1 - rr * p0)
pitre_benchmark <- function(pitre, all_summary, mortality) {
  g <- \(q, col = "value") pitre[[col]][pitre$quantity == q]
  p0 <- g("control_risk_per_1000") / 1000
  pat <- \(col) { r <- select_rows(mortality, col); r <- r[r$data_type == "counts", ]; sum(r$n1 + r$n0) }
  ours <- \(id, lab, col) {
    s <- all_summary[all_summary$id == id, ]
    tibble(source = lab, trials = n_distinct(select_rows(mortality, col)$trial_id), patients = pat(col),
           measure = "OR (posterior median, 95% CrI)", estimate = s$OR_median, lo = s$OR_q025, hi = s$OR_q975,
           P_OR_lt_0.9 = s$P_OR_lt_0.9, control_risk = s$pooled_control_risk,
           abs_per_1000 = -1000 * s$ARR_pooled_median, abs_lo = -1000 * s$ARR_pooled_q975,
           abs_hi = -1000 * s$ARR_pooled_q025)
  }
  bind_rows(
    tibble(source = "Pitre 2025, short-term mortality (reported)", trials = g("short_term_mortality_n_trials"),
           patients = g("short_term_mortality_n_patients"), measure = "RR (95% CI)",
           estimate = g("short_term_mortality_RR"), lo = g("short_term_mortality_RR", "ci_low"),
           hi = g("short_term_mortality_RR", "ci_high"), P_OR_lt_0.9 = g("bayes_P_OR_lt_0.9_short_term"),
           control_risk = p0, abs_per_1000 = g("absolute_effect_per_1000"),
           abs_lo = g("absolute_effect_per_1000", "ci_low"), abs_hi = g("absolute_effect_per_1000", "ci_high")),
    tibble(source = "Pitre 2025 RR converted to OR at their control risk (derived by us, approximate)",
           trials = NA, patients = NA, measure = "OR (approximate)",
           estimate = rr_to_or(g("short_term_mortality_RR"), p0),
           lo = rr_to_or(g("short_term_mortality_RR", "ci_low"), p0),
           hi = rr_to_or(g("short_term_mortality_RR", "ci_high"), p0),
           P_OR_lt_0.9 = NA, control_risk = p0, abs_per_1000 = NA, abs_lo = NA, abs_hi = NA),
    ours("F1_default", "This review F1: severe CAP, short-term (REMAP-CAP as contrast)", "fit_primary_short"),
    ours("F3", "This review F3: broad-severe", "fit_broad_severe"),
    ours("F4", "This review F4: all-hospitalised CAP", "fit_all_hospitalised"))
}
