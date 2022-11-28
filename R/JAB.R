#' Transforms a t-statistic from a glm or lm object into Jeffreys' approximate Bayes factor
#'
#' @param glm_obj a glm or lm object.
#' @param covariate the name of the covariate that you want a BF for as a string.
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
#' # Simulate data
#'
#' ## Sample size
#' n <- 200
#'
#' ## Regressors
#' Z1 <- runif(n, -1, 1)
#' Z2 <- runif(n, -1, 1)
#' Z3 <- runif(n, -1, 1)
#' Z4 <- runif(n, -1, 1)
#' X <- runif(n, -1, 1)
#'
#' ## Error term
#' U <- rnorm(n, 0, 0.5)
#'
#' ## Outcome
#' Y <- X/sqrt(n) + U
#'
#' # Run a GLM
#' LM <- glm(Y ~ X + Z1 + Z2 + Z3 + Z4)
#'
#' # Compute JAB for "X" based on the regression results
#' JAB(LM, "X")
#'
#' # Compute JAB adj
#' JAB(LM, "X", method = "min")
JAB <- function(glm_obj, covariate, method="JAB"){
  glm_obj_sum <- summary(glm_obj)
  n <- glm_obj_sum$df[1] + glm_obj_sum$df[2]
  #p <- glm_obj_sum$df[1]
  t <- as.numeric(glm_obj_sum$coefficients[covariate,][3])

  BF <- JABt(n = n, t = t, method = method)

  return(BF)
}
