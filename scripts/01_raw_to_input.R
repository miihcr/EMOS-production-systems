# 01_raw_to_input.R
# Convert RAW BAG + sales data → INPUT (Steady State 1)

# Step 1: Read raw data (all IDs forced to character)
sales_raw <- read_csv(
  "01_raw/data/sales.csv",
  col_types = cols(.default = col_character())
) |> 
  mutate(
    across(where(is.character), ~ replace_na(.x, ""))
  )

addresses_raw <- read_csv(
  "01_raw/data/addresses.csv",
  col_types = cols(
    id                  = col_character(),
    postcode            = col_character(),
    huisnummer          = col_integer(),
    huisnummertoevoeging= col_character(),
    openbareruimte      = col_character(),
    begin_geldigheid    = col_character(),
    eind_geldigheid     = col_character()
  )
) |> 
  mutate(across(where(is.character), ~ replace_na(.x, "")))

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
# 2. Clean SALES

sales_input <- sales_raw |> 
  mutate(
    address = str_squish(str_to_lower(address))
  ) |> 
  extract(
    col   = address,
    into  = c("street_name", "house_number", "house_addition"),
    regex = "^(.+?)\\s+(\\d+)(?:\\s*-?\\s*([[:alnum:]]+))?$",
    remove = FALSE
  ) |> 
  mutate(
    street_name   = street_name |> str_squish() |> str_to_lower(),
    house_number   = as.integer(house_number),
    house_addition = house_addition |> trimws() |> str_to_upper() |> replace_na(""),
    postcode       = postcode |> str_replace_all(" ", "") |> str_to_upper(),
    
    city = city |>
      str_to_lower() |>
      str_replace_all("[^a-z0-9 ]", "") |>
      str_squish(),
    
    sales_price = as.numeric(sales_price),
    price_eur   = sales_price * 1000,
    sale_date   = ymd(sale_date)
  ) |> 
  mutate(
    sale_id = pmap_chr(
      list(street_name, house_number, house_addition, postcode, sale_date, price_eur),
      ~ digest(paste(
        ifelse(is.na(..1), "", ..1),
        ifelse(is.na(..2), "", ..2),
        ifelse(is.na(..3), "", ..3),
        ifelse(is.na(..4), "", ..4),
        ifelse(is.na(..5), "", ..5),
        ifelse(is.na(..6), "", ..6),
        sep = "_"
      ), algo = "sha1")
    )
  ) |> 
  relocate(sale_id) |> 
  select(sale_id, street_name, house_number, house_addition,
         postcode, city, sale_date, price_eur)


# 3. Clean ADDRESSES
addresses_input <- addresses_raw |> 
  rename(
    house_number   = huisnummer,
    house_addition = huisnummertoevoeging
  ) |> 
  mutate(
    postcode       = postcode |> str_replace_all(" ", "") |> str_to_upper(),
    house_number   = as.integer(house_number),
    house_addition = house_addition |> trimws() |> str_to_upper() |> replace_na(""),
    address_id     = as.character(id),
    public_space_id= as.character(openbareruimte),
    start_valid    = ymd(begin_geldigheid),
    end_valid      = ymd(eind_geldigheid)
  ) |> 
  select(address_id, postcode, house_number, house_addition,
         public_space_id, start_valid, end_valid)


# 4. Clean PUBLIC SPACES

public_spaces_input <- public_spaces_raw |> 
  mutate(
    public_space_id   = as.character(id),
    public_space_name = str_to_lower(naam),
    public_space_type = str_to_lower(type),
    town_id           = as.character(woonplaats),
    start_valid       = ymd(begin_geldigheid),
    end_valid         = ymd(eind_geldigheid)
  ) |> 
  select(public_space_id, public_space_name, public_space_type,
         town_id, start_valid, end_valid)


# 5. Clean DWELLINGS

dwellings_input <- dwellings_raw |> 
  mutate(
    dwelling_id  = as.character(id),
    address_id   = as.character(hoofdadres),
    id_building  = as.character(pand),
    start_valid  = ymd(begin_geldigheid),
    end_valid    = ymd(eind_geldigheid),
    area_m2      = oppervlakte
  ) |> 
  select(dwelling_id, address_id, id_building, start_valid,
         end_valid, gebruiksdoel, area_m2, x, y)


# 6. Clean TOWNS


towns_input <- towns_raw |> 
  mutate(
    town_id     = as.character(id),
    town_name   = str_to_lower(naam),
    start_valid = ymd(begin_geldigheid),
    end_valid   = ymd(eind_geldigheid)
  ) |> 
  select(town_id, town_name, 
         start_valid, end_valid, status, x, y)

# 7. Clean MUNICIPALITIES

municipalities_input <- municipalities_raw |> 
  mutate(
    town_id         = as.character(woonplaats_id),
    municipality_id = as.character(gemeente_id),
    start_valid     = ymd(begin_geldigheid),
    end_valid       = ymd(eind_geldigheid)
  ) |> 
  select(town_id, municipality_id, status, start_valid, end_valid)


# Step 8: Write Steady State 1 files

dir.create("01_raw/data/input/", recursive = TRUE)

write_rds(sales_input,         "01_raw/data/input/sales_input.rds")
write_rds(addresses_input,     "01_raw/data/input/addresses_input.rds")
write_rds(dwellings_input,     "01_raw/data/input/dwellings_input.rds")
write_rds(public_spaces_input, "01_raw/data/input/public_spaces_input.rds")
write_rds(towns_input,         "01_raw/data/input/towns_input.rds")
write_rds(municipalities_input,"01_raw/data/input/municipalities_input.rds")