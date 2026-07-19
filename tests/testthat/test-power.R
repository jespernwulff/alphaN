# Tests for alphaN_power() and alphaN_power_plot().

test_that("alphaN_power matches the one-sample noncentral-t power", {
  a <- alphaN(500, BF = 3)
  expect_equal(alphaN_power(500, d = 0.2, BF = 3),
               power.t.test(n = 500, delta = 0.2, sd = 1, sig.level = a,
                            type = "one.sample")$power,
               tolerance = 1e-6)
})

test_that("alphaN_power increases in n and in d", {
  pw_n <- alphaN_power(c(100, 500, 2000), d = 0.2, BF = 3)
  expect_true(all(diff(pw_n) > 0))
  pw_d <- alphaN_power(500, d = c(0.1, 0.2, 0.5), BF = 3)
  expect_true(all(diff(pw_d) > 0))
})

test_that("alphaN_power is 1 when the calibrated alpha is 1", {
  expect_equal(alphaN_power(100, d = 0.2, BF = 0.01, method = "ES",
                            de = 0.5), 1)
})

test_that("alphaN_power handles joint tests and the p argument", {
  pw <- alphaN_power(200, d = sqrt(0.15), BF = 3, method = "ES", q = 2,
                     p = 2, de = sqrt(0.15))
  expect_true(pw > 0 && pw < 1)
  expect_gt(alphaN_power(200, d = sqrt(0.35), BF = 3, method = "ES", q = 2,
                         p = 2, de = sqrt(0.15)), pw)
  # p shifts the residual degrees of freedom
  expect_equal(alphaN_power(104, d = 0.3, BF = 3, method = "ES", p = 4),
               alphaN_power(100, d = 0.3, BF = 3, method = "ES"),
               tolerance = 1e-8)
})

test_that("alphaN_power validates d", {
  expect_error(alphaN_power(100, d = -0.1), "non-negative")
  expect_error(alphaN_power(100, d = NA_real_), "non-negative")
})

test_that("alphaN_report includes a power section when asked", {
  rep <- capture.output(alphaN_report(n = 1000, BF = 3, method = "JAB",
                                      power_at = c(0.1, 0.5)))
  expect_true(any(grepl("Power at the calibrated alpha", rep)))
  expect_true(any(grepl("effect of 0.1", rep)))
  expect_true(any(grepl("effect of 0.5", rep)))
  expect_error(alphaN_report(1000, power_at = -1), "positive")
})

test_that("alphaN_power_plot draws and validates", {
  pdf(NULL)
  on.exit(dev.off())
  expect_silent(alphaN_power_plot(d = c(0.1, 0.5), BF = 3, max = 2000,
                                  methods = c("JAB", "moment")))
  expect_silent(alphaN_power_plot(d = 0.2, max = 1000, ref = NULL))
  expect_error(alphaN_power_plot(d = 0), "positive")
  expect_error(alphaN_power_plot(d = 0.2, ref = 2), "in \\(0, 1\\)")
})
