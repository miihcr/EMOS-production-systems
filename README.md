
# EMOS – Production Systems

---

## Folder structure

```
01_raw/      - raw inputs
02_input/    - processed inputs
03_valid/    - validation files
04_stats/    - statistical analysis
05_output/   - final outputs
scripts/     - R scripts (00_packages.R, get_data.R, cleaning & analysis scripts)
images/      - figures & plots

```
---

## Setup

### 1. Clone this repository

```bash
git clone https://github.com/miihcr/EMOS-production-systems.git
cd EMOS-production-systems
```

### 2. Open the RStudio project

```
Group Assignment.Rproj
```

### 3. Load all required R packages

Packages are managed via a simple setup script (`scripts/00_packages.R`).
They load automatically when the project opens.

To run manually:

```r
source("scripts/00_packages.R")
```
This script:

* installs missing packages
* loads all required packages

---

## Usage

### Load project packages

```r
source("scripts/00_packages.R")
```

### Read raw data

```r
source("scripts/get_data.R")
data <- get_data("01_raw/data")
```

### Run the analysis pipelines

Run scripts in order:

```r
source("scripts/01_clean_data.R")
source("scripts/02_analysis.R")
source("scripts/03_visualizations.R")
```

Outputs (tables, stats, models, plots) are saved to:

* `04_stats/`
* `05_output/`
* `images/`

---

## Daily workflow

### 1. Pull the latest changes before working

```bash
git pull
```

### 2. Edit scripts or data as needed

Add or remove packages in:

```
scripts/00_packages.R
```

### 3. Commit and push your work

```bash
git add .
git commit -m "Describe your change"
git push
```


