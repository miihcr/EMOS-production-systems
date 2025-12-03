
# EMOS – Production Systems

---

## Folder structure

```
EMOS-production-systems/
├── 01_raw/
│   ├── data/
│   └── get_data.R/
├── 02_input/
│   ├── data/
│   └── raw_to_input.R/
├── 03_valid/
│   ├── data/
│   └── input_to_valid.R/
├── 04_stats/
│   ├── data/
│   └── valid_to_stats.R/
├── 05_output/
│   └── avg_prices_den_bosch_2024.csv/
├── scripts/
│   ├── 00_create_directories.R
│   ├── 00_packages.R
└── .gitignore
└── .Rprofile
└── EMOS-production-systens.Rproj
└── README.md
└── 

```
---

## Setup (first-time use):

### 1. Clone this repository

```bash
git clone https://github.com/miihcr/EMOS-production-systems.git
cd EMOS-production-systems
```
### 2. Open the RStudio Project

```
EMOS-production-systems.Rproj
```
### 3. Create the required folder structure
From inside RStudio, run:

```bash
source("scripts/00_create_directories.R")
```
## Data Setup (important!)

The raw data is not included in the repository. The data files are excluded via ``.gitignore`` due to their size.

### 4. Download the raw data (ZIP file)
Download the datasets here:

[Download files](https://filesender.surf.nl/?s=download&token=8c1876ba-9bdc-409d-a593-d0d7b38afb2c)

### 5. Place the ZIP file hee (Do NOT unzip manually)
After downloading, place the ZIP file and sales.csv file into:

```bash
01_raw/data
```
The folder should look like this:

```
data/
├── buildings_register.zip
└── sales.csv

```
Do not unzip it yourself as the following script will handle this automatically.

## Running the pipeline
Run the following scripts in the console sequentially. 

Note: Packages are managed via a simple setup script (`scripts/00_packages.R`).
They load automatically when the project opens.

To run manually (although not required if the project opens correctly):

```r
source("scripts/00_packages.R")
```
This script installs missing packages and loads all required packages.

### 1. Unzip & Load raw data

```r
source("01_raw/get_data.R")
```
This will:
- Unzip buildings_register.zip
- Fix nested folders
- Load all raw CSV files
- Save RDS files for the next pipeline step

Note: it is important to use the RDS files so that the correct data types are used.

### 2. Process to input data

```r
source("02_input/raw_to_input.R")
```
### 3. Validate the data

```r
source("03_valid/input_to_valid.R")
```
### 4. Run statistical processing

```r
source("04_stats/valid_to_stats.R")
```

### 4. Final output
The final output will be saved automatically into:
```bash
05_output/avg_prices_den_bosch_2024.csv
```
---

## Workflow

### Pull the latest changes before working

```bash
git pull
```

### Edit scripts as needed

Each pipeline step is isolated:

`01_raw/` → raw ingestion

`02_input/` → preprocessing

`03_valid/` → validation

`04_stats/` → statistics

`05_output/` → final output

### Commit and push your work

```bash
git add .
git commit -m "Describe your change"
git push
```


