# Validation

sales        <- read_rds("data/cleaned/sales.rds")
addresses    <- read_rds("data/cleaned/addresses.rds")
dwellings    <- read_rds("data/cleaned/dwellings.rds")
public_spaces <- read_rds("data/cleaned/public_spaces.rds")
towns         <- read_rds("data/cleaned/towns.rds")
municipalities<- read_rds("data/cleaned/municipalities.rds")
buildings    <- read_rds("data/cleaned/buildings.rds")


# DWELLINGS

# residential (10-400m2)

# business (20-2000m2)

# maximum dwelling <= 6000 m2

dwellings <- dwellings |>
  mutate(
    # Fix area: missing-value codes
    area_m2 = na_if(area_m2, 0),
    area_m2 = na_if(area_m2, 1),
    area_m2 = na_if(area_m2, 9999),
    area_m2 = na_if(area_m2, 999999),
    
    # Replace impossible values
    area_m2 = ifelse(
      area_m2 < 10 | area_m2 > 6000, 
      NA,
      area_m2)
  )

# BUILDINGS

# years under 1965 and above 2026 should be NA

buildings <- buildings |>
  mutate(
    # Convert known missing-value codes to NA
    construction_year = na_if(construction_year, 0),
    construction_year = na_if(construction_year, 1),
    construction_year = na_if(construction_year, 9999),
    
    # Remove historically impossible years
    construction_year = ifelse(construction_year < 1800, NA, construction_year),
    
    # Remove future or unrealistic years
    construction_year = ifelse(construction_year > 2026, NA, construction_year),
    
    # Apply your rule: keep only post-1965 data
    construction_year = ifelse(construction_year < 1965, NA, construction_year)
  )

buildings |> 
  summarise(
    min_year = min(construction_year, na.rm = TRUE),
    max_year = max(construction_year, na.rm = TRUE),
    missing_years = sum(is.na(construction_year))
  )


# SALES

sales <- sales |> 
  mutate(
    town_name = town_name |> 
      str_replace("\\s+[Nn][Bb]$", "")
  )

table(sales$town_name, useNA = "ifany")


# Rename columns

# Sales

sales <- sales |> 
  rename(
    sales_full_address     = full_address,
    sales_street_name      = street_name,
    sales_house_number     = house_number,
    sales_house_addition   = house_addition,
    sales_postcode         = postcode,
    sales_town_name        = town_name,
  )


# Addresses
addresses <- addresses |> 
  rename(
    addresses_id_address       = id_address,
    addresses_id_public_space  = id_public_space,
    addresses_postcode         = postcode,
    addresses_house_number     = house_number,
    addresses_house_addition   = house_addition,
    addresses_start_valid      = start_valid,
    addresses_end_valid        = end_valid
  )


# Dwellings
dwellings <- dwellings |>
  rename(
    dwellings_id_dwelling    = id_dwelling,
    dwellings_usage_purpose  = usage_purpose,
    dwellings_area_m2        = area_m2,
    dwellings_status         = dwelling_status,
    dwellings_id_address     = id_address,
    dwellings_id_building    = id_building,
    dwellings_start_valid    = start_valid,
    dwellings_end_valid      = end_valid,
    dwellings_x_coord        = x_coord,
    dwellings_y_coord        = y_coord
  )


# Buildings

buildings <- buildings |>
  rename(
    buildings_id_building         = id_building,
    buildings_construction_year   = construction_year,
    buildings_status              = building_status,
    buildings_start_valid         = start_valid,
    buildings_end_valid           = end_valid,
    buildings_x_coord             = x_coord,
    buildings_y_coord             = y_coord
  )


# Public spaces
public_spaces <- public_spaces |>
  rename(
    public_spaces_id_public_space   = id_public_space,
    public_spaces_name              = public_space_name,
    public_spaces_type              = public_space_type,
    public_spaces_id_town           = id_town,
    public_spaces_start_valid       = start_valid,
    public_spaces_end_valid         = end_valid
  )


# Towns

towns <- towns |>
  rename(
    towns_id_town           = id_town,
    towns_name              = town_name,
    towns_status            = town_status,
    towns_start_valid       = start_valid,
    towns_end_valid         = end_valid,
    towns_x_coord           = x_coord,
    towns_y_coord           = y_coord
  )


# Municipalities

municipalities <- municipalities |>
  rename(
    municipalities_id_town           = id_town,
    municipalities_id_municipality   = id_municipality,
    municipalities_status            = municipality_status,
    municipalities_start_valid       = start_valid,
    municipalities_end_valid         = end_valid
  )



