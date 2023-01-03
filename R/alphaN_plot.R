#' Creates a plot of alpha as function of sample size for each of the four prior options
#'
#' @param BF Bayes factor you would like to match. 1 to avoid Lindley's Paradox, 3 to achieve moderate evidence and 10 to achieve strong evidence.
#' @param max The maximum number of sample size. Defaults to 10,000.
#'
#' @return Prints a plot.
#' @export
#'
#' @examples
#' # Plot of alpha level as a function of n for a Bayes factor of 3
#' alphaN_plot(BF = 3)
#' @importFrom graphics legend lines
alphaN_plot <- function(BF = 1, max = 10000){
  seqN <- seq(50, max, 1)

  plot(seqN, alphaN_vec(seqN, BF = BF), type = "l",
       xlab = "Sample size", ylab = expression(paste(alpha)),
       lwd=2, ylim= c(0, 0.05),xlim=c(0,max),
       axes=FALSE,
       col="#F8766D",
       main = paste("Bayes factor = ", BF))
  lines(seqN, alphaN_vec(seqN, BF = BF, method = "min"), lty=2, lwd=2, col="#7CAE00")
  lines(seqN, alphaN_vec(seqN, BF = BF, method = "robust"), lty=3, lwd=2, col="#00BFC4")
  lines(seqN, alphaN_vec(seqN, BF = BF, method = "balanced"), lty=4, lwd=2, col= "#C77CFF")
  axis(side = 1, at = seq(0, max, 2000), labels = seq(0, max, 2000))
  axis(side = 2, at = seq(0, 0.05, 0.01), labels = seq(0, 0.05, 0.01))

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
