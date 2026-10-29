library(ggplot2); library(dplyr); library(posterior); library(purrr)

# JAMA-style look: white background, sans-serif, minimal rules, blue-gray palette
jama <- list(ink = "#1F3A45", dark = "#2E4A57", steel = "#4F7285", mid = "#5F7F8F", soft = "#7F9CAB",
             light = "#9FB4C0", pale = "#B8C8D1", wash = "#EEF2F4", grid = "#E4EAED")

theme_jama <- function(base_size = 11, base_family = "Helvetica") {
  theme_classic(base_size = base_size, base_family = base_family) +
    theme(axis.line = element_line(colour = jama$dark, linewidth = 0.4),
          axis.ticks = element_line(colour = jama$dark, linewidth = 0.4),
          axis.text = element_text(colour = jama$ink),
          axis.title = element_text(colour = jama$ink),
          panel.grid.major.y = element_line(colour = jama$grid, linewidth = 0.3),
          legend.position = "bottom", legend.title = element_blank(), legend.key = element_blank(),
          strip.background = element_rect(fill = jama$grid, colour = NA),
          strip.text = element_text(face = "bold", colour = jama$ink),
          plot.caption = element_text(hjust = 0, colour = jama$mid, size = base_size - 2),
          plot.caption.position = "plot")
}

# Posterior density of the pooled OR drawn as a slab above its point range; darker where OR < 1.
# `d` needs columns OR (draws), y (factor, same levels as the plot's y axis) and optional `grp`.
pooled_slab <- function(d, nudge = 0, scale = 0.55, alpha = 1, fill_lt = jama$light, fill_ge = "#DDE5E9") {
  list(ggdist::stat_slab(data = d, aes(x = OR, y = y, fill = after_stat(x < 1)), inherit.aes = FALSE,
                         side = "top", scale = scale, colour = jama$mid, linewidth = 0.3, alpha = alpha,
                         normalize = "groups", show.legend = FALSE, position = position_nudge(y = nudge)),
       scale_fill_manual(values = c(`TRUE` = fill_lt, `FALSE` = fill_ge), guide = "none"))
}

save_fig <- function(p, path, w, h) {
  ggsave(path, p, width = w, height = h, dpi = 200)
  path
}

# Trial order in draws: count trials first, then contrast trials (as in build_stan_data)
trial_frame <- function(rows) {
  b <- filter(rows, data_type == "counts"); cc <- filter(rows, data_type == "contrast")
  bind_rows(b, cc) |>
    mutate(k = row_number(),
           flag = case_when(data_type == "contrast" ~ " [contrast]",
                            grepl("subgroup_derived", sensitivity_flags) ~ " [subgroup-derived]",
                            TRUE ~ ""),
           label = paste0(study_label, flag))
}

