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



# 2. Clean SALES


sales_input <- sales_raw |>
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
  )

str(sales_input)
