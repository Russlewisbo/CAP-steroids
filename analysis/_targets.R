library(targets)
library(tarchetypes)

tar_option_set(packages = c("dplyr", "readr", "purrr", "tibble", "cmdstanr", "posterior", "loo"),
               format = "rds")
tar_source("R/00_load_data.R")
tar_source("R/02_fit_primary.R")
tar_source("R/06_tables_figures.R")
tar_source("R/07_crosschecks.R")

# Pipeline root is analysis/. To swap a data row: edit ../analysis_mortality.csv
# (or regenerate with build_handoff.py) and re-run tar_make(); only affected fits rerun.
seed_fit <- 7291L

# ---- Fit specifications -----------------------------------------------------------
# group: D1D2 = decision alternatives; sets = F1-F4; ladder = prior ladder; sens = sensitivity fits
mk <- function(id, group, set, variant, label = NA_character_, agent_hier = 0L, drop_remap = FALSE,
               rung = "reference", tau_sd = 0.5, omega_sd = 0.25, alpha_sd = 10)
  tibble::tibble(id = id, group = group, set = set, variant = variant, label = label,
                 agent_hier = agent_hier, drop_remap = drop_remap, rung = rung,
                 tau_sd = tau_sd, omega_sd = omega_sd, alpha_sd = alpha_sd)

make_ladder <- function(set) {
  pre <- if (set == "F1") "ladder_" else paste0("ladder_", set, "_")
  bind_rows(
    mk(paste0(pre, prior_ladder$rung), "ladder", set, "default", rung = prior_ladder$rung),
    mk(paste0(pre, "remap_harm_noREMAP"), "ladder", set, "default", drop_remap = TRUE, rung = "remap_harm")) |>
    mutate(label = paste0(set, ", prior: ", rung, ifelse(drop_remap, " (REMAP-CAP excluded)", "")))
}

specs <- bind_rows(
  purrr::map_dfr(names(variant_labels), \(v) mk(paste0("F1_", v), "D1D2", "F1", v, variant_labels[[v]])),
  mk("F1_agent", "sets", "F1", "default", "F1 + agent hierarchy", agent_hier = 1L),
  mk("F2", "sets", "F2", "default", "F2 (90-day)"),
  mk("F3", "sets", "F3", "default", "F3 (broad-severe)"),
  mk("F4", "sets", "F4", "default", "F4 (all-hospitalised)"),
  make_ladder("F1"), make_ladder("F2"), make_ladder("F3"),
  # sensitivity fits (ANALYSIS_INSTRUCTIONS.md s5.4)
  mk("S_iii_F1", "sens", "F1", "S_iii", "S-iii contrast-based for all trials (F1)"),
  mk("S_iv_F1_tau025", "sens", "F1", "default", "S-iv F1, tau ~ half-N(0, 0.25)", tau_sd = 0.25),
  mk("S_iv_F1_tau100", "sens", "F1", "default", "S-iv F1, tau ~ half-N(0, 1)", tau_sd = 1),
  mk("S_iv_agent_omega050", "sens", "F1", "default", "S-iv F1-agent, omega ~ half-N(0, 0.5)",
     agent_hier = 1L, omega_sd = 0.5),
  mk("S_iv_agent_tau025", "sens", "F1", "default", "S-iv F1-agent, tau ~ half-N(0, 0.25)",
     agent_hier = 1L, tau_sd = 0.25),
  mk("S_iv_agent_tau100", "sens", "F1", "default", "S-iv F1-agent, tau ~ half-N(0, 1)",
     agent_hier = 1L, tau_sd = 1),
  mk("S_v_F1", "sens", "F1", "default", "S-v F1, baselines alpha ~ N(0, 2)", alpha_sd = 2),
  mk("S_vi_F1", "sens", "F1", "S_vi", "S-vi drop subgroup-derived (F1)"),
  mk("S_vi_F4", "sens", "F4", "S_vi", "S-vi drop subgroup-derived (F4)"),
  mk("S_viii_F1", "sens", "F1", "S_viii", "S-viii drop mineralocorticoid (F1)"),
  mk("S_ix_F1", "sens", "F1", "S_ix", "S-ix drop short course <48 h (F1)"),
  mk("S_IPD_F1", "sens", "F1", "S_IPD", "S-IPD Smit 2025 IPD rows, rank 2 (F1)"),
  mk("S_IPD_F4", "sens", "F4", "S_IPD", "S-IPD Smit 2025 IPD rows, rank 2 (F4)"),
  # Stan fits matched to the brms cross-checks (one likelihood switched off)
  mk("F4_noREMAP", "xcheck", "F4", "default", "F4 without REMAP-CAP (count-only, for brms cross-check)", drop_remap = TRUE),
  mk("S_iii_F4", "xcheck", "F4", "S_iii", "S-iii contrast-based for all trials (F4, for brms cross-check)")) |>
  left_join(prior_ladder, by = "rung")