# Forest plot: raw per-trial log-OR (display only; 0.5 added to all cells when any cell is zero,
# never used in the model) vs shrunken theta_k (posterior median, 95% CrI), plus pooled mu.
forest_plot <- function(res, rows) {
  tf <- trial_frame(rows); dr <- res$draws
  raw <- tf |>
    mutate(zero = data_type == "counts" & (r1 == 0 | r0 == 0),
           a = r1 + 0.5 * zero, b = n1 - r1 + 0.5 * zero, c = r0 + 0.5 * zero, d = n0 - r0 + 0.5 * zero,
           est = if_else(data_type == "contrast", yi, log(a * d / (b * c))),
           se = if_else(data_type == "contrast", sei, sqrt(1 / a + 1 / b + 1 / c + 1 / d))) |>
    transmute(label, type = "Raw (unpooled)", est, lo = est - 1.96 * se, hi = est + 1.96 * se,
              label_dis = if_else(zero, paste0(label, " *"), label))
  shr <- tf |> rowwise() |>
    mutate(v = list(dr[[sprintf("theta[%d]", k)]])) |>
    transmute(label, type = "Shrunken (model)", est = median(v), lo = quantile(v, .025), hi = quantile(v, .975)) |>
    ungroup() |> left_join(distinct(raw, label, label_dis), by = "label")
  pooled <- tibble(label = "Pooled (mu)", type = "Pooled", est = median(dr$mu),
                   lo = quantile(dr$mu, .025), hi = quantile(dr$mu, .975), label_dis = "Pooled (mu)")
  lv <- c(rev(unique(raw$label_dis)), "Pooled (mu)")
  df <- bind_rows(raw, shr, pooled) |>
    mutate(label_dis = factor(label_dis, levels = lv),
           type = factor(type, levels = c("Raw (unpooled)", "Shrunken (model)", "Pooled")))
  pd <- tibble(OR = exp(dr$mu), y = factor("Pooled (mu)", levels = lv))
  ggplot(df, aes(exp(est), label_dis, xmin = exp(lo), xmax = exp(hi), shape = type, colour = type)) +
    geom_vline(xintercept = 1, linetype = 2, colour = jama$mid, linewidth = 0.4) +
    pooled_slab(pd, scale = 0.9) +
    geom_pointrange(position = position_dodge(width = 0.6), size = 0.35) +
    scale_y_discrete(limits = lv, expand = expansion(add = c(0.6, 1.1))) +
    scale_x_log10(breaks = c(0.1, 0.25, 0.5, 1, 2, 4, 10)) +
    scale_shape_manual(values = c(16, 15, 18)) +
    scale_colour_manual(values = c(jama$light, jama$steel, jama$ink)) +
    labs(x = "Odds ratio (log scale; <1 favours corticosteroids)", y = NULL, shape = NULL, colour = NULL,
         caption = "Bars: raw = 95% Wald CI; shrunken and pooled = 95% CrI. * 0.5 added to all four cells for display only (zero cell).\nContrast-based trial entered as normal likelihood; subgroup-derived trial flagged.\nShaded curve: full posterior distribution of the pooled OR (darker where OR < 1).") +
    theme_jama()
}

# PPC: observed deaths vs replicated deaths (median and 50%/95% intervals) per trial arm
ppc_dotplot <- function(res, rows) {
  b <- trial_frame(rows) |> filter(data_type == "counts"); dr <- res$draws
  rep_sum <- \(nm, arm, obs_col) {
    tibble(label = b$label, arm = arm, observed = b[[obs_col]],
           med = map_dbl(b$k, \(k) median(dr[[sprintf("%s[%d]", nm, k)]])),
           lo95 = map_dbl(b$k, \(k) quantile(dr[[sprintf("%s[%d]", nm, k)]], .025)),
           hi95 = map_dbl(b$k, \(k) quantile(dr[[sprintf("%s[%d]", nm, k)]], .975)),
           lo50 = map_dbl(b$k, \(k) quantile(dr[[sprintf("%s[%d]", nm, k)]], .25)),
           hi50 = map_dbl(b$k, \(k) quantile(dr[[sprintf("%s[%d]", nm, k)]], .75)),
           pp_tail = map2_dbl(b$k, b[[obs_col]], \(k, o) mean(dr[[sprintf("%s[%d]", nm, k)]] >= o)))
  }
  df <- bind_rows(rep_sum("r1_rep", "Corticosteroid", "r1"), rep_sum("r0_rep", "Control", "r0"))
  ggplot(df, aes(arm)) +
    geom_linerange(aes(ymin = lo95, ymax = hi95), colour = jama$pale, linewidth = 0.8) +
    geom_linerange(aes(ymin = lo50, ymax = hi50), colour = jama$mid, linewidth = 2) +
    geom_point(aes(y = med), shape = 21, fill = "white", colour = jama$ink, size = 2.5) +
    geom_point(aes(y = observed), colour = jama$ink, size = 2.5) +
    facet_wrap(~label, labeller = label_wrap_gen(24), scales = "free_y", nrow = 2) +
    labs(x = NULL, y = "Deaths",
         caption = "Filled point = observed deaths. Open circle = replicated median; thick/thin bars = 50%/95% posterior-predictive intervals.\nReplicated arms condition on each trial's own baseline (unpooled alpha_k), so control arms are fitted near-exactly by design.") +
    theme_jama() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
}

