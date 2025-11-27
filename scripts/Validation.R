install.packages("validate")

library(validate)
library(here)


data(SBS2000)

rules <- validate::validator(.file = "rules.R")

?validator


out <- validate::confront(SBS2000, rules, key = "id")

plot(out)


