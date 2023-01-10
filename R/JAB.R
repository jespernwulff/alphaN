#' Transforms a t-statistic from a glm or lm object into Jeffreys' approximate Bayes factor
#'
#' @param glm_obj a glm or lm object.
#' @param covariate the name of the covariate that you want a BF for as a string.
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
#' # Compute JAB using the minimum prior
#' JAB(LM, "X", method = "min")
JAB <- function(glm_obj, covariate, method="JAB", upper = 1){
  glm_obj_sum <- summary(glm_obj)
  n <- glm_obj_sum$df[1] + glm_obj_sum$df[2]
  t <- as.numeric(glm_obj_sum$coefficients[covariate,][3])

  BF <- JABt(n = n, t = t, method = method, upper = upper)

  return(BF)
}
