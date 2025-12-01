

# ---- ADDRESSES ---- #

vars <- c(
  "id_address",
  "house_number",
  "house_addition",
  "id_public_space",
  "postcode",
  "start_valid",
  "end_valid"
)

all(vars %in% names(addresses_input))

# Uniqueness

n_distinct(id_address) == nrow(addresses_input)


# Variable type

is.character(id_address)
as.integer(house_number)
is.character(house_addition)
is.character(id_public_space)
is.integer(house_number)
is.Date(start_valid)
is.Date(end_valid)

# Missingness

sum(is.na(id_address)) == 0
sum(is.na(house_number)) == 0
sum(is.na(id_public_space)) == 0
sum(is.na(start_valid)) == 0
# postcode may be NA (after cleaning invalid)

# Value rules

house_number > 0

is.na(house_addition) | grepl("^[A-Z0-9]+$", house_addition)

is.na(postcode) | grepl("^[1-9][0-9]{3}[A-Z]{2}$", postcode)

is.na(end_valid) | end_valid >= start_valid

# Foreign key rule

id_public_space %in% public_spaces_input$id_public_space


# ---- PUBLIC SPACES ---- #


vars <- c("id_public_space", "public_space_name",
          "public_space_type", "id_town", "start_valid", "end_valid")
all(vars %in% names(public_spaces_input))


n_distinct(id_public_space) == nrow(public_spaces_input)


is.character(id_public_space)
is.character(public_space_name)
is.character(public_space_type)
is.character(id_town)
is.Date(start_valid)
is.Date(end_valid)


sum(is.na(id_public_space)) == 0
sum(is.na(public_space_name)) == 0
sum(is.na(id_town)) == 0


grepl("^[a-z0-9 ]+$", public_space_name)


public_space_type %in% c(
  "openbare ruimte", "weg", "water", "rail", "terreindeel", "kunstwerk"
)


is.na(end_valid) | end_valid >= start_valid



id_town %in% towns_input$id_town


# ---- TOWNS ---- #


vars <- c("id_town", "town_name", "town_status",
          "start_valid", "end_valid", "x_coord", "y_coord")


n_distinct(id_town) == nrow(towns_input)


sum(is.na(id_town)) == 0
sum(is.na(town_name)) == 0


town_status %in% c("woonplaats aangewezen", "woonplaats ingetrokken")
is.na(end_valid) | end_valid >= start_valid



# ---- MUNICIPALITIES ---- #

vars <- c("id_town", "id_municipality",
          "municipality_status", "start_valid", "end_valid")



nrow(municipalities_input) == 
  n_distinct(municipalities_input$id_town,
             municipalities_input$start_valid)

is.character(municipalities_input$id_town)
is.character(municipalities_input$id_municipality)
is.character(municipalities_input$municipality_status)
is.Date(municipalities_input$start_valid)
is.Date(municipalities_input$end_valid)



id_town %in% towns_input$id_town


# ---- BUILDINGS ---- #

vars <- c("id_building", "construction_year", "building_status",
          "start_valid", "end_valid", "x_coord", "y_coord")



all(vars %in% names(buildings_input))

n_distinct(buildings_input$id_building) == nrow(buildings_input)


is.character(buildings_input$id_building)
is.integer(buildings_input$construction_year)
is.character(buildings_input$building_status)
as.Date(buildings_input$start_valid)
as.Date(buildings_input$end_valid)
is.numeric(buildings_input$x_coord)
is.numeric(buildings_input$y_coord)


!any(is.na(buildings_input$id_building))
!any(is.na(buildings_input$construction_year))
!any(is.na(buildings_input$building_status))
!any(is.na(buildings_input$start_valid))


all(buildings_input$construction_year >= 1000 &
      buildings_input$construction_year <= year(Sys.Date()))


# Valid building status values:
valid_building_status <- c(
  "Pand in gebruik",
  "Pand buiten gebruik",
  "Pand gesloopt",
  "Pand in aanbouw",
  "Pand ten onrechte opgevoerd",
  "Niet gerealiseerd pand"
)

