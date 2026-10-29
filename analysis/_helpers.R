# Shared helpers for the site pages (no dependence on pipeline targets except `s` via fit_row)
or_ci <- \(m, l, h, d = 2) ifelse(is.na(m), "–", sprintf("%.*f (%.*f%s%.*f)", d, m, d, l, ifelse(l < 0, " to ", "–"), d, h))
pr <- \(x, d = 2) ifelse(is.na(x), "–", sprintf("%.*f", d, x))
dash <- \(x) ifelse(is.na(x), "–", as.character(x))
res_tbl <- function(df) {
  df |> dplyr::transmute(
    Fit = fit,
    `OR (95% CrI)` = or_ci(OR_median, OR_q025, OR_q975),
    `P(OR<1)` = pr(P_OR_lt_1), `P(OR<0.9)` = pr(P_OR_lt_0.9), `P(OR<0.833)` = pr(`P_OR_lt_0.833`),
    `P(OR>1.1)` = pr(P_OR_gt_1.1), `tau median` = pr(tau_median),
    `Predictive OR, new trial (95% interval)` = or_ci(ORnew_median, ORnew_q025, ORnew_q975))
}
# Row of the all-fit summary table `s` (defined on the page) for fit id `i`
fit_row <- \(i) dplyr::filter(s, id == i)

rung_label <- c(enthusiastic = "Enthusiastic", reference = "Reference (weakly informative)",
                skeptical = "Skeptical", mild_harm = "Mild harm-leaning", remap_harm = "REMAP-CAP harm")
prior_text <- \(mu_mean, mu_sd) sprintf("Normal(%s, %.2f)", ifelse(mu_mean == 0, "0", sprintf("log %.2f", exp(mu_mean))), mu_sd)

# Prior-ladder results table (rung names and prior specification instead of internal ids)
ladder_tbl <- function(df) {
  df |> dplyr::transmute(
    Prior = paste0(rung_label[rung], ifelse(drop_remap, " (REMAP-CAP row excluded)", "")),
    `Prior on log-OR` = prior_text(mu_mean, mu_sd),
    `OR (95% CrI)` = or_ci(OR_median, OR_q025, OR_q975),
    `P(OR<1)` = pr(P_OR_lt_1), `P(OR<0.9)` = pr(P_OR_lt_0.9), `P(OR<0.833)` = pr(`P_OR_lt_0.833`),
    `P(OR>1.1)` = pr(P_OR_gt_1.1), `tau median` = pr(tau_median),
    `Predictive OR, new trial (95% interval)` = or_ci(ORnew_median, ORnew_q025, ORnew_q975))
}

cov_label <- c(
  pct_septic_shock_baseline = "Septic shock at baseline (%)",
  pct_imv_baseline = "Invasive ventilation at baseline (%)",
  pct_influenza_viral = "Influenza or viral pneumonia (%)",
  prednisone_equiv_mg_day = "Prednisone-equivalent dose (mg/day)",
  duration_days = "Treatment duration (days)",
  age_central_trial = "Age, trial central value (years)",
  pct_psi_4_5_trial = "PSI class IV-V (%)",
  timing_le24h = "First dose within 24 h (1 = yes)",
  high_income = "High-income setting (1 = yes)",
  icu_setting = "ICU setting (1 = yes)",
  double_blind = "Double-blind placebo (1 = yes)",
  mineralocorticoid = "Mineralocorticoid co-administered (1 = yes)",
  severe_population = "Severe-CAP population (1 = yes)")

# Shorthand for text: OR (95% CrI) and any summary column for fit id, from the all-fit table `s`
oc <- \(id, d = 2) { r <- fit_row(id); or_ci(r$OR_median, r$OR_q025, r$OR_q975, d) }
pv <- \(id, col, d = 2) pr(fit_row(id)[[col]], d)
