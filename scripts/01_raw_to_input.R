# 01_raw_to_input.R
# Stage 1: Raw → Cleaned *_input datasets
# - Read raw CSVs
# - Fix types, whitespace, casing
# - Parse dates
# - Keep latest active BAG records per ID
# - Derive structured fields (e.g. split sales address)
# NO validation decisions here (that’s Stage 2 with validate)


# -------------------------------------------------------------------
# 0. Folders & unzip
# -------------------------------------------------------------------

dir.create("01_raw/data", showWarnings = FALSE, recursive = TRUE)
dir.create("02_input/data", showWarnings = FALSE, recursive = TRUE)

# If the buildings_register.zip is in 01_raw/data, unzip (idempotent)
zip_path <- "01_raw/data/buildings_register.zip"
if (file.exists(zip_path)) {
  unzip(zip_path, exdir = "01_raw/data")
  
  # Fix possible nested folder: 01_raw/data/buildings_register/*
  unzipped_dir <- file.path("01_raw/data", "buildings_register")
  if (dir.exists(unzipped_dir)) {
    files_to_move <- list.files(unzipped_dir, full.names = TRUE)
    file.rename(files_to_move, file.path("01_raw/data", basename(files_to_move)))
    unlink(unzipped_dir, recursive = TRUE)
  }
}

# -------------------------------------------------------------------
# 1. Read RAW data 
# -------------------------------------------------------------------

addresses_raw <- read_csv(
  "01_raw/data/nummeraanduidingen.csv",
  col_types = cols(
    id                   = col_character(),
    postcode             = col_character(),
    huisnummer           = col_integer(),
    huisnummertoevoeging = col_character(),
    openbareruimte       = col_character(),
    begin_geldigheid     = col_character(),
    eind_geldigheid      = col_character()
  )
)

dwellings_raw <- read_csv(
  "01_raw/data/verblijfsobjecten.csv",
  col_types = cols(
    id               = col_character(),
    gebruiksdoel     = col_character(),
    oppervlakte      = col_integer(),
    status           = col_character(),
    hoofdadres       = col_character(),
    pand             = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character(),
    x                = col_double(),
    y                = col_double()
  )
)

public_spaces_raw <- read_csv(
  "01_raw/data/openbareruimte.csv",
  col_types = cols(
    id               = col_character(),
    naam             = col_character(),
    type             = col_character(),
    woonplaats       = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character()
  )
)

towns_raw <- read_csv(
  "01_raw/data/woonplaatsen.csv",
  col_types = cols(
    id               = col_character(),
    naam             = col_character(),
    status           = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character(),
    x                = col_double(),
    y                = col_double()
  )
)

municipalities_raw <- read_csv(
  "01_raw/data/gemeente_woonplaats.csv",
  col_types = cols(
    woonplaats_id    = col_character(),
    gemeente_id      = col_character(),
    status           = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character()
  )
)

buildings_raw <- read_csv(
  "01_raw/data/panden.csv",
  col_types = cols(
    id               = col_character(),
    bouwjaar         = col_integer(),
    pandstatus       = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character(),
    x                = col_double(),
    y                = col_double()
  )
)

sales_raw <- read_csv(
  "01_raw/data/sales.csv",
  col_types = cols(
    address     = col_character(),
    postcode    = col_character(),
    city        = col_character(),
    sales_price = col_integer(),
    sale_date   = col_character()
  )
)

# -------------------------------------------------------------------
# 2. Transform → *_input 
# -------------------------------------------------------------------

# ---- ADDRESSES ---- #

addresses_input <- addresses_raw |> 
  mutate(
    id_address = id,
    addresses_postcode = postcode |> str_squish() |> str_remove_all(" ") |> str_to_upper(),
    addresses_house_number = huisnummer,
    addresses_house_addition = huisnummertoevoeging |> 
      str_squish() |> str_to_upper() |> na_if(""),
    
    addresses_id_public_space = openbareruimte,
    addresses_start_valid = ymd(begin_geldigheid),
    addresses_end_valid   = ymd(eind_geldigheid)
  ) |> 
  
  arrange(id_address, desc(addresses_start_valid)) |> 
  group_by(id_address) |> 
  slice(1) |> 
  ungroup() |> 
  
  distinct(id_address, .keep_all = TRUE) |> 
  
  filter(
    !is.na(addresses_postcode),
    !is.na(addresses_house_number),
    !is.na(addresses_id_public_space),
    str_detect(addresses_postcode, "^[0-9]{4}[A-Z]{2}$")
  ) |> 
  
  arrange(id_address)

write_rds(addresses_input, "02_input/data/addresses_input.rds")

# ---- PUBLIC SPACES ---- #

public_spaces_input <- public_spaces_raw |> 
  mutate(
    public_spaces_id_public_space = id,
    public_spaces_name            = naam |> str_squish() |> str_to_title(),
    public_spaces_type            = type |> str_squish() |> str_to_lower(),
    public_spaces_id_town         = woonplaats,
    public_spaces_start_valid     = ymd(begin_geldigheid),
    public_spaces_end_valid       = ymd(eind_geldigheid)
  ) |> 
  
  arrange(public_spaces_id_public_space, desc(public_spaces_start_valid)) |> 
  group_by(public_spaces_id_public_space) |> 
  slice(1) |> 
  ungroup() |> 
  
  filter(public_spaces_type == "weg") |> 
  filter(!is.na(public_spaces_id_town)) |> 
  
  distinct(public_spaces_id_public_space, .keep_all = TRUE)

