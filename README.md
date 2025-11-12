
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

1) Install renv: install.packages("renv")
2) In the project root, run: renv::restore()

### Daily workflow
- Edit code/00_packages.R to add/remove packages.
- Run renv::snapshot() after changes.
- Commit renv.lock.