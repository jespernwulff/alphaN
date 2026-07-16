# Effect-size or moment Bayes factor from a t or F statistic

Computes the effect-size or moment Bayes factor of Klauer, Meyer-Grant,
and Kellen (2025) from a t statistic (one-sample test or single
regression coefficient) or from an F statistic (joint test of `q`
coefficients). These are the Bayes factors that
[`alphaN()`](https://jespernwulff.github.io/alphaN/reference/alphaN.md)
inverts for `method = "ES"` and `method = "moment"`, so a reported test
statistic can be converted into evidence under the same prior used to
set the alpha level. Vectorized over `t` (or `Fstat`) and `n`.

## Usage

``` r
klauerBF(
  n,
  t = NULL,
  Fstat = NULL,
  q = 1,
  p = 0,
  method = "ES",
  de = 0.5,
  nu = NULL,
  r = NULL
)
```

## Arguments

- n:

  Sample size. A positive numeric vector.

- t:

  The t-statistic. Used when `q = 1`; supply either `t` or `Fstat` (with
  `Fstat` read as the squared t-statistic).

- Fstat:

  The F-statistic of the model comparison. Required when `q > 1`.

- q:

  Number of coefficients tested jointly. The default, 1, covers the
  one-sample test and the test of a single regression coefficient.

- p:

  Number of parameters retained in the reduced model, including any
  intercept. The effective sample size of Klauer et al. (2025) is
  `n - p`; the default, 0, is the one-sample case. For a test of a
  single coefficient in a regression model, `p` is the number of other
  estimated coefficients, including the intercept.

- method:

  `"ES"` for the effect-size Bayes factor or `"moment"` for the moment
  Bayes factor.

- de:

  The prespecified (targeted) effect size: Cohen's d for `q = 1`, and
  Cohen's f for joint tests (the two scales coincide at `q = 1`).
  Defaults to 0.5. For joint tests, Cohen (1988, Chapter 9) labels f^2
  of 0.02, 0.15, and 0.35 as small, medium, and large, so
  `de = sqrt(0.15)` targets a medium effect.

- nu:

  Degrees of freedom of the prior t distribution. The default, NULL,
  uses the recommendations of Klauer et al. (2025): 3 for `"ES"` and
  `5 + (q - 1)` for `"moment"`.

- r:

  Scale of the prior mixture components for method `"ES"`. The default,
  NULL, uses the recommendation of Klauer et al. (2025),
  `r = sqrt((nu - 2)/(nu * q)) * de`, which requires `nu > 2` and
  `de > 0`; otherwise supply `r` explicitly.

## Value

A numeric vector with the Bayes factor in favour of H1.

## Details

For `q = 1` the Bayes factor is evaluated in its noncentral-t form with
`n - p - 1` degrees of freedom, and for `q > 1` in its noncentral-F form
with `(q, n - p - q)` degrees of freedom (Table 4 of Klauer et al.,
2025). The implementation is validated against all printed Bayes factors
in Tables 7 and 8 of that paper.

As a special case, `q = 1, nu = 1, de = 0` with an explicit scale (e.g.
`r = 1`) gives the default (Jeffreys-Zellner-Siow type) Bayes factor of
Rouder et al. (2009).

## References

Cohen, J. (1988). Statistical power analysis for the behavioral sciences
(second edition). Lawrence Erlbaum.  
  
Klauer, K. C., Meyer-Grant, C. G., & Kellen, D. (2025). On Bayes factors
for hypothesis tests. Psychonomic Bulletin & Review, 32, 1070-1094.
[doi:10.3758/s13423-024-02612-2](https://doi.org/10.3758/s13423-024-02612-2)  
  
Rouder, J. N., Speckman, P. L., Sun, D., Morey, R. D., & Iverson, G.
(2009). Bayesian t tests for accepting and rejecting the null
hypothesis. Psychonomic Bulletin & Review, 16, 225-237.

## See also

[`alphaN()`](https://jespernwulff.github.io/alphaN/reference/alphaN.md)
for the inverse mapping from a target Bayes factor to an alpha level,
and [`JABt()`](https://jespernwulff.github.io/alphaN/reference/JABt.md)
for Jeffreys' approximate Bayes factor.

## Examples

``` r
# Effect-size Bayes factor for t(79) = 2.24 targeting a medium effect
# (Table 7 of Klauer et al., 2025)
klauerBF(n = 80, t = 2.24, de = 0.5)
#> [1] 1.567758

# The moment Bayes factor for the same statistic
klauerBF(n = 80, t = 2.24, method = "moment", de = 0.5)
#> [1] 0.9948127

# Joint test of q = 2 coefficients in a regression with 3 retained
# parameters (Table 8 of Klauer et al., 2025, model M9)
klauerBF(n = 175, Fstat = 1.17, q = 2, p = 3, de = sqrt(0.15))
#> [1] 0.06724721
```
