# Validation

sales        <- read_rds("data/cleaned/sales.rds")
addresses    <- read_rds("data/cleaned/addresses.rds")
dwellings    <- read_rds("data/cleaned/dwellings.rds")
public_spaces <- read_rds("data/cleaned/public_spaces.rds")
towns         <- read_rds("data/cleaned/towns.rds")
municipalities<- read_rds("data/cleaned/municipalities.rds")
buildings    <- read_rds("data/cleaned/buildings.rds")


# Dwellings


# 1. Are dwelling IDs unique?
dwellings |> 
  count(id_dwelling) |> 
  filter(n > 1)

# 2. Any missing dwelling IDs?
sum(is.na(dwellings$id_dwelling))

# 3. Validity logic: end >= start OR end NA
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



# Relationship validation

sum(!dwellings$id_building %in% buildings$id_building)


sum(!addresses$id_public_space %in% public_spaces$id_public_space)


sum(!public_spaces$id_town %in% towns$id_town)


sum(!towns$id_town %in% municipalities$id_town)