fit_targets <- tar_map(
  values = specs, names = id,
  tar_target(rows, make_rows(mortality, set, variant, drop_remap)),
  tar_target(stan_data, build_stan_data(rows, mu_mean = mu_mean, mu_sd = mu_sd, agent_hier = agent_hier,
                                        hyper = list(tau_prior_sd = tau_sd, omega_prior_sd = omega_sd,
                                                     alpha_prior_sd = alpha_sd),
                                        override_se = unname(se_override[variant]))),
  tar_target(fit, fit_hma(stan_data, stan_file, seed_fit)),
  tar_target(fit_summary, dplyr::mutate(summarise_fit(fit, label), id = id, group = group, set = set,
                                        rung = rung, mu_mean = mu_mean, mu_sd = mu_sd,
                                        drop_remap = drop_remap, .before = 1)),
  tar_target(fit_diag, dplyr::bind_cols(id = id, fit = label, fit$diag)),
  tar_target(fit_loo, dplyr::mutate(loo_tab(fit, label), id = id, .before = 1))
)

# ---- 1-D tipping-point sweep: skeptical prior N(0, sd) on mu, F1 default rows ------
tip_grid <- tibble::tibble(prior_sd = round(seq(0.05, 1, by = 0.05), 2)) |>
  mutate(tip_id = sprintf("sd%03d", round(prior_sd * 100)))
tip_targets <- tar_map(
  values = tip_grid, names = tip_id,
  tar_target(tip_fit, {
    res <- fit_hma(build_stan_data(rows_F1_default, mu_mean = 0, mu_sd = prior_sd), stan_file, seed_fit)
    dplyr::bind_cols(tibble::tibble(prior_sd = prior_sd), summarise_fit(res, "tip")[, -1], res$diag)
  })
)

# ---- Exact leave-one-trial-out (F1) x baseline model (unpooled primary vs pooled comparison) ----
f1_ids <- load_mortality() |> filter(fit_primary_short == 1) |> pull(trial_id)
loto_specs <- bind_rows(
  tibble::tibble(trial = rep(f1_ids, 2), model = rep(c("unpooled", "pooled"), each = length(f1_ids))),
  tibble::tibble(trial = "none", model = "pooled")) |>
  mutate(id = paste0("loto_", model, "_", trial))
loto_targets <- tar_map(
  values = loto_specs, names = id,
  tar_target(l_rows, dplyr::filter(rows_F1_default, trial_id != trial)),
  tar_target(l_data, build_stan_data(l_rows, mu_mean = 0, mu_sd = 1,
    extra = if (model == "pooled") list(a0_prior_sd = 2, sigma_a_prior_sd = 1) else list())),
  tar_target(l_fit, fit_hma(l_data, if (model == "pooled") stan_file_pooled else stan_file, seed_fit)),
  tar_target(l_summary, dplyr::mutate(summarise_fit(l_fit, id), id = id, trial = trial, model = model, .before = 1)),
  tar_target(l_diag, dplyr::bind_cols(id = id, l_fit$diag)),
  tar_target(l_elpd, if (trial == "none") NULL else loto_elpd(l_fit, rows_F1_default, trial, model))
)

