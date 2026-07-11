#' Transforms a t-statistic into Jeffreys' approximate Bayes factor
#'
#' Converts a t-statistic (or z-statistic) into Jeffreys' approximate Bayes
#' factor, given the sample size. Vectorized over `n` and `t`.
#'
#' @inheritParams alphaN
#' @param t The t-statistic.
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
