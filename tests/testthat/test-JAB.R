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
  expect_equal(JAB_obj, JABt(n = n, t = 2.17450608133496370300008493359200656414031982421875))
})