# ---- 2-D tipping surface: prior centre (OR) x SD on mu, F1 default rows --------------------
tip2_grid <- tibble::tibble(
  centre_or = rep(c(0.70, 0.80, 0.90, 1.00, 1.10, 1.25, 1.50, 1.75), times = 6),
  prior_sd = rep(c(0.10, 0.20, 0.35, 0.50, 0.75, 1.00), each = 8)) |>
  mutate(tip2_id = sprintf("c%03d_s%03d", round(centre_or * 100), round(prior_sd * 100)))
tip2_targets <- tar_map(
  values = tip2_grid, names = tip2_id,
  tar_target(tip2_fit, {
    res <- fit_hma(build_stan_data(rows_F1_default, mu_mean = log(centre_or), mu_sd = prior_sd),
                   stan_file, seed_fit)
    dplyr::bind_cols(tibble::tibble(centre_or = centre_or, prior_sd = prior_sd),
                     summarise_fit(res, "tip2")[, -1], res$diag)
  })
)

# ---- Meta-regression: one covariate at a time, F1 and F4 -----------------------------
mr_grid <- tibble::tibble(
  set = rep(c("F1", "F4"), each = nrow(mr_covariates)),
  covariate = rep(mr_covariates$covariate, 2),
  type = rep(mr_covariates$type, 2)) |>
  mutate(mr_id = paste0("mr_", set, "_", covariate))
mr_targets <- tar_map(
  values = mr_grid, names = mr_id,
  tar_target(mr_res, mr_run(if (set == "F1") rows_F1_default else rows_F4, cov_tbl, set, covariate, type,
                            stan_file_mr, seed_fit))
)

