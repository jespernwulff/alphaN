# alphaN 0.2.0

This release adds one feature and several fixes:

* New: `alphaN()` can calibrate the alpha level to the effect-size and moment
  Bayes factors of Klauer, Meyer-Grant, and Kellen (2024)
  <doi:10.3758/s13423-024-02612-2> (`method = "ES"` / `"moment"`). The
  implementation is validated against the values published in that paper
  (regression tests included).
* Fixed incorrect results for vector-valued sample sizes with two of the
  prior methods; added input validation with informative error messages;
  corrected and updated references; added a CITATION file.

## Test environments

- local windows-x86_64, R 4.5.2
- GitHub Actions: macos-latest (release), windows-latest (release),
  ubuntu-latest (devel, release, oldrel-1)

## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✖ (local); win-builder reports 1 NOTE:

* "Possibly misspelled words in DESCRIPTION: Kellen, Klauer" — these are the
  surnames of the authors of the cited methods paper (Klauer, Meyer-Grant,
  and Kellen, 2024, <doi:10.3758/s13423-024-02612-2>).