# Prior ladder: prior 95% interval (light) and posterior median/95% CrI (dark) per rung, F1
ladder_plot <- function(ladder, draws) {
  lab <- sub("^F[0-9], prior: ", "", ladder$fit)
  lab <- c(enthusiastic = "Enthusiastic", reference = "Reference", skeptical = "Skeptical",
           mild_harm = "Mild harm-leaning", remap_harm = "REMAP-CAP harm")[sub(" \\(.*", "", lab)] |>
    paste0(ifelse(grepl("excluded", ladder$fit), " (REMAP-CAP row excluded)", ""))
  ladder <- ladder |> mutate(label = lab)
  lv <- rev(ladder$label)
  prior <- ladder |> transmute(label, type = "Prior", est = exp(mu_mean),
                               lo = exp(mu_mean - 1.96 * mu_sd), hi = exp(mu_mean + 1.96 * mu_sd))
  post <- ladder |> transmute(label, type = "Posterior", est = OR_median, lo = OR_q025, hi = OR_q975)
  df <- bind_rows(prior, post) |> mutate(label = factor(label, levels = lv),
                                         type = factor(type, levels = c("Prior", "Posterior")))
  pd <- draws |> inner_join(select(ladder, id, label), by = "id") |>
    transmute(OR = exp(mu), y = factor(label, levels = lv))
  ggplot(df, aes(est, label, xmin = lo, xmax = hi, colour = type)) +
    geom_vline(xintercept = 1, linetype = 2, colour = jama$mid, linewidth = 0.4) +
    pooled_slab(pd, nudge = 0.125, scale = 0.5) +
    geom_pointrange(position = position_dodge(width = 0.5), size = 0.35) +
    scale_y_discrete(limits = lv, expand = expansion(add = c(0.6, 0.9))) +
    scale_x_log10(breaks = c(0.1, 0.25, 0.5, 1, 2, 4, 8)) +
    scale_colour_manual(values = c(Prior = jama$pale, Posterior = jama$ink)) +
    labs(x = "Pooled odds ratio (log scale)", y = NULL, colour = NULL,
         caption = "Median and 95% interval. Enthusiastic/reference/skeptical rungs are proposals (D3); harm rungs are protocol-fixed.\nShaded curves: full posterior distribution of the pooled OR (darker where OR < 1).") +
    theme_jama()
}

# Tipping point: P(OR<1) and P(OR<0.833) vs skeptical prior SD
tip_plot <- function(tip, thr) {
  df <- bind_rows(tip |> transmute(prior_sd, metric = "P(OR < 1)", p = P_OR_lt_1),
                  tip |> transmute(prior_sd, metric = "P(OR < 0.833)", p = `P_OR_lt_0.833`))
  vl <- thr |> filter(!is.na(prior_sd_at_crossing)) |>
    mutate(metric = ifelse(metric == "P_OR_lt_1", "P(OR < 1)", "P(OR < 0.833)"))
  ggplot(df, aes(prior_sd, p, colour = metric)) +
    geom_hline(yintercept = c(0.8, 0.9), linetype = 3, colour = jama$mid, linewidth = 0.4) +
    geom_line(linewidth = 0.7) + geom_point(size = 1.2) +
    scale_colour_manual(values = c("P(OR < 1)" = jama$ink, "P(OR < 0.833)" = jama$soft)) +
    geom_vline(data = vl, aes(xintercept = prior_sd_at_crossing, colour = metric), linetype = 2, show.legend = FALSE) +
    scale_y_continuous(limits = c(0, 1)) +
    labs(x = "Skeptical prior SD on log-OR, prior = Normal(0, SD)", y = "Posterior probability", colour = NULL,
         caption = "F1 default rows. Dotted: 0.80 and 0.90. Dashed vertical: prior SD at which the probability crosses 0.90 / 0.80.") +
    theme_jama()
}

# Leave-one-trial-out influence: pooled OR with each F1 trial omitted, both baseline models
loto_plot <- function(loto_summary, full, labels, draws) {
  df <- loto_summary |> filter(trial != "none") |>
    left_join(labels, by = c("trial" = "trial_id")) |>
    mutate(model = factor(model, levels = c("unpooled", "pooled"),
                          labels = c("Unpooled baselines (primary)", "Pooled baselines (comparison)")))
  lv <- sort(unique(df$study_label))
  pd <- draws |> inner_join(select(df, id, study_label, model), by = "id") |>
    transmute(OR = exp(mu), y = factor(study_label, levels = lv), model)
  ggplot(df, aes(OR_median, factor(study_label, levels = lv), xmin = OR_q025, xmax = OR_q975, colour = model)) +
    geom_vline(xintercept = 1, linetype = 2, colour = jama$mid, linewidth = 0.4) +
    geom_vline(xintercept = full$OR_median, linetype = 3, colour = jama$mid, linewidth = 0.4) +
    pooled_slab(filter(pd, grepl("Unpooled", model)), nudge = -0.125, scale = 0.38, alpha = 0.8) +
    scale_colour_manual(values = c(jama$ink, jama$soft)) +
    geom_pointrange(position = position_dodge(width = 0.5), size = 0.35) +
    scale_y_discrete(limits = lv, expand = expansion(add = c(0.6, 0.8))) +
    scale_x_log10(breaks = c(0.25, 0.5, 1, 2)) +
    labs(x = "Pooled OR without the named trial (log scale)", y = "Trial omitted", colour = NULL,
         caption = sprintf("Median and 95%% CrI. Dotted line: full-F1 unpooled-baseline median OR (%.2f).\nShaded curves: posterior of the pooled OR without that trial, primary (unpooled-baseline) model.", full$OR_median)) +
    theme_jama()
}

