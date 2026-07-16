# Tests for the regression/ANOVA (F-form) effect-size and moment Bayes
# factors of Klauer, Meyer-Grant & Kellen (2025) and their inversion.

test_that("F form reproduces Table 8 of Klauer et al. (2025)", {
  # Bailey & Geary (2009) cranial-capacity data via Rouder & Morey (2012):
  # N = 175, full model = 4 predictors + intercept. Reduced models: M2 and
  # M4 drop one predictor (q = 1, p = 4), M9 drops two (q = 2, p = 3). F is
  # recovered from the printed partial R^2 (rounded to 4 digits, hence the
  # looser tolerance for M4, whose R2p = .0002 has one significant digit;
  # see the note under Klauer et al.'s Table 8). Printed values are B01;
  # the implementation returns B10. Effect sizes follow Cohen (1988, Chap.
  # 9): f^2 = 0.02, 0.15, 0.35 for small, medium, large.
  N <- 175
  fe <- sqrt(c(0.02, 0.15, 0.35))
  cases <- list(
    list(p = 4, q = 1, R2p = 0.0126, rtol = 0.015,
         es = c(1.00, 3.48, 5.92),   mom = c(1.36, 8.49, 25.30)),
    list(p = 4, q = 1, R2p = 0.0002, rtol = 0.06,
         es = c(3.36, 11.76, 18.71), mom = c(6.37, 66.98, 218.63)),
    list(p = 3, q = 2, R2p = 0.0136, rtol = 0.015,
         es = c(1.66, 14.77, 41.07), mom = c(3.26, 49.26, 222.66)))
  for (cs in cases) {
    Fs <- (cs$R2p/cs$q)*(N - cs$p - cs$q)/(1 - cs$R2p)
    for (j in 1:3) {
      b_es <- klauerBF(N, Fstat = Fs, q = cs$q, p = cs$p, de = fe[j])
      b_mo <- klauerBF(N, Fstat = Fs, q = cs$q, p = cs$p,
                       method = "moment", de = fe[j])
      expect_lt(abs(1/b_es - cs$es[j])/cs$es[j], cs$rtol)
      expect_lt(abs(1/b_mo - cs$mom[j])/cs$mom[j], cs$rtol)
    }
  }
})

test_that("the q = 1 F form agrees with the t form", {
  for (m in c("ES", "moment")) {
    bt <- klauerBF(80, t = 2.24, method = m, de = 0.5)
    bF <- alphaN:::klauer_bf_F(2.24^2, 80, q = 1, p = 0, m, de = 0.5,
                               nu = if (m == "ES") 3 else 5,
                               r = if (m == "ES") sqrt(1/3)*0.5 else NULL)
    expect_equal(bt, bF, tolerance = 1e-8)
  }
})

test_that("the p argument shifts the effective sample size", {
  expect_equal(klauerBF(104, t = 2, p = 4, de = 0.5),
               klauerBF(100, t = 2, p = 0, de = 0.5), tolerance = 1e-10)
  expect_equal(alphaN(104, BF = 3, method = "ES", p = 4),
               2*pt(qt(1 - alphaN(100, BF = 3, method = "ES")/2, df = 99),
                    df = 99, lower.tail = FALSE),
               tolerance = 1e-8)
})

test_that("alphaN inverts the F-form Bayes factors for q > 1", {
  for (m in c("ES", "moment")) {
    a <- alphaN(200, BF = 3, method = m, q = 2, p = 2, de = sqrt(0.15))
    F_crit <- qf(1 - a, df1 = 2, df2 = 196)
    expect_equal(klauerBF(200, Fstat = F_crit, q = 2, p = 2, method = m,
                          de = sqrt(0.15)), 3, tolerance = 1e-4)
  }
})

test_that("q > 1 alphas decrease in n and alpha = 1 short-circuits", {
  a <- alphaN(c(100, 1000), BF = 3, method = "moment", q = 2, p = 2,
              de = sqrt(0.15))
  expect_true(all(diff(a) < 0))
  expect_equal(alphaN(50, BF = 0.01, method = "ES", q = 2, p = 2,
                      de = sqrt(0.15)), 1)
})

test_that("the large-M chi-square limit joins the exact-F branch smoothly", {
  # The moment q = 2 alpha genuinely falls ~7% over this n gap; the branch
  # switch itself contributes < 0.3% (measured against the forced limit).
  a_lo <- alphaN(49000, BF = 3, method = "moment", q = 2, p = 2,
                 de = sqrt(0.15))
  a_hi <- alphaN(51000, BF = 3, method = "moment", q = 2, p = 2,
                 de = sqrt(0.15))
  expect_lt(abs(a_hi/a_lo - 1), 0.10)
  expect_lt(a_hi, a_lo)
})

test_that("regression-case input validation gives informative errors", {
  expect_error(alphaN(100, method = "JAB", q = 2), "apply only")
  expect_error(alphaN(100, method = "min", p = 2), "apply only")
  expect_error(alphaN(100, method = "ES", q = 1.5), "positive integer")
  expect_error(alphaN(100, method = "ES", p = -1), "non-negative integer")
  expect_error(alphaN(6, method = "ES", q = 2, p = 2), "at least")
  expect_error(alphaN(7, method = "moment", q = 2, p = 2, nu = 6), "at least")
})
