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

# assuming one valid BAG record per address on 2024-01-01

addresses_latest <- addresses |>
  filter(is.na(addresses_end_valid) | addresses_end_valid >= ref_date) |>
  arrange(
    addresses_postcode,
    addresses_house_number,
    addresses_house_addition,
    desc(addresses_start_valid)
  ) |>
  mutate(
    join_house_addition = coalesce(addresses_house_addition, "") |>
      str_trim() |> str_to_upper()
  ) |>
  distinct(
    addresses_postcode,
    addresses_house_number,
    join_house_addition,
    .keep_all = TRUE
  )


public_spaces_latest <- public_spaces |>
  filter(is.na(public_spaces_end_valid) | public_spaces_end_valid >= ref_date) |>
  arrange(public_spaces_id_public_space, desc(public_spaces_start_valid)) |>
  distinct(public_spaces_id_public_space, .keep_all = TRUE)

towns_latest <- towns |>
  filter(is.na(towns_end_valid) | towns_end_valid >= ref_date) |>
  arrange(towns_id_town, desc(towns_start_valid)) |>
  distinct(towns_id_town, .keep_all = TRUE)

municipalities_latest <- municipalities |>
  filter(is.na(municipalities_end_valid) | municipalities_end_valid >= ref_date) |>
  arrange(municipalities_id_town, desc(municipalities_start_valid)) |>
  distinct(municipalities_id_town, .keep_all = TRUE)

buildings_latest <- buildings |>
  arrange(buildings_id_building, desc(buildings_start_valid)) |>
  distinct(buildings_id_building, .keep_all = TRUE)



# NORMALIZE SALES HOUSE ADDITION

sales <- sales |>
  mutate(
    join_house_addition = coalesce(sales_house_addition, "") |>
      str_trim() |> str_to_upper()
  )

# JOIN SALES AND ADDRESSES

sales_addr <- sales |>
  left_join(
    addresses_latest,
    by = join_by(
      sales_postcode      == addresses_postcode,
      sales_house_number  == addresses_house_number,
      join_house_addition == join_house_addition
    )
  )

stopifnot(nrow(sales) == nrow(sales_addr))


# CHECK ABOUT VALIDITY AT THE TIME OF SALE BUT DON'T DROP

sales_addr_latest <- sales_addr |>
  mutate(
    address_valid_at_sale =
      !is.na(addresses_start_valid) &
      addresses_start_valid <= sale_date &
      (is.na(addresses_end_valid) | addresses_end_valid >= sale_date)
  )

stopifnot(nrow(sales) == nrow(sales_addr_latest))



# COLLAPSE DWELLINGS -> ONE ROW PER ADDRESS

dwellings_res <- dwellings |>
  group_by(dwellings_id_address) |>
  summarise(
    dwellings_n_units    = n(),
    dwellings_total_area = sum(dwellings_area_m2, na.rm = TRUE),
    dwellings_mean_area  = mean(dwellings_area_m2, na.rm = TRUE),
    .groups = "drop"
  )


# JOIN SALES TO ADDRESSES TO DWELLINGS

sales_addr_dwell <- sales_addr_latest |>
  left_join(
    dwellings_res,
    by = join_by(id_address == dwellings_id_address)
  )

stopifnot(nrow(sales) == nrow(sales_addr_dwell))

# JOIN TO PUBLIC SPACE + TOWN + MUNICIPALITY

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

stopifnot(nrow(sales) == nrow(sales_full))


# IDENTIFY ’S-HERTOGENBOSCH / DEN BOSCH

den_bosch_town_ids <- towns_latest |>
  filter(str_detect(towns_name, "(?i)hertogenbosch|den bosch")) |>
  pull(towns_id_town)

den_bosch_mun_ids <- municipalities_latest |>
  filter(municipalities_id_town %in% den_bosch_town_ids) |>
  pull(municipalities_id_municipality)

# FILTER SALES IN DEN BOSCH (2024) 

sales_denbosch_2024 <- sales_full |>
  filter(
    municipalities_id_municipality %in% den_bosch_mun_ids
    # sale_date >= as.Date("2024-01-01"),
    # sale_date <= as.Date("2024-12-31")
  )

write_rds(
  sales_denbosch_2024,
  "03_valid/data/sales_denbosch_2024.rds"
)


# COMPUTE STATISTICS

stats_out <- sales_denbosch_2024 |>
  group_by(towns_name) |>
  summarise(
    n_sales      = n(),
    avg_price    = mean(sales_price_euros, na.rm = TRUE),
    median_price = median(sales_price_euros, na.rm = TRUE),
    min_price    = min(sales_price_euros, na.rm = TRUE),
    max_price    = max(sales_price_euros, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(towns_name)

stats_out


stats_out_rounded <- sales_denbosch_2024 |>
  group_by(towns_name) |>
  summarise(
    n_sales      = n(),
    avg_price    = round(mean(sales_price_euros, na.rm = TRUE), 0),
    median_price = round(median(sales_price_euros, na.rm = TRUE), 0),
    min_price    = min(sales_price_euros, na.rm = TRUE),
    max_price    = max(sales_price_euros, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(towns_name)


stats_out_rounded

# Disclosure control (still needs to be modified)

threshold <- 10


# We first need to identify which cell is safe to absorb the values under the threshold
receiver <- stats_out |>
  filter(n_sales >= threshold) |>
  slice_max(n_sales, 
            n = 1,
            with_ties = FALSE) |>
  pull(towns_name)

# We now detect the towns under the threshold

absorbed_towns <- stats_out |>
  filter(n_sales < threshold) |>
  pull(towns_name)

# We combine the names of the towns (absorbed and the one that abosrbs)

if (length(absorbed_towns) > 0) {
  combined_name <- paste0(receiver, " and ", paste(absorbed_towns, 
                                                   collapse = ", "))
} else {
  combined_name <- receiver
}

# We now aggregate the towns' totals
small_totals <- sales_denbosch_2024 |>
  filter(towns_name %in% absorbed_towns) |>
  summarise(
    extra_n = n(),
    extra_value = sum(sales_price_euros, na.rm = TRUE)
  )

# We create the new table
stats_out_protected <- stats_out |>
  filter(n_sales >= threshold) |> 
  mutate(total_value = n_sales*avg_price) |>
  mutate(n_sales = if_else(towns_name == receiver,
                           n_sales + small_totals$extra_n,
                           n_sales),
         total_value = if_else(towns_name == receiver,
                               total_value + small_totals$extra_value,
                               total_value),
         avg_price = total_value / n_sales,
         towns_name = if_else(towns_name == receiver,
                              combined_name,
                              towns_name)) |>
  select(-total_value)

stats_out_protected

# Unprotected 
write_csv(stats_out, 
          "04_stats/data/denbosch_woonplaats_stats_2024_raw.csv")

# Protected with SDC
write_csv(stats_out_protected, 
          "04_stats/data/denbosch_woonplaats_stats_2024_protected.csv")

write_rds(stats_out_protected, 
          "04_stats/data/denbosch_woonplaats_stats_2024_protected.rds")


write_csv(stats_out_protected, 
          "05_output/denbosch_woonplaats_stats_2024_protected.csv")


message("04_stats stage completed ✓ — corrected statistics created.")
