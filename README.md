
# EMOS – Production Systems

---

## Folder structure

Note: 

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

## Data (important!)

The data files used in this project are not included in the repository (they are too large and excluded through ``.gitignore``

### Download the data manually

Download the buildings register dataset:

[Buildings register](https://research.cbs.nl/emos/buildings_register.zip) 

Unzip the contents and place all raw CSV files into:

```bash
data/raw/
```
The folder should look like this:

```
data/
└── raw/
    ├── nummeraanduidingen.csv
    ├── openbareruimte.csv
    ├── verblijfsobjecten.csv
    ├── woonplaatsen.csv
    ├── gemeente_woonplaats.csv
    ├── panden.csv
    └── sales3.csv

```
  
These files are required for the pipeline to run correctly.

## Setup

### 1. Clone this repository

```bash
git clone https://github.com/miihcr/EMOS-production-systems.git
cd EMOS-production-systems
```

### 2. Open the RStudio project

```
EMOS-production-systems.Rproj
```

### 3. Ensure the correct folder structure

Make sure that the project contains the following folder structure:

EMOS-production-systems/
├── 01_raw/
├── 02_input/
├── 02_processed/
├── 03_valid/
├── 04_stats/
├── 05_output/
├── data/
│   ├── raw/
│   └── processed/
├── images/
├── scripts/
│   ├── 00_packages.R
│   ├── 01_raw_to_input.R
│   ├── 02_input_to_linked.R
│   ├── 03_linked_to_output.R
│   └── output.R
└── README.md

If the folders do not yet exist, you can create them automatically by running the following script from inside the RStudio project:
source("scripts/00_create_directories.R")

### 4. Load all required R packages

Packages are managed via a simple setup script (`scripts/00_packages.R`).
They load automatically when the project opens.

To run manually (although not required if the project opens correctly):

```r
source("scripts/00_packages.R")
```
This script install missing packages and loads all required packages.

---

## Usage

### Load project packages

```r
source("scripts/00_packages.R")
```

### Data

All data is stored in `data/raw`and `data/processed`. Eventually they will be moved to its correct steady state. 

### Run the analysis pipelines

Run scripts in order:

```r
source("scripts/01_raw_to_input.R")
source("scripts/02_input_to_linked.R")
source("scripts/03_linked_to_output.R")
source("scripts/04_output.R")
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


