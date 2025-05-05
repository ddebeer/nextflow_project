library(dplyr)

list.files("Data")

# prepare data FEEL Study
data <- read.csv("Data/data_Leuven_emotions_in_daily_life_2012.csv")
names(data)

# recode and select part 1
data <- data |> mutate(
  age = AGE_BL,
  gender = case_when(
    GENDER_BL == 1 ~ "male",
    GENDER_BL == 2 ~ "female",
    .default = "other"),
  er = SUPR_ES,
  anger = ANG_ES / 100,
  stress = STR_ES / 100,
  sad = SAD_ES / 100,
  cont = CONTEMPT_ES / 100,
  disap = DISAP_ES / 100,
  shame = SHAM_ES / 100,
  study = dataset
  ) |>
  rowwise() |>
  mutate(
    erq = (mean(c(ERQ_2_BL, ERQ_4_BL, ERQ_6_BL, ERQ_9_BL), na.rm = TRUE) - 1) / 6,
    neg_aff = mean(c(anger, sad, cont, disap, shame, stress), na.rm = TRUE)
  ) |>
  ungroup() |>
  select(age, gender, erq,
         er,
         anger, sad, neg_aff, UUID,
             Date_Local, Time_Local, study)


# person-level data
data_pp <- data |> group_by(UUID) |>
  summarise(age = mean(age),
            gender = head(gender, 1),
            erq = mean(erq, na.rm = TRUE),
            er_pm = mean(er, na.rm = TRUE),
            anger_pm = mean(anger, na.rm = TRUE),
            sad_pm = mean(sad, na.rm = TRUE),
            neg_aff_pm = mean(neg_aff, na.rm = TRUE),
            study = head(study, 1)
            ) |> mutate (
              age_z = scale(age)[,1],
              ppID = paste0(study, row_number()))


data <- left_join(data, data_pp) |>
  mutate(
    anger_pmc = anger - anger_pm,
    sad_pmc = sad - sad_pm,
    neg_aff_pmc = neg_aff - neg_aff_pm
  ) |> group_by(ppID, Date_Local) |>
  mutate(
    anger_pmc_lag = lag(anger_pmc),
    sad_pmc_lag = lag(sad_pmc),
    neg_aff_pmc_lag = lag(neg_aff_pmc)
  )

# remove others and recode gender
data <- data |> filter(gender != "other") |>
  mutate(m_f = ifelse(gender == "male", .5, -.5),
         type = "binary")

# remove others and recode gender
data_pp <- data_pp |> filter(gender != "other") |>
  mutate(m_f = ifelse(gender == "male", .5, -.5),
         type = "binary")



saveRDS(data_pp, "Data/data_pp_leuven2012.RDS")
saveRDS(data, "Data/data_leuven2012.RDS")



if(FALSE){
  # test model
  library(lmerTest)

  fit <- glmer(er ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                 (1 | ppID),
               data = data,
               family = binomial)


  fit_rs <- glmer(er ~ m_f * (neg_aff_pm + neg_aff_pmc_lag) +
                    (1 + neg_aff_pm + neg_aff_pmc_lag | ppID),
                  data = data,
                  family = binomial)

  anova(fit, fit_rs)
  summary(fit_rs)


  resid <- residuals(fit_rs)
  hist(resid)
  performance::check_model(fit_rs)





  # beta regression
  library(glmmTMB)

  fitb <- glmmTMB(er_b ~ m_f * (neg_aff_pm +neg_aff_pmc + neg_aff_pmc_lag) +
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
