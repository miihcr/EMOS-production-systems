



variables := c(
  "id_address",
  "house_number",
  "house_addition",
  "id_public_space",
  "postcode",
  "start_valid",
  "end_valid"
)

all(variables %in% names(.))

# Unique

is_unique(id_address)

# Variable type

is.character(id_address)
is.character(house_addition)
is.character(id_public_space)
is.integer(house_number)
is.Date(start_valid)
is.Date(end_valid)

# Missingness

!is.na(id_address)
!is.na(house_number)
!is.na(id_public_space)
!is.na(start_valid)

# Value rules

house_number > 0

is.na(house_addition) |
  grepl("^[A-Z0-9]+$", house_addition)

is.na(postcode) |
  grepl("^[1-9][0-9]{3}[A-Z]{2}$", postcode)

is.na(end_valid) | end_valid >= start_valid


id_public_space %vin% public_spaces_input$id_public_space