write_rds(public_spaces_input, "02_input/data/public_spaces_input.rds")

# ---- DWELLINGS ---- #

dwellings_input <- dwellings_raw |> 
  mutate(
    dwellings_id_dwelling   = id,
    dwellings_usage_purpose = gebruiksdoel |> str_squish() |> str_to_lower(),
    dwellings_area_m2       = oppervlakte,
    dwellings_status        = status |> str_squish() |> str_to_lower(),
    dwellings_id_address    = hoofdadres,
    dwellings_id_building   = pand,
    dwellings_start_valid   = ymd(begin_geldigheid),
    dwellings_end_valid     = ymd(eind_geldigheid),
    dwellings_x_coord       = x,
    dwellings_y_coord       = y
  ) |> 
  
  arrange(dwellings_id_dwelling, desc(dwellings_start_valid)) |> 
  group_by(dwellings_id_dwelling) |> 
  slice(1) |> 
  ungroup() |> 
  
  filter(
    dwellings_usage_purpose == "woonfunctie",
    dwellings_status %in% c(
      "verblijfsobject in gebruik",
      "verblijfsobject in gebruik (niet ingemeten)"
    ),
    !is.na(dwellings_id_address),
    !is.na(dwellings_id_building),
    !is.na(dwellings_x_coord),
    !is.na(dwellings_y_coord)
  ) |> 
  
  distinct(dwellings_id_dwelling, .keep_all = TRUE)

write_rds(dwellings_input, "02_input/data/dwellings_input.rds")


# ---- TOWNS ---- #

towns_input <- towns_raw |> 
  mutate(
    towns_id_town     = id,
    towns_name        = naam |> str_squish() |> str_to_title(),
    towns_status      = status |> str_squish() |> str_to_lower(),
    towns_start_valid = ymd(begin_geldigheid),
    towns_end_valid   = ymd(eind_geldigheid),
    towns_x_coord     = x,
    towns_y_coord     = y
  ) |> 
  
  mutate(
    towns_name = towns_name |>
      str_remove("\\s+[Nn][Bb]$") |>
      str_remove("\\sGem.*$") |>
      str_replace("^Rijkevoort-De Walsert$", "Rijkevoort") |>
      str_replace("^'S-Hertogenbosch$", "'s-Hertogenbosch")
  ) |> 
  
  arrange(towns_id_town, desc(towns_start_valid)) |> 
  group_by(towns_id_town) |> 
  slice(1) |> 
  ungroup() |> 
  
  filter(!is.na(towns_x_coord), !is.na(towns_y_coord)) |> 
  
  distinct(towns_id_town, .keep_all = TRUE)

write_rds(towns_input, "02_input/data/towns_input.rds")


# ---- MUNICIPALITIES ---- #

municipalities_input <- municipalities_raw |> 
  mutate(
    municipalities_id_town         = woonplaats_id,
    municipalities_id_municipality = gemeente_id,
    municipalities_status          = status |> str_squish() |> str_to_lower(),
    municipalities_start_valid     = ymd(begin_geldigheid),
    municipalities_end_valid       = ymd(eind_geldigheid)
  ) |> 
  
  arrange(municipalities_id_town, desc(municipalities_start_valid)) |> 
  group_by(municipalities_id_town) |> 
  slice(1) |> 
  ungroup() |> 
  
  filter(municipalities_status == "definitief") |> 
  
  distinct(municipalities_id_town, .keep_all = TRUE)

write_rds(municipalities_input, "02_input/data/municipalities_input.rds")

# ---- BUILDINGS ---- #

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
  
  arrange(buildings_id_building, desc(buildings_start_valid)) |> 
  group_by(buildings_id_building) |> 
  slice(1) |> 
  ungroup() |> 
  
  filter(
    buildings_status %in% c("pand in gebruik", "pand in gebruik (niet ingemeten)"),
    !is.na(buildings_x_coord),
    !is.na(buildings_y_coord)
  ) |> 
  
  distinct(buildings_id_building, .keep_all = TRUE)

write_rds(buildings_input, "02_input/data/buildings_input.rds")

# ---- SALES ---- #

sales_input <- sales_raw |> 
  mutate(
    sales_postcode = postcode |> str_squish() |> str_remove_all(" ") |> str_to_upper(),
    sales_town_name = city |> str_squish() |> str_to_title(),
    sales_full_address = address,
    sales_price = as.numeric(sales_price),
    sale_date = ymd(sale_date)
  ) |> 
  
  extract(
    col   = sales_full_address,
    into  = c("sales_street_name", "sales_house_number", "sales_house_addition"),
    regex = "^(.+?)\\s+(\\d{1,4})(?:[\\s-]*([A-Za-z0-9]+))?.*$",
    remove = FALSE
  ) |> 
  
  mutate(
    sales_street_name    = str_squish(sales_street_name) |> str_to_title(),
    sales_house_number   = as.integer(sales_house_number),
    sales_house_addition = str_squish(sales_house_addition) |> str_to_upper() |> na_if("")
  ) |> 
  
  filter(
    !is.na(sales_postcode),
    !is.na(sales_house_number),
    str_detect(sales_postcode, "^[0-9]{4}[A-Z]{2}$")
  ) |> 
  
  distinct()

write_rds(sales_input, "02_input/data/sales_input.rds")

cat("✔ Stage 1 completed — Cleaned *_input datasets written to 02_input/data/")