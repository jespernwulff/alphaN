#' Transforms a t-statistic into Jeffreys' approximate Bayes factor
#'
#' @param n Sample size.
#' @param t The t-statistic.
#' @param method Used for the choice of 'b', currently one of "JAB" or "JAB adj".
#' @param p Number of parameters in the model, only required if method="JAB adj".
#'
#' @return A numeric value for the BF in favour of H1.
#' @export
#'
#' @examples
#' # Transform a t-statistic of 2.695 computed based on a sample size of 200 into JAB
#' JABt(200, 2.695)
JABt <- function(n, t, method = "JAB", p = NULL){
  if(method=="JAB") {b=sqrt(n)}
  if(method=="JAB adj") {b=sqrt(n/p)}

  BF <- exp(0.5*t^2)/b

  return(BF)
}
