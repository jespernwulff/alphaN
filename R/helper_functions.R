# Helper functions

#' Choose the prior fraction b
#'
#' Selects b, the fraction of the data used to specify the prior, for a given
#' sample size and method. Vectorized over n.
#'
#' @param n Sample size. A positive numeric vector.
#' @param method One of "JAB", "min", "robust" or "balanced".
#' @param upper Upper limit for the range of realistic effect sizes
#'   (method = "balanced" only).
#' @return A numeric vector of the same length as n.
#' @importFrom stats integrate
#' @noRd
choose_b <- function(n, method = c("JAB", "min", "robust", "balanced"),
                     upper = 1) {
  method <- match.arg(method)
  if (!is.numeric(n) || length(n) == 0 || !all(is.finite(n)) || any(n <= 0)) {
    stop("`n` must be a positive, finite numeric vector.", call. = FALSE)
  }
  if (!is.numeric(upper) || length(upper) != 1 || !is.finite(upper) ||
      upper <= 0) {
    stop("`upper` must be a single positive number.", call. = FALSE)
  }

  switch(method,
    JAB = 1/n,
    min = 2/n,
    robust = pmax(2/n, 1/sqrt(n)),
    balanced = vapply(n, function(ni) {
      max(2/ni, min(0.5,
                    integrate(function(x) exp(-ni*x^2/4), lower = 0, upper = upper)$value))
    }, numeric(1))
  )
}
