# Changelog

## alphaN 0.1.3

### Bug fixes

- [`alphaN()`](https://jespernwulff.github.io/alphaN/reference/alphaN.md)
  and
  [`JABt()`](https://jespernwulff.github.io/alphaN/reference/JABt.md)
  now return correct results when `n` is a vector and
  `method = "robust"` or `method = "balanced"`. Previously, `"robust"`
  silently applied the smallest sample size to every element and
  `"balanced"` failed with an unrelated error.

### Improvements

- All functions now validate their inputs and fail with informative
  error messages: a mistyped `method`, a missing `df` in
  `JABp(..., z = FALSE)`, a `p` outside (0, 1\], a non-positive `n` or
  `BF`, and an unknown `covariate` in
  [`JAB()`](https://jespernwulff.github.io/alphaN/reference/JAB.md)
  (which now lists the coefficients available in the model).
- [`JAB_plot()`](https://jespernwulff.github.io/alphaN/reference/JAB_plot.md)
  gained an `upper` argument, passed on to the underlying computations
  for `method = "balanced"`.
- [`alphaN_plot()`](https://jespernwulff.github.io/alphaN/reference/alphaN_plot.md)
  gained a `ylim` argument. The default now covers all four curves;
  previously the y-axis was fixed to (0, 0.05), which silently clipped
  the `"balanced"` curve for small Bayes factors.
- [`JAB()`](https://jespernwulff.github.io/alphaN/reference/JAB.md) now
  determines the sample size via
  [`nobs()`](https://rdrr.io/r/stats/nobs.html).

### Documentation

- [`?JABp`](https://jespernwulff.github.io/alphaN/reference/JABp.md) no
  longer has a placeholder title.
- Corrected the Wagenmakers (2022) reference (year, title) and updated
  the Wulff & Taylor reference to the published version (2024, Strategic
  Organization, <doi:10.1177/14761270231214429>) in the documentation,
  README, and vignette.
- Added a CITATION file for the companion paper.
- Fixed typos in the vignette and documented that
  [`JABp()`](https://jespernwulff.github.io/alphaN/reference/JABp.md)
  expects a two-sided p-value.

## alphaN 0.1.2

CRAN release: 2025-07-13

## alphaN 0.1.1

- Removed vignette example that depended on unstable dataset.

## alphaN 0.1.0

CRAN release: 2023-01-12

- Added a `NEWS.md` file to track changes to the package.
- First CRAN submission.
