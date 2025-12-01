# 01_raw_to_input.R


# -------------------------------------------------------------------
# Helper functions: cleaning & standardization
# -------------------------------------------------------------------

clean_text <- function(x) {
  x |>
    str_squish() |>      # trims + collapses internal whitespace
    str_to_lower() |>
    na_if("")
}


clean_id <- function(x) {
  x |>
    str_replace_all("\\s+", "") |>
    na_if("")
}

# Keep an indicator of spaces (so "1 hoog" != "1-2")
clean_house_addition <- function(x) {
  x |>
    str_squish() |>                 # trim
    str_replace_all("\\s+", "_") |> # preserve separation
    str_to_upper() |>
    na_if("")
}


# Any postcodes starting with 0 are treated as invalid (NA).
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

# Clean + map to codebook values using a dictionary

clean_and_map_status <- function(x, dict = NULL) {
  raw <- clean_status(x)
  if (is.null(dict)) return(raw)
  mapped <- unname(dict[raw])
  ifelse(is.na(mapped), raw, mapped)
}

# Deduplication helper: keep newest (largest) start_valid per ID
dedupe_latest <- function(df, id_col) {
  df |>
    arrange({{ id_col }}, desc(start_valid)) |>
    distinct({{ id_col }}, .keep_all = TRUE)
}

# Generic temporal overlap detection on RAW data
# Assumes start/end are character dates convertible by ymd
find_overlaps <- function(df, id_col, start_col, end_col) {
  df |>
    mutate(
      .start = ymd({{ start_col }}),
      .end   = ymd({{ end_col }})
    ) |>
    arrange({{ id_col }}, .start) |>
    group_by({{ id_col }}) |>
    mutate(
      prev_end = lag(.end),
      overlap  = !is.na(prev_end) & .start <= prev_end
    ) |>
    ungroup() |>
    filter(overlap)
}

# Directionaries for categorical standardization


use_purpose_dict <- c(
  "woonfunctie" = "residential",
  "industriefunctie" = "industrial",
  "winkelfunctie" = "retail",
  "kantoorfunctie" = "office ",
  "bijeenkomstfunctie" = "assembly",
  "sportfunctie" = "sports",
  "gezondheidszorgfunctie" = "healthcare",
  "logiesfunctie" = "lodging",
  "overige gebruiksfunctie" = "other",
  "onderwijsfunctie" = "educational",
  "celfunctie" = "prison",
  "bedrijfsfunctie" = "business",
  "laboratoriumfunctie" = "laboratory",
  "zorgfunctie" = "care",
  "kiesfunctie" = "voting"
)

building_status_dict <- c(
  "bouwvergunning verleend"          = "building_permit_granted",
  "pand ten onrechte opgevoerd"      = "incorrectly_listed",
  "pand in gebruik"                  = "in_use",
  "pand gesloopt"                    = "demolished",
  "pand in gebruik (niet ingemeten)" = "in_use_not_measured",
  "bouw gestart"                     = "construction_started",
  "sloopvergunning verleend"         = "demolition_permit_granted",
  "verbouwing pand"                  = "renovation",
  "niet gerealiseerd pand"           = "not_realized"
)

public_space_type_dict <- c(
  "weg"                  = "road",
  "terrein"              = "terrain",
  "landschappelijk gebied" = "landscape_area",
  "administratief gebied" = "administrative_area",
  "kunstwerk"            = "infrastructure_work",
  "water"                = "water"
)


dwelling_status_dict <- c(
  "verblijfsobject gevormd"               = "formed",
  "verblijfsobject ten onrechte opgevoerd" = "incorrectly_listed",
  "verblijfsobject in gebruik"            = "in_use",
  "verbouwing verblijfsobject"            = "renovation",
  "verblijfsobject in gebruik (niet ingemeten)" = "in_use_not_measured",
  "verblijfsobject ingetrokken"           = "withdrawn",
  "verblijfsobject buiten gebruik"        = "out_of_use",
  "viet gerealiseerd verblijfsobject"     = "not_realized"
)


town_status_dict <- c(
  "woonplaats aangewezen" = "town_designated",
  "woonplaats ingetrokken" = "town_withdrawn"
)

municipality_status_dict <- c(
  "woonplaats aangewezen" = "town_designated",
  "woonplaats ingetrokken" = "town_withdrawn"
)


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

# Step 1 — Clean fields (but keep all rows)

addresses_clean <- addresses_raw |>
  mutate(
    id_address      = clean_id(id),
    house_addition  = clean_house_addition(huisnummertoevoeging),
    house_number    = huisnummer,
    id_public_space = clean_id(openbareruimte),
    postcode        = clean_postcode(postcode),
    start_valid     = ymd(begin_geldigheid),
    end_valid       = ymd(eind_geldigheid)
  )

# Step 2 — Dedupe by address-id (keep newest version)
addresses_clean <- addresses_clean |>
  arrange(id_address, desc(start_valid)) |>
  distinct(id_address, .keep_all = TRUE)

