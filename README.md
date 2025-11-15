
# Project Title

Project EMOS- Production Systems

## Folder structure
- `01_raw/` – raw inputs
- `02_input/` – processed inputs
- `03_valid/` – validation
- `04_stats/` – stats & analysis
- `05_output/` – final outputs
- `code/` – scripts (e.g., `00_packages.R`, `get_data.R`)
- `images/` – figures

## Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/miihcr/EMOS-production-systems.git
   cd EMOS-production-systems
   ```
2. Open the project in RStudio (Group Assignment.Rproj).
3.  Install and activate renv:
  ```r install.packages("renv")
      renv::restore()
  ```
This will install all required R packages with the exact versions used by the team.


## Usage

1. Load all required packages:

source("code/00_packages.R")


2. Read all raw CSVs (if applicable):

source("code/get_data.R")
data <- get_data("01_raw/data")


3. Run the scripts in order:

source("code/01_clean_data.R")
source("code/02_analysis.R")
source("code/03_visualizations.R")

## Daily workflow

1. Always pull the latest changes before starting work:

git pull


2. Add or remove packages in code/00_packages.R.

3. After making package changes, update the environment:

renv::snapshot()


This updates the renv.lock file to capture new package versions.

4. Commit your work:

git add .
git commit -m "Describe your change"
git push
