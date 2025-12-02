# 02_input/raw_to_input.R 

# Convert RAW to INPUT

# Create folder if needed
dir.create("02_input/data", showWarnings = FALSE, recursive = TRUE)


# 1. LOAD RAW FILES ALREADY WITH CORRECT DATA TYPES

addresses_raw      <- read_rds("01_raw/data/addresses_raw.rds")

dwellings_raw      <- read_rds("01_raw/data/dwellings_raw.rds")

public_spaces_raw  <- read_rds("01_raw/data/public_spaces_raw.rds")

towns_raw          <- read_rds("01_raw/data/towns_raw.rds")

municipalities_raw <- read_rds("01_raw/data/municipalities_raw.rds")

buildings_raw      <- read_rds("01_raw/data/buildings_raw.rds")

sales_raw          <- read_rds("01_raw/data/sales_raw.rds")

# 2. CLEAN ADDRESSES

addresses_input <- addresses_raw |>
  mutate(
    id_address                 = id,
    addresses_postcode         = postcode |> str_squish() |> str_to_upper(),
    addresses_house_number     = huisnummer,
    addresses_house_addition   = huisnummertoevoeging |> str_squish() |> str_to_upper(),
    addresses_id_public_space  = openbareruimte,
    addresses_start_valid      = ymd(begin_geldigheid),
    addresses_end_valid        = ymd(eind_geldigheid)
  ) |>
  select(
    id_address, addresses_postcode, addresses_house_number,
    addresses_house_addition, addresses_id_public_space,
    addresses_start_valid, addresses_end_valid
  ) |> 
  distinct() # remove exact duplicates

write_csv(addresses_input, "02_input/data/addresses_input.csv")
write_rds(addresses_input,  "02_input/data/addresses_input.rds")

# ------------------------------------------------------------
# 3. CLEAN PUBLIC SPACES
# ------------------------------------------------------------

public_spaces_input <- public_spaces_raw |>
  mutate(
    public_spaces_id_public_space = id,
    public_spaces_name            = naam |> str_squish() |> str_to_lower(),
    public_spaces_type            = type |> str_squish() |> str_to_lower(),
    public_spaces_id_town         = woonplaats,
    public_spaces_start_valid     = ymd(begin_geldigheid),
    public_spaces_end_valid       = ymd(eind_geldigheid)
  ) |>
  select(
    public_spaces_id_public_space, public_spaces_name, public_spaces_type,
    public_spaces_id_town, public_spaces_start_valid, public_spaces_end_valid
  ) |> 
  distinct() # remove exact duplicates


write_csv(public_spaces_input, "02_input/data/public_spaces_input.csv")
write_rds(public_spaces_input,  "02_input/data/public_spaces_input.rds")
# ------------------------------------------------------------
# 4. CLEAN DWELLINGS
# ------------------------------------------------------------

dwellings_input <- dwellings_raw |>
  mutate(
    dwellings_id_dwelling    = id,
    dwellings_usage_purpose  = gebruiksdoel |> str_squish(),
    dwellings_area_m2        = oppervlakte,
    dwellings_status         = status |> str_squish() |> str_to_lower(),
    dwellings_id_address     = hoofdadres,
    dwellings_id_building    = pand,
    dwellings_start_valid    = ymd(begin_geldigheid),
    dwellings_end_valid      = ymd(eind_geldigheid),
    dwellings_x_coord        = x,
    dwellings_y_coord        = y
  ) |>
  select(
    dwellings_id_dwelling, dwellings_usage_purpose, dwellings_area_m2,
    dwellings_status, dwellings_id_address, dwellings_id_building,
    dwellings_start_valid, dwellings_end_valid, dwellings_x_coord, dwellings_y_coord
  ) |> 
  distinct() # remove exact duplicates


write_csv(dwellings_input, "02_input/data/dwellings_input.csv")
write_rds(dwellings_input, "02_input/data/dwellings_input.rds")

# ------------------------------------------------------------
# 5. CLEAN TOWNS
# ------------------------------------------------------------

