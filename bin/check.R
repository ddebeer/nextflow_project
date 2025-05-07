#!/usr/bin/env Rscript

library(lme4)
library(performance)

# collect three trailing arguments: fit_path, name, threshold
args <- commandArgs(trailingOnly=TRUE)
fit_path <- args[1]
name <- args[2]
threshold <- args[3]


# read the model
fit <- readRDS("fit_path")

if(inherits(fit, "merMod")) {
  tryCatch(
    {
      check <- performance::check_model(fit)
      ggplot2::ggsave(paste0("bin_", threshold, "fit_", name, ".pdf"),
                      check,
                      width = 10,
                      height = 15,
                      dpi = 300)},
    error = function(e) NULL)
}
