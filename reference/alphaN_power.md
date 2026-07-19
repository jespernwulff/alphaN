# Power at the calibrated alpha level

Computes the power of the two-sided coefficient test at the alpha level
that
[`alphaN()`](https://jespernwulff.github.io/alphaN/reference/alphaN.md)
calibrates to a target Bayes factor, for a standardized effect of size
`d`. Together with the calibrated alpha itself, this is the quantity
worth preregistering: it shows what the chosen evidence target costs
against the effects the researcher cares about. Vectorized over `n` and
`d` (recycled).

## Usage

``` r
alphaN_power(
  n,
  d,
  BF = 3,
  method = "JAB",
  upper = 1,
  de = 0.5,
  nu = NULL,
  r = NULL,
  q = 1,
  p = 0
)
```

## Arguments

- n:

  Sample size. A positive numeric vector.

- d:

  The standardized effect size at which power is evaluated, on the same
  scale as `de`: Cohen's d for `q = 1`, Cohen's f for joint tests. A
  non-negative numeric vector.

- BF:

  Target Bayes factor for the calibration. Defaults to 3.

- method:

  Which Bayes factor to calibrate alpha to. The first four options
  invert Jeffreys' approximate Bayes factor and differ in the choice of
  the prior fraction 'b'; the last two invert the exact test-statistic
  Bayes factors of Klauer et al. (2025), whose priors center the
  alternative hypothesis on a prespecified effect size `de`. One of:

  - "JAB": this choice of b produces Jeffreys' approximate BF
    (Wagenmakers, 2022)

  - "min": uses the minimal training sample for the prior (Gu et al.,
    2018)

  - "robust": a robust version of "min" that prevents too small b
    (O'Hagan, 1995)

  - "balanced": this choice of b balances the type I and type II errors
    (Gu et al., 2016)

  - "ES": calibrates alpha to the effect-size Bayes factor (Klauer et
    al., 2025)

  - "moment": calibrates alpha to the moment Bayes factor (Klauer et
    al., 2025), under which effects close to zero are a priori
    implausible

- upper:

  The upper limit for the range of realistic effect sizes. Only relevant
  when method="balanced". Defaults to 1 such that the range of realistic
  effect sizes is uniformly distributed between 0 and 1, U(0,1).
  Conceptually, `upper` plays for the "balanced" method the role that
  `de` plays for "ES" and "moment": both declare which effect sizes the
  researcher deems realistic. `upper` treats them as a uniform band
  whose Type I and Type II error rates are then balanced, whereas `de`
  singles out a focal effect size on which the prior concentrates.

- de:

  The prespecified (targeted) effect size in standardized units: Cohen's
  d for `q = 1` and Cohen's f for joint tests (the scales coincide at
  `q = 1`). Only used by methods "ES" and "moment". Defaults to 0.5, a
  medium effect; use 0.2 for small and 0.8 for large effects (Cohen,
  1988).

- nu:

  Degrees of freedom of the prior t distribution for methods "ES" and
  "moment". The default, NULL, uses the values recommended by Klauer et
  al. (2025): 3 for "ES" and `5 + (q - 1)` for "moment".

- r:

  Scale of the two prior mixture components for method "ES". The
  default, NULL, uses the recommendation of Klauer et al. (2025),
  `r = sqrt((nu - 2)/(nu * q)) * de`, which requires nu \> 2 and de \>
  0; otherwise supply `r` explicitly.

- q:

  Number of coefficients tested jointly. Only used by methods "ES" and
  "moment". The default, 1, is the test of a single coefficient; for
  `q > 1` the alpha level is set for the F test of the joint null that
  all q coefficients are zero.

- p:

  Number of parameters retained in the model under the null, including
  any intercept. Only used by methods "ES" and "moment". The effective
  sample size of Klauer et al. (2025) is `n - p`; the default, 0,
  reproduces the one-sample form, which treats the sample size as
  effective. For a regression coefficient in a small sample, setting `p`
  to the number of other estimated coefficients (including the
  intercept) gives the residual-degrees-of-freedom behavior of the exact
  regression case.

## Value

A numeric vector with the power of the two-sided test (noncentral t for
`q = 1`, noncentral F for `q > 1`, both at the residual degrees of
freedom implied by `n`, `p`, and `q`) at the calibrated alpha.

## Details

The power computation is exact under the normal linear model and carries
the usual Wald-asymptotic interpretation for other generalized linear
models, mirroring the scope of the calibration itself. When the
calibrated alpha is 1 (the evidence target is met vacuously), the power
is 1 for every effect size.

For effects parameterized on a model-specific scale (an odds ratio under
a covariate design, a rate ratio, an R-squared increment), combine the
calibrated alpha with a model-specific power calculator instead: the
functions of the [pwrss](https://CRAN.R-project.org/package=pwrss)
package accept the significance level as an argument, so
`alpha = alphaN(n, BF = 3)` plugs the calibration directly into, for
example,
[`pwrss::power.z.logistic()`](https://metinbulus.github.io/pwrss/reference/power.z.logistic.html).

## See also

[`alphaN()`](https://jespernwulff.github.io/alphaN/reference/alphaN.md),
[`alphaN_power_plot()`](https://jespernwulff.github.io/alphaN/reference/alphaN_power_plot.md),
[`alphaN_report()`](https://jespernwulff.github.io/alphaN/reference/alphaN_report.md)

## Examples

``` r
# Power against a small effect at the JAB-calibrated alpha, n = 1,000
alphaN_power(n = 1000, d = 0.1, BF = 3)
#> [1] 0.5547323

# The same design under the balanced calibration keeps more power
alphaN_power(n = 1000, d = 0.1, BF = 3, method = "balanced")
#> [1] 0.817175

# A power curve across sample sizes
alphaN_power(n = c(100, 500, 1000, 5000), d = 0.2, BF = 3)
#> [1] 0.2603139 0.9397823 0.9995038 1.0000000
# Model-specific power at the calibrated alpha via the pwrss package:
# a logistic-regression coefficient with odds ratio 1.5
pwrss::power.z.logistic(odds.ratio = 1.5, base.prob = 0.2,
                        n = 1000, alpha = alphaN(1000, BF = 3),
                        verbose = FALSE)$power
#> [1] 0.9802585
```
