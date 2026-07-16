# Tests for the effective-sample-size helper (Wulff & Taylor, 2024, Table 1).

test_that("n_effective reproduces the Wulff & Taylor example", {
  # A cluster-robust SE twice the classical one implies an effective sample
  # four times smaller: 237 -> about 59 (their Example 3 check).
  expect_equal(n_effective(237, se = 0.1, se_robust = 0.2), 59.25)
})

test_that("n_effective is vectorized with recycling", {
  expect_equal(n_effective(c(100, 200), se = 1, se_robust = c(1, 2)),
               c(100, 50))
})

test_that("n_effective equals n when the two standard errors agree", {
  expect_equal(n_effective(1234, 0.37, 0.37), 1234)
})

test_that("n_effective input validation gives informative errors", {
  expect_error(n_effective(-5, 0.1, 0.2), "positive")
  expect_error(n_effective(100, 0, 0.2), "positive")
  expect_error(n_effective(100, 0.1, Inf), "finite")
})
