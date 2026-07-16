# Effect-size and moment Bayes factors (Klauer, Meyer-Grant & Kellen, 2025,
# Psychonomic Bulletin & Review, 32, 1070-1094,
# doi:10.3758/s13423-024-02612-2) and their inversion to alpha levels.
# Internal.
#
# One-sample / single-coefficient case (Table 4 of the paper, t form):
#   B10 = Int dt(t | M - 1, ncp = sqrt(M) d) / dt(t | M - 1, 0) * pi(d) dd
# with M = n - p the effective sample size (p = number of retained model
# parameters, 0 for the one-sample test) and pi(d) the prior on the
# standardized effect size d:
#   effect size: pi_E(d) = ( ft(d | nu, -de, r) + ft(d | nu, de, r) ) / 2
#   moment:      pi_M(d) = 2(nu-2)/((nu-1) de^2) d^2 ft(d | nu, 0, s),
#                s = de sqrt((nu-1)/(2 nu))
# where ft(. | nu, m, s) is the scaled and shifted t density.
#
# Regression/ANOVA case (Table 4, F form): a reduced model with p parameters
# (including any intercept) against the full model with p + q parameters,
# tested by F with (q, M - q) degrees of freedom, M = n - p. The priors sit
# on l2 = lambda^2, the noncentrality standardized by M (Cohen's f^2 scale):
#   B10 = Int_0^Inf dF(F | q, M-q, ncp = M l2) / dF(F | q, M-q, 0) pi(l2) dl2
#   pi_E(l2) = G((nu+q)/2)/(G(nu/2) G(q/2)) (nu r^2)^(nu/2) l2^(q/2-1)
#              (l2 + fe^2 + nu r^2)^(-(nu+q)/2)
#              2F1((nu+q)/4, (2+nu+q)/4; q/2; 4 fe^2 l2/(l2+fe^2+nu r^2)^2)
#   pi_M(l2) = 2(nu-2)/(q(nu+q-2) fe^2) G((nu+q)/2)/(G(nu/2) G(q/2))
#              (l2/k)^(q/2) (1 + l2/k)^(-(nu+q)/2) / k * k,
#              k = (q+nu-2) fe^2 / 2
# with fe the prespecified effect size on Cohen's f scale (f = |d| for
# q = 1). Recommended settings: ES nu = 3, r = sqrt((nu-2)/(nu q)) fe;
# moment nu = 5 + (q - 1).

# Scaled and shifted t density
ft_scaled <- function(x, nu, mean, scale) {
  dt((x - mean)/scale, df = nu)/scale
}

# log of dt(t | df, ncp)/dt(t | df, 0). R's noncentral t density is a
# difference of two CDF calls and can cancel to NaN deep in the tails, where
# the true ratio is effectively zero -> clamp to -Inf.
lratio_t <- function(t, df, ncp) {
  lr <- suppressWarnings(dt(t, df = df, ncp = ncp, log = TRUE) -
                           dt(t, df = df, log = TRUE))
  lr[!is.finite(lr)] <- -Inf
  lr
}

# Large-n (normal) limit of the same log ratio:
# log dnorm(t, ncp, 1) - log dnorm(t, 0, 1)
lratio_norm <- function(t, ncp) {
  t*ncp - ncp^2/2
}

# Above this sample size the noncentral t density ratio is evaluated in its
# normal limit: R's dnt carries too much numerical noise at extreme df, and
# the limit is accurate to a fraction of a percent there.
.klauer_normal_switch <- 50000

