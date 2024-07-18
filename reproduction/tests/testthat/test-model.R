# A selection of model scenarios are provided as tests, for you to run and
# confirm whether you are getting consistent results
# Note: This does not represent all model scenarios

test_that("Baseline", {
  test_scenario(file="fig2_baseline")
})

test_that("Exclusive use", {
  test_scenario(file="fig2_exclusive",
                param=list(exclusive_use = TRUE))
})

test_that("Two AngioINRs", {
  test_scenario(file="fig2_twoangio",
                param=list(angio_inr = 2, angio_ir=0))
})
