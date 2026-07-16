# Tests for the exported klauerBF() converter (t form, q = 1).

test_that("klauerBF reproduces Table 7 of Klauer et al. (2025)", {
  # Same anchors as test-klauer.R, driven through the exported interface.
  tab <- expand.grid(t = c(2.03, 2.24), de = c(0.2, 0.5, 0.8))
  tab$es  <- c(2.52, 3.70, 0.98, 1.58, 0.51, 0.80)
  tab$mom <- c(2.13, 3.26, 0.58, 0.99, 0.19, 0.34)
  tab$tol <- c(0.006, 0.006, 0.006, 0.015, 0.006, 0.006)
  for (i in seq_len(nrow(tab))) {
    es <- klauerBF(n = 80, t = tab$t[i], de = tab$de[i])
    mo <- klauerBF(n = 80, t = tab$t[i], method = "moment", de = tab$de[i])
    expect_lt(abs(es - tab$es[i]), tab$tol[i])
    expect_lt(abs(mo - tab$mom[i]), 0.006)
  }
})

test_that("klauerBF recovers the default (JZS-type) Bayes factor", {
  expect_lt(abs(klauerBF(80, t = 2.03, de = 0, nu = 1, r = 1) - 0.64), 0.006)
  expect_lt(abs(klauerBF(80, t = 2.24, de = 0, nu = 1, r = 1) - 0.98), 0.006)
})

test_that("klauerBF accepts Fstat as the squared t for q = 1", {
  expect_equal(klauerBF(80, Fstat = 2.24^2, de = 0.5),
               klauerBF(80, t = 2.24, de = 0.5), tolerance = 1e-10)
})

test_that("klauerBF is vectorized over t and n", {
  ts <- c(1.5, 2.24)
  expect_equal(klauerBF(80, t = ts, de = 0.5),
               vapply(ts, function(t) klauerBF(80, t = t, de = 0.5),
                      numeric(1)))
  ns <- c(80, 200)
  expect_equal(klauerBF(ns, t = 2, de = 0.5),
               vapply(ns, function(n) klauerBF(n, t = 2, de = 0.5),
                      numeric(1)))
})

test_that("klauerBF matches what alphaN inverts", {
  a <- alphaN(500, BF = 3, method = "ES", de = 0.5)
  t_crit <- qt(1 - a/2, df = 499)
  expect_equal(klauerBF(500, t = t_crit, de = 0.5), 3, tolerance = 1e-4)
})

test_that("klauerBF input validation gives informative errors", {
  expect_error(klauerBF(80, de = 0.5), "exactly one")
  expect_error(klauerBF(80, t = 2, Fstat = 4, de = 0.5), "exactly one")
  expect_error(klauerBF(80, t = 2, q = 2, p = 1), "supply `Fstat`")
  expect_error(klauerBF(80, q = 2, p = 1), "Fstat")
  expect_error(klauerBF(80, Fstat = -1, de = 0.5), "non-negative")
  expect_error(klauerBF(80, t = NA_real_, de = 0.5), "missing")
  expect_error(klauerBF(80, t = 2, method = "JAB"), "should be one of")
})
