#' Creates a plot of alpha as function of sample size for the chosen methods
#'
#' Draws alpha as a decreasing function of the sample size for any selection
#' of the calibration methods offered by [alphaN()]. The prior-fraction
#' curves ("JAB", "min", "robust", "balanced") are evaluated exactly at every
#' sample size; the "ES" and "moment" curves are evaluated at twelve
#' log-spaced sample sizes and interpolated by a spline on the log-log
#' scale, which keeps the plot fast (expect roughly a second of computation
#' per Klauer-type curve). Colors follow the colorblind-safe Okabe-Ito
#' palette.
#'
#' @inheritParams alphaN
#' @param max The maximum number of sample size. Defaults to 10,000.
#' @param ylim Limits for the y-axis. The default, NULL, covers all
#'   requested curves. Set to e.g. c(0, 0.05) to zoom in on small alpha
#'   levels.
#' @param methods Character vector with the methods to draw, any subset of
#'   c("JAB", "min", "robust", "balanced", "ES", "moment"). Defaults to the
#'   four prior-fraction methods, matching the behavior of earlier package
#'   versions.
#' @param log Passed to [plot()]: "" (default) for linear axes, "x", "y", or
#'   "xy" for logarithmic ones. Logarithmic axes are useful when the
#'   "moment" curve is included, since it falls much faster than the others.
#'
#' @return Prints a plot.
#' @export
#'
#' @examples
#' # Plot of alpha level as a function of n for a Bayes factor of 3
#' alphaN_plot(BF = 3)
#'
#' # Compare JAB with the effect-size and moment calibrations
#' alphaN_plot(BF = 3, methods = c("JAB", "ES", "moment"), log = "xy")
#' @importFrom graphics legend lines abline par axis title
#' @importFrom grDevices axisTicks
#' @importFrom stats splinefun
alphaN_plot <- function(BF = 1, max = 10000, ylim = NULL,
                        methods = c("JAB", "min", "robust", "balanced"),
                        de = 0.5, log = ""){
  all_methods <- c("JAB", "min", "robust", "balanced", "ES", "moment")
  methods <- match.arg(methods, all_methods, several.ok = TRUE)
  if (!is.character(log) || length(log) != 1 ||
      !log %in% c("", "x", "y", "xy", "yx")) {
    stop('`log` must be one of "", "x", "y", or "xy".', call. = FALSE)
  }

  seqN <- seq(50, max, 1)
  curves <- lapply(methods, function(m) {
    if (m %in% c("ES", "moment")) {
      anchors <- unique(round(10^seq(log10(50), log10(max),
                                     length.out = 12)))
      a <- alphaN(anchors, BF = BF, method = m, de = de)
      f <- splinefun(log(anchors), log(a))
      exp(f(log(seqN)))
    } else {
      alphaN(seqN, BF = BF, method = m)
    }
  })
  names(curves) <- methods

  # Okabe-Ito, colorblind safe
  cols <- c(JAB = "#E69F00", min = "#56B4E9", robust = "#009E73",
            balanced = "#CC79A7", ES = "#0072B2", moment = "#D55E00")
  ltys <- c(JAB = 1, min = 2, robust = 3, balanced = 4, ES = 5, moment = 6)

  logx <- grepl("x", log)
  logy <- grepl("y", log)
  xlim <- if (logx) c(50, max) else c(0, max)
  if (is.null(ylim)) {
    ymax <- base::max(unlist(curves))
    ylim <- if (logy) c(base::min(unlist(curves)), ymax) else c(0, ymax)
  }

  # Plain-notation tick labels: "0.0001" and "10,000", never "1e-04". Ticks
  # are computed up front so the left margin can grow with the label width,
  # keeping the axis title clear of the horizontal labels.
  xat <- if (logx) axisTicks(log10(xlim), log = TRUE) else pretty(xlim)
  yat <- if (logy) axisTicks(log10(ylim), log = TRUE) else pretty(ylim)
  xlabs <- format(xat, scientific = FALSE, big.mark = ",", trim = TRUE)
  ylabs <- format(yat, scientific = FALSE, drop0trailing = TRUE, trim = TRUE)
  # Horizontal y labels occupy roughly 0.55 margin lines per character
  # (starting at the mgp tick-label offset of 0.7), so the axis title sits
  # beyond the widest label plus a cushion, and the margin beyond the title.
  ylab_line <- 1.2 + 0.55*base::max(nchar(ylabs))
  left <- ylab_line + 1.6

  op <- par(mgp = c(2.4, 0.7, 0), tcl = -0.3, mar = c(4.1, left, 3.1, 1.1))
  on.exit(par(op))
  plot(NULL, xlim = xlim, ylim = ylim, log = log, axes = FALSE,
       xlab = "Sample size", ylab = "",
       main = bquote("Target Bayes factor:" ~ .(BF)))
  abline(h = yat, v = xat, col = "grey92", lwd = 0.7)
  for (m in methods) {
    lines(seqN, curves[[m]], lty = ltys[m], lwd = 2.5, col = cols[m])
  }
  axis(side = 1, at = xat, labels = xlabs, lwd = 0, lwd.ticks = 1, las = 1)
  axis(side = 2, at = yat, labels = ylabs, lwd = 0, lwd.ticks = 1, las = 1)
  title(ylab = expression(alpha), line = ylab_line)

  legend(if (logy) "bottomleft" else "topright",
         legend = methods,
         lty = ltys[methods],
         lwd = 2.5,
         col = cols[methods],
         bty = "n", seg.len = 2.6)
}
