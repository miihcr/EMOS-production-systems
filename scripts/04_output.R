# output (not complete)


final_dataset <- read_rds("data/processed/final_dataset.rds")


# 1. Lookup: which municipality owns den bosch?

final_dataset |>
  filter(address_city == "s hertogenbosch") |>
  distinct(municipality_id)


avg_prices_denbosch_2024 <- final_dataset |>
  filter(
    municipality_id == "796",        # Municipality: 's-Hertogenbosch
    # year(sale_date) == 2024          # Only 2024 sales if it is included
  ) |>
  group_by(address_city) |>          # Group by woonplaats
  summarise(
    n_sales       = n(),
    avg_price_eur = mean(price_eur, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(desc(avg_price_eur))

avg_prices_denbosch_2024
