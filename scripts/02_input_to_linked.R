# 02_input_to_linked.R

# Probabilistic address linkage using reclin2

# Helper function

clean_name <- function(x) {
  x |>
    str_to_lower() |>
    str_replace_all("[^a-z0-9 ]", " ") |>
    str_squish()
}

# Step 0 — Load cleaned input data (Steady State 1)


sales_input         <- read_rds("data/processed/sales_input.rds")
addresses_input     <- read_rds("data/processed/addresses_input.rds")
dwellings_input     <- read_rds("data/processed/dwellings_input.rds")
public_spaces_input <- read_rds("data/processed/public_spaces_input.rds")
towns_input         <- read_rds("data/processed/towns_input.rds")
municipalities_input<- read_rds("data/processed/municipalities_input.rds")
buildings_input     <- read_rds("data/processed/buildings_input.rds")

sales         <- sales_input
addresses     <- addresses_input
public_spaces <- public_spaces_input
towns         <- towns_input
dwellings     <- dwellings_input
municipalities<- municipalities_input
buildings     <- buildings_input


# Step 1 — Build BAG reference table

bag_addresses <- addresses |>
  left_join(
    public_spaces |>
      select(id_public_space, public_space_name, town_id),
    by = "id_public_space"
  ) |>
  left_join(
    towns |>
      select(id_town, town_name),
    by = c("town_id" = "id_town")
  ) |>
  transmute(
    address_id    = id_address,
    postcode,
    house_number,
    house_addition,
    street_name   = public_space_name,
    city          = town_name,
    town_id
  )

# Step 2 — Prepare SALES and BAG tables for linkage



# Sales linkage table
sales_link <- sales |>
  transmute(
    sale_id        = row_number(),               # explicit ID per sale
    street_name    = clean_name(street_name),
    house_number   = as.character(house_number),
    house_addition = as.character(house_addition),
    postcode       = as.character(postcode),
    city           = clean_name(town_name),
    sale_date      = sale_date,
    price_eur      = sales_price_eur
  )

# BAG linkage table
bag_link <- bag_addresses |>
  mutate(
    street_name    = clean_name(street_name),
    city           = clean_name(city),
    house_number   = as.character(house_number),
    house_addition = as.character(house_addition),
    postcode       = as.character(postcode)
  )

message("Sales rows: ", nrow(sales_link))
message("BAG address rows: ", nrow(bag_link))


# Step 3 — Generate candidate pairs 

pairs_pc   <- pair_blocking(sales_link, bag_link, "postcode")
pairs_city <- pair_blocking(sales_link, bag_link, "city")


link_pairs <- merge_pairs(pairs_pc, pairs_city)

message("Candidate pairs: ", nrow(link_pairs))

# Step 4 — Compare pairs

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

# Step 5 — Score pairs


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

message("Score range: ", paste(range(link_pairs$score, na.rm = TRUE), 
                               collapse = " – "))


# Decide on a threshold for linking based on the histogram

# hist(link_pairs$score, breaks = 100)
# summary(link_pairs$score)


# Step 6 — Threshold + one-to-one greedy selection

THRESHOLD <- 7.5

link_pairs <- select_threshold(
  link_pairs,
  "threshold",
  score = "score",
  threshold = THRESHOLD
)

message("Pairs above threshold: ", sum(link_pairs$threshold))



link_pairs <- select_greedy(
  link_pairs,
  score = "score",
  variable = "greedy",
  threshold = THRESHOLD
)

# Step 7 — Build linked datased


linked_raw <- link(
  link_pairs,
  selection = "greedy"
)

message("Linked records created: ", nrow(linked_raw))


# Replace with safe names 

names(linked_raw) <- make.names(names(linked_raw), 
                                unique = TRUE)

# Add score + address flags
linked_scored <- linked_raw |> 
  rename(
    bag_row               = .y,
    sales_row             = .x,
    street_name_sales     = street_name.x,
    house_number_sales    = house_number.x,
    house_addition_sales  = house_addition.x,
    postcode_sales        = postcode.x,
    city_sales            = city.x,
    postcode_bag          = postcode.y,
    house_number_bag      = house_number.y,
    house_addition_bag    = house_addition.y,
    street_name_bag       = street_name.y,
    city_bag              = city.y
  ) |> 
  left_join(
    link_pairs |> as_tibble() |> select(.x, .y, score),
    by = c("sales_row" = ".x", "bag_row" = ".y")
  ) |>
  mutate(
    flag_address_prob = if_else(!is.na(address_id), 1L, 0L),
    linkage_weight    = score
  )


# Merge dwellings
linked_final <- linked_scored |>
  left_join(
    dwellings |> 
      select(
        id_address,
        id_dwelling,
        id_building,
        area_m2,
        usage_purpose,
        x_coord,
        y_coord
      ),
    by = c("address_id" = "id_address")
  ) |>
  mutate(
    flag_dwelling_link = if_else(!is.na(id_dwelling), 1L, 0L)
  )


message("Matched sales: ", sum(linked_final$flag_address_prob,
                               na.rm = TRUE))
message("Unmatched sales: ", sum(linked_final$flag_address_prob == 0, 
                                 na.rm = TRUE))
message("Linked dwellings: ", sum(linked_final$flag_dwelling_link, 
                                  na.rm = TRUE))



# Step 8: Save steady state


write_rds(linked_sales_addresses, "data/processed/linked_sales_addresses.rds")

message("Steady State 3 written to data/processed/linked_sales_addresses.rds")
