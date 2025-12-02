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


ref_date <- as.Date("2024-01-01")

# Addresses: unique per physical location

addresses_latest <- addresses |>
  filter(
    is.na(addresses_end_valid) | addresses_end_valid >= ref_date
  ) |>
  arrange(
    addresses_postcode,
    addresses_house_number,
    addresses_house_addition,
    desc(addresses_start_valid)
  ) |>
  distinct(
    addresses_postcode,
    addresses_house_number,
    addresses_house_addition,
    .keep_all = TRUE
  )

# PUBLIC SPACES
public_spaces_latest <- public_spaces |>
  filter(
    is.na(public_spaces_end_valid) | public_spaces_end_valid >= ref_date
  ) |>
  arrange(public_spaces_id_public_space, desc(public_spaces_start_valid)) |>
  distinct(public_spaces_id_public_space, .keep_all = TRUE)

# TOWNS
towns_latest <- towns |>
  filter(
    is.na(towns_end_valid) | towns_end_valid >= ref_date
  ) |>
  arrange(towns_id_town, desc(towns_start_valid)) |>
  distinct(towns_id_town, .keep_all = TRUE)

# MUNICIPALITIES
municipalities_latest <- municipalities |>
  filter(
    is.na(municipalities_end_valid) |
      municipalities_end_valid >= ref_date
  )


# Link SALES TO BAG ADDRESSES

sales_addr <- sales |>
  left_join(
    addresses_latest,
    by = join_by(
      sales_postcode       == addresses_postcode,
      sales_house_number   == addresses_house_number,
      sales_house_addition == addresses_house_addition
    )
  )

# Ensure BAG address was valid at sale date

sales_addr_latest <- sales_addr |>
  filter(
    addresses_start_valid <= sale_date,
    is.na(addresses_end_valid) | addresses_end_valid >= sale_date
  )


# 3. DEDUPLICATE DWELLINGS

dwellings_res <- dwellings  |>
  distinct(dwellings_id_dwelling, .keep_all = TRUE)


# SALES → ADDRESSES → DWELLINGS

sales_addr_dwell <- sales_addr_latest |>
  left_join(
    dwellings_res,
    by = join_by(id_address == dwellings_id_address)
  ) |>
  filter(!is.na(dwellings_id_dwelling))


# LINK TO TOWNS AND MUNICIPALITIES

sales_full <- sales_addr_dwell |>
  left_join(
    public_spaces_latest,
    by = join_by(addresses_id_public_space == public_spaces_id_public_space)
  ) |>
  left_join(
    towns_latest,
    by = join_by(public_spaces_id_town == towns_id_town)
  ) |>
  left_join(
    municipalities_latest,
    by = join_by(public_spaces_id_town == municipalities_id_town)
  )

# 5. Identify municipality 's-Hertogenbosch


den_bosch_town_ids <- towns_latest |>
  filter(str_detect(towns_name, "Hertogenbosch")) |>
  pull(towns_id_town)

den_bosch_mun_ids <- municipalities_latest |>
  filter(municipalities_id_town %in% den_bosch_town_ids) |>
  pull(municipalities_id_municipality)


# 7. Select SALES in that municipality (2024)

sales_denbosch_2024 <- sales_full |>
  filter(
    municipalities_id_municipality %in% den_bosch_mun_ids,
    sale_date >= as.Date("2024-01-01"),
    sale_date <= as.Date("2024-12-31")
  )


# COMPUTE STATISTICS

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


# Disclosure control


stats_out <- stats_out |>
  mutate(
    avg_price    = ifelse(n_sales < 5, NA_real_, avg_price),
    median_price = ifelse(n_sales < 5, NA_real_, median_price)
  )

print(stats_out)

# only save when we know it is correct

# write_csv(stats_out, "04_stats/data/denbosch_woonplaats_stats_2024.csv")
# write_rds(stats_out, "04_stats/data/denbosch_woonplaats_stats_2024.rds")

# message("04_stats stage completed ✓ — corrected statistics created.")


