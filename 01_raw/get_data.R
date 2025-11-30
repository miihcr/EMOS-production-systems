# get.data.R

# 1. Load all raw Dutch CSV files'

dir.create("data/processed", recursive = TRUE)


# --- 1. ADDRESSES --- #

addresses <- read_csv(
  "data/raw/nummeraanduidingen.csv",
  col_types = cols(
    id                   = col_character(),
    postcode             = col_character(),
    huisnummer           = col_integer(),
    huisnummertoevoeging = col_character(),
    openbareruimte       = col_character(),
    begin_geldigheid     = col_character(),
    eind_geldigheid      = col_character()
  )
) |>
  rename(
    id_address      = id,
    postal_code     = postcode,
    house_number    = huisnummer,
    house_addition  = huisnummertoevoeging,
    id_public_space = openbareruimte,
    valid_from      = begin_geldigheid,
    valid_to        = eind_geldigheid
  )

write_csv(addresses, "data/processed/addresses.csv")

# --- 2. PUBLIC SPACES --- #

public_spaces <- read_csv(
  "data/raw/openbareruimte.csv",
  col_types = cols(
    id               = col_character(),
    naam             = col_character(),
    type             = col_character(),
    woonplaats       = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character()
  )
) |>
  rename(
    id_public_space   = id,
    public_space_name = naam,
    public_space_type = type,
    id_town           = woonplaats,
    valid_from        = begin_geldigheid,
    valid_to          = eind_geldigheid
  )

write_csv(public_spaces, "data/processed/public_spaces.csv")

# --- 3. DWELLINGS --- #

dwellings <- read_csv(
  "data/raw/verblijfsobjecten.csv",
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
) |>
  rename(
    id_dwelling     = id,
    usage_purpose   = gebruiksdoel,
    area_m2         = oppervlakte,
    dwelling_status = status,
    id_address      = hoofdadres,
    id_building     = pand,
    valid_from      = begin_geldigheid,
    valid_to        = eind_geldigheid,
    x_coord         = x,
    y_coord         = y
  )

write_csv(dwellings, "data/processed/dwellings.csv")
# --- 4. TOWNS --- #

towns <- read_csv(
  "data/raw/woonplaatsen.csv",
  col_types = cols(
    id               = col_character(),
    naam             = col_character(),
    status           = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character(),
    x                = col_double(),
    y                = col_double()
  )
) |>
  rename(
    id_town     = id,
    town_name   = naam,
    town_status = status,
    valid_from  = begin_geldigheid,
    valid_to    = eind_geldigheid,
    x_coord     = x,
    y_coord     = y
  )

write_csv(towns, "data/processed/towns.csv")


# --- 5. MUNICIPALITIES --- #

municipalities <- read_csv(
  "data/raw/gemeente_woonplaats.csv",
  col_types = cols(
    woonplaats_id    = col_character(),
    gemeente_id      = col_character(),
    status           = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character()
  )
) |>
  rename(
    id_town             = woonplaats_id,
    id_municipality     = gemeente_id,
    municipality_status = status,
    valid_from          = begin_geldigheid,
    valid_to            = eind_geldigheid
  )

write_csv(municipalities, "data/processed/municipalities.csv")

# --- 6. BUILDINGS --- #
buildings <- read_csv(
  "data/raw/panden.csv",
  col_types = cols(
    id               = col_character(),
    bouwjaar         = col_integer(),
    pandstatus       = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character(),
    x                = col_double(),
    y                = col_double()
  )
) |>
  rename(
    id_building       = id,
    construction_year = bouwjaar,
    building_status   = pandstatus,
    valid_from        = begin_geldigheid,
    valid_to          = eind_geldigheid,
    x_coord           = x,
    y_coord           = y
  )

write_csv(buildings, "data/processed/buildings.csv")


# --- 7. SALES --- #

sales <- read_csv(
  "data/raw/sales.csv",
  col_types = cols(.default = col_character())
) |>
  rename(
    street_address = address,
    town_name      = city,
    postal_code    = postcode,
    sales_price    = sales_price,
    sale_date      = sale_date
  )

write_csv(sales, "data/processed/sales.csv")