# output (not complete)


sales_data  <- read_rds("data/processed/sales_input.rds")

sales_data |> 
  group_by(town_name) |> 
  summarise(
    n_sales = n(),
    avg_price = mean(sales_price_eur, na.rm = TRUE)
  )

  

