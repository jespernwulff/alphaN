#' Transforms t-statistics from a glm or lm object into Jeffreys' approximate Bayes factors
#'
#' Extracts the test statistic of one coefficient, or of every coefficient,
#' from a fitted model object and converts it into Jeffreys' approximate
#' Bayes factor, given the sample size used in the fit.
#'
#' @inheritParams JABt
#' @param glm_obj a glm or lm object.
#' @param covariate the name of the covariate that you want a BF for, as a
#'   string. The default, NULL, returns a named vector with the Bayes factor
#'   of every coefficient except the intercept (request the intercept
#'   explicitly with `covariate = "(Intercept)"` if you need it).
#'
#' @return A numeric value with the BF in favour of H1, or a named vector of
#'   BFs when `covariate = NULL`.
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
#' # Compute JAB for every coefficient at once
#' JAB(LM)
#'
#' # Compute JAB using the minimum prior
#' JAB(LM, "X", method = "min")
#' @importFrom stats nobs setNames
JAB <- function(glm_obj, covariate = NULL, method="JAB", upper = 1){
  if (!inherits(glm_obj, c("glm", "lm"))) {
    stop("`glm_obj` must be a model fitted with lm() or glm().", call. = FALSE)
  }

  coefs <- summary(glm_obj)$coefficients
  n <- nobs(glm_obj)

  if (is.null(covariate)) {
    keep <- setdiff(rownames(coefs), "(Intercept)")
    if (length(keep) == 0) {
      stop("The model has no coefficients besides the intercept; request it ",
           "explicitly with covariate = \"(Intercept)\".", call. = FALSE)
    }
    t <- coefs[keep, 3]
    return(setNames(JABt(n = n, t = t, method = method, upper = upper), keep))
  }

  if (!is.character(covariate) || length(covariate) != 1) {
    stop("`covariate` must be a single character string.", call. = FALSE)
  }
  if (!covariate %in% rownames(coefs)) {
    stop("Covariate '", covariate, "' not found in the model. Available: ",
         paste(rownames(coefs), collapse = ", "), ".", call. = FALSE)
  }

  t <- coefs[covariate, 3]

  BF <- JABt(n = n, t = t, method = method, upper = upper)

  return(BF)
}
