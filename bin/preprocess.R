#!/usr/bin/env Rscript

library("dplyr", warn.conflicts = FALSE, quietly = TRUE)

# collect two trailing arguments: dataset and input_path
args <- commandArgs(trailingOnly=TRUE)
dataset <- args[1]
input_path <- args[2]

message(getwd())

# read the data
data <- read.csv(input_path)

# do preprocessing
source(paste0("R/process/preproces_", dataset, ".R"))

# save data
saveRDS(data_pp, "data_pp.RDS")
saveRDS(data, "data.RDS")
