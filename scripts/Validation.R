
# in progress 


# Load datasets
addresses_input     <- read_rds("data/processed/addresses_input.rds")
public_spaces_input <- read_rds("data/processed/public_spaces_input.rds")
towns_input         <- read_rds("data/processed/towns_input.rds")
municipalities_input<- read_rds("data/processed/municipalities_input.rds")
buildings_input     <- read_rds("data/processed/buildings_input.rds")
dwellings_input     <- read_rds("data/processed/dwellings_input.rds")
sales_input         <- read_rds("data/processed/sales_input.rds")

# Load rules
rules <- validate::validator(.file = "scripts/validation_rules.R")

# Validate each dataset
out_addresses      <- confront(addresses_input, rules)
out_public_spaces  <- confront(public_spaces_input, rules)
out_towns          <- confront(towns_input, rules)
out_municipalities <- confront(municipalities_input, rules)
out_buildings      <- confront(buildings_input, rules)
out_dwellings      <- confront(dwellings_input, rules)
out_sales          <- confront(sales_input, rules)


summary(out_addresses)

summary(out_public_spaces)
summary(out_towns)

