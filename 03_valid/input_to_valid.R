indir <- "02Input/"
outdir <- "03Valid/"

library(validate)
library(dcmodify)

dat <- read.csv(file.path(indir,"input.csv"))

rules <- validate::validator(.file=file.path(outdir,"demands_on_valid.R"))

modifyer <- dcmodify::modifier(.file=file.path(outdir,"cleaning_rules.R"))

out <- modify(dat, modifyer)
out


write.csv(out, file=file.path(outdir,"valid.csv"),row.names=FALSE)

