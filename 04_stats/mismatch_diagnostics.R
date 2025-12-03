# MISMATCH DIAGNOSTICS - UNMATCHED SALES

sales_unmatched <- sales_addr_latest |>
  filter(is.na(id_address)) |>
  select(
    sales_full_address,
    sales_postcode,
    sales_house_number,
    sales_house_addition,
    sales_town_name,
    sale_date,
    sales_price_euros
  )

write_csv(sales_unmatched, "04_stats/data/sales_unmatched_all.csv")

# ------------------------------------------------------------
# MISMATCH CAUSE CLASSIFICATION
# ------------------------------------------------------------

mismatch_diagnostics_fixed <- sales_unmatched |>
  mutate(
    postcode_exists_in_bag =
      sales_postcode %in% addresses_latest$addresses_postcode,
    
    number_exists_for_postcode =
      paste(sales_postcode, sales_house_number) %in%
      paste(addresses_latest$addresses_postcode,
            addresses_latest$addresses_house_number),
    
    full_address_exists_in_bag =
      paste(
        sales_postcode,
        sales_house_number,
        coalesce(sales_house_addition, "")
      ) %in%
      paste(
        addresses_latest$addresses_postcode,
        addresses_latest$addresses_house_number,
        coalesce(addresses_latest$addresses_house_addition, "")
      )
  )

write_csv(
  mismatch_diagnostics_fixed,
  "04_stats/data/mismatch_diagnostics_all.csv"
)

# ------------------------------------------------------------
#  DEN BOSCH MISMATCH 
# ------------------------------------------------------------

denbosch_mismatch_audit_fixed <- mismatch_diagnostics_fixed |>
  filter(
    str_detect(sales_town_name, "(?i)hertogenbosch|rosmalen|nuland|vinkel")
  ) |>
  arrange(sales_town_name, sales_postcode, sales_house_number)

write_csv(
  denbosch_mismatch_audit_fixed,
  "04_stats/data/denbosch_mismatch_audit.csv"
)

# ------------------------------------------------------------
# DEN BOSCH MISMATCH SUMMARY (CAUSE COUNTS)
# ------------------------------------------------------------

denbosch_mismatch_summary <- denbosch_mismatch_audit_fixed |>
  summarise(
    wrong_postcode = sum(!postcode_exists_in_bag),
    wrong_number   = sum(postcode_exists_in_bag & !number_exists_for_postcode),
    wrong_addition = sum(number_exists_for_postcode & !full_address_exists_in_bag)
  )

write_csv(
  denbosch_mismatch_summary,
  "04_stats/data/denbosch_mismatch_summary.csv"
)

# ------------------------------------------------------------
# DEN BOSCH MISMATCH BY TOWN
# ------------------------------------------------------------

denbosch_mismatch_by_town <- denbosch_mismatch_audit_fixed |>
  count(sales_town_name, sort = TRUE)

write_csv(
  denbosch_mismatch_by_town,
  "04_stats/data/denbosch_mismatch_by_town.csv"
)


message("04_stats diagnostics + town statistics completed ✅")