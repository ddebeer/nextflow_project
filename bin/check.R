#!/usr/bin/env Rscript

library(lme4)
library(performance)

# collect three trailing arguments: fit_path
args <- commandArgs(trailingOnly=TRUE)
fit_path <- args[1]

name <- c("ri", paste0("rs", 1:3))[c(grepl(pattern = "fit_ri", fit_path, fixed = TRUE),
                                     grepl(pattern = "fit_rs1", fit_path, fixed = TRUE),
                                     grepl(pattern = "fit_rs2", fit_path, fixed = TRUE),
                                     grepl(pattern = "fit_rs3", fit_path, fixed = TRUE))]

threshold <- c(25, 50, 75)[c(grepl(pattern = "bin_25", fit_path, fixed = TRUE),
                             grepl(pattern = "bin_50", fit_path, fixed = TRUE),
                             grepl(pattern = "bin_75", fit_path, fixed = TRUE))]


# read the model
fit <- readRDS(fit_path)

if(inherits(fit, "merMod")) {
  tryCatch(
    {
      check <- performance::check_model(fit, residual_type = "normal")
      pdf(paste0("bin_", threshold, "fit_", name, ".pdf"),
          width = 10,
          height = 15)
      print(check)
      dev.off()},
      error = function(e) NULL)
}
