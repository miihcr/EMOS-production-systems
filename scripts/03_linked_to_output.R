# 03_linked_to_output.R

# Step 0 — Load linked input 

linked_final         <- read_rds("data/processed/linked_final.rds")
municipalities_input <- read_rds("data/processed/municipalities_input.rds")
towns_input          <- read_rds("data/processed/towns_input.rds")

# Step 1 — Prepare municipality lookup (latest per town_id)

municipalities_clean <- municipalities_input |>
  arrange(id_town, desc(start_valid)) |>
  distinct(id_town, .keep_all = TRUE)

# Step 2 — Add municipality info

final <- linked_final |>
  left_join(
    municipalities_clean |> select(id_town, id_municipality),
    by = "id_town"
  ) |>
  mutate(
    flag_municip_link = if_else(!is.na(id_municipality), 1L, 0L)
  )

# Step 3 — Combined linkage success flag

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
    bag_house_add    = house_addition_bag,
    
    municipality_id  = id_municipality,
    dwelling_id      = id_dwelling
  )

# Step 5 — Select the final output structure

linked_dataset <- final |>
  select(
    # Identifiers
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
    id_town,
    
    # Dwelling attributes
    usage_purpose,
    area_m2,
    x_coord,
    y_coord,
    
    # Linkage info
    linkage_weight,
    flag_address_prob,
    flag_dwelling_link,
    flag_municip_link,
    linkage_success
  )

# Canonical final dataset

final_dataset <- final |>
  mutate(
    address_street    = coalesce(bag_street, sale_street),
    address_house_nr  = coalesce(bag_house_num, sale_house_num),
    address_house_add = coalesce(bag_house_add, sale_house_add),
    address_postcode  = coalesce(bag_postcode, sale_postcode),
    address_city      = coalesce(bag_city, sale_city)
  ) |>
  select(
    # Identifiers
    address_id,
    dwelling_id,
    id_building,
    municipality_id,
    
    # Canonical address
    address_street,
    address_house_nr,
    address_house_add,
    address_postcode,
    address_city,
    id_town,
    
    # Sales
    sale_date,
    price_eur,
    
    # Dwelling
    usage_purpose,
    area_m2,
    x_coord,
    y_coord,
    
    # Linkage flags
    linkage_weight,
    flag_address_prob,
    flag_dwelling_link,
    flag_municip_link,
    linkage_success
  )

# Step 6 — Save the final output

write_rds(final_dataset, "data/processed/final_dataset.rds")

message("SS4 successfully written to data/processed/final_dataset.rds")
