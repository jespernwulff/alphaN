#' Transforms a t-statistic into Jeffreys' approximate Bayes factor
#'
#' Converts a t-statistic (or z-statistic) into Jeffreys' approximate Bayes
#' factor, given the sample size. Vectorized over `n` and `t`.
#'
#' @param n Sample size. A positive numeric vector.
#' @param t The t-statistic.
#' @param method Used for the choice of 'b'. Currently one of:
#' \itemize{
#'   \item "JAB": this choice of b produces Jeffreys' approximate BF (Wagenmakers, 2022)
#'   \item "min": uses the minimal training sample for the prior (Gu et al., 2018)
#'   \item "robust": a robust version of "min" that prevents too small b (O'Hagan, 1995)
#'   \item "balanced": this choice of b balances the type I and type II errors (Gu et al., 2016)
#' }
#' @param upper The upper limit for the range of realistic effect sizes. Only relevant when method="balanced". Defaults to 1 such that the range of realistic effect sizes is uniformly distributed between 0 and 1, U(0,1).
#' @return A numeric value for the BF in favour of H1.
#' @export
#'
#' @examples
#' # Transform a t-statistic of 2.695 computed based on a sample size of 200 into JAB
#' JABt(200, 2.695)
JABt <- function(n, t, method = "JAB", upper = 1){
  if (!is.numeric(t) || length(t) == 0 || anyNA(t)) {
    stop("`t` must be a numeric vector without missing values.", call. = FALSE)
  }

  b <- choose_b(n, method, upper)

  BF <- exp(0.5*t^2)*sqrt(b)

  return(BF)
}
