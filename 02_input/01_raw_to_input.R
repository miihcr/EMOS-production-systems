# 01_raw_to_input.R
# Convert RAW BAG + sales data → INPUT (Steady State 1)

# Helper functions

clean_house_addition <- function(x) {
  x |> 
    str_squish() |>                 # remove external whitespace
    str_replace_all("\\s+", "") |>  # remove ANY whitespace variants
    str_to_upper() |> 
    na_if("")                       # empty → NA
}

clean_postcode <- function(x) {
  x <- x |> 
    str_replace_all(" ", "") |> 
    str_to_upper()
  
  if_else(
    str_detect(x, "^[1-9][0-9]{3}[A-Z]{2}$"),
    x,
    NA_character_
  )
}


# Step 1: Read raw data (all IDs forced to character)


sales_raw <- read_csv(
  "01_raw/data/sales.csv",
  col_types = cols(.default = col_character())
)

addresses_raw <- read_csv(
  "01_raw/data/addresses.csv",
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

public_spaces_raw <- read_csv(
  "01_raw/data/public_spaces.csv",
  col_types = cols(
    id               = col_character(),
    naam             = col_character(),
    type             = col_character(),
    woonplaats       = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character()
  )
)

dwellings_raw <- read_csv(
  "01_raw/data/dwellings.csv",
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

towns_raw <- read_csv(
  "01_raw/data/towns.csv",
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
  "01_raw/data/municipalities.csv",
  col_types = cols(
    woonplaats_id    = col_character(),
    gemeente_id      = col_character(),
    status           = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character()
  )
)

buildings_raw <- read_csv(
  "01_raw/data/buildings.csv",
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

# 2. Clean SALES

sales_input <- sales_raw |> 
  mutate(
    address = str_squish(str_to_lower(address))
  ) |> 
  extract(
    col   = address,
    into  = c("street_name", "house_number", "house_addition"),
    regex = "^\\s*(.+?)\\s+(\\d{1,5})(?:\\s*[-/ ]?\\s*([A-Za-z0-9]{1,4}))?\\s*$",
    remove = FALSE
  ) |> 
  mutate(
    street_name   = street_name |> str_squish() |> str_to_lower(),
    house_number  = as.integer(house_number),
    house_addition= clean_house_addition(house_addition),
    postcode      = clean_postcode(postcode),
    
    city = city |>
      str_to_lower() |>
      str_replace_all("[^a-z0-9 ]", "") |>
      str_squish(),
    
    sales_price = as.numeric(sales_price),
    price_eur   = sales_price * 1000,
    sale_date   = ymd(sale_date),
    
    sale_year = lubridate::year(sale_date),
    sale_month = lubridate::month(sale_date, label = TRUE, abbr = FALSE)
  ) |> 
  select(
    street_name, house_number, house_addition,
    postcode, city, sale_date, price_eur,
    sale_year, sale_month
  )


# 3. Clean ADDRESSES

addresses_input <- addresses_raw |> 
  rename(
    house_number   = huisnummer,
    house_addition = huisnummertoevoeging
  ) |> 
  mutate(
    postcode        = clean_postcode(postcode),
    house_number    = as.integer(house_number),
    house_addition  = clean_house_addition(house_addition),
    address_id      = id,
    public_space_id = openbareruimte,
    start_valid     = ymd(begin_geldigheid),
    end_valid       = ymd(eind_geldigheid)
  ) |> 
  select(
    address_id, postcode, house_number, house_addition,
    public_space_id, start_valid, end_valid
  )

# 4. Clean PUBLIC SPACES

public_spaces_input <- public_spaces_raw |> 
  mutate(
    public_space_id   = id,
    public_space_name = naam |> str_to_lower() |> str_squish(),
    public_space_type = type |> str_to_lower() |> str_squish(),
    town_id           = woonplaats,
    start_valid       = ymd(begin_geldigheid),
    end_valid         = ymd(eind_geldigheid)
  ) |> 
  select(
    public_space_id, public_space_name, public_space_type,
    town_id, start_valid, end_valid
  )

# 5. Clean DWELLINGS

dwellings_input <- dwellings_raw |> 
  mutate(
    dwelling_id  = id,
    address_id   = hoofdadres,
    id_building  = pand,
    start_valid  = ymd(begin_geldigheid),
    end_valid    = ymd(eind_geldigheid),
    area_m2      = oppervlakte
  ) |> 
  select(
    dwelling_id, address_id, id_building, start_valid,
    end_valid, gebruiksdoel, area_m2, x, y
  )


# 6. Clean TOWNS

towns_input <- towns_raw |> 
  mutate(
    town_id     = id,
    town_name   = naam |> str_to_lower() |> str_squish(),
    start_valid = ymd(begin_geldigheid),
    end_valid   = ymd(eind_geldigheid)
  ) |> 
  select(
    town_id, town_name, start_valid, end_valid, status, x, y
  )



# 7. Clean MUNICIPALITIES

municipalities_input <- municipalities_raw |> 
  mutate(
    town_id         = woonplaats_id,
    municipality_id = gemeente_id,
    start_valid     = ymd(begin_geldigheid),
    end_valid       = ymd(eind_geldigheid)
  ) |> 
  select(town_id, municipality_id, status, start_valid, end_valid)


# 8. Deduplicate BAG data 


addresses_clean <- addresses_input |>
  arrange(address_id, start_valid) |>
  distinct(address_id, .keep_all = TRUE)

public_spaces_clean <- public_spaces_input |>
  arrange(public_space_id, start_valid) |>
  distinct(public_space_id, .keep_all = TRUE)

towns_clean <- towns_input |>
  arrange(town_id, start_valid) |>
  distinct(town_id, .keep_all = TRUE)

municipalities_clean <- municipalities_input |>
  arrange(town_id, start_valid) |>
  distinct(town_id, .keep_all = TRUE)

buildings_clean <- buildings_raw |>
  arrange(id, begin_geldigheid) |>
  distinct(id, .keep_all = TRUE)



# Step 8: Write Steady State 1 files

# dir.create("02_input/data/", recursive = TRUE)

# write_rds(sales_input,         "02_input/data/sales_input.rds")
# write_rds(addresses_input,     "02_input/data/addresses_input.rds")
# write_rds(dwellings_input,     "02_input/data/dwellings_input.rds")
# write_rds(public_spaces_input, "02_input/data/public_spaces_input.rds")
# write_rds(towns_input,         "02_input/data/towns_input.rds")
# write_rds(municipalities_input,"02_input/data/municipalities_input.rds")