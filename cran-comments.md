# alphaN 0.3.0

This release makes the effect-size/moment calibrations exact for regression
models, adds power analysis and reporting tools, and extends validation:

* `alphaN()` (methods "ES"/"moment") gains `q` and `p`: calibration for
  joint F tests of q coefficients and evaluation at the effective sample
  size n - p, through the exact regression-case Bayes factors of Klauer,
  Meyer-Grant, and Kellen (2025) <doi:10.3758/s13423-024-02612-2>. The
  implementation is validated against all Bayes factors printed in that
  paper (Tables 7 and 8).
* New functions: `klauerBF()` (Bayes factors from reported t/F statistics),
  `alphaN_power()` and `alphaN_power_plot()` (power of the calibrated
  test), `alphaN_report()` (preregistration-ready settings report), and
  `n_effective()` (effective sample size for clustered data). `JAB()` can
  now return the Bayes factors of all coefficients at once.
* Plots restyled (colorblind-safe palette, plain-notation axis labels).
* The test suite has grown to 269 assertions, including cross-validation
  against the BayesFactor and JustifyAlpha packages (used conditionally,
  in Suggests) and an independent quadrature oracle for the numerical
  machinery. The pwrss package (Suggests) is used conditionally in one
  documentation example.

## Test environments

- local windows-x86_64, R 4.5.2
- GitHub Actions: macos-latest (release), windows-latest (release),
  ubuntu-latest (devel, release, oldrel-1)
- win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 0 notes

The only local NOTE is "unable to verify current time" (checking for future
file timestamps), an artifact of the check machine having no access to a
time service; it does not appear on GitHub Actions.

The README links Wulff and Taylor (2024) by DOI
(<https://doi.org/10.1177/14761270231214429>); the publisher returns 403 to
automated URL requests. The link is valid and unchanged from the accepted
0.2.0 release.

## Reverse dependencies

There are no reverse dependencies on CRAN.
