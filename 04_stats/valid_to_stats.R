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


# Link SALES TO BAG ADDRESSES

sales_addr <- sales |>
  left_join(
    addresses,
    by = join_by(
      sales_postcode       == addresses_postcode,
      sales_house_number   == addresses_house_number,
      sales_house_addition == addresses_house_addition
    )
  )

# Keep address valid at sale date
sales_addr_latest <- sales_addr |> 
  filter(
    addresses_start_valid <= sale_date,
    is.na(addresses_end_valid) | addresses_end_valid >= sale_date
  )

# SALES → ADDRESSES → DWELLINGS
sales_addr_dwell <- sales_addr_latest |> 
  left_join(
    dwellings,
    by = join_by(id_address == dwellings_id_address)
  ) |> 
  filter(!is.na(dwellings_id_dwelling))   # keep only linked dwellings



# DEDUPLICATE BAG

public_spaces_latest <- public_spaces |> 
  filter(
    is.na(public_spaces_end_valid) |
      public_spaces_end_valid >= as.Date("2024-01-01")
  )

towns_latest <- towns |> 
  filter(
    is.na(towns_end_valid) |
      towns_end_valid >= as.Date("2024-01-01")
  )

municipalities_latest <- municipalities |> 
  filter(
    is.na(municipalities_end_valid) |
      municipalities_end_valid >= as.Date("2024-01-01")
  )

sales_full <- sales_addr_dwell |> 
  left_join(public_spaces_latest,
            by = join_by(addresses_id_public_space == public_spaces_id_public_space)) |> 
  left_join(towns_latest,
            by = join_by(public_spaces_id_town == towns_id_town)) |> 
  left_join(municipalities_latest,
            by = join_by(public_spaces_id_town == municipalities_id_town))


# 5. Identify municipality 's-Hertogenbosch


den_bosch_town_ids <- towns_latest |> 
  filter(str_detect(towns_name, "Hertogenbosch"))  |> 
  pull(towns_id_town)

den_bosch_mun_ids <- municipalities_latest  |> 
  filter(municipalities_id_town %in% den_bosch_town_ids) |> 
  pull(municipalities_id_municipality)

# 6. Filter sales in 2024 and in municipality

sales_denbosch_2024 <- sales_full |> 
  filter(
    municipalities_id_municipality %in% den_bosch_mun_ids,
    sale_date >= as.Date("2024-01-01"),
    sale_date <= as.Date("2024-12-31")
  )


stats_out <- sales_denbosch_2024 |> 
  group_by(towns_name) |> 
  summarise(
    n_sales      = n(),
    avg_price    = mean(sales_price_euros, na.rm = TRUE),
    median_price = median(sales_price_euros, na.rm = TRUE),
    .groups = "drop"
  ) |> 
  arrange(towns_name)

stats_out


# LINK PUBLIC SPACES -> TOWNS -> MUNICIPALITIES

sales_full <- sales_addr_latest |>
  
  # link public spaces
  left_join(
    public_spaces_latest,
    by = join_by(addresses_id_public_space == public_spaces_id_public_space)
  ) |>
  
  # link towns
  left_join(
    towns_latest,
    by = join_by(public_spaces_id_town == towns_id_town)
  ) |>
  
  # link municipalities
  left_join(
    municipalities_latest,
    by = join_by(public_spaces_id_town == municipalities_id_town)
  )

