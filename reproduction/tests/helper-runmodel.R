source("../scripts/model.R")
source("../scripts/helpers.R")

# Create temporary test directory
testdir <- tempdir()

# Create dataframe
friend.data <- data.frame(
  friend_id = c(1:5),
  friend_name = c("Sachin", "Sourav",
                  "Dravid", "Sehwag",
                  "Dhoni"),
  stringsAsFactors = FALSE
)

path <- file.path(tempdir(), "friends.csv")
write.csv(friend.data, path)
