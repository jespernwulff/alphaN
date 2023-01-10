#' Title
#'
#' @param n Sample size.
#' @param p The p-value.
#' @param z Is the p-value based on a z- or t-statistic? TRUE if z.
#' @param df If z=FALSE, provide the degrees of freedom for the t-statistic.
#' @param method Used for the choice of 'b'. Currently one of:
#' \itemize{
#'   \item "JAB": this choice of b produces Jeffery's approximate BF (Wagenmakers, 2022)
#'   \item "min": uses the minimal training sample for the prior (Gu et al., 2018)
#'   \item "robust": a robust version of "min" that prevents too small b (O'Hagan, 1995)
#'   \item "balanced": this choice of b balances the type I and type II errors (Gu et al, 2016)
#' }
#' @param upper The upper limit for the range of realistic effect sizes. Only relevant when method="balanced". Defaults to 1 such that the range of realistic effect sizes is uniformly distributed between 0 and 1, U(0,1).
#'
#' @return A numeric value for the BF in favour of H1.
#' @export
#'
#' @examples
#' # Transform a p-value of 0.007038863 from a z-test into JAB
#' # using a sample size of 200.
#' JABp(200, 0.007038863)
#'
#' # Transform a p-value of 0.007038863 from a t-test with 190
#' # degrees of freedom into JAB using a sample size of 200.
#' JABp(200, 0.007038863, z=FALSE, df=190)
#'
#' @importFrom stats qnorm qt
JABp <- function(n, p, z = TRUE, df = NULL, method = "JAB", upper = 1){
  # Find the corresponding z- or t-statistic
  if(z){
    stat <- qnorm(p/2, lower.tail = FALSE)
  } else {
    stat <- qt(p/2, df = df, lower.tail = FALSE)
  }

  BF <- JABt(n, stat, method = method, upper = upper)

  return(BF)
}
