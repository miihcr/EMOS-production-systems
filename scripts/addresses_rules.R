# ---- Validation rules for ADDRESSES --------------------------------------

# Check that variables exist
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

# ID must be unique
is_unique(id_address)

# ID must not be missing
!is.na(id_address)

# --- Type checks -----------------------------------------------------------
typeof(id_address) == "character"
typeof(house_number) == "integer"
typeof(house_addition) == "character" | is.na(house_addition)
typeof(id_public_space) == "character"
inherits(start_valid, "Date")
inherits(end_valid, "Date") | is.na(end_valid)

# --- House number ----------------------------------------------------------
house_number > 0

# --- House addition --------------------------------------------------------
is.na(house_addition) |
  grepl("^[A-Z0-9]+$", house_addition)

# --- Postcode --------------------------------------------------------------
is.na(postcode) |
  grepl("^[1-9][0-9]{3}[A-Z]{2}$", postcode)

# --- Date logic ------------------------------------------------------------
!is.na(start_valid)

is.na(end_valid) | end_valid >= start_valid

# --- Foreign key -----------------------------------------------------------
id_public_space %vin% public_spaces_input$id_public_space

# --- Period uniqueness (no duplicate intervals) ----------------------------
key(id_address, start_valid, end_valid)
