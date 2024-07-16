test_that("Baseline 3 replications", {
  test_scenario(file="baseline_3rep",
                param=list(seed=200, nsim=3))
})

test_that("Baseline 6pm 3 replications", {
  test_scenario(file="baseline_6pm_3rep",
                param=list(shifts = c(8,18), seed=200, nsim=3))
})
