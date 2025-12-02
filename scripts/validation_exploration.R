
# DWELLINGS

# 1. Are dwelling IDs unique?
dwellings |> 
  count(id_dwelling) |> 
  filter(n > 1)

# 2. Any missing dwelling IDs?
sum(is.na(dwellings$id_dwelling))

# 3. end >= start OR end NA
dwellings |> 
  filter(!is.na(end_valid) & end_valid < start_valid)

# 4. Coordinates must be numeric, not NA
dwellings |> 
  summarise(
    missing_x = sum(is.na(x_coord)),
    missing_y = sum(is.na(y_coord))
  )

# 5. Valid usage_purpose values?
table(dwellings$usage_purpose, useNA = "ifany")

# 6. Valid status values?
table(dwellings$dwelling_status, useNA = "ifany")

table(dwellings$area_m2, useNA = "ifany")

dwellings |> 
  summarise(
    min_area = min(area_m2, na.rm = TRUE),
    max_area = max(area_m2, na.rm = TRUE)
  )

# 7. Check for invalid coordinates

dwellings |> filter(x_coord < 0 | x_coord > 300000 |
                      y_coord < 300000 | y_coord > 625000)


# 8. Check for missing address or building IDs

sum(is.na(dwellings$id_address))
sum(is.na(dwellings$id_building))


# BUILDINGS

# 1. Unique building IDs
buildings |> 
  count(id_building) |> 
  filter(n > 1)

# 2. Missing building IDs
sum(is.na(buildings$id_building))

# 3. Validity date logic
buildings |> 
  filter(!is.na(end_valid) & end_valid < start_valid)

# 4. Coordinates sanity
buildings |> 
  summarise(
    missing_x = sum(is.na(x_coord)),
    missing_y = sum(is.na(y_coord))
  )

# 5. Construction year reasonable?
buildings |> summarise(
  min_year = min(construction_year, na.rm = TRUE),
  max_year = max(construction_year, na.rm = TRUE)
)

# 6. Building status values
table(buildings$building_status, useNA = "ifany")

# 7. Check construction years that look wrong

buildings |> filter(construction_year < 1800 | construction_year > 2100)

# under 1965 and above 2026 should be NA


# ADDRESSES

# 1. Unique ID
addresses |> 
  count(id_address) |> 
  filter(n > 1)

# 2. Missing ID?
sum(is.na(addresses$id_address))

# 3. Validity period logic
addresses |> 
  filter(!is.na(end_valid) & end_valid < start_valid)

# 4. Postcode format validation
grep("^[0-9]{4}[A-Z]{2}$", addresses$postcode, invert = TRUE) |> length()

# 5. House numbers positive integer?
addresses |> filter(house_number <= 0)

# 6. Public space ID missing?
sum(is.na(addresses$id_public_space))

# 7. Check house addition

table(addresses$house_addition, useNA = "ifany")


addresses |> 
  select(postcode) |> 
  tbl_summary()


# PUBLIC SPACES

# 1. Unique ID
public_spaces |> 
  count(id_public_space) |> 
  filter(n > 1)

# 2. Missing ID?
sum(is.na(public_spaces$id_public_space))

# 3. Validity logic
public_spaces |> 
  filter(!is.na(end_valid) & end_valid < start_valid)

# 4. Missing names?
sum(is.na(public_spaces$public_space_name))

# 5. Valid type values?
table(public_spaces$public_space_type, useNA = "ifany")

# 6. Town ID missing?
sum(is.na(public_spaces$id_town))


# TOWNS

# 1. Unique IDs
towns|> 
  count(id_town) |> 
  filter(n > 1)

# 2. Missing IDs
sum(is.na(towns$id_town))

# 3. Validity logic
towns |> 
  filter(!is.na(end_valid) & end_valid < start_valid)

# 4. Missing names?
sum(is.na(towns$town_name))

# 5. Valid status values?
table(towns$town_status, useNA = "ifany")

# 6. Explore max/min values

towns |> summarise(
  min_x = min(x_coord, na.rm = TRUE),
  max_x = max(x_coord, na.rm = TRUE),
  min_y = min(y_coord, na.rm = TRUE),
  max_y = max(y_coord, na.rm = TRUE)
)


# MUNICIPALITIES

# 1. Unique mapping per town
municipalities |> 
  count(id_town) |> 
  filter(n > 1)

# 2. Missing IDs
summis <- municipalities |> 
  summarise(
    missing_town = sum(is.na(id_town)),
    missing_mun  = sum(is.na(id_municipality))
  )

# 3. Validity logic
municipalities |> 
  filter(!is.na(end_valid) & end_valid < start_valid)

# 4. Status values
table(municipalities$municipality_status, useNA = "ifany")

# SALES

# 1. check for duplicate sale records 

sales |> 
  count(full_address, sale_date, price) |>
  filter(n > 1)


# 2. Missing important fields
sales |> summarise(
  missing_street   = sum(is.na(street_name)),
  missing_number   = sum(is.na(house_number)),
  missing_postcode = sum(is.na(postcode)),
  missing_date     = sum(is.na(sale_date)),
  missing_price    = sum(is.na(price))
)

# 3. House number must be numeric
sales |> filter(!str_detect(house_number, "^[0-9]+$"))

# Convert to integer after validation
sales <- sales |> mutate(house_number = 
                           as.integer(house_number))

# 4. Postcode format must match BAG (4 digits + 2 uppercase letters)
invalid_postcodes <- sales |> 
  filter(!str_detect(postcode, "^[0-9]{4}[A-Z]{2}$"))

nrow(invalid_postcodes)

# 5. House addition should be clean 
table(sales$house_addition, useNA = "ifany")

# 6. Sale price must be positive
sales |> filter(price <= 0)

# 7. Sale date must be in 2024 
sales |> summarise(
  min_date = min(sale_date),
  max_date = max(sale_date)
)


# 8. Validate town names
table(sales$town_name, useNA = "ifany")

# Compare with BAG towns
setdiff(unique(sales$town_name), unique(towns$towns_name))

# 9. Validate street name casing / excessive whitespace
sales |> 
  summarise(
    whitespace_street = sum(str_detect(street_name, "^\\s|\\s$")),
    lowercase_street  = sum(street_name == tolower(street_name))
  )

# 10. Outlier detection (optional for production systems)
sales |> 
  summarise(
    q1 = quantile(price, 0.25),
    q3 = quantile(price, 0.75),
    iqr = IQR(price),
    max_price = max(price),
    min_price = min(price)
  )



# Relationship validation

sum(!dwellings$id_building %in% buildings$id_building)


sum(!addresses$id_public_space %in% public_spaces$id_public_space)


sum(!public_spaces$id_town %in% towns$id_town)


sum(!towns$id_town %in% municipalities$id_town)

