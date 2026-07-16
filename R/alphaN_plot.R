#' Creates a plot of alpha as function of sample size for the chosen methods
#'
#' Draws alpha as a decreasing function of the sample size for any selection
#' of the calibration methods offered by [alphaN()]. The prior-fraction
#' curves ("JAB", "min", "robust", "balanced") are evaluated exactly at every
#' sample size; the "ES" and "moment" curves are evaluated at twelve
#' log-spaced sample sizes and interpolated by a spline on the log-log
#' scale, which keeps the plot fast (expect roughly a second of computation
#' per Klauer-type curve).
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
#'
#' @return Prints a plot.
#' @export
#'
#' @examples
#' # Plot of alpha level as a function of n for a Bayes factor of 3
#' alphaN_plot(BF = 3)
#'
#' # Compare JAB with the effect-size and moment calibrations
#' alphaN_plot(BF = 3, methods = c("JAB", "ES", "moment"))
#' @importFrom graphics legend lines
#' @importFrom stats splinefun
alphaN_plot <- function(BF = 1, max = 10000, ylim = NULL,
                        methods = c("JAB", "min", "robust", "balanced"),
                        de = 0.5){
  all_methods <- c("JAB", "min", "robust", "balanced", "ES", "moment")
  methods <- match.arg(methods, all_methods, several.ok = TRUE)

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

  cols <- c(JAB = "#F8766D", min = "#7CAE00", robust = "#00BFC4",
            balanced = "#C77CFF", ES = "#619CFF", moment = "#F564E3")
  ltys <- c(JAB = 1, min = 2, robust = 3, balanced = 4, ES = 5, moment = 6)

  if (is.null(ylim)) {
    ylim <- c(0, base::max(unlist(curves)))
  }

  plot(seqN, curves[[1]], type = "l",
       xlab = "Sample size", ylab = expression(paste(alpha)),
       lwd = 2, ylim = ylim, xlim = c(0, max),
       axes = FALSE,
       col = cols[methods[1]], lty = ltys[methods[1]],
       main = paste("Bayes factor = ", BF))
  for (m in methods[-1]) {
    lines(seqN, curves[[m]], lty = ltys[m], lwd = 2, col = cols[m])
  }
  axis(side = 1, at = pretty(c(0, max)))
  axis(side = 2, at = pretty(ylim))

  legend("topright",
         legend = methods,
         lty = ltys[methods],
         lwd = 2,
         col = cols[methods],
         box.col = "white", bg = "white")
}
