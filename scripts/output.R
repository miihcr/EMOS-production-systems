# output (not complete)


final_dataset <- read_rds("data/processed/final_dataset.rds")

final_dataset |>
  filter(address_city == "s hertogenbosch") |>
  distinct(municipality_id)

final_dataset |>
  filter(municipality_id == "796") |> # use id here
  group_by(address_city) |>
  summarise(
    avg_price = mean(price_eur, na.rm = TRUE),
    n_sales   = n(),
    .groups = "drop"
  )

