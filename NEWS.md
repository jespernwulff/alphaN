# alphaN 0.2.0

## New features

* `alphaN()` gains two methods based on Klauer, Meyer-Grant & Kellen (2024,
  Psychonomic Bulletin & Review, doi:10.3758/s13423-024-02612-2):
  `method = "ES"` calibrates alpha to their effect-size Bayes factor, whose
  prior centers the alternative hypothesis on a prespecified effect size, and
  `method = "moment"` calibrates alpha to their moment Bayes factor, under
  which effects near zero are a priori implausible. New arguments `de`
  (targeted effect size, default 0.5), `nu`, and `r` control the priors, with
  defaults following the paper's recommendations. Because the moment prior
  rules out near-zero effects, the alpha level it implies falls much faster
  with `n` than under JAB.
* As a special case, `method = "ES", nu = 1, de = 0` with an explicit `r`
  calibrates alpha to the default (Jeffreys-Zellner-Siow type) Bayes factor of
  Rouder et al. (2009).
* The implementation is validated against all twelve Bayes factors printed in
  Table 7 of Klauer et al. (2024); these checks are part of the test suite.

# alphaN 0.1.3

## Bug fixes

* `alphaN()` and `JABt()` now return correct results when `n` is a vector and
  `method = "robust"` or `method = "balanced"`. Previously, `"robust"` silently
  applied the smallest sample size to every element and `"balanced"` failed
  with an unrelated error.

## Improvements

* All functions now validate their inputs and fail with informative error
  messages: a mistyped `method`, a missing `df` in `JABp(..., z = FALSE)`,
  a `p` outside (0, 1], a non-positive `n` or `BF`, and an unknown `covariate`
  in `JAB()` (which now lists the coefficients available in the model).
* `JAB_plot()` gained an `upper` argument, passed on to the underlying
  computations for `method = "balanced"`.
* `alphaN_plot()` gained a `ylim` argument. The default now covers all four
  curves; previously the y-axis was fixed to (0, 0.05), which silently clipped
  the `"balanced"` curve for small Bayes factors.
* `JAB()` now determines the sample size via `nobs()`.

## Documentation

* `?JABp` no longer has a placeholder title.
* Corrected the Wagenmakers (2022) reference (year, title) and updated the
  Wulff & Taylor reference to the published version (2024, Strategic
  Organization, doi:10.1177/14761270231214429) in the documentation, README,
  and vignette.
* Added a CITATION file for the companion paper.
* Fixed typos in the vignette and documented that `JABp()` expects a
  two-sided p-value.

# alphaN 0.1.2

# alphaN 0.1.1

* Removed vignette example that depended on unstable dataset.

# alphaN 0.1.0

* Added a `NEWS.md` file to track changes to the package.
* First CRAN submission.
