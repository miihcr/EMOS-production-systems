# 03_linked_to_output.R
# Steady State 3 (linked) → Steady State 4 (final output tables)
# Prepares the final harmonised sales–BAG dataset


# Step 0 — Load linked input (SS3)


linked_sales_addresses <- read_rds("02_processed/linked_sales_addresses.rds")

addresses_input      <- read_rds("01_raw/data/input/addresses_input.rds")
dwellings_input      <- read_rds("01_raw/data/input/dwellings_input.rds")
municipalities_input <- read_rds("01_raw/data/input/municipalities_input.rds")
towns_input          <- read_rds("01_raw/data/input/towns_input.rds")



# Step 1 — Prepare municipality lookup (latest per town_id)


municipalities_clean <- municipalities_input |>
  arrange(town_id, desc(start_valid)) |>
  distinct(town_id, .keep_all = TRUE)


# Step 2 — Add municipality info

final <- linked_sales_addresses |>
  left_join(
    municipalities_clean |> select(town_id, municipality_id),
    by = "town_id"
  ) |>
  mutate(
    flag_municip_link = if_else(!is.na(municipality_id), 1L, 0L)
  )



# Step 3 — Combined linkage success flag
# A sale is "fully linked" if:
#  1) address was found via probabilistic linkage
#  2) dwelling was found
#  3) municipality was found


final <- final |>
  mutate(
    linkage_success =
      flag_address_prob *
      flag_dwelling_link *
      flag_municip_link
  )



# Step 4 — Standardise final variable names


final <- final |>
  rename(
    bag_postcode     = postcode_bag,
    bag_street       = street_name_bag,
    bag_city         = city_bag,
    sale_postcode    = postcode_sales,
    sale_street      = street_name_sales,
    sale_city        = city_sales,
    sale_house_num   = house_number_sales,
    sale_house_add   = house_addition_sales,
    bag_house_num    = house_number_bag,
    bag_house_add    = house_addition_bag
  )



# Step 5 — Select the final output structure


final_output <- final |>
  select(
    # Identifiers
    sale_id,
    address_id,
    dwelling_id,
    id_building,
    municipality_id,
    
    # Sales details
    sale_date,
    price_eur,
    sale_street,
    sale_house_num,
    sale_house_add,
    sale_postcode,
    sale_city,
    
    # BAG reference details
    bag_street,
    bag_house_num,
    bag_house_add,
    bag_postcode,
    bag_city,
    town_id,
    
    # Dwelling attributes
    gebruiksdoel,
    area_m2,
    x,
    y,
    
    # Linkage info
    linkage_weight,
    flag_address_prob,
    flag_dwelling_link,
    flag_municip_link,
    linkage_success
  )



# Step 6 — Save Steady State 4


# dir.create("03_final/output", recursive = TRUE, showWarnings = FALSE)

# write_rds(final_output, "03_final/output/final_dataset.rds")
# write_csv(final_output, "03_final/output/final_dataset.csv")

message("SS4 successfully written to 03_final/output/")
