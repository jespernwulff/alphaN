#' Write a settings report for a calibrated alpha level
#'
#' Generates a short, human-readable Markdown report that records every input
#' behind a calibrated alpha level together with the result: the sample size,
#' the evidence target, the calibration method and its prior settings, the
#' resulting alpha, and the decision rule. The report is designed to be
#' attached to a preregistration protocol or a supplementary appendix, so
#' that an alpha level chosen before data collection leaves a citable trace.
#' It mirrors the downloadable report of the package's companion Shiny
#' application.
#'
#' @inheritParams alphaN
#' @param n Sample size. A single positive number (one report describes one
#'   design).
#' @param BF Target Bayes factor. A single positive number.
#' @param file Optional path. If supplied, the report is also written to
#'   this file.
#' @param width Maximum line width of the report; longer lines are wrapped
#'   with a hanging indent. Defaults to 72 characters.
#' @param power_at Optional numeric vector of standardized effect sizes. If
#'   supplied, the report includes the power of the calibrated test against
#'   each of them (computed with [alphaN_power()]), so the preregistered
#'   alpha is documented together with what it costs.
#' @return The report as a character vector of lines, invisibly. The report
#'   is printed to the console.
#' @export
#'
#' @examples
#' alphaN_report(n = 1000, BF = 3, method = "JAB")
#'
#' # Effect-size calibration with a power section, written to a file
#' f <- tempfile(fileext = ".md")
#' alphaN_report(n = 1000, BF = 3, method = "ES", de = 0.5,
#'               power_at = c(0.1, 0.2, 0.5), file = f)
#' @seealso [alphaN()], [alphaN_power()]
alphaN_report <- function(n, BF = 1, method = "JAB", upper = 1, de = 0.5,
                          nu = NULL, r = NULL, q = 1, p = 0, file = NULL,
                          width = 72, power_at = NULL) {
  if (!is.null(power_at) &&
      (!is.numeric(power_at) || length(power_at) == 0 ||
         !all(is.finite(power_at)) || any(power_at <= 0))) {
    stop("`power_at` must be a positive, finite numeric vector, or NULL.",
         call. = FALSE)
  }
  if (!is.numeric(width) || length(width) != 1 || !is.finite(width) ||
      width < 40) {
    stop("`width` must be a single number of at least 40.", call. = FALSE)
  }
  if (!is.numeric(n) || length(n) != 1) {
    stop("`n` must be a single number: one report describes one design.",
         call. = FALSE)
  }
  if (!is.numeric(BF) || length(BF) != 1) {
    stop("`BF` must be a single number: one report describes one design.",
         call. = FALSE)
  }
  method <- match.arg(method,
                      c("JAB", "min", "robust", "balanced", "ES", "moment"))

  alpha <- alphaN(n, BF = BF, method = method, upper = upper, de = de,
                  nu = nu, r = r, q = q, p = p)

  fmt_a <- format(signif(alpha, 3), scientific = FALSE, trim = TRUE,
                  drop0trailing = TRUE)
  if (alpha < 1e-4) {
    fmt_a <- paste0(fmt_a, " (", format(signif(alpha, 3), scientific = TRUE),
                    ")")
  }

  target_label <- if (BF < 1) {
    "below even odds"
  } else if (BF == 1) {
    "even odds, which rules out Lindley's paradox"
  } else if (BF < 3) {
    "anecdotal evidence"
  } else if (BF < 10) {
    "moderate evidence"
  } else if (BF < 30) {
    "strong evidence"
  } else if (BF < 100) {
    "very strong evidence"
  } else {
    "extreme evidence"
  }

  method_line <- switch(method,
    JAB = "JAB: Jeffreys' approximate Bayes factor (unit-information prior, b = 1/n)",
    min = "min: minimal training sample prior (b = 2/n)",
    robust = "robust: minimal training sample prior with a floor (b = max(2/n, 1/sqrt(n)))",
    balanced = "balanced: prior fraction balancing Type I and Type II error rates",
    ES = "ES: effect-size Bayes factor of Klauer, Meyer-Grant & Kellen (2025)",
    moment = "moment: moment Bayes factor of Klauer, Meyer-Grant & Kellen (2025)")

  prior_lines <- if (method == "balanced") {
    sprintf("- Realistic effect sizes: uniform on [0, %s]", format(upper))
  } else if (method %in% c("ES", "moment")) {
    args <- resolve_klauer_args(n, method, de, nu, r, q = q, p = p)
    c(sprintf("- Targeted effect size (de): %s%s", format(de),
              if (q > 1) " on Cohen's f scale" else " (Cohen's d)"),
      sprintf("- Prior degrees of freedom (nu): %s", format(args$nu)),
      if (method == "ES")
        sprintf("- Prior scale (r): %s", format(signif(args$r, 4))),
      if (q > 1)
        sprintf("- Joint test of q = %d coefficients (F test)", q),
      if (p > 0)
        sprintf("- Retained model parameters (p): %d (effective sample size %s)",
                p, format(n - p)))
  } else {
    character(0)
  }

  stat_line <- if (method %in% c("ES", "moment") && q > 1) {
    sprintf("Reject H0 if the p-value of the joint F test is at or below %s.",
            fmt_a)
  } else {
    sprintf("Reject H0 if the two-sided p-value of the coefficient is at or below %s.",
            fmt_a)
  }

  cite_lines <- c(
    "- Wulff, J. N., & Taylor, L. (2024). How and why alpha should depend on sample size: A Bayesian-frequentist compromise for significance testing. Strategic Organization, 22(3), 550-581. doi:10.1177/14761270231214429",
    if (method %in% c("ES", "moment"))
      "- Klauer, K. C., Meyer-Grant, C. G., & Kellen, D. (2025). On Bayes factors for hypothesis tests. Psychonomic Bulletin & Review, 32, 1070-1094. doi:10.3758/s13423-024-02612-2")

  lines <- c(
    "# alphaN settings report",
    "",
    sprintf("Generated on %s with alphaN %s.", format(Sys.Date()),
            as.character(utils::packageVersion("alphaN"))),
    "",
    "## Inputs",
    "",
    sprintf("- Sample size (n): %s", format(n, big.mark = ",")),
    sprintf("- Target Bayes factor: %s (%s)", format(BF), target_label),
    sprintf("- Calibration method: %s", method_line),
    prior_lines,
    "",
    "## Result",
    "",
    sprintf("- Calibrated alpha level: %s", fmt_a),
    sprintf("- Decision rule: %s", stat_line),
    sprintf("- Interpretation: a significant result then corresponds to a Bayes factor of at least %s in favor of the alternative under this prior.",
            format(BF)),
    if (!is.null(power_at)) c(
      "",
      "## Power at the calibrated alpha",
      "",
      sprintf("- Against a standardized effect of %s: %s",
              format(power_at),
              formatC(alphaN_power(n, power_at, BF = BF, method = method,
                                   upper = upper, de = de, nu = nu, r = r,
                                   q = q, p = p),
                      format = "f", digits = 2))),
    "",
    "## Please cite",
    "",
    cite_lines)

  # Hard-wrap long lines (citations, the interpretation sentence) so the
  # report reads well in consoles, files, and rendered documents; wrapped
  # continuations of a bullet hang under its text.
  lines <- unlist(lapply(lines, function(l) {
    if (nchar(l) <= width) return(l)
    strwrap(l, width = width, exdent = if (startsWith(l, "- ")) 2 else 0)
  }))

  if (!is.null(file)) {
    writeLines(lines, file)
  }
  cat(lines, sep = "\n")
  invisible(lines)
}