# 2-D tipping surface: prior centre (as OR) x prior SD
tip2_heatmap <- function(tab, what = c("P_OR_lt_1", "OR_median")) {
  what <- match.arg(what)
  df <- tab |> mutate(centre = factor(centre_or), sd = factor(prior_sd),
                      val = .data[[what]], txt = sprintf("%.2f", val),
                      dark_cell = if (what == "OR_median") (log(val) - min(log(val))) / diff(range(log(val))) < 0.5 else val > 0.45)
  p <- ggplot(df, aes(centre, sd, fill = if (what == "OR_median") log(val) else val)) +
    geom_tile(colour = "white") +
    geom_text(aes(label = txt, colour = dark_cell), size = 3) +
    scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = jama$ink), guide = "none") +
    labs(x = "Prior centre (OR)", y = "Prior SD (log-OR)",
         caption = paste0("F1 default rows, REMAP-CAP d90 contrast included.",
                          if (what == "OR_median") " Darker cells = lower median OR (more benefit)." else " Darker cells = higher probability.")) +
    theme_jama() + theme(panel.grid = element_blank(), axis.line = element_blank(), axis.ticks = element_blank(),
                         legend.position = "right", legend.title = element_text(colour = jama$ink))
  if (what == "P_OR_lt_1") {
    p + scale_fill_gradient(low = jama$wash, high = jama$ink, limits = c(0, 1), name = "P(OR < 1)")
  } else {
    p + scale_fill_gradient(low = jama$ink, high = jama$wash, name = "Posterior\nmedian OR",
                            breaks = log(c(0.7, 1, 1.4)), labels = c("0.7", "1.0", "1.4"))
  }
}

# Meta-regression coefficients (per 1 SD for continuous covariates; group difference for binary)
mr_plot <- function(mr, labels = NULL) {
  df <- mr |> filter(status == "fitted") |>
    mutate(label = sprintf("%s (n=%d)", if (is.null(labels)) covariate else unname(labels[covariate]), n_trials),
           set = factor(set, levels = c("F1", "F4")))
  ggplot(df, aes(b_median, label, xmin = b_q025, xmax = b_q975)) +
    geom_vline(xintercept = 0, linetype = 2, colour = jama$mid, linewidth = 0.4) +
    geom_pointrange(size = 0.35, colour = jama$ink) +
    facet_wrap(~set, scales = "free_y", ncol = 1) +
    labs(x = "Coefficient b on the log-OR (median and 95% CrI)", y = NULL,
         caption = "b is per 1 SD for continuous covariates and the group difference for binary ones; negative = more benefit.\nExploratory, across-trial (ecological), underpowered. Prior b ~ Normal(0, 1) (proposed).") +
    theme_jama()
}

