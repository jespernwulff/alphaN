test_that("larger sample size decreases alpha", {
  expect_gt(alphaN(100), alphaN(101))
  expect_gt(alphaN(200), alphaN(201))
  expect_gt(alphaN(2000), alphaN(2001))
})

test_that("larger Bayes factor decreases alpha", {
  expect_gt(alphaN(100, BF = 1), alphaN(100, BF = 2))
  expect_gt(alphaN(200, BF = 1), alphaN(200, BF = 2))
  expect_gt(alphaN(2000, BF = 1), alphaN(2000, BF = 2))
})

test_that("method = JAB has the lowest alpha", {
  expect_gt(alphaN(100, method = "balanced"), alphaN(100, method = "JAB"))
  expect_gt(alphaN(100, method = "robust"), alphaN(100, method = "JAB"))
  expect_gt(alphaN(100, method = "min"), alphaN(100, method = "JAB"))
})

test_that("method = balanced has the highest alpha", {
  expect_gt(alphaN(100, method = "balanced"), alphaN(100, method = "robust"))
  expect_gt(alphaN(100, method = "balanced"), alphaN(100, method = "min"))
})

test_that("method = robust has a higher alpha than method = min", {
  expect_gt(alphaN(100, method = "robust"), alphaN(100, method = "min"))
  expect_gt(alphaN(200, method = "robust"), alphaN(200, method = "min"))
  expect_gt(alphaN(300, method = "robust"), alphaN(300, method = "min"))
})
