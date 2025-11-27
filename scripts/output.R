# output (not complete)

final_output <- read_rds("data/processed/final_dataset.rds")

avg_prices_denbosch_2024 <- final_output |> 
  mutate(year = year(sale_date)) |> 
  filter(
    year == 2024,
    sale_city %in% c(
      "s hertogenbosch",  
      "den bosch"
    )
  ) |> 
  group_by(sale_city) |> 
  summarise(
    n_sales = n(),
    avg_price = mean(price_eur, na.rm = TRUE),
    median_price = median(price_eur, na.rm = TRUE),
    min_price = min(price_eur, na.rm = TRUE),
    max_price = max(price_eur, na.rm = TRUE)
  ) |> 
  arrange(desc(avg_price))


avg_prices_denbosch_2024

