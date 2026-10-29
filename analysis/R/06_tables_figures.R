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
    geom_vline(xintercept = 1, linetype = 2, colour = jama$mid, linewidth = 0.4) +
    geom_pointrange(position = position_dodge(width = 0.6), size = 0.35) +
    scale_x_log10(breaks = c(0.1, 0.25, 0.5, 1, 2, 4, 10)) +
    scale_shape_manual(values = c(16, 15, 18)) +
    scale_colour_manual(values = c(jama$light, jama$steel, jama$ink)) +
    labs(x = "Odds ratio (log scale; <1 favours corticosteroids)", y = NULL, shape = NULL, colour = NULL,
         caption = "Bars: raw = 95% Wald CI; shrunken and pooled = 95% CrI. * 0.5 added to all four cells for display only (zero cell).\nContrast-based trial entered as normal likelihood; subgroup-derived trial flagged.") +
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
ladder_plot <- function(ladder) {
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
  ggplot(df, aes(est, label, xmin = lo, xmax = hi, colour = type)) +
    geom_vline(xintercept = 1, linetype = 2, colour = jama$mid, linewidth = 0.4) +
    geom_pointrange(position = position_dodge(width = 0.5), size = 0.35) +
    scale_x_log10(breaks = c(0.1, 0.25, 0.5, 1, 2, 4, 8)) +
    scale_colour_manual(values = c(Prior = jama$pale, Posterior = jama$ink)) +
    labs(x = "Pooled odds ratio (log scale)", y = NULL, colour = NULL,
         caption = "Median and 95% interval. Enthusiastic/reference/skeptical rungs are proposals (D3); harm rungs are protocol-fixed.") +
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
loto_plot <- function(loto_summary, full, labels) {
  df <- loto_summary |> filter(trial != "none") |>
    left_join(labels, by = c("trial" = "trial_id")) |>
    mutate(model = factor(model, levels = c("unpooled", "pooled"),
                          labels = c("Unpooled baselines (primary)", "Pooled baselines (comparison)")))
  ggplot(df, aes(OR_median, study_label, xmin = OR_q025, xmax = OR_q975, colour = model)) +
    geom_vline(xintercept = 1, linetype = 2, colour = jama$mid, linewidth = 0.4) +
    geom_vline(xintercept = full$OR_median, linetype = 3, colour = jama$mid, linewidth = 0.4) +
    scale_colour_manual(values = c(jama$ink, jama$soft)) +
    geom_pointrange(position = position_dodge(width = 0.5), size = 0.35) +
    scale_x_log10(breaks = c(0.25, 0.5, 1, 2)) +
    labs(x = "Pooled OR without the named trial (log scale)", y = "Trial omitted", colour = NULL,
         caption = sprintf("Median and 95%% CrI. Dotted line: full-F1 unpooled-baseline median OR (%.2f).", full$OR_median)) +
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
