#' Effective sample size from cluster-robust standard errors
#'
#' Computes the effective sample size recommended by Wulff and Taylor (2024)
#' for calibrating alpha with clustered (panel) data, where observations are
#' not independent and the nominal sample size overstates the information in
#' the data: `n_e = n * (se / se_robust)^2`, the total number of
#' observations deflated by the squared ratio of the classical to the
#' cluster-robust standard error. Vectorized over its arguments (recycled).
#'
#' @param n Total number of observations. A positive numeric vector.
#' @param se The classical (non-robust) standard error of the coefficient.
#' @param se_robust The cluster-robust standard error of the same
#'   coefficient.
#' @return A numeric vector with the effective sample size.
#'
#' @details
#' Wulff and Taylor (2024) recommend calibrating alpha with the total number
#' of observations, which is the conservative choice, and then checking
#' whether conclusions survive when alpha and the Bayes factor are
#' recomputed with the effective sample size. Because cluster-robust
#' standard errors typically exceed classical ones, `n_effective()` is
#' typically smaller than `n`, which yields a larger calibrated alpha.
#' @export
#'
#' @examples
#' # A regression on 237 clustered observations where the cluster-robust
#' # standard error is twice the classical one implies an effective sample
#' # size four times smaller (Wulff & Taylor, 2024, Example 3)
#' n_effective(n = 237, se = 0.1, se_robust = 0.2)
#'
#' # Alpha for moderate evidence at the nominal and the effective sample size
#' alphaN(n = 237, BF = 3, method = "robust")
#' alphaN(n = n_effective(237, 0.1, 0.2), BF = 3, method = "robust")
#' @seealso [alphaN()]
#' @section References:
#' Wulff, J. N., & Taylor, L. (2024). How and why alpha should depend on
#' sample size: A Bayesian-frequentist compromise for significance testing.
#' Strategic Organization, 22(3), 550-581. \doi{10.1177/14761270231214429}
n_effective <- function(n, se, se_robust) {
  if (!is.numeric(n) || length(n) == 0 || !all(is.finite(n)) || any(n <= 0)) {
    stop("`n` must be a positive, finite numeric vector.", call. = FALSE)
  }
  if (!is.numeric(se) || length(se) == 0 || !all(is.finite(se)) ||
      any(se <= 0)) {
    stop("`se` must be a positive, finite numeric vector.", call. = FALSE)
  }
  if (!is.numeric(se_robust) || length(se_robust) == 0 ||
      !all(is.finite(se_robust)) || any(se_robust <= 0)) {
    stop("`se_robust` must be a positive, finite numeric vector.",
         call. = FALSE)
  }
  n * (se / se_robust)^2
}
