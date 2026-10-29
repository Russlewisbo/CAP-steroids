# Bayesian meta-analysis of adjunctive corticosteroids in severe CAP

Draft analysis (not peer reviewed; PROSPERO registration pending).

**Report (GitHub Pages):** https://russlewisbo.github.io/CAP-steroids/

## Layout

* `analysis/` - Stan models (`stan/`), R code (`R/`), the `targets` pipeline (`_targets.R`), `renv` lockfile and the Quarto website sources (`*.qmd`, `_quarto.yml`).
* `docs/` - the rendered website that GitHub Pages serves. Generated; do not edit by hand.
* `analysis_mortality.csv`, `trials.csv`, `mortality_long.csv` - analysis datasets (see `ANALYSIS_INSTRUCTIONS.md`).

## Rebuilding the site

The fits need CmdStan 2.40 and take a few minutes, so the site is rendered locally and committed; it is not built on GitHub.

```r
setwd("analysis")
renv::restore()
targets::tar_make()   # refits what changed, re-renders the site into ../docs
```

Then commit `docs/` and push.

## Publishing

On GitHub: Settings > Pages > Build and deployment > Source: *Deploy from a branch*, Branch: `main`, folder `/docs`.
