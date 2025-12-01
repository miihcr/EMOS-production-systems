############################################################
# ADDRESSES
############################################################

# Required fields exist implicitly checked in R
# Uniqueness
is_unique(id_address)

# Missingness
!is.na(id_address)
!is.na(house_number)
!is.na(id_public_space)
!is.na(start_valid)

# Value rules
house_number > 0

house_addition %in% regex("^[A-Z0-9]+$") | is.na(house_addition)

postcode %in% regex("^[1-9][0-9]{3}[A-Z]{2}$") | is.na(postcode)

end_valid >= start_valid | is.na(end_valid)

# Foreign key
id_public_space %in% public_spaces_input$id_public_space


############################################################
# PUBLIC SPACES
############################################################

# Uniqueness
is_unique(id_public_space)

# Missingness
!is.na(id_public_space)
!is.na(public_space_name)
!is.na(id_town)

# Value rules
public_space_name %in% regex("^[a-z0-9 ]+$")
public_space_type %in% c(
  "openbare ruimte",
  "weg",
  "water",
  "rail",
  "terreindeel",
  "kunstwerk"
)

end_valid >= start_valid | is.na(end_valid)

# Foreign key
id_town %in% towns_input$id_town


############################################################
# TOWNS
############################################################

# Uniqueness
is_unique(id_town)

# Missingness
!is.na(id_town)
!is.na(town_name)

# Value rules
town_status %in% c("woonplaats aangewezen", "woonplaats ingetrokken")
end_valid >= start_valid | is.na(end_valid)

x_coord > 0
y_coord > 0


############################################################
# MUNICIPALITIES
############################################################

# Uniqueness pair
is_unique(id_town, start_valid)

# Missingness
!is.na(id_town)
!is.na(id_municipality)
!is.na(start_valid)

# Value rules
end_valid >= start_valid | is.na(end_valid)

municipality_status %in% c(
  "gemeente aangewezen",
  "gemeente ingetrokken"
)

# Foreign key
id_town %in% towns_input$id_town


############################################################
# BUILDINGS
############################################################

# Required vars not checked here
is_unique(id_building)

!is.na(id_building)
!is.na(construction_year)
!is.na(building_status)
!is.na(start_valid)

# Value rules
construction_year >= 1000
construction_year <= year(Sys.Date())

building_status %in% c(
  "Pand in gebruik",
  "Pand buiten gebruik",
  "Pand gesloopt",
  "Pand in aanbouw",
  "Pand ten onrechte opgevoerd",
  "Niet gerealiseerd pand"
)

end_valid >= start_valid | is.na(end_valid)

x_coord > 0
y_coord > 0


############################################################
# DWELLINGS
############################################################

is_unique(id_dwelling)

!is.na(id_dwelling)
!is.na(id_address)
!is.na(id_building)
!is.na(start_valid)

# Value rules
area_m2 >= 5
area_m2 < 1000

usage_purpose %in% c(
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

status_clean %in% c(
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

end_valid >= start_valid | is.na(end_valid)

x_coord > 0
y_coord > 0

# Foreign keys
id_address %in% addresses_input$id_address
id_building %in% buildings_input$id_building


############################################################
# SALES
############################################################

!is.na(full_address)
!is.na(street_name)
!is.na(house_number)
!is.na(sale_date)

house_number > 0

house_addition %in% regex("^[A-Za-z0-9]+$") | is.na(house_addition)

postcode %in% regex("^[1-9][0-9]{3}[A-Z]{2}$") | is.na(postcode)

sales_price_eur >= 10000
sales_price_eur <= 10000000

year(sale_date) >= 1995
