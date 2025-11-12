indir <- "01Raw"
outdir <- "02Input"

library(jsonlite)
library(validate)
library(writexl)


# read data, transform to data frame
dat <- jsonlite::fromJSON(file.path(indir,"SBS2000.json"))

# perform technical checks; export summary
rules <- validate::validator(.file=file.path(outdir,"demands_on_input.R"))

check <- confront(dat, rules, key="id")

writexl::write_xlsx(summary(check), path=file.path(outdir,"validation_summary.xlsx"))

if (!all(check)){
  write.csv(as.data.frame(check),file=file.path(outdir,"validation_results.csv"))
} 

# export cleaned up file
write.csv(dat, file=file.path(outdir,"input.csv"), row.names=FALSE)



