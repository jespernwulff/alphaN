#' Power at the calibrated alpha level
#'
#' Computes the power of the two-sided coefficient test at the alpha level
#' that [alphaN()] calibrates to a target Bayes factor, for a standardized
#' effect of size `d`. Together with the calibrated alpha itself, this is
#' the quantity worth preregistering: it shows what the chosen evidence
#' target costs against the effects the researcher cares about. Vectorized
#' over `n` and `d` (recycled).
#'
#' @inheritParams alphaN
#' @param d The standardized effect size at which power is evaluated, on the
#'   same scale as `de`: Cohen's d for `q = 1`, Cohen's f for joint tests.
#'   A non-negative numeric vector.
#' @param BF Target Bayes factor for the calibration. Defaults to 3.
#' @return A numeric vector with the power of the two-sided test (noncentral
#'   t for `q = 1`, noncentral F for `q > 1`, both at the residual degrees
#'   of freedom implied by `n`, `p`, and `q`) at the calibrated alpha.
#'
#' @details
#' The power computation is exact under the normal linear model and carries
#' the usual Wald-asymptotic interpretation for other generalized linear
#' models, mirroring the scope of the calibration itself. When the
#' calibrated alpha is 1 (the evidence target is met vacuously), the power
#' is 1 for every effect size.
#'
#' For effects parameterized on a model-specific scale (an odds ratio under
#' a covariate design, a rate ratio, an R-squared increment), combine the
#' calibrated alpha with a model-specific power calculator instead: the
#' functions of the \CRANpkg{pwrss} package accept the significance level as
#' an argument, so `alpha = alphaN(n, BF = 3)` plugs the calibration
#' directly into, for example, `pwrss::power.z.logistic()`.
#' @export
#'
#' @examples
#' # Power against a small effect at the JAB-calibrated alpha, n = 1,000
#' alphaN_power(n = 1000, d = 0.1, BF = 3)
#'
#' # The same design under the balanced calibration keeps more power
#' alphaN_power(n = 1000, d = 0.1, BF = 3, method = "balanced")
#'
#' # A power curve across sample sizes
#' alphaN_power(n = c(100, 500, 1000, 5000), d = 0.2, BF = 3)
#' @examplesIf requireNamespace("pwrss", quietly = TRUE)
#' # Model-specific power at the calibrated alpha via the pwrss package:
#' # a logistic-regression coefficient with odds ratio 1.5
#' pwrss::power.z.logistic(odds.ratio = 1.5, base.prob = 0.2,
#'                         n = 1000, alpha = alphaN(1000, BF = 3),
#'                         verbose = FALSE)$power
#' @seealso [alphaN()], [alphaN_power_plot()], [alphaN_report()]
#' @importFrom stats qt qf
alphaN_power <- function(n, d, BF = 3, method = "JAB", upper = 1, de = 0.5,
                         nu = NULL, r = NULL, q = 1, p = 0) {
  if (!is.numeric(d) || length(d) == 0 || !all(is.finite(d)) || any(d < 0)) {
    stop("`d` must be a non-negative, finite numeric vector.", call. = FALSE)
  }
  alpha <- alphaN(n, BF = BF, method = method, upper = upper, de = de,
                  nu = nu, r = r, q = q, p = p)

  len <- max(length(n), length(d), length(alpha))
  n <- rep_len(n, len)
  d <- rep_len(d, len)
  alpha <- rep_len(alpha, len)
  M <- n - p

  if (q == 1) {
    t_crit <- qt(1 - alpha/2, df = M - 1)
    ncp <- sqrt(M)*d
    suppressWarnings(
      pt(-t_crit, df = M - 1, ncp = ncp) +
        1 - pt(t_crit, df = M - 1, ncp = ncp)
    )
  } else {
    F_crit <- qf(1 - alpha, df1 = q, df2 = M - q)
    suppressWarnings(1 - pf(F_crit, df1 = q, df2 = M - q, ncp = M*d^2))
  }
}

