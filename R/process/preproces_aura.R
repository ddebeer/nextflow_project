library(dplyr)

list.files("Data")

# prepare data FEEL Study
data <- read.csv("Data/data_Assessing_Understanding_and_Regulating_Affect_AURA.csv")
names(data)



# recode and select part 1
data <- data |> mutate(
  age = AGE_BL,
  gender = case_when(
    GENDER_BL == "1" ~ "female",
    GENDER_BL == "2" ~ "male",
    .default = "other"),
  er = SUPR_ES,
  er_b = (0.05 + er) / 100.1,
  sad = SAD_ES / 100,
  anx = ANX_ES / 100,
  dull = DULL_ES / 100,
  irr = IRR_ES / 100,
  study = dataset
  ) |>
  rowwise() |>
  mutate(
    neg_aff = mean(c(anx, dull, irr, sad), na.rm = TRUE)
  ) |>
  ungroup() |>
  select(age, gender,
         er, er_b,
         sad,
         neg_aff, UUID,
             Date_Local, Time_Local, study)


# person-level data
data_pp <- data |> group_by(UUID) |>
  summarise(age = mean(age),
            gender = head(gender, 1),
            er_pm = mean(er, na.rm = TRUE),
            sad_pm = mean(sad, na.rm = TRUE),
            neg_aff_pm = mean(neg_aff, na.rm = TRUE),
            study = head(study, 1)
            ) |> mutate (
              age_z = scale(age)[,1],
              ppID = paste0(study, row_number()))


data <- left_join(data, data_pp) |>
  mutate(
    sad_pmc = sad - sad_pm,
    neg_aff_pmc = neg_aff - neg_aff_pm
  ) |> group_by(ppID, Date_Local) |>
  mutate(
    sad_pmc_lag = lag(sad_pmc),
    neg_aff_pmc_lag = lag(neg_aff_pmc)
  )

# remove others and recode gender
data <- data |> filter(gender != "other") |>
  mutate(m_f = ifelse(gender == "male", .5, -.5),
         type = "cont")

# remove others and recode gender
data_pp <- data_pp |> filter(gender != "other") |>
  mutate(m_f = ifelse(gender == "male", .5, -.5),
         type = "cont")



saveRDS(data_pp, "Data/data_pp_aura.RDS")
saveRDS(data, "Data/data_aura.RDS")




if(FALSE){
  # test model
  library(lmerTest)

  fit <- lmer(er ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                (1 | ppID),
              data = data)


  fit_rs <- lmer(er ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                   (1 + neg_aff_pm + neg_aff_pmc_lag | ppID),
                 data = data)

  anova(fit, fit_rs)
  summary(fit_rs)

  performance::check_model(fit_rs)
  resid <- residuals(fit_rs)
  hist(resid)


  # beta regression
  library(glmmTMB)

  fitb <- glmmTMB(er_b ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                    (1 | ppID),
                  data = data,
                  family = beta_family(link = "logit"))


  fitb_rs <- glmmTMB(er_b ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                       (1 + neg_aff_pm + neg_aff_pmc_lag| ppID),
                     data = data,
                     family = beta_family(link = "logit"))


  anova(fitb, fitb_rs)
  summary(fitb_rs)

  residb <- residuals(fitb_rs)
  hist(residb)

  performance::check_model(fitb_rs)

}
