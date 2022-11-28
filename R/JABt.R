#' Transforms a t-statistic into Jeffreys' approximate Bayes factor
#'
#' @param n Sample size.
#' @param t The t-statistic.
#' @param method Used for the choice of 'b'. Currently one of:
#' \itemize{
#'   \item "JAB": this choice of b produces Jeffery's approximate BF
#'   \item "min": uses the minimal training sample for the prior (Gu et al., '17)
#'   \item "robust": a robust version of "min" that prevents too small b (O'Hagan, '95)
#'   \item "balanced: this choice of b balances the type I and type II errors
#' }
#'
#' @return A numeric value for the BF in favour of H1.
#' @export
#'
#' @examples
#' # Transform a t-statistic of 2.695 computed based on a sample size of 200 into JAB
#' JABt(200, 2.695)
#' @importFrom stats integrate
JABt <- function(n, t, method = "JAB"){
  if(method=="JAB") {b <- 1/n}
  if(method=="min") {b <- 2/n}
  if(method=="robust") {b <- max(2/n, 1/sqrt(n))}
  if(method=="balanced") {
    b <- max(2/n, min(0.5,
                      integrate(function(x) exp(-n*x^2/4), lower=0, upper=1)$value))
  }


  BF <- exp(0.5*t^2)*sqrt(b)

  return(BF)
}
