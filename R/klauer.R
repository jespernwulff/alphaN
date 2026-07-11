# Effect-size and moment Bayes factors (Klauer, Meyer-Grant & Kellen, 2024,
# Psychonomic Bulletin & Review, doi:10.3758/s13423-024-02612-2) and their
# inversion to alpha levels. Internal.
#
# Both Bayes factors have the test-statistic form (Table 4 of the paper,
# one-sample / single-coefficient case):
#   B10 = Int dt(t | n - 1, ncp = sqrt(n) d) / dt(t | n - 1, 0) * pi(d) dd
# with pi(d) the prior on the standardized effect size d:
#   effect size: pi_E(d) = ( ft(d | nu, -de, r) + ft(d | nu, de, r) ) / 2
#   moment:      pi_M(d) = 2(nu-2)/((nu-1) de^2) d^2 ft(d | nu, 0, s),
#                s = de sqrt((nu-1)/(2 nu))
# where ft(. | nu, m, s) is the scaled and shifted t density.

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
#' @return The Bayes factor in favour of H1 (scalar).
#' @importFrom stats dt dnorm integrate
#' @noRd
klauer_bf <- function(t, n, method, de, nu, r = NULL) {
  prior <- if (method == "ES") {
    function(d) 0.5*(ft_scaled(d, nu, -de, r) + ft_scaled(d, nu, de, r))
  } else {
    s <- de*sqrt((nu - 1)/(2*nu))
    function(d) 2*(nu - 2)/((nu - 1)*de^2) * d^2 * ft_scaled(d, nu, 0, s)
  }

  sn <- sqrt(n)
  lim <- abs(t) + 45
  kernel <- function(lr_fun) {
    integrate(function(u) exp(lr_fun(u)) * prior(u/sn)/sn,
              lower = -lim, upper = lim,
              rel.tol = 1e-6, subdivisions = 500L)$value
  }

  if (n > .klauer_normal_switch) {
    return(kernel(function(u) lratio_norm(t, u)))
  }
  tryCatch(suppressWarnings(kernel(function(u) lratio_t(t, n - 1, u))),
           error = function(e) kernel(function(u) lratio_norm(t, u)))
}

#' Validate and resolve the ES/moment prior settings
#'
#' Fills in the recommended defaults of Klauer et al. (2024): nu = 3 and
#' r = sqrt((nu - 2)/nu) de for "ES", nu = 5 for "moment".
#'
#' @return list(nu = ..., r = ...)
#' @noRd
resolve_klauer_args <- function(n, method, de, nu, r) {
  if (!is.numeric(de) || length(de) != 1 || !is.finite(de) || de < 0) {
    stop("`de` must be a single non-negative number.", call. = FALSE)
  }
  if (is.null(nu)) nu <- if (method == "ES") 3 else 5
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
      r <- sqrt((nu - 2)/nu)*de
    }
    if (!is.numeric(r) || length(r) != 1 || !is.finite(r) || r <= 0) {
      stop("`r` must be a single positive number.", call. = FALSE)
    }
  }

  if (!is.numeric(n) || length(n) == 0 || !all(is.finite(n)) || any(n <= 0)) {
    stop("`n` must be a positive, finite numeric vector.", call. = FALSE)
  }
  n_min <- if (method == "ES") nu + 1 else max(nu - 1, 2)
  if (any(n < n_min)) {
    stop("For method = \"", method, "\" with nu = ", nu, ", `n` must be at least ",
         n_min, " for the Bayes factor to be invertible (consistency in information; ",
         "Klauer et al., 2024).", call. = FALSE)
  }

  list(nu = nu, r = r)
}

#' Alpha level calibrated to the effect-size or moment Bayes factor
#'
#' Solves for the critical t at which the Bayes factor equals `BF` and
#' converts it to a two-sided p-value on the t distribution with n - 1
#' degrees of freedom. Vectorized over `n` and `BF` (recycled).
#'
#' @return Numeric vector of alpha levels.
#' @importFrom stats pt uniroot
#' @noRd
klauer_alpha <- function(n, BF, method, de, nu, r) {
  args <- resolve_klauer_args(n, method, de, nu, r)

  len <- max(length(n), length(BF))
  n <- rep_len(n, len)
  BF <- rep_len(BF, len)

  vapply(seq_len(len), function(i) {
    bf_i <- function(t) klauer_bf(t, n[i], method, de, args$nu, args$r)
    # If even t = 0 meets the evidence target, any result does: alpha = 1
    if (bf_i(0) >= BF[i]) return(1)
    t_crit <- uniroot(function(t) log(bf_i(t)) - log(BF[i]),
                      interval = c(0, 12), extendInt = "upX", tol = 1e-8)$root
    2*pt(t_crit, df = n[i] - 1, lower.tail = FALSE)
  }, numeric(1))
}
