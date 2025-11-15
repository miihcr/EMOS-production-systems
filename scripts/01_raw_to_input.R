#01_raw_to_input.R



# 1. Read raw data
sales_raw <- read_csv("01_raw/data/sales.csv",
                      col_types = cols(.default = col_character())) |>
  mutate(sale_id = row_number()) |>
  relocate(sale_id)
             

addresses_raw    <- read_csv("01_raw/data/addresses.csv")
dwellings_raw    <- read_csv("01_raw/data/dwellings.csv")
public_spaces_raw<- read_csv("01_raw/data/public_spaces.csv")
towns_raw        <- read_csv("01_raw/data/towns.csv")
municipalities_raw <- read_csv("01_raw/data/municipalities.csv")


str(sales_input)
# 2. Clean SALES


sales_input <- sales_raw |>
  distinct() |> 
  mutate(
    # lower-case and squeeze multiple spaces
    address  = str_squish(str_to_lower(address))
  ) |>
  extract(
    col   = address,
    into  = c("street_name", "house_number", "house_addition"),
    # e.g.: "kerkstraat 12", "kerkstraat 12a", "kerkstraat 12 - a"
    regex = "^(.+?)\\s+(\\d+)(?:\\s*-?\\s*([[:alnum:]]+))?$",
    remove = FALSE
  ) |>
  mutate(
    # make sure house_number is numeric
    house_number   = as.integer(house_number),
    house_addition = if_else(
      is.na(house_addition),
      "",
      str_to_upper(trimws(house_addition))
    ),
    # clean postcode: remove spaces, make uppercase
    postcode = str_replace_all(postcode, " ", ""),
    postcode = str_to_upper(postcode),
    sales_price = as.numeric(sales_price),
    # scale price 
    price_eur = sales_price * 1000,
    # convert sale_date to Date
    sale_date = ymd(sale_date)
  ) |> 
  select(sale_id, street_name, house_number, house_addition,
         postcode, city, sale_date, price_eur)



# 3. Clean ADDRESSES

addresses_input <- addresses_raw |> 
  rename(
    house_number   = huisnummer,
    house_addition = huisnummertoevoeging
  ) |> 
  mutate(
    house_number     = as.integer(house_number),
    house_addition   = house_addition |> 
      trimws() |> 
      str_to_upper() |> 
      tidyr::replace_na(""),
    address_id       = as.character(id),
    openbareruimte   = as.character(openbareruimte),
    start_valid      = begin_geldigheid,
    end_valid        = eind_geldigheid,
    public_space_id   = as.character(openbareruimte)
  ) |> 
  select(address_id, postcode, house_number, house_addition,
         public_space_id)


# 4. Clean PUBLIC SPACES

str(public_spaces_raw)


public_spaces_input <- public_spaces_raw |> 
  mutate(
    public_space_id   = as.character(id),
    public_space_name = str_to_lower(naam),
    public_space_type = str_to_lower(type),
    town_id          = as.character(woonplaats),
    start_valid      = begin_geldigheid,
    end_valid        = eind_geldigheid
  ) |> 
  select(public_space_id, public_space_name, public_space_type,
         town_id, start_valid, end_valid)

str(public_spaces_input)

str(dwellings_raw)

# 5. Clean DWELLINGS

dwellings_input <- dwellings_raw |> 
  mutate(
    dwelling_id = as.character(id),
    address_id = as.character(hoofdadres),
    id_building = as.character(pand),
    start_valid      = begin_geldigheid,
    end_valid        = eind_geldigheid,
    area_m2 = oppervlakte
  ) |> 
  select(dwelling_id, address_id, id_building, start_valid,
         end_valid, gebruiksdoel, area_m2, x, y)


# 6. Clean TOWNS
str(towns_raw)
towns_input <- towns_raw |> 
  mutate(
    town_id = as.character(id),
    town_name = str_to_lower(naam),
    start_valid      = begin_geldigheid,
    end_valid        = eind_geldigheid
  ) |> 
  select(town_id, town_name, start_valid, end_valid,
         status, x, y)

# 7. Clean MUNICIPALITIES

str(municipalities_raw)

municipalities_input <- municipalities_raw |> 
  mutate(
    town_id = as.character(woonplaats_id),
    municipality_id = as.character(gemeente_id),
    start_valid      = begin_geldigheid,
    end_valid        = eind_geldigheid
  ) |> 
  select(town_id, municipality_id,status,start_valid, end_valid,
         )



# Identify and remove duplicates



# Final line -- move if any other operations are done before this

write_rds(sales_input,         "data/input/sales_input.rds")
write_rds(addresses_input,     "data/input/addresses_input.rds")
write_rds(dwellings_input,     "data/input/dwellings_input.rds")
write_rds(public_spaces_input, "data/input/public_spaces_input.rds")
write_rds(towns_input,         "data/input/towns_input.rds")
write_rds(municipalities_input,"data/input/municipalities_input.rds")