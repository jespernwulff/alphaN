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