# Step 3 — Build physical-address key (after dedupe)
addresses_input <- addresses_clean |>
  mutate(
    house_addition = coalesce(house_addition, ""),
    address_key = paste(postcode, house_number, house_addition, sep = "_")
  ) |>
  arrange(address_key, desc(start_valid)) |>
  distinct(address_key, .keep_all = TRUE)

# Step 4 — Select final variables for input
addresses_input <- addresses_input |>
  select(
    id_address, address_key,
    house_number, house_addition, postcode,
    id_public_space,
    start_valid, end_valid
  )



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

public_spaces_input <- public_spaces_raw |>
  mutate(
    id_public_space   = clean_id(id),
    public_space_name = clean_text(naam),
    public_space_type = clean_and_map_status(type, public_space_type_dict),
    id_town           = clean_id(woonplaats),
    start_valid       = ymd(begin_geldigheid),
    end_valid         = ymd(eind_geldigheid)
  ) |>
  select(
    id_public_space, public_space_name, public_space_type,
    id_town, start_valid, end_valid
  ) |>
  dedupe_latest(id_public_space)


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

dwellings_input <- dwellings_raw |>
  mutate(
    id_dwelling   = clean_id(id),
    usage_purpose = clean_and_map_status(gebruiksdoel, use_purpose_dict),
    area_m2       = oppervlakte,
    status_clean  = clean_and_map_status(status, dwelling_status_dict),
    id_address    = clean_id(hoofdadres),
    id_building   = clean_id(pand),
    start_valid   = ymd(begin_geldigheid),
    end_valid     = ymd(eind_geldigheid),
    x_coord       = x,
    y_coord       = y
  ) |>
  select(
    id_dwelling, usage_purpose, area_m2, status_clean,
    id_address, id_building,
    start_valid, end_valid,
    x_coord, y_coord
  ) |>
  dedupe_latest(id_dwelling)


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

towns_input <- towns_raw |>
  mutate(
    id_town     = clean_id(id),
    town_name   = clean_text(naam),
    town_status = clean_and_map_status(status, town_status_dict),
    start_valid = ymd(begin_geldigheid),
    end_valid   = ymd(eind_geldigheid),
    x_coord     = x,
    y_coord     = y
  ) |>
  select(
    id_town, town_name, town_status,
    start_valid, end_valid, x_coord, y_coord
  ) |>
  dedupe_latest(id_town)



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

municipalities_input <- municipalities_raw |>
  mutate(
    id_town             = clean_id(woonplaats_id),
    id_municipality     = clean_id(gemeente_id),
    municipality_status = clean_and_map_status(status, municipality_status_dict),
    start_valid         = ymd(begin_geldigheid),
    end_valid           = ymd(eind_geldigheid)
  ) |>
  select(
    id_town, id_municipality,
    municipality_status,
    start_valid, end_valid
  ) |>
  dedupe_latest(id_town)

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

buildings_input <- buildings_raw |>
  mutate(
    id_building       = clean_id(id),
    construction_year = bouwjaar,
    building_status   = clean_and_map_status(pandstatus, building_status_dict),
    start_valid       = ymd(begin_geldigheid),
    end_valid         = ymd(eind_geldigheid),
    x_coord           = x,
    y_coord           = y
  ) |>
  select(
    id_building, construction_year, building_status,
    start_valid, end_valid, x_coord, y_coord
  ) |>
  dedupe_latest(id_building)


## ---- 7. SALES ---- ##


sales_raw <- read_csv("data/processed/sales.csv")

sales_input <- sales_raw |>
  mutate(
    full_address    = clean_text(address),
    town_name       = clean_text(city),
    postcode        = clean_postcode(postcode),
    sales_price_eur = as.numeric(sales_price) * 1000,
    sale_date       = ymd(sale_date)
  ) |>
  # More robust splitting of "Street 12A", "Street 12 A", "Street 12A 2-hoog"
  extract(
    col   = full_address,
    into  = c("street_name", "house_number_raw", "house_addition_raw"),
    regex = "^(.+?)\\s+(\\d+[A-Za-z]*)(?:\\s*(.*))?$",
    remove = FALSE
  ) |>
  mutate(
    street_name    = clean_text(street_name),
    house_number   = readr::parse_number(house_number_raw),
    house_addition = clean_house_addition(house_addition_raw)
  ) |>
  select(
    full_address, street_name, house_number, house_addition,
    postcode, town_name, sales_price_eur, sale_date
  )


# Save all modified files 

dir.create("data/cleaned", recursive = TRUE)

write_rds(addresses_input,      "data/cleaned/addresses.rds")
write_rds(public_spaces_input,  "data/cleaned/public_spaces.rds")
write_rds(dwellings_input,      "data/cleaned/dwellings.rds")
write_rds(towns_input,          "data/cleaned/towns.rds")
write_rds(municipalities_input, "data/cleaned/municipalities.rds")
write_rds(buildings_input,      "data/cleaned/buildings.rds")
write_rds(sales_input,          "data/cleaned/sales.rds")
