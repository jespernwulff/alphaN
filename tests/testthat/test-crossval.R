# Cross-validation against independent implementations (run only when the
# comparison packages are installed; they are Suggests, not hard deps).

test_that("the JZS special case agrees with BayesFactor::ttest.tstat", {
  skip_if_not_installed("BayesFactor")
  for (tt in c(2.03, 2.24)) {
    ours   <- klauerBF(80, t = tt, de = 0, nu = 1, r = 1)
    theirs <- exp(BayesFactor::ttest.tstat(t = tt, n1 = 80, rscale = 1)$bf)
    expect_equal(ours, theirs, tolerance = 1e-8)
  }
})

test_that("alphaN reproduces JustifyAlpha's evidence calibration under its prior", {
  skip_if_not_installed("JustifyAlpha")
  # JustifyAlpha's ttestEvidence() calibrates alpha to the JZS Bayes factor
  # with BayesFactor's default scale r = sqrt(2)/2; the same prior is the
  # ES special case nu = 1, de = 0 with that r.
  theirs <- JustifyAlpha::ttestEvidence(evidence = 3, n1 = 100,
                                        one.sided = FALSE)$alpha
  ours <- alphaN(100, BF = 3, method = "ES", nu = 1, de = 0, r = sqrt(2)/2)
  expect_equal(ours, theirs, tolerance = 1e-4)
})
