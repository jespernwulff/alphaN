#' Creates a plot of alpha as function of sample size for each of the four prior options
#'
#' @inheritParams alphaN
#' @param max The maximum number of sample size. Defaults to 10,000.
#' @param ylim Limits for the y-axis. The default, NULL, covers all four
#'   curves. Set to e.g. c(0, 0.05) to zoom in on small alpha levels.
#'
#' @return Prints a plot.
#' @export
#'
#' @examples
#' # Plot of alpha level as a function of n for a Bayes factor of 3
#' alphaN_plot(BF = 3)
#' @importFrom graphics legend lines
alphaN_plot <- function(BF = 1, max = 10000, ylim = NULL){
  seqN <- seq(50, max, 1)

  alpha_jab <- alphaN(seqN, BF = BF)
  alpha_min <- alphaN(seqN, BF = BF, method = "min")
  alpha_robust <- alphaN(seqN, BF = BF, method = "robust")
  alpha_balanced <- alphaN(seqN, BF = BF, method = "balanced")

  if (is.null(ylim)) {
    ylim <- c(0, base::max(alpha_jab, alpha_min, alpha_robust, alpha_balanced))
  }

  plot(seqN, alpha_jab, type = "l",
       xlab = "Sample size", ylab = expression(paste(alpha)),
       lwd=2, ylim= ylim, xlim=c(0,max),
       axes=FALSE,
       col="#F8766D",
       main = paste("Bayes factor = ", BF))
  lines(seqN, alpha_min, lty=2, lwd=2, col="#7CAE00")
  lines(seqN, alpha_robust, lty=3, lwd=2, col="#00BFC4")
  lines(seqN, alpha_balanced, lty=4, lwd=2, col= "#C77CFF")
  axis(side = 1, at = pretty(c(0, max)))
  axis(side = 2, at = pretty(ylim))

  legend("topright",
         c("JAB",
           "Min",
           "Robust",
           "Balanced"
         ),
         lty = c(1,2,3,4),
         lwd = c(2,2,2,2),
         col = c("#F8766D",
                 "#7CAE00",
                 "#00BFC4",
                 "#C77CFF"),
         box.col="white", bg="white")

}
