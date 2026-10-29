# Prior-predictive and parameter-recovery checks for hybrid_ma.stan (hard rule 7)
# Seed 4817: arbitrary, fixed for reproducibility of the simulation study.
library(cmdstanr); library(posterior); library(dplyr); library(purrr)
source("R/00_load_data.R")

set.seed(4817)
mod <- cmdstan_model("stan/hybrid_ma.stan")
d <- load_mortality()
print(check_membership(d))
f1 <- select_rows(d, "fit_primary_short")
base_sd <- build_stan_data(f1, mu_mean = 0, mu_sd = 1)

fit_quiet <- \(sd, seed, ...) mod$sample(data = sd, chains = 4, parallel_chains = 4,
  iter_warmup = 1000, iter_sampling = 1000, adapt_delta = 0.95, max_treedepth = 12,
  seed = seed, refresh = 0, show_messages = FALSE, show_exceptions = FALSE, ...)

# ---- 1. Prior-predictive: Stan (prior_only = 1) vs direct R draws --------------------
pp_stan <- fit_quiet(modifyList(base_sd, list(prior_only = 1L)), 1L)
dr <- as_draws_df(pp_stan$draws(c("mu", "tau", "OR", "OR_new")))
n <- 20000
mu_r <- rnorm(n, 0, 1); tau_r <- abs(rnorm(n, 0, 0.5))
pp_tab <- tibble(
  quantity = c("OR median", "OR 2.5%", "OR 97.5%", "tau median", "tau 95%", "OR_new 2.5%", "OR_new 97.5%"),
  stan = c(median(dr$OR), quantile(dr$OR, .025), quantile(dr$OR, .975), median(dr$tau),
           quantile(dr$tau, .95), quantile(dr$OR_new, .025), quantile(dr$OR_new, .975)),
  direct_R = c(median(exp(mu_r)), quantile(exp(mu_r), c(.025, .975)), median(tau_r),
               quantile(tau_r, .95), quantile(exp(rnorm(n, mu_r, tau_r)), c(.025, .975))))
print(pp_tab)
readr::write_csv(pp_tab, "output/tables/sim_prior_predictive.csv")

# ---- 2. Parameter recovery on simulated data shaped like F1 ---------------------------
b <- filter(f1, data_type == "counts")
cc <- filter(f1, data_type == "contrast")
sim_dataset <- function(mu, tau, omega = 0, agent_hier = 0) {
  agents <- sort(unique(f1$agent_cluster))
  beta <- if (agent_hier) rnorm(length(agents), mu, omega) else rep(mu, length(agents))
  th_b <- rnorm(nrow(b), beta[match(b$agent_cluster, agents)], tau)
  th_c <- rnorm(nrow(cc), beta[match(cc$agent_cluster, agents)], tau)
  alpha <- qlogis(pmin(pmax((b$r0 + 0.5) / (b$n0 + 1), 0.02), 0.5))
  sim <- b
  sim$r0 <- rbinom(nrow(b), b$n0, plogis(alpha))
  sim$r1 <- rbinom(nrow(b), b$n1, plogis(alpha + th_b))
  csim <- cc
  csim$yi <- rnorm(nrow(cc), th_c, cc$sei)
  bind_rows(sim, csim)
}

recover <- function(nrep, mu_true, tau_true, omega_true = 0, agent_hier = 0, seed0 = 100L) {
  map_dfr(seq_len(nrep), \(i) {
    sim <- sim_dataset(mu_true, tau_true, omega_true, agent_hier)
    sd <- build_stan_data(sim, mu_mean = 0, mu_sd = 1, agent_hier = agent_hier)
    fit <- fit_quiet(sd, seed0 + i)
    s <- fit$summary(c("mu", "tau"), "mean", "median", ~quantile2(.x, c(.025, .975)), "rhat", "ess_bulk")
    dg <- fit$diagnostic_summary(quiet = TRUE)
    mutate(s, rep = i, divergences = sum(dg$num_divergent), agent_hier = agent_hier,
           truth = c(mu_true, tau_true))
  })
}

# Scenarios chosen to span the plausible range: modest benefit/moderate heterogeneity; null; harm
scen <- tibble(mu = c(log(0.8), 0, log(1.3)), tau = c(0.3, 0.15, 0.3))
rec <- pmap_dfr(scen, \(mu, tau) recover(40, mu, tau) |> mutate(mu_true = mu, tau_true = tau))
readr::write_csv(rec, "output/tables/sim_recovery_F1.csv")

rec_sum <- rec |>
  group_by(mu_true, tau_true, variable) |>
  summarise(truth = first(truth), mean_post_median = mean(median),
            bias_median = mean(median - truth),
            coverage95 = mean(q2.5 <= truth & truth <= q97.5),
            max_rhat = max(rhat), min_ess = min(ess_bulk),
            total_divergences = sum(divergences), .groups = "drop")
print(rec_sum)
readr::write_csv(rec_sum, "output/tables/sim_recovery_F1_summary.csv")

# Agent-hierarchy version: expect omega to sit near its prior (weak identification)
rec_ag <- recover(20, log(0.8), 0.3, omega_true = 0.2, agent_hier = 1, seed0 = 500L)
print(rec_ag |> group_by(variable) |>
        summarise(truth = first(truth), median_of_medians = median(median),
                  coverage95 = mean(q2.5 <= truth & truth <= q97.5),
                  max_rhat = max(rhat), divergences = sum(divergences)))
