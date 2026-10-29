library(ggplot2); library(dplyr); library(posterior); library(purrr)

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
  ggplot(df, aes(exp(est), label_dis, xmin = exp(lo), xmax = exp(hi), shape = type, colour = type)) +
    geom_vline(xintercept = 1, linetype = 2) +
    geom_pointrange(position = position_dodge(width = 0.6), size = 0.35) +
    scale_x_log10(breaks = c(0.1, 0.25, 0.5, 1, 2, 4, 10)) +
    scale_shape_manual(values = c(16, 15, 18)) +
    labs(x = "Odds ratio (log scale; <1 favours corticosteroids)", y = NULL, shape = NULL, colour = NULL,
         caption = "Bars: raw = 95% Wald CI; shrunken and pooled = 95% CrI. * 0.5 added to all four cells for display only (zero cell).\nContrast-based trial entered as normal likelihood; subgroup-derived trial flagged.") +
    theme_minimal() + theme(legend.position = "bottom")
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
    geom_linerange(aes(ymin = lo95, ymax = hi95), colour = "grey60", linewidth = 0.8) +
    geom_linerange(aes(ymin = lo50, ymax = hi50), colour = "grey35", linewidth = 2) +
    geom_point(aes(y = med), shape = 1, size = 2.5) +
    geom_point(aes(y = observed), colour = "red3", size = 2.5) +
    facet_wrap(~label, labeller = label_wrap_gen(24), scales = "free_y", nrow = 2) +
    labs(x = NULL, y = "Deaths",
         caption = "Red = observed deaths. Open circle = replicated median; thick/thin bars = 50%/95% posterior-predictive intervals.\nReplicated arms condition on each trial's own baseline (unpooled alpha_k), so control arms are fitted near-exactly by design.") +
    theme_minimal() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
}

# Prior ladder: prior 95% interval (light) and posterior median/95% CrI (dark) per rung, F1
ladder_plot <- function(ladder) {
  ladder <- ladder |> rename(label = fit)
  lv <- rev(ladder$label)
  prior <- ladder |> transmute(label, type = "Prior", est = exp(mu_mean),
                               lo = exp(mu_mean - 1.96 * mu_sd), hi = exp(mu_mean + 1.96 * mu_sd))
  post <- ladder |> transmute(label, type = "Posterior", est = OR_median, lo = OR_q025, hi = OR_q975)
  df <- bind_rows(prior, post) |> mutate(label = factor(label, levels = lv),
                                         type = factor(type, levels = c("Prior", "Posterior")))
  ggplot(df, aes(est, label, xmin = lo, xmax = hi, colour = type)) +
    geom_vline(xintercept = 1, linetype = 2) +
    geom_pointrange(position = position_dodge(width = 0.5), size = 0.35) +
    scale_x_log10(breaks = c(0.1, 0.25, 0.5, 1, 2, 4, 8)) +
    scale_colour_manual(values = c(Prior = "grey60", Posterior = "black")) +
    labs(x = "Pooled odds ratio (log scale)", y = NULL, colour = NULL,
         caption = "Median and 95% interval. Enthusiastic/reference/skeptical rungs are proposals (D3); harm rungs are protocol-fixed.") +
    theme_minimal() + theme(legend.position = "bottom")
}

