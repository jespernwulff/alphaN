# Transforms t-statistics from a glm or lm object into Jeffreys' approximate Bayes factors

Extracts the test statistic of one coefficient, or of every coefficient,
from a fitted model object and converts it into Jeffreys' approximate
Bayes factor, given the sample size used in the fit.

## Usage

``` r
JAB(glm_obj, covariate = NULL, method = "JAB", upper = 1)
```

## Arguments

- glm_obj:

  a glm or lm object.

- covariate:

  the name of the covariate that you want a BF for, as a string. The
  default, NULL, returns a named vector with the Bayes factor of every
  coefficient except the intercept (request the intercept explicitly
  with `covariate = "(Intercept)"` if you need it).

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

A numeric value with the BF in favour of H1, or a named vector of BFs
when `covariate = NULL`.

## Examples

``` r
# Simulate data

## Sample size
n <- 200

## Regressors
Z1 <- runif(n, -1, 1)
Z2 <- runif(n, -1, 1)
Z3 <- runif(n, -1, 1)
Z4 <- runif(n, -1, 1)
X <- runif(n, -1, 1)

## Error term
U <- rnorm(n, 0, 0.5)

## Outcome
Y <- X/sqrt(n) + U

# Run a GLM
LM <- glm(Y ~ X + Z1 + Z2 + Z3 + Z4)

# Compute JAB for "X" based on the regression results
JAB(LM, "X")
#> [1] 0.07981323

# Compute JAB for every coefficient at once
JAB(LM)
#>          X         Z1         Z2         Z3         Z4 
#> 0.07981323 0.09386151 0.20528203 0.09049906 0.07918742 

# Compute JAB using the minimum prior
JAB(LM, "X", method = "min")
#> [1] 0.1128729
```
