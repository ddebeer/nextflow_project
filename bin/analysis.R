#!/usr/bin/env Rscript

# collect four trailing arguments: data_path, name, formula, threshold
args <- commandArgs(trailingOnly=TRUE)
data_path <- args[1]
name <- args[2]
formula <- args[3]
threshold <- args[4]


# read the data
data <- readRDS(data_path)


# create binary outcome
data$er_bin <- NA
data$er_bin[data$type == "binary"] <- data$er[data$type == "binary"]
data$er_bin[data$type == "cont"] <- 1 * (data$er[data$type == "cont"] > threshold)


# rescue solution?
formula <- switch(name,
      "ri"  = 'm_f*(neg_aff_pm+neg_aff_pmc_lag)+(1|ppID)+(1|study)',
      "rs1" = 'm_f*(neg_aff_pm+neg_aff_pmc_lag)+(1+neg_aff_pm+neg_aff_pmc_lag|ppID)+(1|study)',
      "rs2" = 'm_f*(neg_aff_pm+neg_aff_pmc_lag)+(1+neg_aff_pm+neg_aff_pmc_lag|ppID)+(1+neg_aff_pm+neg_aff_pmc_lag|study)',
      "rs3" = 'm_f*(neg_aff_pm+neg_aff_pmc_lag)+(1+neg_aff_pm+neg_aff_pmc_lag|ppID)+(1+m_f+neg_aff_pm+neg_aff_pmc_lag|study)')


# create formula
formula <- as.formula(paste0("er_bin ~ ", formula))


## fit binary model ----

fit <- tryCatch(lme4::glmer(formula,
                   family = binomial,
                   data = data),
                error = function(e) e)

saveRDS(fit, paste0("bin_", threshold, "fit_", name, ".RDS"))

