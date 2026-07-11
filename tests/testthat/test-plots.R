test_that("plot functions run without errors or warnings", {
  pdf(NULL)
  on.exit(dev.off())
  expect_silent(alphaN_plot(BF = 3, max = 1000))
  expect_silent(alphaN_plot(BF = 1, max = 500, ylim = c(0, 0.05)))
  expect_silent(JAB_plot(1000))
  expect_silent(JAB_plot(500, BF = 3, method = "robust"))
  expect_silent(JAB_plot(500, BF = 3, method = "balanced", upper = 0.5))
})
