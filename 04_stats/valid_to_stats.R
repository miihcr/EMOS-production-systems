# 04_stats/valid_to_stats.R


dir.create("04_stats/data", showWarnings = FALSE, recursive = TRUE)

# 1. LOAD VALIDATED DATA (from 03_valid)

addresses      <- read_rds("03_valid/data/addresses_valid.rds")
dwellings      <- read_rds("03_valid/data/dwellings_valid.rds")
public_spaces  <- read_rds("03_valid/data/public_spaces_valid.rds")
towns          <- read_rds("03_valid/data/towns_valid.rds")
municipalities <- read_rds("03_valid/data/municipalities_valid.rds")
buildings      <- read_rds("03_valid/data/buildings_valid.rds")
sales          <- read_rds("03_valid/data/sales_valid.rds")

# 2. STANDARDIZE TEXT FOR MERGING

public_spaces <- public_spaces |>
  mutate(
    public_spaces_name = public_spaces_name |> str_squish() |> str_to_lower()
  )

sales <- sales |>
  mutate(
    sales_street_name = sales_street_name |> str_squish() |> str_to_lower(),
    
    # Harmonise Den Bosch naming
    sales_town_name = sales_town_name |>
      str_squish() |>
      str_replace("\\s+[Nn][Bb]$", "") |>
      str_replace("^Den ?Bosch$", "'s-Hertogenbosch")
  )

towns <- towns |>
  mutate(
    towns_name = towns_name |> str_squish()
  )

# 3. LINK SALES TO ADDRESSES USING POSTCODE + HOUSE NUMBER

sales_addr <- sales |>
  left_join(
    addresses,
    join_by(
      sales_postcode     == addresses_postcode,
      sales_house_number == addresses_house_number
    ),
    relationship = "many-to-many"
  )

# 4. CHOOSE LATEST BAG VALIDITY RECORD PER SALE

sales_addr <- sales_addr |>
  distinct() |>
  group_by(sales_full_address, sale_date, sales_price) |>
  slice_max(order_by = addresses_start_valid, n = 1, with_ties = FALSE) |>
  ungroup()


# 5. LINK DWELLINGS (RESIDENTIAL ONLY)


sales_addr_dwelling <- sales_addr |>
  left_join(
    dwellings |>
      select(
        dwellings_id_dwelling,
        dwellings_id_address
      ),
    join_by(id_address == dwellings_id_address)
  ) |>
  filter(!is.na(dwellings_id_dwelling))

# 6. LINK PUBLIC SPACES -> TOWNS -> MUNICIPALITIES

sales_full <- sales_addr_dwelling |>
  
  # public spaces 
  left_join(
    public_spaces,
    join_by(addresses_id_public_space == public_spaces_id_public_space)
  ) |>
  
  # towns 
  left_join(
    towns,
    join_by(public_spaces_id_town == towns_id_town)
  ) |>
  
  # municipalities
  left_join(
    municipalities,
    join_by(public_spaces_id_town == municipalities_id_town)
  )

# 7. IDENTIFY MUNICIPALITY: DEN BOSCH


den_bosch_town_ids <- towns |>
  filter(towns_name == "'s-Hertogenbosch") |>
  pull(towns_id_town) |>
  unique()

den_bosch_mun_ids <- municipalities |>
  filter(municipalities_id_town %in% den_bosch_town_ids) |>
  pull(municipalities_id_municipality) |>
  unique()


# 8. FILTER SALES IN 2024 (if needed) + DEN BOSCH MUNICIPALITY

sales_den_bosch_2024 <- sales_full |>
  filter(
    municipalities_id_municipality %in% den_bosch_mun_ids
  )

write_rds(
  sales_den_bosch_2024,
  "04_stats/data/linked_sales_2024.rds"
)


# 9. CALCULATE AVERAGE HOUSING PRICES BY TOWN

avg_prices_by_town <- sales_den_bosch_2024 |>
  group_by(towns_name) |>
  summarise(
    n_sales      = n(),
    avg_price    = mean(sales_price, na.rm = TRUE),
    median_price = median(sales_price, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(towns_name)


# 10. DISCLOSURE CONTROL (6=5 + ROUNDING)

k_min <- 5

avg_prices_protected <- avg_prices_by_town |>
  mutate(
    avg_price_rounded = round(avg_price, -3),  # round to nearest 1000
    avg_price_pub     = if_else(n_sales < k_min, NA_real_, avg_price_rounded),
    suppressed        = n_sales < k_min
  )

write_rds(
  avg_prices_protected,
  "04_stats/data/avg_prices_den_bosch_2024.rds"
)

message("04_stats completed ✓ — statistics + disclosure created.")