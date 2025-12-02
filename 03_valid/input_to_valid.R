# 03_valid/input_to_valid

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
      str_to_lower()
  ) |>
  filter(dwellings_usage_purpose == "woonfunctie")

write_rds(dwellings_valid, "03_valid/data/dwellings_valid.rds")

# 4. VALIDATE BUILDINGS

buildings_valid <- buildings |>
  mutate(
    buildings_construction_year = na_if(buildings_construction_year, 0),
    buildings_construction_year = na_if(buildings_construction_year, 1),
    buildings_construction_year = na_if(buildings_construction_year, 9999),
    buildings_construction_year = if_else(buildings_construction_year < 1800, NA_integer_, buildings_construction_year),
    buildings_construction_year = if_else(buildings_construction_year > 2026, NA_integer_, buildings_construction_year),
    buildings_construction_year = if_else(buildings_construction_year < 1965, NA_integer_, buildings_construction_year)
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
    towns_name = towns_name |> str_squish(),
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


sales_valid <- sales |>
  mutate(
    sales_postcode = if_else(
      str_detect(sales_postcode, "^[0-9]{4}[A-Z]{2}$"),
      sales_postcode,
      NA_character_
    ),
    sales_house_number = if_else(
      sales_house_number > 0,
      sales_house_number,
      NA_integer_
    ),
    sales_price = if_else(
      sales_price <= 0,
      NA_real_,
      sales_price
    ),
    sale_date = ymd(sale_date)
  )

write_rds(sales_valid, "03_valid/data/sales_valid.rds")

message("03_valid stage completed ✓ — validated datasets created.")