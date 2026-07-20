# Adversarial checks on the numerical machinery behind the ES/moment
# methods. The anchor tests (test-klauer*.R) validate results at the
# configurations printed in Klauer et al. (2025); the tests here stress the
# quadrature and inversion choices themselves: the u-substitution, the fixed
# integration windows, the log-ratio evaluation with NaN clamping, and the
# normal-limit switch. The oracles below share the prior formulas (which the
# anchors validate) but integrate on the original effect scale with
# stats::integrate over an infinite range, a plain (non-log) density ratio,
# and a tighter tolerance, so none of the package's quadrature choices are
# reused.

oracle_bf_t <- function(t, n, method, de, nu, r = NULL, p = 0) {
  M <- n - p
  prior <- if (method == "ES") {
    function(d) 0.5 * (dt((d + de)/r, nu)/r + dt((d - de)/r, nu)/r)
  } else {
    s <- de * sqrt((nu - 1)/(2 * nu))
    function(d) 2 * (nu - 2)/((nu - 1) * de^2) * d^2 * dt(d/s, nu)/s
  }
  f <- function(d) {
    ratio <- suppressWarnings(dt(t, M - 1, ncp = sqrt(M) * d)/dt(t, M - 1))
    ratio[!is.finite(ratio)] <- 0
    ratio * prior(d)
  }
  integrate(f, -Inf, Inf, rel.tol = 1e-9, subdivisions = 2000L)$value
}

oracle_bf_F <- function(Fstat, n, q, p, method, de, nu, r = NULL) {
  M <- n - p
  df2 <- M - q
  pri <- if (method == "ES") {
    lc <- lgamma((nu + q)/2) - lgamma(nu/2) - lgamma(q/2) +
      (nu/2) * log(nu * r^2)
    function(l2) {
      s <- l2 + de^2 + nu * r^2
      h <- vapply(4 * de^2 * l2/s^2, function(z)
        alphaN:::hyp2f1((nu + q)/4, (2 + nu + q)/4, q/2, z), numeric(1))
      exp(lc - ((nu + q)/2) * log(s)) * h * l2^(q/2 - 1)
    }
  } else {
    k <- (q + nu - 2) * de^2/2
    lc <- log(2 * (nu - 2)/(q * (nu + q - 2) * de^2)) +
      lgamma((nu + q)/2) - lgamma(nu/2) - lgamma(q/2) - (q/2) * log(k)
    function(l2) exp(lc - ((nu + q)/2) * log1p(l2/k)) * l2^(q/2)
  }
  f <- function(l2) {
    ratio <- suppressWarnings(df(Fstat, q, df2, ncp = M * l2)/
                                df(Fstat, q, df2))
    ratio[!is.finite(ratio)] <- 0
    ratio * pri(l2)
  }
  integrate(f, 0, Inf, rel.tol = 1e-9, subdivisions = 2000L)$value
}

test_that("the t-form quadrature matches an independent oracle", {
  configs <- list(
    list(t = 2.5, n = 100,  method = "ES",     de = 0.5, nu = 3, p = 0),
    list(t = 2.5, n = 100,  method = "moment", de = 0.5, nu = 5, p = 0),
    list(t = 0.5, n = 1000, method = "ES",     de = 0.2, nu = 3, p = 0),
    list(t = 4.0, n = 500,  method = "moment", de = 0.8, nu = 5, p = 5),
    list(t = 6.0, n = 2000, method = "ES",     de = 0.5, nu = 3, p = 10)
  )
  for (cf in configs) {
    r <- if (cf$method == "ES") sqrt((cf$nu - 2)/cf$nu) * cf$de else NULL
    got <- alphaN:::klauer_bf(cf$t, cf$n, cf$method, cf$de, cf$nu, r,
                              p = cf$p)
    want <- oracle_bf_t(cf$t, cf$n, cf$method, cf$de, cf$nu, r, p = cf$p)
    expect_lt(abs(got/want - 1), 1e-4)
  }
})

test_that("the F-form quadrature matches an independent oracle", {
  r <- sqrt((3 - 2)/(3 * 2)) * 0.3
  got <- alphaN:::klauer_bf_F(2, 300, q = 2, p = 3, method = "ES",
                              de = 0.3, nu = 3, r = r)
  want <- oracle_bf_F(2, 300, q = 2, p = 3, method = "ES",
                      de = 0.3, nu = 3, r = r)
  expect_lt(abs(got/want - 1), 1e-4)

  got_m <- alphaN:::klauer_bf_F(3, 150, q = 3, p = 4, method = "moment",
                                de = 0.4, nu = 7)
  want_m <- oracle_bf_F(3, 150, q = 3, p = 4, method = "moment",
                        de = 0.4, nu = 7)
  expect_lt(abs(got_m/want_m - 1), 1e-4)
})

