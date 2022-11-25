#' Set the alpha level based on sample size for coefficients in a regression models.
#'
#' @param n Sample size
#' @param BF Bayes factor you would like to match. 1 to avoid the Lindley Paradox, 3 to achieve moderate evidence and 10 to achieve strong evidence.
#' @param method Used for the choice of 'b', currently one of "JAB" or "JAB adj"
#' @param p Number of parameters in the model, only required if method="JAB adj"
#'
#' @return Numeric alpha level required to achieve the desired level of evidence.
#' @export
#'
#' @examples
#'
#' # Plot of alpha level as a function of n
#'seqN <- seq(50, 1000, 1)
#'plot(seqN, alphaN(seqN), type = "l")
#'
#'
#' @section References:
#' Taylor, L. & Wulff, J.N. (2022). Let alpha depend on n: A Bayesian-frequentist compromise by using lower alpha levels in larger sample size
#' @importFrom stats pchisq pt
alphaN <- function(n, BF=1, method="JAB", p=NULL) {
  if(method=="JAB") {b=sqrt(n)}
  if(method=="JAB adj") {b=sqrt(n/p)}

  alpha <- 1-pchisq(2*log(BF*b), 1)
  return(alpha)
}
