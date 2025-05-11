#!/usr/bin/env Rscript

library("dplyr", warn.conflicts = FALSE, quietly = TRUE)


# collect two trailing arguments: type, dataset
args <- commandArgs(trailingOnly=TRUE)
type <- args[1]
datasets <- args[2]

#print(datasets)

#print("\n")

# preprocess datasets
datasets <- gsub("[", "", datasets, fixed = TRUE)
datasets <- gsub("]", "", datasets, fixed = TRUE)
datasets <- unlist(strsplit(datasets, split = ", ", fixed = TRUE))
datasets <- gsub(",", "", datasets, fixed = TRUE)

# print(datasets)

# esm data
if(type == "esm"){
  data_esm <- do.call(rbind, lapply(datasets, function(file){
    #browser()
    data <- readRDS(file)

    # check if anger is present
    if("anger" %in% names(data)) {
      data$has_anger <- TRUE
    } else {
      data$has_anger <- FALSE
      data$anger_pm <- data$anger_pmc <- data$anger_pmc_lag <- 0
    }

    # check if sad is present
    if("sad" %in% names(data)) {
      data$has_sad <- TRUE
    } else {
      data$has_sad <- FALSE
      data$sad_pm <- data$sad_pmc <- data$sad_pmc_lag <- 0
    }

    # check if erq is present
    if("erq" %in% names(data)) {
      data$has_erq <- TRUE
    } else {
      data$has_erq <- FALSE
      data$erq <- 0
    }

    # check if type is binary
    if(all(data$type == "binary")) {
      #print(file)
      data$er_b <- NA
    }


    # check
    if(any(data$er_b >= 1, na.rm = TRUE)) {
      #browser()
    }


    data <- data |> ungroup() |>
      select(er, er_b, age_z, m_f,
             erq, has_erq,
             neg_aff_pm, neg_aff_pmc, neg_aff_pmc_lag,
             anger_pm, anger_pmc, anger_pmc_lag, has_anger,
             sad_pm, sad_pmc, sad_pmc_lag, has_sad,
             ppID, study, type)
    #print("OK")
    data
  }))

  saveRDS(data_esm, "data_esm_all.RDS")
} else if(type == "pp"){
  # person level data
  data_pp <- do.call(rbind, lapply(datasets, function(file){

    data <- readRDS(file)

    # check if anger is present
    if("anger_pm" %in% names(data)) {
      data$has_anger <- TRUE
    } else {
      data$has_anger <- FALSE
      data$anger_pm <- NA
    }

    # check if sad is present
    if("sad_pm" %in% names(data)) {
      data$has_sad <- TRUE
    } else {
      data$has_sad <- FALSE
      data$sad_pm <- NA
    }

    # check if erq is present
    if("erq" %in% names(data)) {
      data$has_erq <- TRUE
    } else {
      data$has_erq <- FALSE
      data$erq <- NA
    }

    # check if type is binary
    if(all(data$type == "binary")) {
      data$er_pm <- data$er_pm * 100
    }

    data <- data |> ungroup() |>
      select(er_pm, age_z, m_f,
             erq, has_erq,
             neg_aff_pm,
             anger_pm, has_anger,
             sad_pm, has_sad,
             ppID, study, type)
    #print("OK")
    data
  }))

  saveRDS(data_pp, "data_pp_all.RDS")

} else {
  saveRDS("test", "test.RDS")
  #stop("Incorrect 'type' argument.")
}



