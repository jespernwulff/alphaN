#' Plots JAB as a function of the p-value
#'
#' @inheritParams alphaN
#'
#' @return Prints a plot.
#' @export
#'
#' @examples
#' # Plot JAB as function of the p-value for a sample size of 2000
#' JAB_plot(2000)
#' @importFrom graphics abline axis points
JAB_plot <- function(n, BF=1, method="JAB", upper = 1){

  alpha <- alphaN(n = n, BF = BF, method = method, upper = upper)

  indicated <- alpha
  lindley <- alphaN(n = n, BF = 1, method = method, upper = upper)
  moderate <- alphaN(n = n, BF = 3, method = method, upper = upper)
  strong <- alphaN(n = n, BF = 10, method = method, upper = upper)

  ### and make a sequence of t-stats to get p-values
  ts <- seq(1.2, 5, length.out=150)
  ps <- 1-pchisq(ts^2, 1)
  ## Third, get a Bayes factor for every p-value
  bf <- JABt(n = n, t = ts, method = method, upper = upper)

  plot(ps, bf, type="l", lty=1, lwd=2, log = "y",
       xlab = bquote(italic("p")*"-value"), ylab = "Bayes factor",
       ylim = c(0.1, 10), xlim = c(0, max(c(0.05, lindley))),
       axes=FALSE)

  axis(side=1, at = c(0, as.numeric(lindley), as.numeric(moderate),
                      as.numeric(strong), 0.05, indicated),
       labels = c(0, round(lindley, digits = 3), round(moderate, digits = 3),
                  round(strong, digits = 3), 0.05, round(indicated, digits = 3)),
       lwd = 2, las = 3)

  axis(side=2, at = c(0.1, 0.33, 1, 3, 10), labels = c("1/10", "1/3", 1, 3, 10), lwd = 2)
  abline(h = c(0.1, 0.33, 1, 3, 10), col = "gray", lty = 2)
  abline(v = c(lindley, moderate, strong), lty = 3)
  abline(v = indicated, lty = 3, col = "red")

  points(indicated, BF, col = "black", bg="red", cex=2, pch = 24, lwd = 2)
}
