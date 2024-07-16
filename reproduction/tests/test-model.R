source("../model.R")

test_that("Test Number 1", {
  value <- paramNames[[1]]

  expect_that(value, equals("ct"))
})
