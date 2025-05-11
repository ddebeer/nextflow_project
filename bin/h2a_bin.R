# Hypothesis 2a - continuous

# load packages
library(lmerTest)

# read data
data <- readRDS("Data/data.RDS")


# threshold
threshold <- 0.5


thresholds <- c(25, 50, 75)

for(threshold in thresholds){
  data$er_bin <- NA
  data$er_bin[data$type == "binary"] <- data$er[data$type == "binary"]
  data$er_bin[data$type == "cont"] <- 1 * (data$er[data$type == "cont"] > threshold)


  ## fit binary model ----
  fit <- glmer(er_bin ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                 (1 | ppID) +
                 (1 | study),
               family = binomial,
               data = data)


  fit_rs1 <- glmer(er_bin ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                     (1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
                     (1 | study),
                   family = binomial,
                   data = data)


  fit_rs2 <- glmer(er_bin ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                     (1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
                     (1 + neg_aff_pm + neg_aff_pmc_lag | study),
                   family = binomial,
                   data = data)


  fit_rs3 <- glmer(er_bin ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                     (1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
                     (1 + m_f + neg_aff_pm + neg_aff_pmc_lag | study),
                   family = binomial,
                   data = data)


  anova_h2a <- anova(fit, fit_rs1, fit_rs2, fit_rs3)
  anova_h2a
  summary(fit_rs2)

  check_h2a <- NA
  # check_h2a <- performance::check_model(fit_rs2)
  # resid <- residuals(fit_rs2)
  # hist(resid)
  # plot(fit_rs2)


  knitr::kable(broom.mixed::tidy(fit_rs2))


  saveRDS(list(
    anova = anova_h2a,
    best_model = fit_rs2@call,
    fit = fit_rs2,
    estimates = knitr::kable(broom.mixed::tidy(fit_rs2)),
    check = check_h2a,
    total_sample = nrow(data),
    studies = unique(data$study)),
    paste0("Results/h2a_bin", threshold, ".RDS"))
}