towns_input <- towns_raw |>
  mutate(
    towns_id_town      = id,
    towns_name         = naam |> str_trim() |> str_to_title(),
    towns_status       = status |> str_squish() |> str_to_lower(),
    towns_start_valid  = ymd(begin_geldigheid),
    towns_end_valid    = ymd(eind_geldigheid),
    towns_x_coord      = x,
    towns_y_coord      = y
  ) |>
  mutate(
    towns_name = towns_name |>
      str_remove("\\s+[Nn][Bb]$") |>
      str_remove("\\sGem.*$") |>
      str_replace("^Rijkevoort-De Walsert$", "Rijkevoort") |>
      str_replace("^'S-Hertogenbosch$", "'s-Hertogenbosch")
  ) |>
  select(
    towns_id_town, towns_name, towns_status,
    towns_start_valid, towns_end_valid,
    towns_x_coord, towns_y_coord
  ) |> 
  distinct() # remove exact duplicates

write_csv(towns_input, "02_input/data/towns_input.csv")
write_rds(towns_input, "02_input/data/towns_input.rds")

# ------------------------------------------------------------
# 6. CLEAN MUNICIPALITIES
# ------------------------------------------------------------

municipalities_input <- municipalities_raw |>
  mutate(
    municipalities_id_town         = woonplaats_id,
    municipalities_id_municipality = gemeente_id,
    municipalities_status          = status |> str_squish() |> str_to_lower(),
    municipalities_start_valid     = ymd(begin_geldigheid),
    municipalities_end_valid       = ymd(eind_geldigheid)
  ) |>
  select(
    municipalities_id_town,
    municipalities_id_municipality,
    municipalities_status,
    municipalities_start_valid,
    municipalities_end_valid
  ) |> 
  distinct() # remove exact duplicates

write_csv(municipalities_input, "02_input/data/municipalities_input.csv")
write_rds(municipalities_input, "02_input/data/municipalities_input.rds")

# ------------------------------------------------------------
# 7. CLEAN BUILDINGS
# ------------------------------------------------------------

buildings_input <- buildings_raw |>
  mutate(
    buildings_id_building       = id,
    buildings_construction_year = bouwjaar,
    buildings_status            = pandstatus |> str_squish() |> str_to_lower(),
    buildings_start_valid       = ymd(begin_geldigheid),
    buildings_end_valid         = ymd(eind_geldigheid),
    buildings_x_coord           = x,
    buildings_y_coord           = y
  ) |>
  select(
    buildings_id_building, buildings_construction_year, buildings_status,
    buildings_start_valid, buildings_end_valid,
    buildings_x_coord, buildings_y_coord
  )  |> 
  distinct() # remove exact duplicates

write_csv(buildings_input, "02_input/data/buildings_input.csv")
write_rds(buildings_input, "02_input/data/buildings_input.rds")

# ------------------------------------------------------------
# 8. CLEAN SALES
# ------------------------------------------------------------

sales_input <- sales_raw |>
  mutate(
    sales_full_address  = address,
    sales_postcode      = postcode |> str_squish() |> str_to_upper(),
    sales_town_name     = city |> str_squish(),
    sales_price_raw     = as.numeric(sales_price),
    sales_price         = if_else(sales_price_raw < 2000,
                                sales_price_raw * 1000,
                                sales_price_raw),
    sale_date           = ymd(sale_date)
  ) |> 
  select(sales_full_address, sales_postcode, sales_town_name,
         sales_price, sale_date) |> 
  extract(
    col   = sales_full_address,
    into  = c("sales_street_name", "sales_house_number", "sales_house_addition"),
    regex = "^(.+?)\\s+(\\d{1,4})(?:[\\s-]*([A-Za-z0-9]+))?.*$",
    remove = FALSE
  ) |>
  mutate(
    sales_street_name    = str_to_lower(str_squish(sales_street_name)),
    sales_house_number   = as.integer(sales_house_number),
    sales_house_addition = str_to_upper(str_squish(sales_house_addition))
  ) |>
  select(
    sales_full_address, sales_street_name, sales_house_number,
    sales_house_addition, sales_postcode, sales_town_name,
    sales_price, sale_date
  )

write_csv(sales_input, "02_input/data/sales_input.csv")
write_rds(sales_input, "02_input/data/sales_input.rds")


# ------------------------------------------------------------
# DONE
# ------------------------------------------------------------
message("02_input stage completed ✓ — cleaned input files created.")


