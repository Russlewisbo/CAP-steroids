// COMPARISON MODEL ONLY (not primary; hard rule 6 keeps baselines unpooled in primary fits).
// Same as hybrid_ma.stan but baselines are exchangeable: alpha_k ~ Normal(a0, sigma_a).
data {
  int<lower=0> K_b;
  array[K_b] int<lower=0> r1;
  array[K_b] int<lower=0> n1;
  array[K_b] int<lower=0> r0;
  array[K_b] int<lower=0> n0;
  int<lower=0> K_c;
  vector[K_c] y_c;
  vector<lower=0>[K_c] se_c;
  int<lower=1> J;
  array[K_b] int<lower=1, upper=J> agent_b;
  array[K_c] int<lower=1, upper=J> agent_c;
  int<lower=0, upper=1> agent_hier;
  real mu_prior_mean;
  real<lower=0> mu_prior_sd;
  real<lower=0> tau_prior_sd;
  real<lower=0> omega_prior_sd;
  real<lower=0> a0_prior_sd;
  real<lower=0> sigma_a_prior_sd;
  int<lower=0> N_r0grid;
  vector<lower=0, upper=1>[N_r0grid] r0grid;  // baseline risks for NNT
  int<lower=0, upper=1> prior_only;           // 1 = ignore likelihood
}
parameters {
  real a0;
  real<lower=0> sigma_a;
  vector[K_b] z_alpha;
  real mu;
  real<lower=0> tau;
  real<lower=0> omega;
  vector[J] z_a;
  vector[K_b + K_c] z_t;
}
transformed parameters {
  vector[K_b] alpha = a0 + sigma_a * z_alpha;
  vector[J] beta = mu + (agent_hier == 1 ? omega : 0) * z_a;
  vector[K_b + K_c] theta;
  for (k in 1:K_b)
    theta[k] = (agent_hier == 1 ? beta[agent_b[k]] : mu) + tau * z_t[k];
  for (k in 1:K_c)
    theta[K_b + k] = (agent_hier == 1 ? beta[agent_c[k]] : mu) + tau * z_t[K_b + k];
}
model {
  a0 ~ normal(0, a0_prior_sd);
  sigma_a ~ normal(0, sigma_a_prior_sd);
  z_alpha ~ std_normal();
  mu ~ normal(mu_prior_mean, mu_prior_sd);
  tau ~ normal(0, tau_prior_sd);
  omega ~ normal(0, omega_prior_sd);
  z_a ~ std_normal();
  z_t ~ std_normal();
  if (!prior_only) {
    if (K_b > 0) {
      r0 ~ binomial_logit(n0, alpha);
      r1 ~ binomial_logit(n1, alpha + theta[1:K_b]);
    }
    if (K_c > 0) y_c ~ normal(theta[(K_b + 1):(K_b + K_c)], se_c);
  }
}
generated quantities {
  real OR = exp(mu);
  real theta_new = normal_rng(mu, tau);
  real OR_new = exp(theta_new);
  vector[J] OR_agent = exp(beta);
  vector[N_r0grid] ARR;
  vector[N_r0grid] NNT;
  for (g in 1:N_r0grid) {
    real p1 = inv_logit(logit(r0grid[g]) + mu);
    ARR[g] = r0grid[g] - p1;
    NNT[g] = 1 / ARR[g];
  }
  array[K_b] int r1_rep;
  array[K_b] int r0_rep;
  vector[2 * K_b + K_c] log_lik;
  for (k in 1:K_b) {
    r1_rep[k] = binomial_rng(n1[k], inv_logit(alpha[k] + theta[k]));
    r0_rep[k] = binomial_rng(n0[k], inv_logit(alpha[k]));
    log_lik[k] = binomial_logit_lpmf(r0[k] | n0[k], alpha[k]);
    log_lik[K_b + k] = binomial_logit_lpmf(r1[k] | n1[k], alpha[k] + theta[k]);
  }
  for (k in 1:K_c)
    log_lik[2 * K_b + k] = normal_lpdf(y_c[k] | theta[K_b + k], se_c[k]);
}
