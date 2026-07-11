#' Transforms a t-statistic from a glm or lm object into Jeffreys' approximate Bayes factor
#'
#' Extracts the test statistic of a coefficient from a fitted model object and
#' converts it into Jeffreys' approximate Bayes factor, given the sample size
#' used in the fit.
#'
#' @inheritParams JABt
#' @param glm_obj a glm or lm object.
#' @param covariate the name of the covariate that you want a BF for as a string.
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
#' @importFrom stats nobs
JAB <- function(glm_obj, covariate, method="JAB", upper = 1){
  if (!inherits(glm_obj, c("glm", "lm"))) {
    stop("`glm_obj` must be a model fitted with lm() or glm().", call. = FALSE)
  }
  if (!is.character(covariate) || length(covariate) != 1) {
    stop("`covariate` must be a single character string.", call. = FALSE)
  }

  coefs <- summary(glm_obj)$coefficients
  if (!covariate %in% rownames(coefs)) {
    stop("Covariate '", covariate, "' not found in the model. Available: ",
         paste(rownames(coefs), collapse = ", "), ".", call. = FALSE)
  }

  n <- nobs(glm_obj)
  t <- coefs[covariate, 3]

  BF <- JABt(n = n, t = t, method = method, upper = upper)

  return(BF)
}
