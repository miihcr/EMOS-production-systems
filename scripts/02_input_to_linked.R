# 02_input_to_linked.R
# Steady State 1 (input) → Steady State 3 (linked & harmonised)
# Probabilistic address linkage using reclin2

# Step 0 — Load cleaned input data (Steady State 1)


sales_input          <- read_rds("01_raw/data/input/sales_input.rds")
addresses_input      <- read_rds("01_raw/data/input/addresses_input.rds")
dwellings_input      <- read_rds("01_raw/data/input/dwellings_input.rds")
public_spaces_input  <- read_rds("01_raw/data/input/public_spaces_input.rds")
towns_input          <- read_rds("01_raw/data/input/towns_input.rds")
municipalities_input <- read_rds("01_raw/data/input/municipalities_input.rds")


# Step 1–5 — Deduplicate BAG register tables

addresses_clean <- addresses_input |> 
  arrange(address_id, desc(start_valid)) |> 
  distinct(address_id, .keep_all = TRUE)

public_spaces_clean <- public_spaces_input |> 
  arrange(public_space_id, desc(start_valid)) |> 
  distinct(public_space_id, .keep_all = TRUE)

dwellings_clean <- dwellings_input |> 
  arrange(dwelling_id, desc(start_valid)) |> 
  distinct(dwelling_id, .keep_all = TRUE)

towns_clean <- towns_input |> 
  arrange(town_id, desc(start_valid)) |> 
  distinct(town_id, .keep_all = TRUE)

municipalities_clean <- municipalities_input |> 
  arrange(town_id, municipality_id, desc(start_valid)) |> 
  distinct(town_id, municipality_id, .keep_all = TRUE)


# Step 6 — Build BAG reference table

bag_addresses <- addresses_clean |> 
  left_join(
    public_spaces_clean |> 
      select(public_space_id, public_space_name, town_id),
    by = "public_space_id"
  ) |> 
  left_join(
    towns_clean |> 
      select(town_id, town_name),
    by = "town_id"
  ) |> 
  transmute(
    address_id,
    postcode,
    house_number,
    house_addition,
    street_name = public_space_name,
    city        = town_name,
    town_id
  )


# Step 7 — Harmonise variable types & normalise city/street names


sales <- sales_input |> 
  mutate(
    house_number   = as.character(house_number),
    house_addition = as.character(house_addition),
    postcode       = as.character(postcode),
    city           = str_to_lower(city)
  )

bag_addresses <- bag_addresses |> 
  mutate(
    house_number   = as.character(house_number),
    house_addition = as.character(house_addition),
    postcode       = as.character(postcode),
    street_name    = as.character(street_name),
    city = city |> 
      str_to_lower() |> 
      str_replace_all("[^a-z0-9 ]", "") |> 
      str_squish()
  )


# Step 8 — Generate candidate pairs 

pairs_pc   <- pair_blocking(sales, bag_addresses, "postcode")
pairs_city <- pair_blocking(sales, bag_addresses, "city")

link_pairs <- merge_pairs(pairs_pc, pairs_city)

message("Candidate pairs: ", nrow(link_pairs))

# Step 9 — Compare pairs with correct comparators

link_pairs <- compare_pairs(
  link_pairs,
  on = c("house_number", "house_addition", "street_name", "city"),
  comparators = list(
    house_number   = cmp_identical(),
    house_addition = cmp_identical(),
    street_name    = cmp_jarowinkler(0.95),
    city           = cmp_identical()
  ),
  inplace = TRUE
)


# Step 10 — Score pairs


link_pairs <- score_simple(
  link_pairs,
  "score",
  on = c("house_number", "house_addition", "street_name", "city"),
  w1 = c(
    house_number   = 3,
    house_addition = 1.5,
    street_name    = 2.5,
    city           = 1.5
  ),
  w0  = 0,
  wna = 0
)

message("Score range: ", paste(range(link_pairs$score, na.rm = TRUE), collapse = " – "))


# Decide on a threshold for linking based on the 

# hist(link_pairs$score, breaks = 100)
# summary(link_pairs$score)
# quantile(link_pairs$score, seq(0,1,0.01))



# Step 11 — Select pairs above threshold

THRESHOLD <- 7.5

link_pairs <- select_threshold(
  link_pairs,
  "threshold",
  score = "score",
  threshold = THRESHOLD
)

message("Pairs above threshold: ", sum(link_pairs$threshold))



# Step 12 — Enforce one-to-one linking (greedy)


link_pairs <- select_greedy(
  link_pairs,
  score = "score",
  variable = "greedy",
  threshold = THRESHOLD
)

# Step 13 — Create linked dataset

linked_sales_addresses <- link(
  link_pairs,
  selection = "greedy"
)

message("Linked records created: ", nrow(linked_sales_addresses))


# Replace empty names with safe placeholders
names(linked_sales_addresses) <- make.names(names(linked_sales_addresses), unique = TRUE)


# Rename into meaningful variable names
names(linked_sales_addresses)[1:17] <- c(
  "bag_row", "sales_row",
  "sale_id",
  "street_name_sales",
  "house_number_sales",
  "house_addition_sales",
  "postcode_sales",
  "city_sales",
  "sale_date",
  "price_eur",
  "address_id",
  "postcode_bag",
  "house_number_bag",
  "house_addition_bag",
  "street_name_bag",
  "city_bag",
  "town_id"
)

# Step 15 — Re-join the score & create flags


linked_sales_addresses <- linked_sales_addresses |> 
  left_join(
    link_pairs |> 
      as_tibble() |> 
      select(.x, .y, score),
    by = c("sales_row" = ".x", "bag_row" = ".y")
  ) |> 
  mutate(
    flag_address_prob = if_else(!is.na(address_id), 1L, 0L),
    linkage_weight    = score
  )


# Step 16 — Join dwellings (address_id → dwelling_id)


linked_sales_addresses <- linked_sales_addresses |>
  left_join(
    dwellings_clean |> 
      select(address_id, dwelling_id, id_building, area_m2,
             gebruiksdoel, x, y),
    by = "address_id"
  ) |>
  mutate(
    flag_dwelling_link = if_else(!is.na(dwelling_id), 1L, 0L)
  )

message("Matched sales: ", sum(linked_sales_addresses$flag_address_prob))
message("Unmatched sales: ", sum(linked_sales_addresses$flag_address_prob == 0))
message("Linked dwellings: ", sum(linked_sales_addresses$flag_dwelling_link))


# Step 17 — Save Steady State 3


dir.create("02_processed", showWarnings = FALSE)

# write_rds(linked_sales_addresses, "02_processed/linked_sales_addresses.rds")

message("Steady State 3 written to 02_processed/linked_sales_addresses.rds")