#!/usr/bin/env Rscript

library("dplyr", warn.conflicts = FALSE, quietly = TRUE)

# collect three trailing arguments: dataset, input_path, and source_file
args <- commandArgs(trailingOnly=TRUE)
dataset <- args[1]
input_path <- args[2]
source_file <- args[3]

# read the data
data <- read.csv(input_path)

# do preprocessing
source(source_file)

# save data
saveRDS(data_pp, "data_pp.RDS")
saveRDS(data, "data_esm.RDS")
