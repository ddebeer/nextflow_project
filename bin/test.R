#!/usr/bin/env Rscript

# collect four trailing arguments: data_path, name, formula, threshold
args <- commandArgs(trailingOnly=TRUE)
data_path <- args[1]
print(data_path)
name <- args[2]
print(name)
formula <- args[3]
print(formula)
threshold <- args[4]
print(threshold)


# read the data
data <- readRDS(data_path)
dim(data)

