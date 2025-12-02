# 03_valid/unique_to_valid

# Create if needed

dir.create("03_valid/data", showWarnings = FALSE, recursive = TRUE)

# 1. LOAD CLEAN INPUT FILES 

addresses      <- read_rds("02_input/data/addresses_input.rds")
dwellings      <- read_rds("02_input/data/dwellings_input.rds")
public_spaces  <- read_rds("02_input/data/public_spaces_input.rds")
towns          <- read_rds("02_input/data/towns_input.rds")
municipalities <- read_rds("02_input/data/municipalities_input.rds")
buildings      <- read_rds("02_input/data/buildings_input.rds")
sales          <- read_rds("02_input/data/sales_input.rds")

# 2. VALIDATE ADDRESSES

addresses_valid <- addresses |>
  mutate(
    addresses_postcode = if_else(
      str_detect(addresses_postcode, "^[0-9]{4}[A-Z]{2}$"),
      addresses_postcode,
      NA_character_
    ),
    addresses_house_number = if_else(
      addresses_house_number > 0,
      addresses_house_number,
      NA_integer_
    )
  )

write_rds(addresses_valid, "03_valid/data/addresses_valid.rds")


# 3. VALIDATE DWELLINGS

dwellings_valid <- dwellings |>
  mutate(
    dwellings_area_m2 = na_if(dwellings_area_m2, 0),
    dwellings_area_m2 = na_if(dwellings_area_m2, 1),
    dwellings_area_m2 = na_if(dwellings_area_m2, 9999),
    dwellings_area_m2 = if_else(
      dwellings_area_m2 < 10 | dwellings_area_m2 > 6000,
      NA_integer_,
      dwellings_area_m2
    ),
    dwellings_usage_purpose = dwellings_usage_purpose |>
      str_squish() |>
      str_to_lower(),
    dwellings_status = dwellings_status |>
      str_squish() |>
      str_to_lower()
  ) |>
  # Keep only residential use
  filter(dwellings_usage_purpose == "woonfunctie") # |>
  # Keep only real and in-use dwellings
  # filter(dwellings_status %in% c(
  #   "verblijfsobject in gebruik",
   #  "verblijfsobject in gebruik (niet ingemeten)"
  # ))

write_rds(dwellings_valid, "03_valid/data/dwellings_valid.rds")

# 4. VALIDATE BUILDINGS

buildings_valid <- buildings |>
  mutate(
    buildings_construction_year = na_if(buildings_construction_year, 0),
    buildings_construction_year = na_if(buildings_construction_year, 1),
    buildings_construction_year = na_if(buildings_construction_year, 9999),
    buildings_construction_year = if_else(
      buildings_construction_year < 1800,
      NA_integer_,
      buildings_construction_year
    ),
    buildings_construction_year = if_else(
      buildings_construction_year > 2026,
      NA_integer_,
      buildings_construction_year
    ),
    # drop very old buildings prior to 1965
    buildings_construction_year = if_else(
      buildings_construction_year < 1965,
      NA_integer_,
      buildings_construction_year
    )
  )

write_rds(buildings_valid, "03_valid/data/buildings_valid.rds")

# 5. VALIDATE PUBLIC SPACES

public_spaces_valid <- public_spaces |>
  mutate(
    public_spaces_name = str_squish(public_spaces_name),
    public_spaces_type = str_squish(public_spaces_type)
  )

write_rds(public_spaces_valid, "03_valid/data/public_spaces_valid.rds")


# 6. VALIDATE TOWNS

towns_valid <- towns |>
  mutate(
    towns_name   = towns_name   |> str_squish(),
    towns_status = towns_status |> str_squish() |> str_to_lower()
  )

write_rds(towns_valid, "03_valid/data/towns_valid.rds")

# 7. VALIDATE MUNICIPALITIES


municipalities_valid <- municipalities |>
  mutate(
    municipalities_status = municipalities_status |>
      str_squish() |>
      str_to_lower()
  )

write_rds(municipalities_valid, "03_valid/data/municipalities_valid.rds")


# 8. VALIDATE SALES

# Standardize prices - convert everything to whole euros
sales_validation_flags <- sales |>
  mutate(
    # Determine unit and convert ALL to whole euros
    sales_price_euros = case_when(
      sales_price >= 10000 ~ sales_price,           # Already in whole euros
      sales_price >= 100 ~ sales_price * 1000,      # In k€, convert to euros
      TRUE ~ NA_real_                                # Suspiciously low, flag as invalid
    ),
    
    # Also keep k€ version for reference
    sales_price_k = sales_price_euros / 1000,
    
    # Clean postcode (remove any spaces)
    sales_postcode_clean = str_remove_all(sales_postcode, "\\s+"),
    
    # Validation flags
    flag_missing_postcode = is.na(sales_postcode),
    flag_invalid_postcode_format = !is.na(sales_postcode_clean) & 
      !str_detect(sales_postcode_clean, "^[0-9]{4}[A-Z]{2}$"),
    flag_invalid_house_number = is.na(sales_house_number) | sales_house_number <= 0,
    flag_invalid_price = is.na(sales_price_euros) | sales_price_euros <= 0,
    flag_suspicious_low = !is.na(sales_price) & sales_price < 100,  # < 100k seems wrong
    flag_invalid_date = is.na(sale_date) | year(sale_date) != 2024,
    
    # Combined flag for hard errors
    flag_any_error = flag_missing_postcode | flag_invalid_postcode_format | 
      flag_invalid_house_number | flag_invalid_price | flag_invalid_date
  )

# Check the standardization worked

sample_check <- sales_validation_flags |>
  filter(!flag_any_error) |>
  select(sales_full_address, original = sales_price, 
         standardized_euros = sales_price_euros, standardized_k = sales_price_k) |>
  slice_sample(n = 10)
print(sample_check)

# Final valid dataset - USE EUROS as standard
sales_valid <- sales_validation_flags |>
  filter(!flag_any_error) |>
  select(
    sales_full_address, sales_street_name, sales_house_number,
    sales_house_addition, sales_postcode = sales_postcode_clean,
    sales_town_name, 
    sales_price_euros,  # Standardized in whole euros
    sale_date
  )

write_rds(sales_valid, "03_valid/data/sales_valid.rds")


message("03_valid stage completed ✓ — validated datasets created.")


