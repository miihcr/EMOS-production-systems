# 00_create_directories.R
# Ensures that all required project directories exist

required_dirs <- c(
  "01_raw",
  "02_input",
  "02_processed",
  "03_valid",
  "04_stats",
  "05_output",
  "data",
  "data/raw",
  "data/processed",
  "images",
  "scripts"
)

for (d in required_dirs) {
  if (!dir.exists(d)) {
    dir.create(d, recursive = TRUE)
    message("Created directory: ", d)
  }
}

message("✓ All required directories are present.")
