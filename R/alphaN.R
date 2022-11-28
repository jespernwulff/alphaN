#' Set the alpha level based on sample size for coefficients in a regression models.
#'
#' @param n Sample size
#' @param BF Bayes factor you would like to match. 1 to avoid Lindley's Paradox, 3 to achieve moderate evidence and 10 to achieve strong evidence.
#' @param method Used for the choice of 'b'. Currently one of:
#' \itemize{
#'   \item "JAB": this choice of b produces Jeffery's approximate BF
#'   \item "min": uses the minimal training sample for the prior (Gu et al., '17)
#'   \item "robust": a robust version of "min" that prevents too small b (O'Hagan, '95)
#'   \item "balanced": this choice of b balances the type I and type II errors
#' }
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
#' Gu et al. (2018). Approximated adjusted fractional Bayes factors: A general method for testing informative hypotheses. The British Journal of Mathematical and Statistical Psychology, 71(2). \cr
#' O’Hagan, A. (1995). Fractional Bayes Factors for Model Comparison. Journal of the Royal Statistical Society. Series B (Methodological), 57(1), 99–138. \cr
#' Taylor, L. & Wulff, J.N. (2022). Let alpha depend on n: A Bayesian-frequentist compromise by using lower alpha levels in larger sample size. \cr
#' @importFrom stats pchisq pt integrate
alphaN <- function(n, BF=1, method="JAB") {
  if(method=="JAB") {b <- 1/n}
  if(method=="min") {b <- 2/n}
  if(method=="robust") {b <- max(2/n, 1/sqrt(n))}
  if(method=="balanced") {
    b <- max(2/n, min(0.5,
                      integrate(function(x) exp(-n*x^2/4), lower=0, upper=1)$value))
  }

  alpha <- 1-pchisq(2*log(BF/sqrt(b)), 1)
  return(alpha)
}
