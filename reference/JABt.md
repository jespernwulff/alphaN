# Transforms a t-statistic into Jeffreys' approximate Bayes factor

Converts a t-statistic (or z-statistic) into Jeffreys' approximate Bayes
factor, given the sample size. Vectorized over `n` and `t`.

## Usage

``` r
JABt(n, t, method = "JAB", upper = 1)
```

## Arguments

- n:

  Sample size. A positive numeric vector.

- t:

  The t-statistic.

- method:

  Used for the choice of 'b'. Currently one of:

  - "JAB": this choice of b produces Jeffreys' approximate BF
    (Wagenmakers, 2022)

  - "min": uses the minimal training sample for the prior (Gu et al.,
    2018)

  - "robust": a robust version of "min" that prevents too small b
    (O'Hagan, 1995)

  - "balanced": this choice of b balances the type I and type II errors
    (Gu et al., 2016)

- upper:

  The upper limit for the range of realistic effect sizes. Only relevant
  when method="balanced". Defaults to 1 such that the range of realistic
  effect sizes is uniformly distributed between 0 and 1, U(0,1).

## Value

A numeric value for the BF in favour of H1.

## Examples

``` r
# Transform a t-statistic of 2.695 computed based on a sample size of 200 into JAB
JABt(200, 2.695)
#> [1] 2.670735
```
