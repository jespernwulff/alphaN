#' Transforms a t-statistic into Jeffreys' approximate Bayes factor
#'
#' @param n Sample size.
#' @param t The t-statistic.
#' @param method Used for the choice of 'b'. Currently one of:
#' \itemize{
#'   \item "JAB": this choice of b produces Jeffery's approximate BF (Wagenmakers, 2022)
#'   \item "min": uses the minimal training sample for the prior (Gu et al., 2018)
#'   \item "robust": a robust version of "min" that prevents too small b (O'Hagan, 1995)
#'   \item "balanced": this choice of b balances the type I and type II errors (Gu et al, 2016)
#' }
#' @param upper The upper limit for the range of realistic effect sizes. Only relevant when method="balanced". Defaults to 1 such that the range of realistic effect sizes is uniformly distributed between 0 and 1, U(0,1).
#' @return A numeric value for the BF in favour of H1.
#' @export
#'
#' @examples
#' # Transform a t-statistic of 2.695 computed based on a sample size of 200 into JAB
#' JABt(200, 2.695)
#' @importFrom stats integrate
JABt <- function(n, t, method = "JAB", upper = 1){
  if(method=="JAB") {b <- 1/n}
  if(method=="min") {b <- 2/n}
  if(method=="robust") {b <- max(2/n, 1/sqrt(n))}
  if(method=="balanced") {
    b <- max(2/n, min(0.5,
                      integrate(function(x) exp(-n*x^2/4), lower=0, upper=upper)$value))
  }


  BF <- exp(0.5*t^2)*sqrt(b)

  return(BF)
}