all(buildings_input$building_status %in% valid_building_status)


all(buildings_input$x_coord > 0 & buildings_input$y_coord > 0)


# ---- DWELLINGS ---- #

vars <- c("id_dwelling", "usage_purpose", "area_m2", "status_clean",
          "id_address", "id_building", "start_valid", "end_valid",
          "x_coord","y_coord")


all(vars %in% names(dwellings_input))

n_distinct(dwellings_input$id_dwelling) == nrow(dwellings_input)


# Types
is.character(dwellings_input$id_dwelling)
is.character(dwellings_input$usage_purpose)
is.integer(dwellings_input$area_m2)
is.character(dwellings_input$status_clean)
is.Date(dwellings_input$start_valid)
is.Date(dwellings_input$end_valid)
is.numeric(dwellings_input$x_coord)
is.numeric(dwellings_input$y_coord)

# Missingness
!any(is.na(dwellings_input$id_dwelling))
!any(is.na(dwellings_input$id_address))
!any(is.na(dwellings_input$id_building))
!any(is.na(dwellings_input$start_valid))
# end_valid allowed to be NA

# Value rules

# Floor area must be realistic
all(dwellings_input$area_m2 >= 5 &
      dwellings_input$area_m2 < 1000)

# Allowed usage_purpose values
valid_usage_purpose <- c(
  "woonfunctie",
  "bijeenkomstfunctie",
  "celfunctie",
  "gezondheidszorgfunctie",
  "industriefunctie",
  "kantoorfunctie",
  "logiesfunctie",
  "onderwijsfunctie",
  "sportfunctie",
  "winkelfunctie",
  "overige gebruiksfunctie"
)
all(dwellings_input$usage_purpose %in% valid_usage_purpose)

# Allowed dwelling statuses
valid_status_clean <- c(
  "verblijfsobject in gebruik",
  "verblijfsobject in gebruik (niet ingemeten)",
  "verblijfsobject gevormd",
  "verblijfsobject ingetrokken",
  "verblijfsobject buiten gebruik",
  "bouw gestart verblijfsobject",
  "sloop verblijfsobject",
  "ten onrechte opgevoerd verblijfsobject",
  "niet gerealiseerd verblijfsobject"
)
all(dwellings_input$status_clean %in% valid_status_clean)

# Coordinates
all(dwellings_input$x_coord > 0 & dwellings_input$y_coord > 0)

# Foreign keys
all(dwellings_input$id_address %in% addresses_input$id_address)
all(dwellings_input$id_building %in% buildings_input$id_building)


# ---- SALES ---- #


vars <- c(
  "full_address",
  "street_name",
  "house_number",
  "house_addition",
  "postcode",
  "town_name",
  "sales_price_eur",
  "sale_date"
)

# Required columns
all(vars %in% names(sales_input))

# Types
is.character(sales_input$full_address)
is.character(sales_input$street_name)
is.integer(sales_input$house_number)
is.character(sales_input$house_addition)
is.character(sales_input$postcode)
is.character(sales_input$town_name)
is.numeric(sales_input$sales_price_eur)
is.Date(sales_input$sale_date)

# Missingness
!any(is.na(sales_input$full_address))
!any(is.na(sales_input$street_name))
!any(is.na(sales_input$house_number))
!any(is.na(sales_input$sale_date))



all(sales_input$house_number > 0)

# House addition only A–Z and digits (or empty)
all(
  is.na(sales_input$house_addition) |
    grepl("^[A-Za-z0-9]+$", sales_input$house_addition)
)

# Valid postcode format (or NA)
all(
  is.na(sales_input$postcode) |
    grepl("^[1-9][0-9]{3}[A-Z]{2}$", sales_input$postcode)
)

# Valid sale price (10k – 10M range)
all(
  sales_input$sales_price_eur >= 10000 &
    sales_input$sales_price_eur <= 10000000
)

# Valid time period
all(year(sales_input$sale_date) >= 1995)
