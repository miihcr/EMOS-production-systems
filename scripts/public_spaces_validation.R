# Validation for public spaces dataset


public_spaces_input <- read_rds("data/processed/public_spaces_input.rds")

str(public_spaces_input)

skim(public_spaces_input)

# Any missing names?

# Are some names empty strings?
  
# Are IDs unique?
  
# How many public space types?
  
# Missing end dates?
  
# Any future start dates?

public_spaces_input |>
  summarise(across(everything(), \(x) sum(is.na(x)), .names = "missing_{.col}"))

# No missing values

public_spaces_input |>
  count(id_public_space) |>
  filter(n > 1)

# No duplicates

public_spaces_input |>
  summarise(
    all_numeric = all(grepl("^[0-9]+$", id_public_space)),
    min_length = min(nchar(id_public_space)),
    max_length = max(nchar(id_public_space))
  )

public_spaces_input |>
  count(public_space_name, sort = TRUE)


public_spaces_input |>
  filter(public_space_name == "" | str_trim(public_space_name) == "")


public_spaces_input |>
  mutate(name_length = nchar(public_space_name)) |>
  summarise(
    min = min(name_length),
    med = median(name_length),
    max = max(name_length)
  )

public_spaces_input |>
  count(public_space_type, sort = TRUE)

public_spaces_input |> count(id_town, sort = TRUE)

public_spaces_input |> filter(is.na(start_valid))


public_spaces_input |> filter(start_valid > Sys.Date())

public_spaces_input |>
  filter(!is.na(end_valid) & end_valid < start_valid)
