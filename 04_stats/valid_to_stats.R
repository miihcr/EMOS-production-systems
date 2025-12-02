# 04_stats/valid_to_stats.R


dir.create("04_stats/data", showWarnings = FALSE, recursive = TRUE)

# 1. LOAD VALIDATED DATA (from 03_valid)

addresses      <- read_rds("03_valid/data/addresses_valid.rds")
dwellings      <- read_rds("03_valid/data/dwellings_valid.rds")
public_spaces  <- read_rds("03_valid/data/public_spaces_valid.rds")
towns          <- read_rds("03_valid/data/towns_valid.rds")
municipalities <- read_rds("03_valid/data/municipalities_valid.rds")
buildings      <- read_rds("03_valid/data/buildings_valid.rds")
sales          <- read_rds("02_input/data/sales_valid.rds")


sales <- sales_input
# Link SALES TO BAG ADDRESSES

sales_addr <- sales |>
  left_join(
    addresses,
    by = join_by(
      sales_postcode       == addresses_postcode,
      sales_house_number   == addresses_house_number
    )
  )

# KEEP ONLY LATEST RECORDS

sales_addr_latest <- sales_addr |>
  filter(
    addresses_start_valid <= sale_date,
    is.na(addresses_end_valid) | addresses_end_valid >= sale_date
  ) |>
  group_by(
    sales_full_address,
    sale_date,
    sales_price,
    sales_postcode,
    sales_house_number,
    sales_house_addition
  ) |>
  slice_max(addresses_start_valid, with_ties = FALSE) |>
  ungroup()

# DEDUPLICATE BAG

public_spaces_latest <- public_spaces |>
  group_by(public_spaces_id_public_space) |>
  slice_max(public_spaces_start_valid, with_ties = FALSE) |>
  ungroup()

towns_latest <- towns |>
  group_by(towns_id_town) |>
  slice_max(towns_start_valid, with_ties = FALSE) |>
  ungroup()

municipalities_latest <- municipalities |>
  group_by(municipalities_id_town) |>
  slice_max(municipalities_start_valid, with_ties = FALSE) |>
  ungroup()

# LINK PUBLIC SPACES -> TOWNS -> MUNICIPALITIES

sales_full <- sales_addr_latest |>
  
  # public spaces
  left_join(
    public_spaces_latest,
    by = join_by(addresses_id_public_space == public_spaces_id_public_space)
  ) |>
  
  # towns
  left_join(
    towns_latest,
    by = join_by(public_spaces_id_town == towns_id_town)
  ) |>
  
  # municipalities
  left_join(
    municipalities_latest,
    by = join_by(public_spaces_id_town == municipalities_id_town)
  )

#  IDENTIFY MUNICIPALITY: ’s-Hertogenbosch

den_bosch_town_ids <- towns_latest |>
  filter(towns_name == "'s-Hertogenbosch") |>
  pull(towns_id_town) |>
  unique()

den_bosch_mun_ids <- municipalities_latest |>
  filter(municipalities_id_town %in% den_bosch_town_ids) |>
  pull(municipalities_id_municipality) |>
  unique()

# FILTER SALES BY DEN BOSCH


sales_den_bosch_2024 <- sales_full |>
  filter(
    municipalities_id_municipality %in% den_bosch_mun_ids,
    sale_date >= as.Date("2024-01-01"),
    sale_date <= as.Date("2024-12-31")
  )


sales_den_bosch_2024 |>
  group_by(towns_name) |>
  summarise(
    n_sales      = n(),
    avg_price    = mean(sales_price, na.rm = TRUE),
    median_price = median(sales_price, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(towns_name)


group_by(towns_name) |>
  summarise(
    n_sales      = n(),
    avg_price    = mean(sales_price, na.rm = TRUE),
    median_price = median(sales_price, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(towns_name)
