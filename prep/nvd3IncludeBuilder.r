library(magrittr)
# names of files
nvStyles <- c(
    'libraries/nvd3/css/nv.d3.css',
    'libraries/nvd3/css/rNVD3.css'
)
nvScripts <- c(
    'libraries/nvd3/js/jquery-1.8.2.min.js',
    'libraries/nvd3/js/d3.v3.min.js',
    'libraries/nvd3/js/nv.d3.min-new.js',
    'libraries/nvd3/js/fisheye.js'
)

# create
dir.create('nvd3Files/libraries/nvd3/css', recursive=TRUE, showWarnings=FALSE)
dir.create('nvd3Files/libraries/nvd3/js', recursive=TRUE, showWarnings=FALSE)
fileDest <- file.path('nvd3Files', c(nvStyles, nvScripts))
# copy from package to folder in repo
system.file(c(nvStyles, nvScripts), package='rCharts') %>% 
    purrr::walk2(fileDest, file.copy, overwrite=TRUE)

# create html file listing the includes
c(
    sprintf("<link rel='stylesheet' href=%s>", fileDest[1:NROW(nvStyles)]),
    sprintf("<script type='text/javascript' src=%s></script>", fileDest[(NROW(nvStyles)+1):NROW(fileDest)])
) %>% writeLines(con='nPlot_Includes.html', sep='\n')
