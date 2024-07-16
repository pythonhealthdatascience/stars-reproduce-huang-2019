test_that("Test Number 1", {
  value <- paramNames[[1]]

  expect_that(value, equals("ct"))
})

test_that("Friends", {
  friends_df <- data.frame(
    friend_id = c(1:5),
    friend_name = c("Sachin", "Sourav",
                    "Dravid", "Sehwag",
                    "Dhoni"),
    stringsAsFactors = FALSE
  )
  friends_csv <- read.csv(path)[,-1]
  expect_identical(friends_csv, friends_df)
})