# Tipping point: P(OR<1) and P(OR<0.833) vs skeptical prior SD
tip_plot <- function(tip, thr) {
  df <- bind_rows(tip |> transmute(prior_sd, metric = "P(OR < 1)", p = P_OR_lt_1),
                  tip |> transmute(prior_sd, metric = "P(OR < 0.833)", p = `P_OR_lt_0.833`))
  vl <- thr |> filter(!is.na(prior_sd_at_crossing)) |>
    mutate(metric = ifelse(metric == "P_OR_lt_1", "P(OR < 1)", "P(OR < 0.833)"))
  ggplot(df, aes(prior_sd, p, colour = metric)) +
    geom_hline(yintercept = c(0.8, 0.9), linetype = 3) +
    geom_line() + geom_point(size = 1) +
    geom_vline(data = vl, aes(xintercept = prior_sd_at_crossing, colour = metric), linetype = 2, show.legend = FALSE) +
    scale_y_continuous(limits = c(0, 1)) +
    labs(x = "Skeptical prior SD on log-OR, prior = Normal(0, SD)", y = "Posterior probability", colour = NULL,
         caption = "F1 default rows. Dotted: 0.80 and 0.90. Dashed vertical: prior SD at which the probability crosses 0.90 / 0.80.") +
    theme_minimal() + theme(legend.position = "bottom")
}

# Leave-one-trial-out influence: pooled OR with each F1 trial omitted, both baseline models
loto_plot <- function(loto_summary, full, labels) {
  df <- loto_summary |> filter(trial != "none") |>
    left_join(labels, by = c("trial" = "trial_id")) |>
    mutate(model = factor(model, levels = c("unpooled", "pooled"),
                          labels = c("Unpooled baselines (primary)", "Pooled baselines (comparison)")))
  ggplot(df, aes(OR_median, study_label, xmin = OR_q025, xmax = OR_q975, colour = model)) +
    geom_vline(xintercept = 1, linetype = 2) +
    geom_vline(xintercept = full$OR_median, linetype = 3) +
    geom_pointrange(position = position_dodge(width = 0.5), size = 0.35) +
    scale_x_log10(breaks = c(0.25, 0.5, 1, 2)) +
    labs(x = "Pooled OR without the named trial (log scale)", y = "Trial omitted", colour = NULL,
         caption = sprintf("Median and 95%% CrI. Dotted line: full-F1 unpooled-baseline median OR (%.2f).", full$OR_median)) +
    theme_minimal() + theme(legend.position = "bottom")
}

# 2-D tipping surface: prior centre (as OR) x prior SD
tip2_heatmap <- function(tab, what = c("P_OR_lt_1", "OR_median")) {
  what <- match.arg(what)
  df <- tab |> mutate(centre = factor(centre_or), sd = factor(prior_sd),
                      val = .data[[what]], txt = sprintf("%.2f", val))
  p <- ggplot(df, aes(centre, sd, fill = if (what == "OR_median") log(val) else val)) +
    geom_tile(colour = "white") + geom_text(aes(label = txt), size = 3) +
    labs(x = "Prior centre (OR)", y = "Prior SD (log-OR)",
         caption = "F1 default rows, REMAP-CAP d90 contrast included.") +
    theme_minimal() + theme(panel.grid = element_blank())
  if (what == "P_OR_lt_1") {
    p + scale_fill_gradient2(midpoint = 0.5, limits = c(0, 1), name = "P(OR < 1)")
  } else {
    p + scale_fill_gradient2(midpoint = 0, name = "Posterior\nmedian OR",
                             breaks = log(c(0.6, 0.8, 1, 1.25)), labels = c("0.6", "0.8", "1.0", "1.25"))
  }
}

# Meta-regression coefficients (per 1 SD for continuous covariates; group difference for binary)
mr_plot <- function(mr) {
  df <- mr |> filter(status == "fitted") |>
    mutate(label = sprintf("%s (n=%d)", covariate, n_trials),
           set = factor(set, levels = c("F1", "F4")))
  ggplot(df, aes(b_median, label, xmin = b_q025, xmax = b_q975)) +
    geom_vline(xintercept = 0, linetype = 2) +
    geom_pointrange(size = 0.35) +
    facet_wrap(~set, scales = "free_y", ncol = 1) +
    labs(x = "Coefficient b on log-OR (median, 95% CrI; per 1 SD for continuous, group difference for binary)",
         y = NULL, caption = "Exploratory, across-trial (ecological), underpowered. Prior b ~ Normal(0, 1) (proposed).") +
    theme_minimal()
}
