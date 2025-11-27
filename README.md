
# EMOS – Production Systems

---

## Folder structure

```
01_raw/      - raw inputs
02_input/    - processed inputs
03_valid/    - validation files
04_stats/    - statistical analysis
05_output/   - final outputs
scripts/     - R scripts that will later be organized in the above folders
images/      - figures & plots
data/        - both raw and processed data

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

### Data

All data is stored in data/raw and data/processed.

### Run the analysis pipelines

Run scripts in order:

```r
source("scripts/01_raw_to_input.R")
source("scripts/02_input_to_linked.R")
source("scripts/03_linked_to_output.R")
source("scripts/output.R")
```
---

## Workflow

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


