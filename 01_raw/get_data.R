
# get_data.R

# Create folder if needed
dir.create("01_raw/data", showWarnings = FALSE, recursive = TRUE)

# Unzip file

unzip("01_raw/data/buildings_register.zip", exdir = "01_raw/data")


# Fix nested folder issue:
unzipped_dir <- file.path("01_raw/data", "buildings_register")

if (dir.exists(unzipped_dir)) {
  files_to_move <- list.files(unzipped_dir, full.names = TRUE)
  file.rename(files_to_move, file.path("01_raw/data", basename(files_to_move)))
  unlink(unzipped_dir, recursive = TRUE)
}


# Load raw files with the correct data types

raw_addresses      <- read_csv(
  "01_raw/data/nummeraanduidingen.csv",
col_types = cols(
id                   = col_character(),
postcode             = col_character(),
huisnummer           = col_integer(),
huisnummertoevoeging = col_character(),
openbareruimte       = col_character(),
begin_geldigheid     = col_character(),
eind_geldigheid      = col_character()
                               ))


raw_dwellings      <- read_csv(
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



raw_public_spaces  <- read_csv(
  "01_raw/data/openbareruimte.csv",
  col_types = cols(
    id               = col_character(),
    naam             = col_character(),
    type             = col_character(),
    woonplaats       = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character()
  ))


raw_towns          <- read_csv(
  "01_raw/data/woonplaatsen.csv",
  col_types = cols(
    id               = col_character(),
    naam             = col_character(),
    status           = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character(),
    x                = col_double(),
    y                = col_double()
  ))


raw_municipalities <- read_csv(
  "01_raw/data/gemeente_woonplaats.csv",
  col_types = cols(
    woonplaats_id    = col_character(),
    gemeente_id      = col_character(),
    status           = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character()
  ))


raw_buildings      <- read_csv(
  "01_raw/data/panden.csv",
  col_types = cols(
    id               = col_character(),
    bouwjaar         = col_integer(),
    pandstatus       = col_character(),
    begin_geldigheid = col_character(),
    eind_geldigheid  = col_character(),
    x                = col_double(),
    y                = col_double()
  ))


raw_sales          <- read_csv(
  "01_raw/data/sales.csv",
  col_types = cols(
    address        = col_character(),
    postcode       = col_character(),
    city           = col_character(),
    sales_price    = col_integer(),
    sale_date      =  col_character()
))

# Save as RDS for next script
write_rds(raw_addresses,      "01_raw/data/addresses_raw.rds")
write_rds(raw_dwellings,      "01_raw/data/dwellings_raw.rds")
write_rds(raw_public_spaces,  "01_raw/data/public_spaces_raw.rds")
write_rds(raw_towns,          "01_raw/data/towns_raw.rds")
write_rds(raw_municipalities, "01_raw/data/municipalities_raw.rds")
write_rds(raw_buildings,      "01_raw/data/buildings_raw.rds")
write_rds(raw_sales,          "01_raw/data/sales_raw.rds")