# Per-trial raw and shrunken ORs (raw: 0.5 added to all cells for a zero cell, display only)
trial_effects <- function(res, rows) {
  tf <- trial_frame(rows); dr <- res$draws
  raw <- tf |> mutate(zero = data_type == "counts" & (r1 == 0 | r0 == 0),
                      a = r1 + 0.5 * zero, b = n1 - r1 + 0.5 * zero, c = r0 + 0.5 * zero, d = n0 - r0 + 0.5 * zero,
                      est = if_else(data_type == "contrast", yi, log(a * d / (b * c))),
                      se = if_else(data_type == "contrast", sei, sqrt(1 / a + 1 / b + 1 / c + 1 / d)))
  shr <- map(tf$k, \(k) dr[[sprintf("theta[%d]", k)]])
  tibble(trial = tf$study_label, data_type = tf$data_type, zero_cell = raw$zero,
         subgroup_derived = grepl("subgroup", tf$flag),
         raw_or = exp(raw$est), raw_lo = exp(raw$est - 1.96 * raw$se), raw_hi = exp(raw$est + 1.96 * raw$se),
         shrunk_or = exp(map_dbl(shr, median)), shrunk_lo = exp(map_dbl(shr, quantile, .025)),
         shrunk_hi = exp(map_dbl(shr, quantile, .975)))
}

# Observed vs replicated deaths per arm (count trials)
ppc_summary <- function(res, rows) {
  b <- trial_frame(rows) |> filter(data_type == "counts"); dr <- res$draws
  one <- \(nm, arm, obs) {
    rep <- map(b$k, \(k) dr[[sprintf("%s[%d]", nm, k)]])
    tibble(trial = b$study_label, arm = arm, observed = b[[obs]],
           rep_median = map_dbl(rep, median), lo95 = map_dbl(rep, quantile, .025),
           hi95 = map_dbl(rep, quantile, .975)) |>
      mutate(inside_95 = observed >= lo95 & observed <= hi95)
  }
  bind_rows(one("r1_rep", "Corticosteroid", "r1"), one("r0_rep", "Control", "r0"))
}


# ---- Convergence and fit diagnostics ----------------------------------------------------
chain_cols <- c(`1` = jama$ink, `2` = jama$steel, `3` = jama$soft, `4` = "#A9BCC6")
par_labels <- c(mu = "mu (pooled log-OR)", tau = "tau (between-trial SD)", `theta[1]` = "theta[1]", `theta[2]` = "theta[2]")

chain_long <- function(res, pars) {
  dr <- as.data.frame(res$draws)
  bind_rows(lapply(pars, \(p) tibble(par = p, chain = factor(dr$.chain), iter = dr$.iteration, value = dr[[p]])))
}

trace_plot <- function(res, pars = c("mu", "tau")) {
  ggplot(chain_long(res, pars), aes(iter, value, colour = chain)) +
    geom_line(linewidth = 0.25, alpha = 0.85) +
    facet_wrap(~par, ncol = 1, scales = "free_y", labeller = as_labeller(par_labels)) +
    scale_colour_manual(values = chain_cols) +
    labs(x = "Post-warmup iteration", y = NULL, colour = "Chain",
         caption = "Four chains of 2000 post-warmup draws each; good mixing looks like overlapping, trendless bands.") +
    theme_jama() + theme(legend.title = element_text(colour = jama$ink))
}

rank_plot <- function(res, pars = c("mu", "tau"), bins = 20) {
  df <- chain_long(res, pars) |> group_by(par) |> mutate(rk = rank(value) / n()) |> ungroup()
  per <- nrow(df) / length(pars) / nlevels(df$chain) / bins
  ggplot(df, aes(rk)) +
    geom_histogram(breaks = seq(0, 1, length.out = bins + 1), fill = jama$soft, colour = "white", linewidth = 0.2) +
    geom_hline(yintercept = per, linetype = 2, colour = jama$ink, linewidth = 0.4) +
    facet_grid(par ~ chain, labeller = labeller(par = par_labels, chain = \(x) paste("Chain", x))) +
    labs(x = "Pooled rank of draw (scaled 0 to 1)", y = "Count",
         caption = "Rank histograms: if chains agree, every chain's ranks are uniform (dashed line = expected count).") +
    theme_jama()
}

density_chain_plot <- function(res, pars = c("mu", "tau")) {
  ggplot(chain_long(res, pars), aes(value, colour = chain)) +
    geom_density(linewidth = 0.6) +
    facet_wrap(~par, scales = "free", nrow = 1, labeller = as_labeller(par_labels)) +
    scale_colour_manual(values = chain_cols) +
    labs(x = NULL, y = "Density", colour = "Chain",
         caption = "Posterior density estimated separately for each chain; the four curves should coincide.") +
    theme_jama() + theme(legend.title = element_text(colour = jama$ink))
}

