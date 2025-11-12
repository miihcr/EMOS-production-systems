# .Rprofile (project-level)

# Use renv if present (reproducible libs)
if (requireNamespace("renv", quietly = TRUE)) {
  try(renv::load(), silent = TRUE)
}

# Load your package set
if (file.exists("code/00_packages.R")) source("code/00_packages.R")
