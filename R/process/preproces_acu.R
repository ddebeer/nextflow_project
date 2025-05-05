library(dplyr)

# get arguments
input <- commandArgs(trailingOnly = TRUE)
data_path <- input[1]
output_dir <- input[2]

# prepare data FEEL Study
data <- read.csv(data_path)
names(data)

# include:
# 1. age
# 2. gender
# 3. emotion regulation questionnaire (erq) if available
# 4. negative emotion (average of negative emotions)
# 5. sad
# 6. anger
# 7. stress

# check:
# 1. emotions on 0-1 scale using POMS
# 2. person mean center time variant vars


# recode and select part 1
data <- data |> mutate(
  age = AGE_BL,
  gender = case_when(
    GENDER_BL == "1" ~ "male",
    GENDER_BL == "2" ~ "female",
    .default = "other"),
  er = SUPR_ES,
  er_b = (0.05 + er) / 100.1,
  anger = ANG_ES / 100,
  sad = SAD_ES / 100,
  anx = ANX_ES / 100,
  emb = EMB_ES / 100,
  guil = GUIL_ES / 100,
  study = dataset
  ) |>
  rowwise() |>
  mutate(
    neg_aff = mean(c(anger, anx, sad, emb, guil), na.rm = TRUE)
  ) |>
  ungroup() |>
  select(age, gender,
         er, er_b,
         anger, sad,
         neg_aff, UUID,
             Date_Local, Time_Local, study)


# person-level data
data_pp <- data |> group_by(UUID) |>
  summarise(age = mean(age),
            gender = head(gender, 1),
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
         type = "cont")

# remove others and recode gender
data_pp <- data_pp |> filter(gender != "other") |>
  mutate(m_f = ifelse(gender == "male", .5, -.5),
         type = "cont")



saveRDS(data_pp, paste0(output_dir, "/data_pp_acu.RDS"))
saveRDS(data, paste0(output_dir, "/data_acu.RDS"))