#' Effect-size or moment Bayes factor from a t-statistic
#'
#' Integrates over u = sqrt(n) d (the noncentrality parameter) so that the
#' density-ratio factor varies on an O(1) scale for every n. The integration
#' bounds +/-(|t| + 45) are conservative: beyond them the density ratio has
#' decayed below the double-precision floor.
#'
#' @param t t-statistic (scalar).
#' @param n Sample size (scalar).
#' @param method "ES" or "moment".
#' @param de Prespecified effect size.
#' @param nu Degrees of freedom of the prior.
#' @param r Scale of the prior mixture components ("ES" only).
#' @param p Number of retained model parameters; the effective sample size
#'   M = n - p drives the degrees of freedom and the noncentrality.
#' @return The Bayes factor in favour of H1 (scalar).
#' @importFrom stats dt dnorm integrate df pf dchisq
#' @noRd
klauer_bf <- function(t, n, method, de, nu, r = NULL, p = 0) {
  prior <- if (method == "ES") {
    function(d) 0.5*(ft_scaled(d, nu, -de, r) + ft_scaled(d, nu, de, r))
  } else {
    s <- de*sqrt((nu - 1)/(2*nu))
    function(d) 2*(nu - 2)/((nu - 1)*de^2) * d^2 * ft_scaled(d, nu, 0, s)
  }

  M <- n - p
  sn <- sqrt(M)
  lim <- abs(t) + 45
  kernel <- function(lr_fun) {
    integrate(function(u) exp(lr_fun(u)) * prior(u/sn)/sn,
              lower = -lim, upper = lim,
              rel.tol = 1e-6, subdivisions = 500L)$value
  }

  if (M > .klauer_normal_switch) {
    return(kernel(function(u) lratio_norm(t, u)))
  }
  tryCatch(suppressWarnings(kernel(function(u) lratio_t(t, M - 1, u))),
           error = function(e) kernel(function(u) lratio_norm(t, u)))
}

#' Validate and resolve the ES/moment prior settings
#'
#' Fills in the recommended defaults of Klauer et al. (2025): nu = 3 and
#' r = sqrt((nu - 2)/(nu q)) de for "ES", nu = 5 + (q - 1) for "moment".
#'
#' @return list(nu = ..., r = ...)
#' @noRd
resolve_klauer_args <- function(n, method, de, nu, r, q = 1, p = 0) {
  if (!is.numeric(q) || length(q) != 1 || !is.finite(q) || q < 1 ||
      q != round(q)) {
    stop("`q` must be a single positive integer.", call. = FALSE)
  }
  if (!is.numeric(p) || length(p) != 1 || !is.finite(p) || p < 0 ||
      p != round(p)) {
    stop("`p` must be a single non-negative integer.", call. = FALSE)
  }
  if (!is.numeric(de) || length(de) != 1 || !is.finite(de) || de < 0) {
    stop("`de` must be a single non-negative number.", call. = FALSE)
  }
  if (is.null(nu)) nu <- if (method == "ES") 3 else 5 + (q - 1)
  if (!is.numeric(nu) || length(nu) != 1 || !is.finite(nu)) {
    stop("`nu` must be a single number.", call. = FALSE)
  }

  if (method == "moment") {
    if (de == 0) {
      stop("`de` must be positive for method = \"moment\".", call. = FALSE)
    }
    if (nu <= 2) {
      stop("`nu` must be larger than 2 for method = \"moment\".", call. = FALSE)
    }
  } else {
    if (nu < 1) {
      stop("`nu` must be at least 1 for method = \"ES\".", call. = FALSE)
    }
    if (is.null(r)) {
      if (nu <= 2 || de == 0) {
        stop("For method = \"ES\" with `nu` <= 2 or `de` = 0, supply the prior scale `r` explicitly.",
             call. = FALSE)
      }
      r <- sqrt((nu - 2)/(nu*q))*de
    }
    if (!is.numeric(r) || length(r) != 1 || !is.finite(r) || r <= 0) {
      stop("`r` must be a single positive number.", call. = FALSE)
    }
  }

  if (!is.numeric(n) || length(n) == 0 || !all(is.finite(n)) || any(n <= 0)) {
    stop("`n` must be a positive, finite numeric vector.", call. = FALSE)
  }
  # Consistency-in-information bounds of Klauer et al. (2025): for regression
  # and ANOVA, n >= p + q + nu (ES) and n >= p + q + nu - 2 (moment); the
  # one-sample case is p = 0, q = 1. The p + q + 1 floor keeps the residual
  # degrees of freedom positive.
  n_min <- if (method == "ES") max(p + q + nu, p + q + 1) else
    max(p + q + nu - 2, p + q + 1)
  if (any(n < n_min)) {
    stop("For method = \"", method, "\" with nu = ", nu, ", q = ", q,
         ", and p = ", p, ", `n` must be at least ", n_min,
         " for the Bayes factor to be invertible (consistency in information; ",
         "Klauer et al., 2025).", call. = FALSE)
  }

  list(nu = nu, r = r)
}

