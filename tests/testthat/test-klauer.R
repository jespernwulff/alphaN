# Tests for the effect-size ("ES") and moment Bayes factor methods of
# Klauer, Meyer-Grant & Kellen (2024, Psychonomic Bulletin & Review).

test_that("Bayes factors reproduce Table 7 of Klauer et al. (2024)", {
  # One-sample t tests with t(79), i.e. n = 80, from Grider & Malmberg data.
  # Printed values are rounded to two decimals -> tolerance 0.006. The ES cell
  # at t = 2.24, de = 0.5 gets 0.015: we compute 1.568 (i.e. 1.57), while the
  # paper prints 1.58. The other eleven cells and the JZS special case all
  # match to print rounding at t = 2.24 (and no in-rounding t reconciles all
  # cells at once), so the printed 1.58 appears to be off in its last digit.
  tab <- expand.grid(t = c(2.03, 2.24), de = c(0.2, 0.5, 0.8))
  tab$es  <- c(2.52, 3.70, 0.98, 1.58, 0.51, 0.80)
  tab$mom <- c(2.13, 3.26, 0.58, 0.99, 0.19, 0.34)
  tab$tol <- c(0.006, 0.006, 0.006, 0.015, 0.006, 0.006)
  for (i in seq_len(nrow(tab))) {
    es <- klauer_bf(tab$t[i], 80, "ES", de = tab$de[i], nu = 3,
                    r = sqrt(1/3)*tab$de[i])
    mo <- klauer_bf(tab$t[i], 80, "moment", de = tab$de[i], nu = 5)
    expect_lt(abs(es - tab$es[i]), tab$tol[i])
    expect_lt(abs(mo - tab$mom[i]), 0.006)
  }
})

test_that("nu = 1, de = 0 recovers the default (JZS-type) Bayes factor", {
  # Rouder et al. (2009) values with r = 1, printed in Table 7 of Klauer et al.
  expect_lt(abs(klauer_bf(2.03, 80, "ES", de = 0, nu = 1, r = 1) - 0.64), 0.006)
  expect_lt(abs(klauer_bf(2.24, 80, "ES", de = 0, nu = 1, r = 1) - 0.98), 0.006)
})

test_that("alphaN methods ES and moment invert their Bayes factors", {
  for (m in c("ES", "moment")) {
    for (bf in c(1, 3)) {
      a <- alphaN(500, BF = bf, method = m, de = 0.5)
      t_crit <- qt(1 - a/2, df = 499)
      nu <- if (m == "ES") 3 else 5
      r <- if (m == "ES") sqrt(1/3)*0.5 else NULL
      expect_equal(klauer_bf(t_crit, 500, m, de = 0.5, nu = nu, r = r), bf,
                   tolerance = 1e-4)
    }
  }
})

test_that("ES and moment alphas decrease in n and BF, vectorized", {
  ns <- c(100, 1000)
  for (m in c("ES", "moment")) {
    a_vec <- alphaN(ns, BF = 3, method = m)
    a_ele <- vapply(ns, function(n) alphaN(n, BF = 3, method = m), numeric(1))
    expect_equal(a_vec, a_ele)
    expect_true(all(diff(a_vec) < 0))
    expect_gt(alphaN(1000, BF = 1, method = m), alphaN(1000, BF = 10, method = m))
  }
})

test_that("moment alpha falls much faster in n than JAB alpha", {
  expect_lt(alphaN(10000, BF = 1, method = "moment", de = 0.5),
            alphaN(10000, BF = 1)/10)
})

test_that("large-n normal limit joins the exact-t branch smoothly", {
  # .klauer_normal_switch is 50000; compare alphas just below and above
  a_lo <- alphaN(49000, BF = 3, method = "ES", de = 0.5)
  a_hi <- alphaN(51000, BF = 3, method = "ES", de = 0.5)
  expect_lt(abs(a_hi/a_lo - 1), 0.05)
  expect_lt(a_hi, a_lo)  # still decreasing across the switch
})

test_that("ES/moment input validation gives informative errors", {
  expect_error(alphaN(1000, method = "ES", de = -0.2), "de")
  expect_error(alphaN(1000, method = "moment", de = 0), "de")
  expect_error(alphaN(1000, method = "moment", nu = 2), "nu")
  expect_error(alphaN(1000, method = "ES", nu = 1), "supply the prior scale")
  expect_error(alphaN(1000, method = "ES", de = 0), "supply the prior scale")
  expect_error(alphaN(1000, method = "ES", r = -1), "r")
  expect_error(alphaN(3, method = "ES"), "at least")
  expect_error(alphaN(-10, method = "ES"), "positive")
  # methods "ES"/"moment" are not available in the JAB-family functions
  expect_error(JABt(100, 2, method = "ES"), "should be one of")
  expect_error(JAB_plot(100, method = "ES"), "should be one of")
})

test_that("alpha = 1 when even t = 0 exceeds the evidence target", {
  # At tiny BF targets the Bayes factor at t = 0 can already exceed BF
  expect_equal(alphaN(100, BF = 0.01, method = "ES", de = 0.5), 1)
})
