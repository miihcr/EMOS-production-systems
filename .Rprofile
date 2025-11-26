message(">>> .Rprofile HAS BEEN LOADED <<<")

# Delay loading until R session is fully ready
local({
  later <- function(expr) {
    # schedule the expression to run after startup
    base::setHook("rstudio.sessionInit", function(...) eval(expr, envir = .GlobalEnv), action = "append")
  }
  
  if (file.exists("scripts/00_packages.R")) {
    later(quote(source("scripts/00_packages.R")))
  }
})
