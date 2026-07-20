# Tests for the settings-report generator.

test_that("alphaN_report returns the report invisibly and prints it", {
  out <- capture.output(rep <- alphaN_report(n = 1000, BF = 3,
                                             method = "JAB"))
  expect_type(rep, "character")
  expect_true(any(grepl("alphaN settings report", out)))
  expect_true(any(grepl("Sample size \\(n\\): 1,000", rep)))
  expect_true(any(grepl("moderate evidence", rep)))
  expect_true(any(grepl("Jeffreys' approximate", rep)))
  a <- format(signif(alphaN(1000, BF = 3), 3), scientific = FALSE,
              trim = TRUE, drop0trailing = TRUE)
  expect_true(any(grepl(a, rep, fixed = TRUE)))
})

test_that("alphaN_report documents ES/moment prior settings and citations", {
  rep <- capture.output(alphaN_report(n = 1000, BF = 3, method = "ES",
                                      de = 0.5))
  expect_true(any(grepl("Targeted effect size \\(de\\): 0.5", rep)))
  expect_true(any(grepl("Prior degrees of freedom \\(nu\\): 3", rep)))
  expect_true(any(grepl("Prior scale \\(r\\)", rep)))
  expect_true(any(grepl("Klauer", rep)))

  rep_q <- capture.output(alphaN_report(n = 200, BF = 3, method = "moment",
                                        q = 2, p = 2, de = sqrt(0.15)))
  expect_true(any(grepl("Joint test of q = 2", rep_q)))
  expect_true(any(grepl("effective sample size 198", rep_q)))
  expect_true(any(grepl("joint F test", rep_q)))
})

test_that("alphaN_report states the scope of the ES/moment calibration", {
  rep_p0 <- capture.output(alphaN_report(n = 1000, BF = 3, method = "ES"))
  expect_true(any(grepl("conservative large-sample form", rep_p0)))
  rep_p <- capture.output(alphaN_report(n = 1000, BF = 3, method = "moment",
                                        p = 4))
  expect_true(any(grepl("exact for the normal linear model", rep_p)))
  rep_jab <- capture.output(alphaN_report(n = 1000, BF = 3, method = "JAB"))
  expect_false(any(grepl("Scope:", rep_jab)))
})

test_that("alphaN_report documents the balanced range", {
  rep <- capture.output(alphaN_report(n = 500, BF = 3, method = "balanced",
                                      upper = 0.6))
  expect_true(any(grepl("uniform on \\[0, 0.6\\]", rep)))
})

test_that("alphaN_report writes to a file", {
  f <- tempfile(fileext = ".md")
  capture.output(rep <- alphaN_report(n = 1000, BF = 3, file = f))
  expect_true(file.exists(f))
  expect_identical(readLines(f), as.character(rep))
  unlink(f)
})

test_that("alphaN_report insists on a single design", {
  expect_error(alphaN_report(n = c(100, 200), BF = 3), "single number")
  expect_error(alphaN_report(n = 100, BF = c(1, 3)), "single number")
})

test_that("alphaN_report wraps every line to the requested width", {
  rep <- capture.output(alphaN_report(n = 254654, BF = 3, method = "moment",
                                      q = 2, p = 4, de = sqrt(0.15)))
  expect_true(all(nchar(rep) <= 72))
  rep60 <- capture.output(alphaN_report(n = 1000, BF = 3, method = "ES",
                                        width = 60))
  expect_true(all(nchar(rep60) <= 60))
  expect_error(alphaN_report(1000, width = 20), "at least 40")
})
