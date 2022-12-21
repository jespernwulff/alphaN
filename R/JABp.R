#' Title
#'
#' @param n Sample size.
#' @param p The p-value.
#' @param z Is the p-value based on a z- or t-statistic? TRUE if z.
#' @param df If z=FALSE, provide the degrees of freedom for the t-statistic.
#' @param method Used for the choice of 'b'. Currently one of:
#' \itemize{
#'   \item "JAB": this choice of b produces Jeffery's approximate BF
#'   \item "min": uses the minimal training sample for the prior (Gu et al., '17)
#'   \item "robust": a robust version of "min" that prevents too small b (O'Hagan, '95)
#'   \item "balanced": this choice of b balances the type I and type II errors
#' }
#'
#' @return A numeric value for the BF in favour of H1.
#' @export
#'
#' @examples
#' #' # Transform a p-value of 0.007038863 from a z-test into JAB
#' # using a sample size of 200.
#' JABt(200, 2.695)
#' @importFrom stats qnorm qt
JABp <- function(n, p, z = TRUE, df = NULL, method = "JAB"){
  # Find the corresponding z- or t-statistic
  if(z){
    stat <- qnorm(p/2, lower.tail = FALSE)
  } else {
    stat <- qt(p/2, df = df, lower.tail = FALSE)
  }

  BF <- JABt(n, stat, method = method)

  return(BF)
}
