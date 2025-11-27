# output (not complete)


final_dataset <- read_rds("data/processed/final_dataset.rds")

final_dataset |>
  filter(address_city == "s hertogenbosch") |>
  summarise(
    address_city = first(address_city),
    avg_price    = mean(price_eur, na.rm = TRUE),
    n_sales      = n()
  )
