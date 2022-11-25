#' Plots JAB as a function of the p-value
#'
#' @param n Sample size
#' @param BF Bayes factor you would like to match. 1 to avoid the Lindley Paradox, 3 to achieve moderate evidence and 10 to achieve strong evidence.
#' @param method Used for the choice of 'b', currently one of "JAB" or "JAB adj".
#' @param p Number of parameters in the model, only required if method="JAB adj".
#'
#' @return Prints a plot.
#' @export
#'
#' @examples
#' # Plot JAB as function of the p-value for a sample size of 2000
#' JAB_plot(2000)
JAB_plot <- function(n, BF=1, method="JAB", p = NULL){

  alpha <- alphaN(n = n, BF = BF, method = method, p = p)

  indicated <- alpha
  lindley <- alphaN(n = n, BF = 1, method = method, p = p)
  moderate <- alphaN(n = n, BF = 3, method = method, p = p)
  strong <- alphaN(n = n, BF = 10, method = method, p = p)

  ### and make a sequence of t-stats to get p-values
  ts <- seq(1.2, 5, length.out=150)
  ps <- 1-pchisq(ts^2, 1)
  ## Third, loop to get a Bayes factor every p-value

  bf <- numeric(length(ts))
  i <- 0

  for(t in ts){
    i <- i+1
    bf[i] <- JABt(n = n, t = t, method = method, p = p)
  }

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