acf_plot <- function(res, pars = c("mu", "tau"), lag.max = 30) {
  df <- chain_long(res, pars) |> group_by(par, chain) |>
    reframe(lag = 0:lag.max, acf = as.numeric(stats::acf(value, lag.max = lag.max, plot = FALSE)$acf))
  ggplot(df, aes(lag, acf, colour = chain)) +
    geom_hline(yintercept = 0, colour = jama$mid, linewidth = 0.3) +
    geom_line(linewidth = 0.5) +
    facet_wrap(~par, nrow = 1, labeller = as_labeller(par_labels)) +
    scale_colour_manual(values = chain_cols) +
    labs(x = "Lag (draws)", y = "Autocorrelation", colour = "Chain",
         caption = "Autocorrelation should fall to about zero within a few lags (efficient sampling).") +
    theme_jama() + theme(legend.title = element_text(colour = jama$ink))
}

energy_plot <- function(res) {
  sm <- res$sampler
  df <- sm |> group_by(.chain) |> reframe(marginal = energy__ - mean(energy__), transition = c(NA, diff(energy__))) |>
    tidyr::pivot_longer(c(marginal, transition), names_to = "type", values_to = "value") |> filter(!is.na(value)) |>
    mutate(type = factor(type, levels = c("marginal", "transition"), labels = c("Marginal energy", "Energy transition")),
           chain = factor(.chain))
  bf <- sm |> group_by(.chain) |> summarise(bfmi = sum(diff(energy__)^2) / sum((energy__ - mean(energy__))^2), .groups = "drop") |>
    mutate(chain = factor(.chain), label = sprintf("E-BFMI %.2f", bfmi))
  ggplot(df, aes(value, fill = type, colour = type)) +
    geom_density(alpha = 0.5, linewidth = 0.4) +
    geom_text(data = bf, aes(x = Inf, y = Inf, label = label), inherit.aes = FALSE, hjust = 1.1, vjust = 1.5, size = 3,
              colour = jama$ink) +
    facet_wrap(~chain, nrow = 1, labeller = labeller(chain = \(x) paste("Chain", x))) +
    scale_fill_manual(values = c(jama$pale, jama$ink)) + scale_colour_manual(values = c(jama$soft, jama$ink)) +
    labs(x = "Energy (centred)", y = "Density",
         caption = "The marginal energy and energy-transition densities should overlap; E-BFMI below 0.3 would flag a problem.") +
    theme_jama()
}

funnel_plot <- function(res, pars = c("mu", "theta[1]", "theta[2]")) {
  dr <- as.data.frame(res$draws); sm <- res$sampler
  dv <- sm$divergent__[match(paste(dr$.chain, dr$.iteration), paste(sm$.chain, sm$.iteration))] == 1
  ids <- res$meta$trials_b
  lab <- c(mu = "mu (pooled log-OR)", `theta[1]` = paste("theta:", ids[1]), `theta[2]` = paste("theta:", ids[2]))
  df <- bind_rows(lapply(pars, \(p) tibble(par = lab[[p]], log_tau = log(dr$tau), value = dr[[p]], divergent = dv)))
  ggplot(df, aes(log_tau, value)) +
    geom_point(aes(colour = divergent), alpha = 0.25, size = 0.6) +
    scale_colour_manual(values = c(`FALSE` = jama$soft, `TRUE` = "black"), guide = "none") +
    facet_wrap(~par, nrow = 1, scales = "free_y") +
    labs(x = "log(tau)", y = NULL,
         caption = sprintf("Each point is one draw; %d divergent transitions (black). A funnel narrowing at small tau with divergences would signal trouble.", sum(dv))) +
    theme_jama()
}

diag_overview <- function(df) {
  long <- df |> transmute(group, `Max R-hat` = max_rhat, `Min bulk ESS` = min_ess_bulk, `Min tail ESS` = min_ess_tail, `Min E-BFMI` = min_ebfmi) |>
    tidyr::pivot_longer(-group, names_to = "metric", values_to = "value") |> filter(!is.na(value)) |>
    mutate(metric = factor(metric, levels = c("Max R-hat", "Min bulk ESS", "Min tail ESS", "Min E-BFMI")))
  ref <- tibble(metric = factor(c("Max R-hat", "Min bulk ESS", "Min tail ESS", "Min E-BFMI"),
                                levels = levels(long$metric)), ref = c(1.01, 400, 400, 0.3))
  ggplot(long, aes(group, value)) +
    geom_hline(data = ref, aes(yintercept = ref), linetype = 2, colour = jama$ink, linewidth = 0.4) +
    geom_jitter(width = 0.15, height = 0, colour = jama$steel, alpha = 0.7, size = 1.3) +
    facet_wrap(~metric, scales = "free_y", nrow = 1) +
    labs(x = NULL, y = NULL, caption = "Each point is one fit. Dashed lines are the acceptance thresholds (R-hat 1.01, ESS 400, E-BFMI 0.3).") +
    theme_jama() + theme(axis.text.x = element_text(angle = 40, hjust = 1))
}

