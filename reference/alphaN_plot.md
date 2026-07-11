# Creates a plot of alpha as function of sample size for each of the four prior options

Creates a plot of alpha as function of sample size for each of the four
prior options

## Usage

``` r
alphaN_plot(BF = 1, max = 10000, ylim = NULL)
```

## Arguments

- BF:

  Bayes factor you would like to match. 1 to avoid Lindley's Paradox, 3
  to achieve moderate evidence and 10 to achieve strong evidence.

- max:

  The maximum number of sample size. Defaults to 10,000.

- ylim:

  Limits for the y-axis. The default, NULL, covers all four curves. Set
  to e.g. c(0, 0.05) to zoom in on small alpha levels.

## Value

Prints a plot.

## Examples

``` r
# Plot of alpha level as a function of n for a Bayes factor of 3
alphaN_plot(BF = 3)
```
