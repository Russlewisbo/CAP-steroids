// Meta-regression variant of hybrid_ma.stan (one covariate at a time; no agent layer).
// theta_k = mu + b * x_k + tau * z_k ; mu is the pooled log-OR at the covariate mean (x is centred).
// Count trials first, then contrast trials (same order as build_stan_data()).
data {
  int<lower=0> K_b;
  array[K_b] int<lower=0> r1;
  array[K_b] int<lower=0> n1;
  array[K_b] int<lower=0> r0;
  array[K_b] int<lower=0> n0;
  int<lower=0> K_c;
  vector[K_c] y_c;
  vector<lower=0>[K_c] se_c;
  vector[K_b + K_c] x;
  real mu_prior_mean;
  real<lower=0> mu_prior_sd;
  real<lower=0> b_prior_sd;
  real<lower=0> tau_prior_sd;
  real<lower=0> alpha_prior_sd;
  int<lower=0> N_r0grid;
  vector<lower=0, upper=1>[N_r0grid] r0grid;
}
parameters {
  vector[K_b] alpha;
  real mu;
  real b;
  real<lower=0> tau;
  vector[K_b + K_c] z_t;
}
transformed parameters {
  vector[K_b + K_c] theta = mu + b * x + tau * z_t;
}
model {
  alpha ~ normal(0, alpha_prior_sd);
  mu ~ normal(mu_prior_mean, mu_prior_sd);
  b ~ normal(0, b_prior_sd);
  tau ~ normal(0, tau_prior_sd);
  z_t ~ std_normal();
  if (K_b > 0) {
    r0 ~ binomial_logit(n0, alpha);
    r1 ~ binomial_logit(n1, alpha + theta[1:K_b]);
  }
  if (K_c > 0) y_c ~ normal(theta[(K_b + 1):(K_b + K_c)], se_c);
}
generated quantities {
  real OR = exp(mu);
  real theta_new = normal_rng(mu, tau);
  real OR_new = exp(theta_new);
  vector[N_r0grid] ARR;
  vector[N_r0grid] NNT;
  for (g in 1:N_r0grid) {
    real p1 = inv_logit(logit(r0grid[g]) + mu);
    ARR[g] = r0grid[g] - p1;
    NNT[g] = 1 / ARR[g];
  }
}
