test_that("JABp is consistent with alphaN", {
  BF <- 1
  n <- 100

  # JAB
  alpha <- alphaN(n, BF = BF)
  expect_equal(JABp(n, alpha), BF)

  # min
  alpha <- alphaN(n, BF = BF, method = "min")
  expect_equal(JABp(n, alpha, method = "min"), BF)

  # robust
  alpha <- alphaN(n, BF = BF, method = "robust")
  expect_equal(JABp(n, alpha, method = "robust"), BF)

  # balanced
  alpha <- alphaN(n, BF = BF, method = "balanced")
  expect_equal(JABp(n, alpha, method = "balanced"), BF)
})

test_that("JAB increases when df decrease for the t-stat", {
  n <- 100
  p <- 0.05
  expect_gt(JABp(n, p, z = FALSE, df = 99), JABp(n, p, z = FALSE, df = 100))
  expect_gt(JABp(n, p, z = FALSE, df = 98), JABp(n, p, z = FALSE, df = 99))
  expect_gt(JABp(n, p, z = FALSE, df = 97), JABp(n, p, z = FALSE, df = 98))
})
