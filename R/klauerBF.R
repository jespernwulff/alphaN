#' Effect-size or moment Bayes factor from a t or F statistic
#'
#' Computes the effect-size or moment Bayes factor of Klauer, Meyer-Grant,
#' and Kellen (2025) from a t statistic (one-sample test or single
#' regression coefficient) or from an F statistic (joint test of `q`
#' coefficients). These are the Bayes factors that [alphaN()] inverts for
#' `method = "ES"` and `method = "moment"`, so a reported test statistic can
#' be converted into evidence under the same prior used to set the alpha
#' level. Vectorized over `t` (or `Fstat`) and `n`.
#'
#' @param n Sample size. A positive numeric vector.
#' @param t The t-statistic. Used when `q = 1`; supply either `t` or `Fstat`
#'   (with `Fstat` read as the squared t-statistic).
#' @param Fstat The F-statistic of the model comparison. Required when
#'   `q > 1`.
#' @param q Number of coefficients tested jointly. The default, 1, covers
#'   the one-sample test and the test of a single regression coefficient.
#' @param p Number of parameters retained in the reduced model, including
#'   any intercept. The effective sample size of Klauer et al. (2025) is
#'   `n - p`; the default, 0, is the one-sample case. For a test of a single
#'   coefficient in a regression model, `p` is the number of other estimated
#'   coefficients, including the intercept.
#' @param method `"ES"` for the effect-size Bayes factor or `"moment"` for
#'   the moment Bayes factor.
#' @param de The prespecified (targeted) effect size: Cohen's d for `q = 1`,
#'   and Cohen's f for joint tests (the two scales coincide at `q = 1`).
#'   Defaults to 0.5. For joint tests, Cohen (1988, Chapter 9) labels
#'   f^2 of 0.02, 0.15, and 0.35 as small, medium, and large, so
#'   `de = sqrt(0.15)` targets a medium effect.
#' @param nu Degrees of freedom of the prior t distribution. The default,
#'   NULL, uses the recommendations of Klauer et al. (2025): 3 for `"ES"`
#'   and `5 + (q - 1)` for `"moment"`.
#' @param r Scale of the prior mixture components for method `"ES"`. The
#'   default, NULL, uses the recommendation of Klauer et al. (2025),
#'   \code{r = sqrt((nu - 2)/(nu * q)) * de}, which requires `nu > 2` and
#'   `de > 0`; otherwise supply `r` explicitly.
#' @return A numeric vector with the Bayes factor in favour of H1.
#'
#' @details
#' For `q = 1` the Bayes factor is evaluated in its noncentral-t form with
#' `n - p - 1` degrees of freedom, and for `q > 1` in its noncentral-F form
#' with `(q, n - p - q)` degrees of freedom (Table 4 of Klauer et al.,
#' 2025). The implementation is validated against all printed Bayes factors
#' in Tables 7 and 8 of that paper.
#'
#' As a special case, `q = 1, nu = 1, de = 0` with an explicit scale (e.g.
#' \code{r = 1}) gives the default (Jeffreys-Zellner-Siow type) Bayes factor of
#' Rouder et al. (2009).
#' @export
#'
#' @examples
#' # Effect-size Bayes factor for t(79) = 2.24 targeting a medium effect
#' # (Table 7 of Klauer et al., 2025)
#' klauerBF(n = 80, t = 2.24, de = 0.5)
#'
#' # The moment Bayes factor for the same statistic
#' klauerBF(n = 80, t = 2.24, method = "moment", de = 0.5)
#'
#' # Joint test of q = 2 coefficients in a regression with 3 retained
#' # parameters (Table 8 of Klauer et al., 2025, model M9)
#' klauerBF(n = 175, Fstat = 1.17, q = 2, p = 3, de = sqrt(0.15))
#' @seealso [alphaN()] for the inverse mapping from a target Bayes factor to
#'   an alpha level, and [JABt()] for Jeffreys' approximate Bayes factor.
#' @section References:
#' Cohen, J. (1988). Statistical power analysis for the behavioral sciences
#' (second edition). Lawrence Erlbaum. \cr
#' \cr
#' Klauer, K. C., Meyer-Grant, C. G., & Kellen, D. (2025). On Bayes factors
#' for hypothesis tests. Psychonomic Bulletin & Review, 32, 1070-1094.
#' \doi{10.3758/s13423-024-02612-2} \cr
#' \cr
#' Rouder, J. N., Speckman, P. L., Sun, D., Morey, R. D., & Iverson, G.
#' (2009). Bayesian t tests for accepting and rejecting the null hypothesis.
#' Psychonomic Bulletin & Review, 16, 225-237.
klauerBF <- function(n, t = NULL, Fstat = NULL, q = 1, p = 0,
                     method = "ES", de = 0.5, nu = NULL, r = NULL) {
  method <- match.arg(method, c("ES", "moment"))
  args <- resolve_klauer_args(n, method, de, nu, r, q = q, p = p)

  if (q == 1) {
    if (is.null(t) == is.null(Fstat)) {
      stop("For `q` = 1, supply exactly one of `t` or `Fstat`.",
           call. = FALSE)
    }
    if (!is.null(Fstat)) {
      if (!is.numeric(Fstat) || length(Fstat) == 0 || anyNA(Fstat) ||
          any(Fstat < 0)) {
        stop("`Fstat` must be a non-negative numeric vector without missing values.",
             call. = FALSE)
      }
      t <- sqrt(Fstat)
    }
    if (!is.numeric(t) || length(t) == 0 || anyNA(t)) {
      stop("`t` must be a numeric vector without missing values.",
           call. = FALSE)
    }
    len <- max(length(t), length(n))
    t <- rep_len(t, len)
    nn <- rep_len(n, len)
    return(vapply(seq_len(len), function(i) {
      klauer_bf(t[i], nn[i], method, de, args$nu, args$r, p = p)
    }, numeric(1)))
  }

  if (!is.null(t)) {
    stop("For `q` > 1 the test statistic is an F statistic; supply `Fstat`, not `t`.",
         call. = FALSE)
  }
  if (is.null(Fstat) || !is.numeric(Fstat) || length(Fstat) == 0 ||
      anyNA(Fstat) || any(Fstat < 0)) {
    stop("`Fstat` must be a non-negative numeric vector without missing values.",
         call. = FALSE)
  }
  len <- max(length(Fstat), length(n))
  Fs <- rep_len(Fstat, len)
  nn <- rep_len(n, len)
  vapply(seq_len(len), function(i) {
    klauer_bf_F(Fs[i], nn[i], q, p, method, de, args$nu, args$r)
  }, numeric(1))
}