test_that("the normal-limit branch agrees with the quadrature at the same M", {
  # klauer_bf branches on M = n - p, so (n0, p = 1) runs the exact-t
  # quadrature at M = 50000 while (n0, p = 0) runs the normal limit at
  # M = 50001: a direct measurement of the branch discontinuity at
  # essentially the same sample size (the O(1/M) effect of one observation
  # is orders of magnitude below the tolerance).
  n0 <- 50001
  for (m in c("ES", "moment")) {
    r <- if (m == "ES") sqrt(1/3) * 0.5 else NULL
    exact <- alphaN:::klauer_bf(2, n0, m, 0.5, if (m == "ES") 3 else 5, r,
                                p = 1)
    limit <- alphaN:::klauer_bf(2, n0, m, 0.5, if (m == "ES") 3 else 5, r,
                                p = 0)
    expect_lt(abs(limit/exact - 1), 0.005)
  }
  exact_F <- alphaN:::klauer_bf_F(3, 50003, q = 2, p = 3, method = "moment",
                                  de = 0.4, nu = 6)
  limit_F <- alphaN:::klauer_bf_F(3, 50003, q = 2, p = 2, method = "moment",
                                  de = 0.4, nu = 6)
  expect_lt(abs(limit_F/exact_F - 1), 0.005)
})

test_that("alpha is monotone over an (n, BF, de, q, p) grid", {
  n_grid <- c(60, 100, 300, 1000, 5000, 1e5)  # crosses the 5e4 switch
  for (m in c("ES", "moment")) {
    for (de in c(0.2, 0.8)) {
      a <- alphaN(n_grid, BF = 3, method = m, de = de)
      expect_true(all(diff(a) < 0))
      expect_true(all(a > 0 & a <= 1))
    }
  }
  a_bf <- alphaN(500, BF = c(1, 3, 10, 30, 100), method = "ES", de = 0.5)
  expect_true(all(diff(a_bf) < 0))
  a_q <- alphaN(c(60, 200, 1000, 61000), BF = 3, method = "moment",
                q = 3, p = 5, de = 0.4)
  expect_true(all(diff(a_q) < 0))
  expect_true(all(a_q > 0 & a_q <= 1))
})

test_that("the Bayes factor increases in the test statistic", {
  bf_t <- klauerBF(n = 500, t = c(0.5, 1, 2, 4, 8), de = 0.5)
  expect_true(all(diff(bf_t) > 0))
  bf_F <- vapply(c(1, 2, 4, 8, 16), function(Fs)
    klauerBF(n = 100, Fstat = Fs, q = 3, p = 4, method = "moment",
             de = 0.4), numeric(1))
  expect_true(all(diff(bf_F) > 0))
})

test_that("round trips recover the target across branches and forms", {
  # Exact-t branch with p > 0
  a1 <- alphaN(104, BF = 3, method = "ES", de = 0.5, p = 4)
  t1 <- qt(1 - a1/2, df = 104 - 4 - 1)
  expect_lt(abs(klauerBF(n = 104, t = t1, p = 4, de = 0.5)/3 - 1), 1e-3)
  # Normal-limit branch at an extreme target
  a2 <- alphaN(1e5, BF = 100, method = "moment", de = 0.5)
  expect_true(a2 > 0 && a2 < 1e-4)
  t2 <- qt(1 - a2/2, df = 1e5 - 1)
  expect_lt(abs(klauerBF(n = 1e5, t = t2, method = "moment",
                         de = 0.5)/100 - 1), 1e-3)
  # F form with small residual degrees of freedom
  a3 <- alphaN(20, BF = 3, method = "moment", q = 3, p = 5, de = 0.4)
  expect_true(a3 > 0 && a3 <= 1)
  if (a3 < 1) {
    F3 <- qf(1 - a3, 3, 20 - 5 - 3)
    expect_lt(abs(klauerBF(n = 20, Fstat = F3, q = 3, p = 5,
                           method = "moment", de = 0.4)/3 - 1), 1e-3)
  }
})
