# 01_raw_to_clean

# Every dataset follows a 4-step structure

# 1. Inspection
# 2. Normalization and coercion
# 3. Standardization
# 4. Preparation for validation

# Helper functions

clean_text <- function(x) {
  x |>
    str_squish() |>
    na_if("")
}

clean_id <- function(x) {
  x |>
    str_replace_all("\\s+", "") |>
    na_if("")
}


clean_house_addition <- function(x) {
  x |>
    str_replace_all("\\s+", "") |>
    str_to_upper() |>
    na_if("")
}

clean_postcode <- function(x) {
  x <- x |> 
    str_remove_all(" ") |> 
    str_to_upper()
  
  case_when(
    str_detect(x, "^[1-9][0-9]{3}[A-Z]{2}$") ~ x,
    TRUE ~ NA_character_
  )
}

clean_status <- function(x) {
  x |>
    str_squish() |>
    str_to_lower() |>
    na_if("")
}


## ---- 1. ADDRESSES ---- ##

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



addresses_input <- addresses_raw |> 
  mutate(
    id_address      = clean_id(id),
    house_addition  = clean_house_addition(huisnummertoevoeging),
    house_number    = huisnummer,
    id_public_space = clean_id(openbareruimte),
    postcode        = clean_postcode(postcode),
    start_valid     = ymd(begin_geldigheid),
    end_valid       = ymd(eind_geldigheid)
  ) |>
  select(id_address, house_number, house_addition,
         postcode,
         id_public_space, start_valid, end_valid)


## ---- 2. PUBLIC SPACES ---- ##

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

public_spaces_input <- public_spaces_raw |> 
  mutate(
    id_public_space   = clean_id(id),
    name              = clean_text(naam),
    type_public_space = clean_status(type),
    town_id           = clean_id(woonplaats),
    
    start_valid       = ymd(begin_geldigheid),
    end_valid         = ymd(eind_geldigheid)
  ) |>
  select(
    id_public_space, name, type_public_space,
    town_id, start_valid, end_valid
  )


## ---- 3. DWELLINGS ---- ##

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

dwellings_input <- dwellings_raw |> 
  mutate(
    id_dwelling     = clean_id(id),
    usage_purpose   = clean_status(gebruiksdoel),
    area_m2         = oppervlakte,
    status_clean    = clean_status(status),
    
    id_address      = clean_id(hoofdadres),
    id_building     = clean_id(pand),
    
    start_valid     = ymd(begin_geldigheid),
    end_valid       = ymd(eind_geldigheid),
    
    x_coord         = as.numeric(x),
    y_coord         = as.numeric(y)
  ) |>
  select(
    id_dwelling, usage_purpose, area_m2, status_clean,
    id_address, id_building,
    start_valid, end_valid,
    x_coord, y_coord
  )



## ---- 4. TOWNS ---- ##

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

towns_input <- towns_raw |> 
  mutate(
    id_town      = clean_id(id),
    town_name    = clean_text(naam),
    town_status  = clean_status(status),
    
    start_valid  = ymd(begin_geldigheid),
    end_valid    = ymd(eind_geldigheid),
    
    x_coord      = as.numeric(x),
    y_coord      = as.numeric(y)
  ) |>
  select(
    id_town, town_name, town_status,
    start_valid, end_valid,
    x_coord, y_coord
  )




## ---- 5. MUNICIPALITIES ---- ##

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




municipalities_input <- municipalities_raw |> 
  mutate(
    id_town             = clean_id(woonplaats_id),
    id_municipality     = clean_id(gemeente_id),
    municipality_status = clean_status(status),
    
    start_valid         = ymd(begin_geldigheid),
    end_valid           = ymd(eind_geldigheid)
  ) |>
  select(
    id_town, id_municipality,
    municipality_status,
    start_valid, end_valid
  )


## ---- 6. BUILDINGS ---- ##

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

buildings_input <- buildings_raw |> 
  mutate(
    id_building       = clean_id(id),
    construction_year = bouwjaar,
    building_status   = clean_status(pandstatus),
    
    start_valid       = ymd(begin_geldigheid),
    end_valid         = ymd(eind_geldigheid),
    
    x_coord           = as.numeric(x),
    y_coord           = as.numeric(y)
  ) |>
  select(
    id_building,
    construction_year,
    building_status,
    start_valid, end_valid,
    x_coord, y_coord
  )


## ---- 7. SALES ---- ##


sales_raw <- read_csv(
  "01_raw/data/sales.csv",
  col_types = cols(.default = col_character())
)


sales_input <- sales_raw |> 
  mutate(
    full_address    = clean_text(address),
    town_name       = clean_text(city),
    
    postcode        = clean_postcode(postcode),
    
    sales_price_eur = as.numeric(sales_price) * 1000,
    
    sale_date       = ymd(sale_date)
  ) |>
  select(
    full_address, postcode, town_name,
    sales_price_eur, sale_date
  )

