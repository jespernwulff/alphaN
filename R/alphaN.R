#' Set the alpha level based on sample size for coefficients in a regression model
#'
#' Computes the alpha level required to achieve a desired level of evidence,
#' expressed as a Bayes factor, when testing a coefficient in a regression
#' model. The alpha level is a decreasing function of the sample size.
#' Vectorized over `n` and `BF`.
#'
#' @param n Sample size. A positive numeric vector.
#' @param BF Bayes factor you would like to match. 1 to avoid Lindley's Paradox, 3 to achieve moderate evidence and 10 to achieve strong evidence.
#' @param method Used for the choice of 'b'. Currently one of:
#' \itemize{
#'   \item "JAB": this choice of b produces Jeffreys' approximate BF (Wagenmakers, 2022)
#'   \item "min": uses the minimal training sample for the prior (Gu et al., 2018)
#'   \item "robust": a robust version of "min" that prevents too small b (O'Hagan, 1995)
#'   \item "balanced": this choice of b balances the type I and type II errors (Gu et al., 2016)
#' }
#' @param upper The upper limit for the range of realistic effect sizes. Only relevant when method="balanced". Defaults to 1 such that the range of realistic effect sizes is uniformly distributed between 0 and 1, U(0,1).
#' @return Numeric alpha level required to achieve the desired level of evidence.
#' @export
#'
#' @examples
#'# Plot of alpha level as a function of n
#'seqN <- seq(50, 1000, 1)
#'plot(seqN, alphaN(seqN), type = "l")
#' @section References:
#' Gu et al. (2016). Error probabilities in default Bayesian hypothesis testing. Journal of Mathematical Psychology, 72, 130–143. \cr
#' \cr
#' Gu et al. (2018). Approximated adjusted fractional Bayes factors: A general method for testing informative hypotheses. The British Journal of Mathematical and Statistical Psychology, 71(2). \cr
#' \cr
#' O’Hagan, A. (1995). Fractional Bayes Factors for Model Comparison. Journal of the Royal Statistical Society. Series B (Methodological), 57(1), 99–138. \cr
#' \cr
#' Wagenmakers, E.-J. (2022). Approximate objective Bayes factors from p-values and sample size: The 3p(sqrt(n)) rule. PsyArXiv. \cr
#' \cr
#' Wulff, J. N., & Taylor, L. (2024). How and why alpha should depend on sample size: A Bayesian-frequentist compromise for significance testing. Strategic Organization. \doi{10.1177/14761270231214429}
#' @importFrom stats pchisq
alphaN <- function(n, BF=1, method="JAB", upper = 1) {
  if (!is.numeric(BF) || length(BF) == 0 || !all(is.finite(BF)) ||
      any(BF <= 0)) {
    stop("`BF` must be a positive, finite numeric value.", call. = FALSE)
  }

  b <- choose_b(n, method, upper)

  alpha <- 1-pchisq(2*log(BF/sqrt(b)), 1)
  return(alpha)
}
