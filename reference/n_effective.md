# Effective sample size from cluster-robust standard errors

Computes the effective sample size recommended by Wulff and Taylor
(2024) for calibrating alpha with clustered (panel) data, where
observations are not independent and the nominal sample size overstates
the information in the data: `n_e = n * (se / se_robust)^2`, the total
number of observations deflated by the squared ratio of the classical to
the cluster-robust standard error. Vectorized over its arguments
(recycled).

## Usage

``` r
n_effective(n, se, se_robust)
```

## Arguments

- n:

  Total number of observations. A positive numeric vector.

- se:

  The classical (non-robust) standard error of the coefficient.

- se_robust:

  The cluster-robust standard error of the same coefficient.

## Value

A numeric vector with the effective sample size.

## Details

Wulff and Taylor (2024) recommend calibrating alpha with the total
number of observations, which is the conservative choice, and then
checking whether conclusions survive when alpha and the Bayes factor are
recomputed with the effective sample size. Because cluster-robust
standard errors typically exceed classical ones, `n_effective()` is
typically smaller than `n`, which yields a larger calibrated alpha.

## References

Wulff, J. N., & Taylor, L. (2024). How and why alpha should depend on
sample size: A Bayesian-frequentist compromise for significance testing.
Strategic Organization, 22(3), 550-581.
[doi:10.1177/14761270231214429](https://doi.org/10.1177/14761270231214429)

## See also

[`alphaN()`](https://jespernwulff.github.io/alphaN/reference/alphaN.md)

## Examples

``` r
# A regression on 237 clustered observations where the cluster-robust
# standard error is twice the classical one implies an effective sample
# size four times smaller (Wulff & Taylor, 2024, Example 3)
n_effective(n = 237, se = 0.1, se_robust = 0.2)
#> [1] 59.25

# Alpha for moderate evidence at the nominal and the effective sample size
alphaN(n = 237, BF = 3, method = "robust")
#> [1] 0.02637516
alphaN(n = n_effective(237, 0.1, 0.2), BF = 3, method = "robust")
#> [1] 0.0395262
```
