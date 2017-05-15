# CRAN packages
r_packages <- c("crosstalk", "devtools", "dplyr", "htmltools", "httr",
                "jsonlite", "knitr", "magrittr", "purrr", "readr", "rmarkdown",
                "shiny", "shinydashboard", "stringr", "tibble", "tidyjson",
                "tidyr")
# GitHub packages
r_github_packages <- "rstudio/DT"

# Install the CRAN packages
install.packages(r_packages)
# Install the GitHub packages
purrr::walk(r_github_packages, devtools::install_github)

# Build the site
rmarkdown::render_site()