# ---------------------------------------------------------------------------
# Regression/ANOVA case: F-statistic Bayes factors for a joint test of q
# coefficients, and their inversion.

#' Gaussian hypergeometric function 2F1(a, b; c; z) for 0 <= z < 1
#'
#' Direct series. In the effect-size prior, z = 4 fe^2 l2/(l2 + fe^2 +
#' nu r^2)^2 is bounded by fe^2/(fe^2 + nu r^2) < 1 (maximized at
#' l2 = fe^2 + nu r^2), so the series converges geometrically; under the
#' recommended r the bound is q/(q + nu - 2).
#'
#' @noRd
hyp2f1 <- function(a, b, cc, z, tol = 1e-12, max_terms = 200000L) {
  if (z == 0) return(1)
  term <- 1
  s <- 1
  for (k in 0:max_terms) {
    term <- term*(a + k)*(b + k)/((cc + k)*(k + 1))*z
    s <- s + term
    if (abs(term) < tol*abs(s)) return(s)
  }
  stop("The hypergeometric series did not converge; this can happen when `r` ",
       "is chosen very small relative to `de`.", call. = FALSE)
}

# log of dF(F | q, df2, ncp)/dF(F | q, df2, 0); NaN tails clamped to -Inf as
# in lratio_t().
lratio_F <- function(Fstat, q, df2, ncp) {
  lr <- suppressWarnings(df(Fstat, q, df2, ncp = ncp, log = TRUE) -
                           df(Fstat, q, df2, log = TRUE))
  lr[!is.finite(lr)] <- -Inf
  lr
}

# Large-M limit of the same ratio: q F_{q, M-q} -> chi-square_q, so the ratio
# tends to dchisq(q F, q, ncp)/dchisq(q F, q).
lratio_chisq <- function(Fstat, q, ncp) {
  lr <- suppressWarnings(dchisq(q*Fstat, q, ncp = ncp, log = TRUE) -
                           dchisq(q*Fstat, q, log = TRUE))
  lr[!is.finite(lr)] <- -Inf
  lr
}

#' Effect-size or moment Bayes factor from an F statistic (regression/ANOVA)
#'
#' Integrates over u = sqrt(M l2), the square root of the noncentrality, so
#' the density-ratio factor is O(1)-wide for every M; bounds 0 to sqrt(qF) +
#' 45 are conservative. The l2 powers of the priors combine with the
#' Jacobian 2u/M into a u^(2e+1) factor, which removes the q = 1 endpoint
#' singularity of the ES prior.
#'
#' @param Fstat F statistic (scalar).
#' @param n Sample size (scalar).
#' @param q Number of coefficients tested jointly.
#' @param p Number of retained model parameters (including any intercept).
#' @param method "ES" or "moment".
#' @param de Prespecified effect size on Cohen's f scale.
#' @param nu Degrees of freedom of the prior.
#' @param r Scale of the prior ("ES" only).
#' @return The Bayes factor in favour of H1 (scalar).
#' @noRd
klauer_bf_F <- function(Fstat, n, q, p, method, de, nu, r = NULL) {
  M <- n - p
  df2 <- M - q

  if (method == "ES") {
    e <- q/2 - 1
    lc <- lgamma((nu + q)/2) - lgamma(nu/2) - lgamma(q/2) +
      (nu/2)*log(nu*r^2)
    lshape <- function(l2) {
      s <- l2 + de^2 + nu*r^2
      z <- 4*de^2*l2/s^2
      h <- vapply(z, function(zz)
        hyp2f1((nu + q)/4, (2 + nu + q)/4, q/2, zz), numeric(1))
      lc - ((nu + q)/2)*log(s) + log(h)
    }
  } else {
    e <- q/2
    k <- (q + nu - 2)*de^2/2
    lc <- log(2*(nu - 2)/(q*(nu + q - 2)*de^2)) +
      lgamma((nu + q)/2) - lgamma(nu/2) - lgamma(q/2) - (q/2)*log(k)
    lshape <- function(l2) lc - ((nu + q)/2)*log1p(l2/k)
  }

  lim <- sqrt(q*Fstat) + 45
  upow <- 2*e + 1
  kernel <- function(lr_fun) {
    integrate(function(u) {
      lpw <- if (upow == 0) 0 else upow*log(u)
      exp(lr_fun(u^2) + lshape(u^2/M) + lpw - (e + 1)*log(M) + log(2))
    }, lower = 0, upper = lim, rel.tol = 1e-6, subdivisions = 500L)$value
  }

  if (M > .klauer_normal_switch) {
    return(kernel(function(ncp) lratio_chisq(Fstat, q, ncp)))
  }
  tryCatch(suppressWarnings(kernel(function(ncp) lratio_F(Fstat, q, df2, ncp))),
           error = function(e2) kernel(function(ncp) lratio_chisq(Fstat, q, ncp)))
}