prior_posterior_plot <- function(res, mu_prior = c(0, 1), tau_sd = 0.5) {
  dr <- as.data.frame(res$draws)
  xs_mu <- seq(-3, 3, length.out = 400); xs_tau <- seq(0, 2, length.out = 400)
  post <- bind_rows(tibble(par = "mu (pooled log-OR)", value = dr$mu), tibble(par = "tau (between-trial SD)", value = dr$tau))
  pri <- bind_rows(tibble(par = "mu (pooled log-OR)", value = xs_mu, d = dnorm(xs_mu, mu_prior[1], mu_prior[2])),
                   tibble(par = "tau (between-trial SD)", value = xs_tau, d = 2 * dnorm(xs_tau, 0, tau_sd)))
  ggplot() +
    geom_density(data = post, aes(value, fill = "Posterior"), colour = jama$ink, alpha = 0.8, linewidth = 0.4) +
    geom_line(data = pri, aes(value, d, colour = "Prior"), linewidth = 0.7, linetype = 2) +
    facet_wrap(~par, scales = "free", nrow = 1) +
    scale_fill_manual(values = c(Posterior = jama$soft)) + scale_colour_manual(values = c(Prior = jama$ink)) +
    coord_cartesian(xlim = NULL) +
    labs(x = NULL, y = "Density",
         caption = "Prior and posterior for the pooled log-OR and the between-trial SD (F1, reference prior). Heavy overlap means the data add little.") +
    theme_jama()
}

pareto_plot <- function(loo_tab) {
  df <- loo_tab |> mutate(unit = factor(unit, levels = unique(unit)), level = factor(level, levels = c("arm", "trial"), labels = c("Arm", "Trial")))
  ggplot(df, aes(unit, pareto_k, shape = level, colour = level)) +
    geom_hline(yintercept = c(0.5, 0.7, 1), linetype = c(3, 2, 1), colour = jama$mid, linewidth = 0.4) +
    geom_point(size = 2.2) +
    scale_colour_manual(values = c(Arm = jama$soft, Trial = jama$ink)) + scale_shape_manual(values = c(16, 17)) +
    labs(x = NULL, y = "Pareto k",
         caption = "PSIS-LOO diagnostic (F1). Values above 0.7 (dashed) mean the importance-sampling estimate is unreliable; that is why exact leave-one-trial-out refits are used.") +
    theme_jama() + theme(axis.text.x = element_text(angle = 50, hjust = 1))
}

sim_recovery_plot <- function(rec) {
  df <- rec |> filter(variable %in% c("mu", "tau")) |>
    mutate(scenario = sprintf("true OR %.2f, tau %.2f", exp(mu_true), tau_true),
           variable = factor(variable, levels = c("mu", "tau"), labels = c("mu (log-OR)", "tau (SD)")),
           covers = `q2.5` <= truth & truth <= `q97.5`)
  tr <- df |> distinct(scenario, variable, truth)
  ggplot(df, aes(rep, median, ymin = `q2.5`, ymax = `q97.5`, colour = covers)) +
    geom_hline(data = tr, aes(yintercept = truth), linetype = 2, colour = jama$ink, linewidth = 0.4) +
    geom_pointrange(size = 0.15, linewidth = 0.3) +
    facet_grid(variable ~ scenario, scales = "free_y") +
    scale_colour_manual(values = c(`TRUE` = jama$light, `FALSE` = jama$ink), labels = c(`TRUE` = "Interval covers truth", `FALSE` = "Misses truth")) +
    labs(x = "Simulated dataset", y = "Posterior median and 95% interval",
         caption = "40 simulated F1-shaped datasets per scenario; dashed line = true value.") +
    theme_jama()
}
