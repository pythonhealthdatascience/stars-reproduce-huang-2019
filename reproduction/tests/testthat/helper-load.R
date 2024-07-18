# This file will run before all tests are executed

# Import parameters and functions
source("../../scripts/model.R")
source("../../scripts/helpers.R")

# Set seed
SEED = 200


test_scenario <- function(file, param=NULL) {
  #' Run the model with specified parameters, and then compare against
  #' expected result
  #'
  #' @param file string, name of .csv.gz file with expected results
  #' (don't need to include '.csv.gz' in name)
  #' @param param list, with parameters to input to run_model()

  # Get model inputs - combined with param if provided
  inputs = list(seed=SEED)
  if (!is.null(param)) {
    inputs = c(inputs, param)
  }

  # Run model using provided parameters
  result <- do.call(run_model, inputs)

  # Import the expected results
  exp <- as.data.frame(data.table::fread(
    paste0("expected_results/", file, ".csv.gz")))

  # Compare the dataframes
  expect_equal(result, exp)
}
