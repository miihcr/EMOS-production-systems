# 00_packages.R
# Central package setup for the project
# Automatically installs + loads all required R packages.

load_required_packages <- function() {
  
  # List all required packages here:
  packages <- c(
    # Tidyverse core
    "tidyverse", "dplyr", "readr", "tidyr", "ggplot2",
    "stringr", "forcats", "lubridate", "purrr",
    
    # Data & modeling
    "broom", "caret", "glmnet", "reclin2",
    
    # Utilities
    "here", "fs", "janitor", "data.table", "validate",
    
    # Others you need
    "digest"
  )
  
  # Function to install missing packages
  install_missing <- function(pkgs) {
    missing <- pkgs[!pkgs %in% rownames(installed.packages())]
    if (length(missing) > 0) {
      message("Installing missing packages: ", paste(missing, collapse = ", "))
      install.packages(missing, dependencies = TRUE)
    }
  }
  
  install_missing(packages)
  
  # Load all packages quietly
  invisible(lapply(packages, function(pkg) {
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
  }))
  
  message("✓ All packages loaded successfully")
}

# Run it
load_required_packages()
