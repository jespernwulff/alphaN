# Plot power across sample sizes at the calibrated alpha

Draws, for each requested effect size, the power of the two-sided
single-coefficient test as a function of the sample size, where every
calibration method is evaluated at its own alpha level for the given
Bayes factor target. A fixed reference level (default 0.05) is drawn as
a dashed curve. This is the design-time companion of
[`alphaN_plot()`](https://jespernwulff.github.io/alphaN/reference/alphaN_plot.md):
one figure shows what each calibration costs in power. Colors follow the
colorblind-safe Okabe-Ito palette; the effect-size and moment curves use
the same log-spaced spline interpolation as
[`alphaN_plot()`](https://jespernwulff.github.io/alphaN/reference/alphaN_plot.md).

## Usage

``` r
alphaN_power_plot(
  d = c(0.1, 0.5),
  BF = 3,
  max = 10000,
  methods = c("JAB", "min", "robust", "balanced"),
  de = 0.5,
  ref = 0.05
)
```

## Arguments

- d:

  Standardized effect sizes to draw, one panel per element (Cohen's d
  scale). Defaults to c(0.1, 0.5).

- BF:

  Target Bayes factor for the calibration. Defaults to 3.

- max:

  The maximum number of sample size. Defaults to 10,000.

- methods:

  Character vector with the methods to draw, any subset of c("JAB",
  "min", "robust", "balanced", "ES", "moment"). Defaults to the four
  prior-fraction methods, matching the behavior of earlier package
  versions.

- de:

  The prespecified (targeted) effect size in standardized units: Cohen's
  d for `q = 1` and Cohen's f for joint tests (the scales coincide at
  `q = 1`). Only used by methods "ES" and "moment". Defaults to 0.5, a
  medium effect; use 0.2 for small and 0.8 for large effects (Cohen,
  1988).

- ref:

  A fixed significance level drawn as a dashed reference curve, or NULL
  to omit it. Defaults to 0.05.

## Value

Prints a plot.

## See also

[`alphaN_power()`](https://jespernwulff.github.io/alphaN/reference/alphaN_power.md),
[`alphaN_plot()`](https://jespernwulff.github.io/alphaN/reference/alphaN_plot.md)

## Examples

``` r
# The power cost of evidence calibration for a small and a medium effect
alphaN_power_plot(d = c(0.1, 0.5), BF = 3,
                  methods = c("JAB", "balanced", "moment"), max = 2000)
```
