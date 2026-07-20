# alphaN (development version)

## New features

* New function `alphaN_power()` computes the power of the calibrated test
  against a standardized effect of size `d`: the design-time companion of
  `alphaN()` (noncentral t for single coefficients, noncentral F for joint
  tests, at the residual degrees of freedom). For model-specific effect
  parameterizations (odds ratios, rate ratios), the calibrated alpha plugs
  directly into the calculators of the pwrss package via their `alpha`
  argument; see `?alphaN_power`.
* New function `alphaN_power_plot()` draws power against sample size, one
  panel per effect size, with every calibration method evaluated at its own
  alpha(n) and a fixed reference level as a dashed curve.
* `alphaN_report()` gains a `power_at` argument: the settings report can now
  document the power of the calibrated test against the effect sizes the
  researcher cares about, alongside the alpha itself.
* `alphaN_report()` now also states the scope of the `"ES"` and `"moment"`
  calibrations: exact for the normal linear model when `p` is supplied
  (evaluated at the effective sample size `n - p`), the conservative
  large-sample form otherwise, and asymptotic for other generalized linear
  models.

* New function `alphaN_report()` writes a preregistration-ready Markdown
  settings report: every input behind a calibrated alpha (sample size,
  evidence target, method, prior settings), the resulting alpha, the
  decision rule, and the references to cite. It mirrors the downloadable
  report of the companion Shiny application, can write straight to a file,
  and hard-wraps its lines (default 72 characters, see `width`) so the
  report reads well in consoles, files, and rendered documents.
* `JAB()` called without a `covariate` now returns a named vector with the
  Bayes factor of every coefficient except the intercept (which remains
  available on explicit request).
* `alphaN_plot()` and `JAB_plot()` have been restyled: colorblind-safe
  Okabe-Ito palette, light grid lines, open axes, and horizontal axis
  labels. `alphaN_plot()` additionally gains a `log` argument ("x", "y",
  "xy") which helps when the fast-falling "moment" curve is drawn next to
  the others, and its tick labels always use plain notation ("0.0001" and
  "10,000", never "1e-04").

* New function `klauerBF()` exports the effect-size and moment Bayes factors
  of Klauer, Meyer-Grant & Kellen (2025) that `alphaN()` inverts: from a
  t statistic (one-sample test or single regression coefficient) or from an
  F statistic for a joint test of `q` coefficients.
* `alphaN()` (methods `"ES"` and `"moment"`) gains arguments `q` and `p`.
  With `q > 1` the alpha level is calibrated for the joint F test of q
  coefficients through the exact regression-case Bayes factors of Klauer et
  al. (2025, Table 4), implemented natively including their Gaussian
  hypergeometric term; `p` sets the number of retained model parameters so
  that small-sample calibrations can use the effective sample size `n - p`
  (residual degrees of freedom). The defaults (`q = 1`, `p = 0`) reproduce
  the previous behavior exactly. The moment-prior default `nu` is now
  `5 + (q - 1)` and the ES-prior scale recommendation generalizes to
  `r = sqrt((nu - 2)/(nu * q)) * de`, both following the paper (unchanged
  at `q = 1`).
* New function `n_effective()` computes the effective sample size
  `n * (se/se_robust)^2` that Wulff & Taylor (2024) recommend as a
  sensitivity check when calibrating alpha with clustered (panel) data.
* `alphaN_plot()` gains a `methods` argument and can now draw the `"ES"`
  and `"moment"` curves alongside the prior-fraction methods.
* The regression-case implementation is validated against all printed Bayes
  factors in Table 8 of Klauer et al. (2025), in addition to the existing
  Table 7 anchors, and the q = 1 F form agrees with the validated t form to
  near machine precision.
* The quadrature and inversion machinery is additionally stress-tested
  against an independent oracle that integrates on the original effect
  scale over an infinite range with a plain density ratio (none of the
  package's substitution, windowing, or log-clamping choices); the
  normal-limit switch at `n - p` = 50,000 is measured directly by running
  both branches at the same effective sample size, and monotonicity of
  alpha in `n` and `BF`, and of the Bayes factors in the test statistic,
  is checked over grids that cross the switch, including joint tests and
  small residual degrees of freedom.

## Documentation

* Klauer, Meyer-Grant & Kellen is now cited with its printed-issue details
  (2025, Psychonomic Bulletin & Review, 32, 1070-1094) throughout; it was
  previously cited by its online-first year, 2024.
* `?alphaN` states the model scope of the `"ES"` and `"moment"` methods:
  exact under the normal linear model, asymptotic (like the prior-fraction
  methods) for other generalized linear models.
* `citation("alphaN")` now also lists Klauer et al. (2025) for users of the
  `"ES"` and `"moment"` methods.

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
