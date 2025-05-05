# create input.csv

input <- gsub("data_", "", list.files("data/data_raw"), fixed = TRUE)
input <- gsub(".csv", "", input, fixed = TRUE)

input <- data.frame(dataset = input)
write.csv(input, "input/input.csv")
