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

test_that("alphaN vectorizes over n for every method", {
  ns <- c(100, 1000, 10000)
  for (m in c("JAB", "min", "robust", "balanced")) {
    expect_equal(alphaN(ns, method = m),
                 vapply(ns, function(n) alphaN(n, method = m), numeric(1)))
  }
})

test_that("alphaN vectorizes over BF", {
  BFs <- c(1, 3, 10)
  expect_equal(alphaN(1000, BF = BFs),
               vapply(BFs, function(BF) alphaN(1000, BF = BF), numeric(1)))
})

test_that("alphaN rejects invalid input with informative errors", {
  expect_error(alphaN(1000, method = "typo"), "should be one of")
  expect_error(alphaN(-5), "positive")
  expect_error(alphaN(0), "positive")
  expect_error(alphaN(Inf), "finite")
  expect_error(alphaN("many"), "numeric")
  expect_error(alphaN(1000, BF = -2), "BF")
  expect_error(alphaN(1000, BF = 0), "BF")
  expect_error(alphaN(1000, method = "balanced", upper = -1), "upper")
})
