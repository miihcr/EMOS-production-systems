# get.data.R

# 1. Load all raw Dutch CSV files'

dir.create("data/processed", recursive = TRUE)


dir.create("data/processed", recursive = TRUE)

file.copy("data/raw/nummeraanduidingen.csv",
          "data/processed/addresses.csv",
          overwrite = TRUE)

file.copy("data/raw/openbareruimte.csv",
          "data/processed/public_spaces.csv",
          overwrite = TRUE)

file.copy("data/raw/verblijfsobjecten.csv",
          "data/processed/dwellings.csv",
          overwrite = TRUE)

file.copy("data/raw/woonplaatsen.csv",
          "data/processed/towns.csv",
          overwrite = TRUE)

file.copy("data/raw/gemeente_woonplaats.csv",
          "data/processed/municipalities.csv",
          overwrite = TRUE)

file.copy("data/raw/panden.csv",
          "data/processed/buildings.csv",
          overwrite = TRUE)

file.copy("data/raw/sales.csv",
          "data/processed/sales.csv",
          overwrite = TRUE)

message("✓ Raw Dutch files copied and renamed into English filenames.")