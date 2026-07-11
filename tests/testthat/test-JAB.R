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
