test_that("JABp is consistent with alphaN", {
  BF <- 1
  n <- 100
  alpha <- alphaN(n, BF = BF)
  expect_equal(JABp(n, alpha), BF)
})
