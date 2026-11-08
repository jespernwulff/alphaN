# R and Stata side by side

The R package and the Stata command implement the same calculations. The
Stata command is a port of R package version 0.3.0.

## Commands

| What | R | Stata |
|----|----|----|
| Calibrate the level | `alphaN(n, BF)` | `alphan n, bf()` |
| Power at the calibrated level | `alphaN_power(n, d, BF)` | `alphan power n, d() bf()` |
| Settings report | `alphaN_report(n, BF)` | `alphan report n, bf()` |
| Bayes factors after a fit | `JAB(model, covariate)` | `alphan jab [coefficients]` |
| Bayes factor from a *t* statistic | `JABt(n, t)` | `alphan jabt t, n()` |
| Bayes factor from a *p*-value | `JABp(n, p, z, df)` | `alphan jabp p, n() [df()]` |
| Klauer Bayes factor | `klauerBF(n, t, Fstat)` | `alphan klauerbf, n() t() fstat()` |
| Effective sample size | `n_effective(n, se, se_robust)` | `alphan n_effective, n() se() se_robust()` |
| Level against sample size | `alphaN_plot(BF)` | `alphan plot, bf()` |
| Power against sample size | `alphaN_power_plot(d, BF)` | `alphan powerplot, d() bf()` |
| Bayes factor against *p*-value | `JAB_plot(n, BF)` | `alphan jabplot n, bf()` |

## Arguments and options

| R argument | Stata option | Meaning |
|----|----|----|
| `BF` | `bf()` | Target Bayes factor |
| `method` | `method()` | `"JAB"`, `"min"`, `"robust"`, `"balanced"`, `"ES"`, `"moment"`; in Stata, case does not matter |
| `upper` | `upper()` | Upper limit of realistic effects (balanced) |
| `de` | [`de()`](https://rdrr.io/r/utils/dataentry.html) | Targeted effect size (ES, moment) |
| `nu` | `nu()` | Degrees of freedom of the prior (ES, moment) |
| `r` | `r()` | Scale of the prior (ES) |
| `q` | [`q()`](https://rdrr.io/r/base/quit.html) | Coefficients tested jointly (ES, moment) |
| `p` | `p()` | Parameters retained under the null (ES, moment) |
| `d` | `d()` | Standardized effect for power |
| `power_at` | `powerat()` | Effects for the power section of the report |
| `file` | `saving(filename [, replace])` | Where to write the report |
| `width` | `width()` | Line width of the report |
| `methods`, `max`, `ylim`, `log`, `ref` | [`methods()`](https://rdrr.io/r/utils/methods.html), [`max()`](https://rdrr.io/r/base/Extremes.html), `ylim()`, [`log()`](https://rdrr.io/r/base/Log.html), `ref()` | Graph settings; `noref` in Stata corresponds to `ref = NULL` |

Numeric lists are recycled in Stata as vectors are in R.

## Things that differ by design

- `alphan jab` reads `e(b)`, `e(V)` and `e(N)`, so it runs after any
  Stata estimator and uses that estimator’s standard errors.
  [`JAB()`](https://jespernwulff.github.io/alphaN/reference/JAB.md)
  accepts `lm` and `glm` objects and uses their classical standard
  errors; for cluster-robust ones, pass the statistics to
  [`JABt()`](https://jespernwulff.github.io/alphaN/reference/JABt.md),
  as in the [worked
  example](https://jespernwulff.github.io/alphaN/articles/wages.md).
- `alphan jab` takes an `n()` option, for instance to use an effective
  sample size. In R, the same is `JABt(ne, t)`.
- Bayes factors too large for a double are `Inf` in R and about 8e+307
  in Stata.
- Stata prints a table and leaves the numbers in `r()`, including
  `r(table)` with one row per case.
- The graphs have the same colors and contents, but a different layout
  engine.

## How closely they agree

`tests/run-tests.do` in the [Stata
repository](https://github.com/jespernwulff/alphaN-stata) compares the
command with more than 1,100 reference values written by the R package.
The checks enforce these tolerances:

| Quantity | Relative tolerance |
|----|----|
| Level, JAB, min and robust | 1e-12 |
| Level, balanced | 1e-8 |
| Level, ES and moment, up to *n* = 10,000 | 2e-5 |
| Level, ES and moment, all *n* up to 100,000 | 1e-3 |
| Bayes factors from *t* (*n* up to 1,000) and from *F* (BF above 1e-4) | 2e-5 |
| Bayes factors from *t* and *F*, the rest, down to BF of 1e-12 | 2e-3 |
| Power | 2e-5 |
| [`JAB()`](https://jespernwulff.github.io/alphaN/reference/JAB.md) after [`lm()`](https://rdrr.io/r/stats/lm.html) and `regress` | 1e-9 |
| [`JAB()`](https://jespernwulff.github.io/alphaN/reference/JAB.md) after [`glm()`](https://rdrr.io/r/stats/glm.html) and `logit`, which stop iterating at different points | 1e-5 |

The tests also reproduce the Bayes factors printed in Tables 7 and 8 of
Klauer et al. (2025) and compare the text of the settings report line by
line.

The largest gaps come from the R side. R package 0.3.0 integrates the
balanced method numerically where the Stata command uses the closed form
of the integral; the next R release uses the closed form too. For very
small Bayes factors at a sample size of 60,000, a 40-digit evaluation
agrees with Stata and not with R, whose integration tolerance is
coarser. Over the range tested (sample sizes up to 2.5 million, `upper`
of at most 1) the gaps are far too small to matter for any decision
about a significance level.

## Version

This page describes R package 0.3.0 and Stata command 0.3.0. The command
is written for Stata 14 or later and has been tested on StataNow 19.5.
