test_that("JABt is consistent with alphaN", {
  # calculate the p-value for a z-score of 1.96
  z <- 1.96
  p <- 2*pnorm(q=z, lower.tail=FALSE)

  # compute BF for z-score assuming a sample size of 100
  n <- 100
  BF <- JABt(n, z)

  # compute alpha for that BF and sample size
  alpha <- alphaN(n, BF = BF)

  # check that the result from alphaN matches the p-value
  expect_equal(alpha, p)

  # repeat for other methods
  ## min
  BF <- JABt(n, z, method = "min")
  alpha <- alphaN(n, BF = BF, method = "min")
  expect_equal(alpha, p)

  ## robust
  BF <- JABt(n, z, method = "robust")
  alpha <- alphaN(n, BF = BF, method = "robust")
  expect_equal(alpha, p)

  ## balanced
  BF <- JABt(n, z, method = "balanced")
  alpha <- alphaN(n, BF = BF, method = "balanced")
  expect_equal(alpha, p)

})

test_that("larger sample size decreases BF for constant t-score", {
  expect_gt(JABt(100, 1), JABt(101, 1))
  expect_gt(JABt(200, 1), JABt(201, 1))
  expect_gt(JABt(3000, 1), JABt(3001, 1))
})

test_that("larger t-score increases BF for fixed n", {
  expect_gt(JABt(100, 0.01), JABt(100, 0))
  expect_gt(JABt(100, 1.01), JABt(100, 1))
  expect_gt(JABt(100, 2.01), JABt(100, 2))
})

test_that("method = JAB has the lowest BF", {
  expect_gt(JABt(100, 1, method = "balanced"), JABt(100, 1, method = "JAB"))
  expect_gt(JABt(100, 1, method = "robust"), JABt(100, 1, method = "JAB"))
  expect_gt(JABt(100, 1, method = "min"), JABt(100, 1, method = "JAB"))
})

test_that("method = balanced has the highest BF", {
  expect_gt(JABt(100, 1, method = "balanced"), JABt(100, 1, method = "robust"))
  expect_gt(JABt(100, 1, method = "balanced"), JABt(100, 1, method = "min"))
})

test_that("method = robust has a higher BF than method = min", {
  expect_gt(JABt(100, 1, method = "robust"), JABt(100, 1, method = "min"))
  expect_gt(JABt(200, 1, method = "robust"), JABt(200, 1, method = "min"))
  expect_gt(JABt(300, 1, method = "robust"), JABt(300, 1, method = "min"))
})

