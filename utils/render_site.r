# install required packages
pkgs <- c('crosstalk', 'tidyjson')
install.packages(pkgs)

# need dev version of DT to work properly
devtools::install_github('rstudio/DT')

# render website
rmarkdown::render_site()