#' Alpha level calibrated to the F-statistic Bayes factors
#'
#' Solves for the critical F at which the Bayes factor equals `BF` and
#' converts it to a p-value on the F distribution with (q, n - p - q)
#' degrees of freedom. Vectorized over `n` and `BF` (recycled).
#'
#' @return Numeric vector of alpha levels.
#' @noRd
klauer_alpha_F <- function(n, BF, q, p, method, de, nu, r) {
  args <- resolve_klauer_args(n, method, de, nu, r, q = q, p = p)

  len <- max(length(n), length(BF))
  n <- rep_len(n, len)
  BF <- rep_len(BF, len)

  vapply(seq_len(len), function(i) {
    bf_i <- function(Fs) klauer_bf_F(Fs, n[i], q, p, method, de,
                                     args$nu, args$r)
    # The central F density is singular at 0 for q = 1, so probe just inside
    if (bf_i(1e-8) >= BF[i]) return(1)
    F_crit <- uniroot(function(Fs) log(bf_i(Fs)) - log(BF[i]),
                      interval = c(1e-8, 150), extendInt = "upX",
                      tol = 1e-8)$root
    pf(F_crit, q, n[i] - p - q, lower.tail = FALSE)
  }, numeric(1))
}

#' Alpha level calibrated to the effect-size or moment Bayes factor
#'
#' For q = 1, solves for the critical t at which the Bayes factor equals
#' `BF` and converts it to a two-sided p-value on the t distribution with
#' n - p - 1 degrees of freedom; for q > 1, dispatches to the F form.
#' Vectorized over `n` and `BF` (recycled).
#'
#' @return Numeric vector of alpha levels.
#' @importFrom stats pt uniroot
#' @noRd
klauer_alpha <- function(n, BF, method, de, nu, r, q = 1, p = 0) {
  if (q > 1) {
    return(klauer_alpha_F(n, BF, q, p, method, de, nu, r))
  }
  args <- resolve_klauer_args(n, method, de, nu, r, q = q, p = p)

  len <- max(length(n), length(BF))
  n <- rep_len(n, len)
  BF <- rep_len(BF, len)

  vapply(seq_len(len), function(i) {
    bf_i <- function(t) klauer_bf(t, n[i], method, de, args$nu, args$r, p = p)
    # If even t = 0 meets the evidence target, any result does: alpha = 1
    if (bf_i(0) >= BF[i]) return(1)
    t_crit <- uniroot(function(t) log(bf_i(t)) - log(BF[i]),
                      interval = c(0, 12), extendInt = "upX", tol = 1e-8)$root
    2*pt(t_crit, df = n[i] - p - 1, lower.tail = FALSE)
  }, numeric(1))
}
