# Write a settings report for a calibrated alpha level

Generates a short, human-readable Markdown report that records every
input behind a calibrated alpha level together with the result: the
sample size, the evidence target, the calibration method and its prior
settings, the resulting alpha, and the decision rule. The report is
designed to be attached to a preregistration protocol or a supplementary
appendix, so that an alpha level chosen before data collection leaves a
citable trace. It mirrors the downloadable report of the package's
companion Shiny application.

## Usage

``` r
alphaN_report(
  n,
  BF = 1,
  method = "JAB",
  upper = 1,
  de = 0.5,
  nu = NULL,
  r = NULL,
  q = 1,
  p = 0,
  file = NULL,
  width = 72,
  power_at = NULL
)
```

## Arguments

- n:

  Sample size. A single positive number (one report describes one
  design).

- BF:

  Target Bayes factor. A single positive number.

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

- file:

  Optional path. If supplied, the report is also written to this file.

- width:

  Maximum line width of the report; longer lines are wrapped with a
  hanging indent. Defaults to 72 characters.

- power_at:

  Optional numeric vector of standardized effect sizes. If supplied, the
  report includes the power of the calibrated test against each of them
  (computed with
  [`alphaN_power()`](https://jespernwulff.github.io/alphaN/reference/alphaN_power.md)),
  so the preregistered alpha is documented together with what it costs.

## Value

The report as a character vector of lines, invisibly. The report is
printed to the console.

## See also

[`alphaN()`](https://jespernwulff.github.io/alphaN/reference/alphaN.md),
[`alphaN_power()`](https://jespernwulff.github.io/alphaN/reference/alphaN_power.md)

## Examples

``` r
alphaN_report(n = 1000, BF = 3, method = "JAB")
#> # alphaN settings report
#> 
#> Generated on 2026-07-23 with alphaN 0.2.0.9000.
#> 
#> ## Inputs
#> 
#> - Sample size (n): 1,000
#> - Target Bayes factor: 3 (moderate evidence)
#> - Calibration method: JAB: Jeffreys' approximate Bayes factor
#>   (unit-information prior, b = 1/n)
#> 
#> ## Result
#> 
#> - Calibrated alpha level: 0.00255
#> - Decision rule: Reject H0 if the two-sided p-value of the coefficient
#>   is at or below 0.00255.
#> - Interpretation: a significant result then corresponds to a Bayes
#>   factor of at least 3 in favor of the alternative under this prior.
#> 
#> ## Please cite
#> 
#> - Wulff, J. N., & Taylor, L. (2024). How and why alpha should depend on
#>   sample size: A Bayesian-frequentist compromise for significance
#>   testing. Strategic Organization, 22(3), 550-581.
#>   doi:10.1177/14761270231214429

# Effect-size calibration with a power section, written to a file
f <- tempfile(fileext = ".md")
alphaN_report(n = 1000, BF = 3, method = "ES", de = 0.5,
              power_at = c(0.1, 0.2, 0.5), file = f)
#> # alphaN settings report
#> 
#> Generated on 2026-07-23 with alphaN 0.2.0.9000.
#> 
#> ## Inputs
#> 
#> - Sample size (n): 1,000
#> - Target Bayes factor: 3 (moderate evidence)
#> - Calibration method: ES: effect-size Bayes factor of Klauer,
#>   Meyer-Grant & Kellen (2025)
#> - Targeted effect size (de): 0.5 (Cohen's d)
#> - Prior degrees of freedom (nu): 3
#> - Prior scale (r): 0.2887
#> - Scope: conservative large-sample form; supply p for the calibration
#>   that is exact for the normal linear model. Asymptotic for other
#>   generalized linear models.
#> 
#> ## Result
#> 
#> - Calibrated alpha level: 0.00219
#> - Decision rule: Reject H0 if the two-sided p-value of the coefficient
#>   is at or below 0.00219.
#> - Interpretation: a significant result then corresponds to a Bayes
#>   factor of at least 3 in favor of the alternative under this prior.
#> 
#> ## Power at the calibrated alpha
#> 
#> - Against a standardized effect of 0.1: 0.54
#> - Against a standardized effect of 0.2: 1.00
#> - Against a standardized effect of 0.5: 1.00
#> 
#> ## Please cite
#> 
#> - Wulff, J. N., & Taylor, L. (2024). How and why alpha should depend on
#>   sample size: A Bayesian-frequentist compromise for significance
#>   testing. Strategic Organization, 22(3), 550-581.
#>   doi:10.1177/14761270231214429
#> - Klauer, K. C., Meyer-Grant, C. G., & Kellen, D. (2025). On Bayes
#>   factors for hypothesis tests. Psychonomic Bulletin & Review, 32,
#>   1070-1094. doi:10.3758/s13423-024-02612-2
```
