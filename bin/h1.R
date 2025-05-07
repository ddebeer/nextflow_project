# Hypothesis 1

# load packages
library(lmerTest)

# read data
data <- readRDS("Data/data_pp.RDS")


# Hypothesis 1a - ERQ ----
fit_erq <- lmer(erq ~ age + m_f + neg_aff_pm +
                  (1 | study),
                data = data[data$has_erq,])

fit_erq_rs1 <- lmer(erq ~ age + m_f + neg_aff_pm +
                  (1 + neg_aff_pm | study),
                data = data[data$has_erq,])

fit_erq_rs2 <- lmer(erq ~ age + m_f + neg_aff_pm +
                     (1 + m_f | study),
                   data = data[data$has_erq,])

fit_erq_rs <- lmer(erq ~ age + m_f + neg_aff_pm +
                     (1 + m_f + neg_aff_pm | study),
                   data = data[data$has_erq,])

anova_erq <- anova(fit_erq, fit_erq_rs1, fit_erq_rs2, fit_erq_rs)
summary(fit_erq)

hist(residuals(fit_erq))
check_erq <- performance::check_model(fit_erq)

knitr::kable(broom.mixed::tidy(fit_erq))

# included studies
unique(data[data$has_erq,]$study)

# total sample size
nrow(data[data$has_erq,])

saveRDS(list(anova = anova_erq,
                    best_model = fit_erq@call,
                    fit = fit_erq,
                    estimates = knitr::kable(broom.mixed::tidy(fit_erq)),
                    check = check_erq,
                    total_sample = nrow(data[data$has_erq,]),
                    studies = unique(data[data$has_erq,]$study)),
               "Results/h1a.RDS")



# Hypothesis 1b - er_pm ----

## gaussian model ----
fit_er_pm <- lmer(er_pm ~ age_z + m_f + neg_aff_pm +
                  (1 | study),
                data = data)

fit_er_pm_rs1 <- lmer(er_pm ~ age_z + m_f + neg_aff_pm +
                      (1 + neg_aff_pm | study),
                    data = data)

fit_er_pm_rs2 <- lmer(er_pm ~ age_z + m_f + neg_aff_pm +
                      (1 + m_f | study),
                    data = data)

fit_er_pm_rs <- lmer(er_pm ~ age_z + m_f + neg_aff_pm +
                     (1 + m_f + neg_aff_pm | study),
                   data = data)

anova(fit_er_pm, fit_er_pm_rs1, fit_er_pm_rs2, fit_er_pm_rs)
anova_er_pm <- anova(fit_er_pm, fit_er_pm_rs1, fit_er_pm_rs)
summary(fit_er_pm_rs1)

hist(residuals(fit_er_pm_rs1))
check_er_pm <- performance::check_model(fit_er_pm_rs1)

knitr::kable(broom.mixed::tidy(fit_er_pm_rs1))


saveRDS(list(
  anova = anova_er_pm,
  best_model = fit_er_pm_rs1@call,
  fit = fit_er_pm_rs1,
  estimates = knitr::kable(broom.mixed::tidy(fit_er_pm_rs1)),
  check = check_er_pm,
  total_sample = nrow(data),
  studies = unique(data$study)),
  "Results/h1b_gauss.RDS")


## beta model ----
library(glmmTMB)
data$er_b_pm <- (0.05 + data$er_pm) / 100.1

fitb_er_pm <- glmmTMB(er_b_pm ~ age_z + m_f + neg_aff_pm +
                    (1 | study),
                    dispformula = ~ age_z + m_f + neg_aff_pm +
                      (1 | study),
                  data = data,
                  family = beta_family(link = "logit"))

fitb_er_pm_rs1 <- glmmTMB(er_b_pm ~ age_z + m_f + neg_aff_pm +
                        (1 + neg_aff_pm | study),
                        dispformula = ~ age_z + m_f + neg_aff_pm +
                          (1 + neg_aff_pm | study),
                      data = data,
                      family = beta_family(link = "logit"))

fitb_er_pm_rs2 <- glmmTMB(er_b_pm ~ age_z + m_f + neg_aff_pm +
                        (1 + m_f | study),
                        dispformula = ~ age_z + m_f + neg_aff_pm +
                          (1 + m_f | study),
                      data = data,
                      family = beta_family(link = "logit"))

fitb_er_pm_rs <- glmmTMB(er_b_pm ~ age_z + m_f + neg_aff_pm +
                       (1 + m_f + neg_aff_pm | study),
                       dispformula = ~ age_z + m_f + neg_aff_pm +
                         (1 + m_f + neg_aff_pm | study),
                     data = data,
                     family = beta_family(link = "logit"))



anova(fitb_er_pm, fitb_er_pm_rs1, fitb_er_pm_rs2, fitb_er_pm_rs)
anova_er_b_pm <- anova(fitb_er_pm, fitb_er_pm_rs1, fitb_er_pm_rs2)
summary(fitb_er_pm_rs1)


hist(residuals(fitb_er_pm_rs1))
check_er_b_pm <- performance::check_model(fitb_er_pm_rs1)

knitr::kable(broom.mixed::tidy(fitb_er_pm_rs1))


saveRDS(list(
  anova = anova_er_b_pm,
  best_model = fitb_er_pm_rs1$call,
  fit = fitb_er_pm_rs1,
  estimates = knitr::kable(broom.mixed::tidy(fitb_er_pm_rs1)),
  check = check_er_b_pm,
  total_sample = nrow(data),
  studies = unique(data$study)),
  "Results/h1b_beta.RDS")

# included studies
unique(data$study)

# total sample size
nrow(data)



## log model ----
fitl_er_pm <- lmer(log(er_pm + 0.5) ~ age_z + m_f + neg_aff_pm +
                    (1 | study),
                  data = data)

fitl_er_pm_rs1 <- lmer(log(er_pm + 0.5) ~ age_z + m_f + neg_aff_pm +
                        (1 + neg_aff_pm | study),
                      data = data)

fitl_er_pm_rs2 <- lmer(log(er_pm + 0.5) ~ age_z + m_f + neg_aff_pm +
                        (1 + m_f | study),
                      data = data)

fitl_er_pm_rs <- lmer(log(er_pm + 0.5) ~ age_z + m_f + neg_aff_pm +
                       (1 + m_f + neg_aff_pm | study),
                     data = data)

anova(fitl_er_pm, fitl_er_pm_rs1, fitl_er_pm_rs2, fitl_er_pm_rs)
anoval_er_pm <- anova(fitl_er_pm, fitl_er_pm_rs1, fitl_er_pm_rs)
summary(fitl_er_pm_rs1)

hist(residuals(fitl_er_pm_rs1))
checkl_er_pm <- performance::check_model(fitl_er_pm_rs1)

knitr::kable(broom.mixed::tidy(fitl_er_pm_rs1))


saveRDS(list(
  anova = anoval_er_pm,
  best_model = fitl_er_pm_rs1@call,
  fit = fitl_er_pm_rs1,
  estimates = knitr::kable(broom.mixed::tidy(fitl_er_pm_rs1)),
  check = checkl_er_pm,
  total_sample = nrow(data),
  studies = unique(data$study)),
  "Results/h1b_log.RDS")







# check data
library(dplyr)
data |> group_by(study) |>
  summarize(min = min(er_pm),
            med = median(er_pm),
            max = max(er_pm))


data |> group_by(study) |>
  summarize(min = min(er_b_pm),
            med = median(er_b_pm),
            max = max(er_b_pm))