#' Plot power across sample sizes at the calibrated alpha
#'
#' Draws, for each requested effect size, the power of the two-sided
#' single-coefficient test as a function of the sample size, where every
#' calibration method is evaluated at its own alpha level for the given
#' Bayes factor target. A fixed reference level (default 0.05) is drawn as
#' a dashed curve. This is the design-time companion of [alphaN_plot()]:
#' one figure shows what each calibration costs in power. Colors follow the
#' colorblind-safe Okabe-Ito palette; the effect-size and moment curves use
#' the same log-spaced spline interpolation as [alphaN_plot()].
#'
#' @inheritParams alphaN_plot
#' @param d Standardized effect sizes to draw, one panel per element
#'   (Cohen's d scale). Defaults to c(0.1, 0.5).
#' @param BF Target Bayes factor for the calibration. Defaults to 3.
#' @param ref A fixed significance level drawn as a dashed reference curve,
#'   or NULL to omit it. Defaults to 0.05.
#'
#' @return Prints a plot.
#' @export
#'
#' @examples
#' # The power cost of evidence calibration for a small and a medium effect
#' alphaN_power_plot(d = c(0.1, 0.5), BF = 3,
#'                   methods = c("JAB", "balanced", "moment"), max = 2000)
#' @seealso [alphaN_power()], [alphaN_plot()]
#' @importFrom graphics legend lines abline par axis
#' @importFrom grDevices axisTicks
#' @importFrom stats splinefun
alphaN_power_plot <- function(d = c(0.1, 0.5), BF = 3, max = 10000,
                              methods = c("JAB", "min", "robust", "balanced"),
                              de = 0.5, ref = 0.05){
  all_methods <- c("JAB", "min", "robust", "balanced", "ES", "moment")
  methods <- match.arg(methods, all_methods, several.ok = TRUE)
  if (!is.numeric(d) || length(d) == 0 || !all(is.finite(d)) || any(d <= 0)) {
    stop("`d` must be a positive, finite numeric vector.", call. = FALSE)
  }
  if (!is.null(ref) && (!is.numeric(ref) || length(ref) != 1 ||
                        !is.finite(ref) || ref <= 0 || ref >= 1)) {
    stop("`ref` must be a single value in (0, 1), or NULL.", call. = FALSE)
  }

  grid_n <- unique(round(10^seq(log10(50), log10(max), length.out = 120)))
  alpha_grid <- sapply(methods, function(m) {
    if (m %in% c("ES", "moment")) {
      anchors <- unique(round(10^seq(log10(50), log10(max),
                                     length.out = 12)))
      f <- splinefun(log(anchors),
                     log(alphaN(anchors, BF = BF, method = m, de = de)))
      exp(f(log(grid_n)))
    } else {
      alphaN(grid_n, BF = BF, method = m)
    }
  })

  pw <- function(alpha, dd) {
    t_crit <- qt(1 - alpha/2, df = grid_n - 1)
    ncp <- sqrt(grid_n)*dd
    suppressWarnings(
      pt(-t_crit, df = grid_n - 1, ncp = ncp) +
        1 - pt(t_crit, df = grid_n - 1, ncp = ncp)
    )
  }

  cols <- c(JAB = "#E69F00", min = "#56B4E9", robust = "#009E73",
            balanced = "#CC79A7", ES = "#0072B2", moment = "#D55E00")

  xat <- axisTicks(log10(c(50, max)), log = TRUE)
  op <- par(mfrow = c(1, length(d)), mgp = c(2.1, 0.6, 0), tcl = -0.3,
            mar = c(3.4, 3.4, 2, 0.8))
  on.exit(par(op))
  for (i in seq_along(d)) {
    plot(NULL, xlim = c(50, max), ylim = c(0, 1), log = "x", axes = FALSE,
         xlab = "Sample size", ylab = "Power", main = bquote(d == .(d[i])))
    abline(h = seq(0, 1, 0.2), col = "grey92", lwd = 0.7)
    if (!is.null(ref)) {
      lines(grid_n, pw(ref, d[i]), col = "grey45", lwd = 2, lty = 2)
    }
    for (m in methods) {
      lines(grid_n, pw(alpha_grid[, m], d[i]), col = cols[m], lwd = 2)
    }
    axis(1, at = xat,
         labels = format(xat, scientific = FALSE, big.mark = ",",
                         trim = TRUE),
         lwd = 0, lwd.ticks = 1, las = 1)
    axis(2, at = seq(0, 1, 0.2), lwd = 0, lwd.ticks = 1, las = 1)
    if (i == 1) {
      legend("topleft",
             legend = c(methods, if (!is.null(ref)) paste("fixed", ref)),
             col = c(cols[methods], if (!is.null(ref)) "grey45"),
             lwd = 2,
             lty = c(rep(1, length(methods)), if (!is.null(ref)) 2),
             bty = "n", cex = 0.85)
    }
  }
}
