# code/00_packages.R
# central place to install + load packages for this project

pkgs <- c(
  # core
  "tidyverse", "here", "janitor", "validate",
  "readr", "lumberjack"
)

# install any missing ones into the project library
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing)) install.packages(missing)

# load them all
invisible(lapply(pkgs, require, character.only = TRUE))