list(
  tar_target(data_file, "../analysis_mortality.csv", format = "file"),
  tar_target(stan_file, "stan/hybrid_ma.stan", format = "file"),
  tar_target(stan_file_mr, "stan/hybrid_ma_mr.stan", format = "file"),
  tar_target(trials_file, "../trials.csv", format = "file"),
  tar_target(trials_tbl, readr::read_csv(trials_file, show_col_types = FALSE)),
  tar_target(cov_tbl, code_covariates(trials_tbl)),
  tar_target(pitre_file, "pitre2025_reported.csv", format = "file"),
  tar_target(pitre_tbl, readr::read_csv(pitre_file, show_col_types = FALSE)),
  tar_target(pitre_bench, pitre_benchmark(pitre_tbl, all_summary, mortality)),

  # brms cross-checks: pure-count (REMAP-CAP removed) and pure-contrast (S-iii rows), F1 and F4
  tar_target(xc_brms_F1_count, brms_count(rows_F1_D2b, seed_fit)),
  tar_target(xc_brms_F4_count, brms_count(rows_F4_noREMAP, seed_fit)),
  tar_target(xc_brms_F1_contrast, brms_contrast(rows_S_iii_F1, seed_fit)),
  tar_target(xc_brms_F4_contrast, brms_contrast(rows_S_iii_F4, seed_fit)),
  tar_target(xc_compare, dplyr::bind_rows(
    compare_fits(fit_F1_D2b, xc_brms_F1_count, "F1 count-only (6 trials)"),
    compare_fits(fit_F4_noREMAP, xc_brms_F4_count, "F4 count-only (16 trials)"),
    compare_fits(fit_S_iii_F1, xc_brms_F1_contrast, "F1 contrast-only, S-iii (7 trials)"),
    compare_fits(fit_S_iii_F4, xc_brms_F4_contrast, "F4 contrast-only, S-iii (16 trials)"))),
  tar_target(xc_diag, dplyr::bind_rows(
    dplyr::bind_cols(comparison = "F1 count-only (6 trials)", sampler = "brms", xc_brms_F1_count$diag),
    dplyr::bind_cols(comparison = "F4 count-only (16 trials)", sampler = "brms", xc_brms_F4_count$diag),
    dplyr::bind_cols(comparison = "F1 contrast-only, S-iii (7 trials)", sampler = "brms", xc_brms_F1_contrast$diag),
    dplyr::bind_cols(comparison = "F4 contrast-only, S-iii (16 trials)", sampler = "brms", xc_brms_F4_contrast$diag))),

  tar_target(s_ii_status, rob_status(trials_tbl)),
  tar_target(stan_file_pooled, "stan/hybrid_ma_pooled.stan", format = "file"),
  tar_target(mortality, load_mortality(data_file)),
  tar_target(membership, check_membership(mortality)),

  # Simulation checks (hard rule 7); rerun only when the script or Stan model changes
  tar_target(sim_script, "R/01_simulate.R", format = "file"),
  tar_target(sim_outputs, {
    stan_file; sim_script
    source(sim_script, local = new.env())
    list.files("output/tables", pattern = "^sim_", full.names = TRUE)
  }, format = "file"),

  fit_targets, tip_targets, loto_targets, tip2_targets, mr_targets,

  tar_combine(all_summary, fit_targets$fit_summary, command = dplyr::bind_rows(!!!.x)),
  tar_combine(all_diagnostics, fit_targets$fit_diag, command = dplyr::bind_rows(!!!.x)),
  tar_combine(all_loo, fit_targets$fit_loo, command = dplyr::bind_rows(!!!.x)),
  tar_combine(tip_tab, tip_targets$tip_fit, command = dplyr::bind_rows(!!!.x)),
  tar_combine(mr_tab, mr_targets$mr_res, command = dplyr::bind_rows(!!!.x)),
  tar_combine(tip2_tab, tip2_targets$tip2_fit, command = dplyr::bind_rows(!!!.x)),
  tar_combine(loto_summary, loto_targets$l_summary, command = dplyr::bind_rows(!!!.x)),
  tar_combine(loto_diag, loto_targets$l_diag, command = dplyr::bind_rows(!!!.x)),
  tar_combine(loto_elpd_long, loto_targets$l_elpd, command = dplyr::bind_rows(!!!.x)),

  tar_target(loto_compare, {
    w <- elpd_wide(loto_elpd_long)
    list(by_trial = w,
         total = tibble::tibble(
           n_trials = nrow(w), elpd_unpooled = sum(w$unpooled), elpd_pooled = sum(w$pooled),
           diff_pooled_minus_unpooled = sum(w$pooled - w$unpooled),
           se_diff = sqrt(nrow(w)) * sd(w$pooled - w$unpooled)))
  }),

  tar_target(agent_F1, agent_summary(fit_F1_agent, rows_F1_agent, "F1 + agent hierarchy")),
  tar_target(tip_thresholds_tab, dplyr::bind_rows(
    tip_thresholds(tip_tab, "P_OR_lt_1"), tip_thresholds(tip_tab, "P_OR_lt_0.833"))),

  tar_target(tables, {
    od <- "output/tables/"
    readr::write_csv(dplyr::filter(all_summary, group == "D1D2"), paste0(od, "F1_summary_D1_D2.csv"))
    readr::write_csv(dplyr::filter(all_summary, group == "sets"), paste0(od, "sets_summary_F1agent_F2_F3_F4.csv"))
    for (st in c("F1", "F2", "F3"))
      readr::write_csv(dplyr::filter(all_summary, group == "ladder", set == st), paste0(od, "prior_ladder_", st, ".csv"))
    readr::write_csv(dplyr::filter(all_summary, group == "sens" | id %in% c("F1_default", "F1_D2b")),
                     paste0(od, "sensitivity_summary.csv"))
    readr::write_csv(mr_tab, paste0(od, "meta_regression.csv"))
    readr::write_csv(xc_compare, paste0(od, "xcheck_brms_vs_stan.csv"))
    readr::write_csv(xc_diag, paste0(od, "xcheck_brms_diagnostics.csv"))
    readr::write_csv(pitre_bench, paste0(od, "benchmark_pitre2025.csv"))
    readr::write_csv(dplyr::left_join(cov_tbl, timing_coding, by = c("trial_id", "timing_le24h")),
                     paste0(od, "mr_covariate_coding.csv"))
    readr::write_csv(all_diagnostics, paste0(od, "all_fit_diagnostics.csv"))
    readr::write_csv(all_loo, paste0(od, "loo_pareto_k.csv"))
    readr::write_csv(agent_F1, paste0(od, "agent_summary_F1.csv"))
    readr::write_csv(tip_tab, paste0(od, "tipping_1d_F1.csv"))
    readr::write_csv(tip_thresholds_tab, paste0(od, "tipping_1d_thresholds.csv"))
    readr::write_csv(tip2_tab, paste0(od, "tipping_2d_F1.csv"))
    readr::write_csv(loto_summary, paste0(od, "loto_F1_posterior_without_trial.csv"))
    readr::write_csv(loto_diag, paste0(od, "loto_F1_diagnostics.csv"))
    readr::write_csv(loto_compare$by_trial, paste0(od, "loto_F1_elpd_by_trial.csv"))
    readr::write_csv(loto_compare$total, paste0(od, "loto_F1_elpd_total.csv"))
    list.files(od, pattern = "^(F1_summary_D1_D2|sets_summary|prior_ladder|sensitivity_|meta_regression|mr_cov|xcheck_|benchmark_|all_fit|loo_|agent_|tipping|loto_)",
               full.names = TRUE)
  }, format = "file"),

  tar_target(fig_forest_F1,
    save_fig(forest_plot(fit_F1_default, rows_F1_default), "output/figures/F1_forest.png", 8, 4.8),
    format = "file"),
  tar_target(fig_ppc_F1,
    save_fig(ppc_dotplot(fit_F1_default, rows_F1_default), "output/figures/F1_ppc_dotplot.png", 9, 5.5),
    format = "file"),
  tar_target(fig_ladder_F1,
    save_fig(ladder_plot(dplyr::filter(all_summary, group == "ladder", set == "F1")), "output/figures/F1_prior_ladder.png", 8, 4.5),
    format = "file"),
  tar_target(fig_ladder_F2,
    save_fig(ladder_plot(dplyr::filter(all_summary, group == "ladder", set == "F2")), "output/figures/F2_prior_ladder.png", 8, 4.5),
    format = "file"),
  tar_target(fig_ladder_F3,
    save_fig(ladder_plot(dplyr::filter(all_summary, group == "ladder", set == "F3")), "output/figures/F3_prior_ladder.png", 8, 4.5),
    format = "file"),
  tar_target(fig_mr,
    save_fig(mr_plot(mr_tab), "output/figures/meta_regression_b.png", 8, 5),
    format = "file"),
  tar_target(fig_loto_F1,
    save_fig(loto_plot(loto_summary, dplyr::filter(all_summary, id == "F1_default"),
                       dplyr::distinct(mortality, trial_id, study_label)),
             "output/figures/F1_loto_influence.png", 8, 4.8),
    format = "file"),
  tar_target(fig_tip2_P,
    save_fig(tip2_heatmap(tip2_tab, "P_OR_lt_1"), "output/figures/F1_tipping_2d_P_OR_lt_1.png", 7.5, 4.8),
    format = "file"),
  tar_target(fig_tip2_OR,
    save_fig(tip2_heatmap(tip2_tab, "OR_median"), "output/figures/F1_tipping_2d_median_OR.png", 7.5, 4.8),
    format = "file"),
  tar_target(fig_tipping_F1,
    save_fig(tip_plot(tip_tab, tip_thresholds_tab), "output/figures/F1_tipping_1d.png", 7, 4.5),
    format = "file"),

  tar_target(session_info, list(
    r = R.version.string, platform = R.version$platform, cmdstan = as.character(cmdstanr::cmdstan_version()),
    pkgs = vapply(c("cmdstanr", "brms", "posterior", "loo", "targets", "tarchetypes", "dplyr", "ggplot2", "quarto"),
                  \(p) as.character(utils::packageVersion(p)), character(1)))),

  tarchetypes::tar_quarto(site, path = ".", quiet = TRUE)
)
