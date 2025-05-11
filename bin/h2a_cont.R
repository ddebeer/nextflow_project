# Hypothesis 2a - continuous

# load packages
library(lmerTest)

# read data
data <- readRDS("Data/data.RDS")
data <- data[data$type == "cont",]
data <- data[!is.na(data$er), ]
data <- data[!is.na(data$neg_aff_pmc_lag), ]


## gaussian model ----
fit <- lmer(er ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
              (1 | ppID) +
              (1 | study) ,
            data = data)

hist(resid(fit))
plot(fit)
summary(fit)


fit_rs1 <- lmer(er ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                 (1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
                 (1 | study),
               data = data)


fit_rs2 <- lmer(er ~  m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                  (1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
                  (1 + neg_aff_pm + neg_aff_pmc_lag | study),
                data = data)


fit_rs3 <- lmer(er ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                  (1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
                  (1 + m_f * (neg_aff_pm + neg_aff_pmc_lag) | study),
                data = data)


anova_h2a <- anova(fit, fit_rs1, fit_rs2, fit_rs3)
anova_h2a
summary(fit_rs2)

check_h2a <- NA
#check_h2a <- performance::check_model(fit_rs2)
resid <- residuals(fit_rs2)
hist(resid)


knitr::kable(broom.mixed::tidy(fit_er_pm_rs1))


saveRDS(list(
  anova = anova_h2a,
  best_model = fit_rs2@call,
  fit = fit_rs2,
  estimates = knitr::kable(broom.mixed::tidy(fit_rs2)),
  check = check_h2a,
  total_sample = nrow(data),
  studies = unique(data$study)),
  "Results/h2a_gauss.RDS")




## beta model ----
library(glmmTMB)
fitb <- glmmTMB(er_b ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                  (1 | ppID) +
                  (1 | study) ,
                dispformula = ~ m_f + (neg_aff_pm + neg_aff_pmc_lag) +
                  #(1 | ppID) +
                  (1 | study),
            data = data,
            family = beta_family(link = "logit"))


hist(resid(fitb))
plot(fitb)
summary(fitb)


fitb2 <- glmmTMB(er_b ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                  (1 | ppID) +
                  (1 | study) ,
                dispformula = ~
                  (1 | ppID),# +
                  #(1 | study),
                data = data,
                family = beta_family(link = "logit"))


fitb_rs1 <- glmmTMB(er_b ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                      (1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
                      (1 | study),
                    dispformula = ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                      #(1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
                      (1 | study),
                data = data,
                family = beta_family(link = "logit"))


fitb_rs2 <- glmmTMB(er_b ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                      (1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
                      (1 + neg_aff_pm + neg_aff_pmc_lag | study),
                    dispformula = ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                      #(1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
                      (1 + neg_aff_pm + neg_aff_pmc_lag | study),
                data = data,
                family = beta_family(link = "logit"))


fitb_rs3 <- glmmTMB(er_b ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                  (1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
                  (1 + m_f * (neg_aff_pm + neg_aff_pmc_lag) | study),
                  dispformula = ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                    #(1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
                    (1 + m_f * (neg_aff_pm + neg_aff_pmc_lag) | study),
                data = data,
                family = beta_family(link = "logit"))


anovab_h2a <- anova(fitb, fitb_rs1, fitb_rs2, fitb_rs3)
summary(fitb_rs2)

checkb_h2a <- NULL
checkb_h2a <- performance::check_model(fitb_rs2)
residb <- residuals(fitb_rs2)
hist(residb)


knitr::kable(broom.mixed::tidy(fitb_rs2))

saveRDS(VarCorr(res$fitb_rs2), "Results/h2a_beta_VarCorr.RDS")

saveRDS(list(
  anova = anovab_h2a,
  best_model = fitb_rs2$call,
  fit = fitb_rs2,
  estimates = knitr::kable(broom.mixed::tidy(fitb_rs2)),
  check = checkb_h2a,
  total_sample = nrow(data),
  studies = unique(data$study)),
  "Results/h2a_beta.RDS")


## brms ----

# zero inflated beta
library(brms)
priors <- c(
  set_prior("student_t(3, 0, 2.5)", class = "Intercept"),
  set_prior("normal(0, 1)", class = "b"),
  set_prior("logistic(0, 1", class = "Intercept", dpar = "zi")
)

model_beta <- brm(
  bf(er_b ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
       (1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
       (1 + m_f * (neg_aff_pm + neg_aff_pmc_lag) | study),

    phi ~  m_f * (neg_aff_pm + neg_aff_pmc_lag) +
      #(1 + neg_aff_pm + neg_aff_pmc_lag | ppID) +
      (1 + m_f * (neg_aff_pm + neg_aff_pmc_lag) | study),
    zi ~ 1
  ),
  data = data,
  family = zero_inflated_beta(),
  prior = priors,
  chains = 4, iter = 2000, seed = 1234,
  file = "Results/model_beta"
)
