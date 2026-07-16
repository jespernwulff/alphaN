test_that("JAB correctly extracts t-stat", {
  n <- 200
  set.seed(200)
  ## Regressors
  Z1 <- runif(n, -1, 1)
  Z2 <- runif(n, -1, 1)
  Z3 <- runif(n, -1, 1)
  Z4 <- runif(n, -1, 1)
  X <- runif(n, -1, 1)
  ## Error term
  U <- rnorm(n, 0, 0.5)
  ## Outcome
  Y <- X/sqrt(n) + U
  # Run a GLM
  LM <- glm(Y ~ X + Z1 + Z2 + Z3 + Z4)
  # Compute JAB for "X" based on the regression results
  JAB_obj <- JAB(LM, "X")
  # check that JAB has extracted the correct t-statistic
  t_X <- summary(LM)$coefficients["X", 3]
  expect_equal(JAB_obj, JABt(n = n, t = t_X))
  # an lm fit of the same model gives the same result
  expect_equal(JAB(lm(Y ~ X + Z1 + Z2 + Z3 + Z4), "X"), JAB_obj)
})

test_that("JAB uses the number of observations actually used in the fit", {
  set.seed(1)
  d <- data.frame(Y = rnorm(50), X = rnorm(50))
  d$X[1:5] <- NA
  m <- lm(Y ~ X, data = d)
  expect_equal(JAB(m, "X"),
               JABt(n = nobs(m), t = summary(m)$coefficients["X", 3]))
})

test_that("JAB works for non-gaussian glms", {
  set.seed(2)
  X <- rnorm(100)
  Y <- rbinom(100, 1, plogis(0.5 * X))
  m <- glm(Y ~ X, family = binomial)
  expect_equal(JAB(m, "X"),
               JABt(n = 100, t = summary(m)$coefficients["X", 3]))
})

test_that("JAB with covariate = NULL returns a named vector, no intercept", {
  set.seed(4)
  d <- data.frame(Y = rnorm(80), X = rnorm(80), Z = rnorm(80))
  m <- lm(Y ~ X + Z, data = d)
  all_bf <- JAB(m)
  expect_named(all_bf, c("X", "Z"))
  expect_false("(Intercept)" %in% names(all_bf))
  expect_equal(all_bf[["X"]], JAB(m, "X"))
  expect_equal(all_bf[["Z"]], JAB(m, "Z"))
  # the method argument propagates
  expect_equal(JAB(m, method = "min")[["X"]], JAB(m, "X", method = "min"))
  # the intercept stays available on explicit request
  expect_equal(JAB(m, "(Intercept)"),
               JABt(n = nobs(m), t = summary(m)$coefficients["(Intercept)", 3]))
  # intercept-only model: no silent empty vector
  expect_error(JAB(lm(Y ~ 1, data = d)), "besides the intercept")
})

test_that("JAB rejects invalid input with informative errors", {
  set.seed(3)
  d <- data.frame(Y = rnorm(20), X = rnorm(20))
  m <- lm(Y ~ X, data = d)
  expect_error(JAB(d, "X"), "lm\\(\\) or glm\\(\\)")
  expect_error(JAB(m, "Z"), "not found")
  expect_error(JAB(m, "Z"), "Available")
  expect_error(JAB(m, c("X", "Y")), "single character string")
  expect_error(JAB(m, 1), "single character string")
})
