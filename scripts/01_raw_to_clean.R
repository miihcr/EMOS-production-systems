


## ---- 1. ADDRESSES ---- ##

addresses_raw <- read_csv(
  "data/processed/addresses.csv",
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



addresses_clean <- addresses_raw |>
  mutate(
    id_address      = id,
    house_addition  = huisnummertoevoeging,
    house_number    = huisnummer,
    id_public_space = openbareruimte,
    start_valid     = ymd(begin_geldigheid),
    end_valid       = ymd(eind_geldigheid)
  ) |> 
  select(
    id_address, id_public_space, postcode, house_number, house_addition,
    start_valid, end_valid
  ) |> 
  mutate(
    house_addition = str_to_upper(house_addition)
  )



addresses_clean |> 
  select(house_number, house_addition, start_valid, end_valid) |> 
  tbl_summary()



## ---- 2. PUBLIC SPACES ---- ##

public_spaces_raw <- read_csv(
  "data/processed/public_spaces.csv",
  col_types = cols(
    id               = col_character(),
    naam             = col_character(),
    type             = col_character(),
    woonplaats       = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character()
  )
)

public_spaces_clean <- public_spaces_raw |>
  mutate(
    id_public_space   = id,
    public_space_name = naam,
    public_space_type = type,
    id_town           = woonplaats,
    start_valid       = ymd(begin_geldigheid),
    end_valid         = ymd(eind_geldigheid)
  ) |>
  select(
    id_public_space, public_space_name, public_space_type,
    id_town, start_valid, end_valid
  ) |> 
  mutate(
    public_space_name = public_space_name |> 
      str_squish() |> 
      str_to_lower(),
    public_space_type = public_space_type |> 
      str_squish() |> 
      str_to_lower()
  )

public_spaces_clean |> 
  select(public_space_name, public_space_type) |> 
  tbl_summary()


## ---- 3. DWELLINGS ---- ##

dwellings_raw <- read_csv(
  "data/processed/dwellings.csv",
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

dwellings_clean <- dwellings_raw |>
  mutate(
    id_dwelling     = id,
    usage_purpose   = gebruiksdoel,
    area_m2         = oppervlakte,
    dwelling_status = status |> 
      str_to_lower(),
    id_address      = hoofdadres,
    id_building     = pand,
    start_valid     = ymd(begin_geldigheid),
    end_valid       = ymd(eind_geldigheid),
    x_coord         = x,
    y_coord         = y
  ) |>
  select(
    id_dwelling, usage_purpose, area_m2, dwelling_status,
    id_address, id_building,
    start_valid, end_valid,
    x_coord, y_coord
  ) 




## ---- 4. TOWNS ---- ##

towns_raw <- read_csv(
  "data/processed/towns.csv",
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

towns_clean <- towns_raw |>
  mutate(
    id_town     = id,
    town_name   = naam,
    town_status = status,
    start_valid = ymd(begin_geldigheid),
    end_valid   = ymd(eind_geldigheid),
    x_coord     = x,
    y_coord     = y
  ) |>
  select(
    id_town, town_name, town_status,
    start_valid, end_valid, x_coord, y_coord
  ) |> 
  mutate(
    town_name = town_name |> 
      str_trim() |> 
      str_to_title() |> 
      str_replace("\\s+[Nn][Bb]$", "") |> 
      str_remove("\\sGem.*$") |> 
      str_replace("^Rijkevoort-De Walsert$", "Rijkevoort") |> 
      str_replace("^'S-Hertogenbosch$", "'s-Hertogenbosch"),
      town_status = town_status |> 
      str_to_lower()
  )

towns_clean |> 
  select(town_name) |> 
  tbl_summary()
  

# Heusden Gem Heusde = Heusden

# Rijkevoort-De Walsert = Rijkevoort

# remove "Nb"



## ---- 5. MUNICIPALITIES ---- ##

municipalities_raw <- read_csv(
  "data/processed/municipalities.csv",
  col_types = cols(
    woonplaats_id    = col_character(),
    gemeente_id      = col_character(),
    status           = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character()
  )
)

municipalities_clean <- municipalities_raw |>
  mutate(
    id_town             = woonplaats_id,
    id_municipality     = gemeente_id,
    municipality_status = status,
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
  "data/processed/buildings.csv",
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

buildings_clean <- buildings_raw |>
  mutate(
    id_building       = id,
    construction_year = bouwjaar,
    building_status   = pandstatus,
    start_valid       = ymd(begin_geldigheid),
    end_valid         = ymd(eind_geldigheid),
    x_coord           = x,
    y_coord           = y
  ) |>
  select(
    id_building, construction_year, building_status,
    start_valid, end_valid, x_coord, y_coord
  ) |> 
  mutate(
    building_status = building_status |> 
      str_to_lower()
  )


## ---- 7. SALES ---- ##


sales_raw <- read_csv("data/processed/sales.csv")

sales_clean <- sales_raw |>
  mutate(
    full_address    = address,
    town_name       = city,
    postcode        = postcode,
    sales_price     = as.numeric(sales_price) * 1000,
    sale_date       = ymd(sale_date)
  ) |> 
  select(full_address, town_name, postcode, 
         sales_price, sale_date) |> 
  extract(
    col   = full_address,
    into  = c("street_name", "house_number", "house_addition"),
    regex = "^(.+?)\\s+(\\d{1,4})(?:[\\s-]*([A-Za-z0-9]{1,4}|hs|bis|II|III|IV)\\b.*)?$",
    remove = FALSE
  ) |> 
  mutate(
    across(c(house_number, house_addition), ~na_if(.x, "")),
    house_addition = str_to_upper(house_addition)
  ) |>
  select(
    full_address, street_name, house_number, house_addition,
    postcode, town_name, sales_price, sale_date
  )

# Deduplicate by keeping the most recent record per ID

addresses_clean <- addresses_clean |>
  distinct() |> 
  arrange(id_address, desc(start_valid)) |> 
  group_by(id_address) |> 
  slice_head(n = 1) |> 
  ungroup()


public_spaces_clean <- public_spaces_clean |>
  distinct() |>
  group_by(id_public_space) |>
  slice_max(order_by = start_valid, n = 1, with_ties = FALSE) |>
  ungroup()


dwellings_clean <- dwellings_clean |>
  distinct() |>
  group_by(id_dwelling) |>
  slice_max(order_by = start_valid, n = 1, with_ties = FALSE) |>
  ungroup()


towns_clean <- towns_clean |>
  distinct() |>
  group_by(id_town) |>
  slice_max(order_by = start_valid, n = 1, with_ties = FALSE) |>
  ungroup()


municipalities_clean <- municipalities_clean |>
  distinct() |>
  group_by(id_town) |>
  slice_max(order_by = start_valid, n = 1, with_ties = FALSE) |>
  ungroup()

buildings_clean <- buildings_clean |>
  distinct() |>
  group_by(id_building) |>
  slice_max(order_by = start_valid, n = 1, with_ties = FALSE) |>
  ungroup()


# dir.create("data/cleaned", recursive = TRUE)

write_rds(addresses_clean,      "data/cleaned/addresses.rds")
write_rds(public_spaces_clean,  "data/cleaned/public_spaces.rds")
write_rds(dwellings_clean,      "data/cleaned/dwellings.rds")
write_rds(towns_clean,          "data/cleaned/towns.rds")
write_rds(municipalities_clean, "data/cleaned/municipalities.rds")
write_rds(buildings_clean,      "data/cleaned/buildings.rds")
write_rds(sales_clean,          "data/cleaned/sales.rds")

