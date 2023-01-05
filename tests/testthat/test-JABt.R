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
