models <- data.frame(name = c("ri", "rs1", "rs2", "rs3"),
                     formula = c(
                       "'m_f*(neg_aff_pm+neg_aff_pmc_lag)+(1|ppID)+(1|study)'",
                       "'m_f*(neg_aff_pm+neg_aff_pmc_lag)+(1+neg_aff_pm+neg_aff_pmc_lag|ppID)+(1|study)'",
                       "'m_f*(neg_aff_pm+neg_aff_pmc_lag)+(1+neg_aff_pm+neg_aff_pmc_lag|ppID)+(1+neg_aff_pm+neg_aff_pmc_lag|study)'",
                       "'m_f*(neg_aff_pm+neg_aff_pmc_lag)+(1+neg_aff_pm+neg_aff_pmc_lag|ppID)+(1+m_f+neg_aff_pm+neg_aff_pmc_lag|study)'"
                     ))

write.csv(models, "input/models.csv", row.names = FALSE, quote = FALSE)
