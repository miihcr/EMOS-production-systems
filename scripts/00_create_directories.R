# 00_create_directories.R
# Ensures that all required project directories exist

cat("Starting project structure check...\n\n")

cat("Starting project structure check...\n\n")

# ----------------------------
# 1. DEFINE ALL DIRECTORIES
# ----------------------------
dirs <- c(
  "01_raw/data",
  "02_input/data",
  "03_valid/data",
  "04_stats/data",
  "05_output"
)

# ----------------------------
# 2. CREATE DIRECTORIES
# ----------------------------
for (d in dirs) {
  if (!dir.exists(d)) {
    dir.create(d, recursive = TRUE)
    cat("Created directory:", d, "\n")
  } else {
    cat("Exists:", d, "\n")
  }
}

cat("\n")

# ----------------------------
# 3. DEFINE ONLY THE PIPELINE FILES
# ----------------------------
files <- c(
  "01_raw/get_data.R",
  "02_input/raw_to_input.R",
  "03_valid/input_to_valid.R",
  "04_stats/valid_to_stats.R",
  "05_output/avg_prices_den_bosch_2024.csv"
)

# ----------------------------
# 4. CREATE FILES SAFELY
# ----------------------------
for (f in files) {
  if (!file.exists(f)) {
    file.create(f)
    cat("Created file:", f, "\n")
  } else {
    cat("Exists:", f, "\n")
  }
}

cat("\n✅ Pipeline structure is now complete.\n")

