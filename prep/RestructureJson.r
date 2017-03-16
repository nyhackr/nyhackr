library(magrittr)

jPlain <- readLines('data/events.json') %>% paste(collapse='')

jClean <- jPlain %>% 
    # get rid of newlines and tabs
    stringr::str_replace_all('\\n', '') %>% stringr::str_replace_all('\t', '') %>% 
    # replace slide blocks with no info with just the empty self
    stringr::str_replace_all('"slides": \\{\\s*\\}', '"slides": []') %>% 
    # replace numbered slides sections just with the { objects
    stringr::str_replace_all('"slides\\d":', '') %>% 
    # replace opening slide block { with [
    stringr::str_replace_all('"slides": \\{', '"slides": [') %>% 
    # replace closing ]}} with ]}]
    stringr::str_replace_all(']\\s*\\}\\s*\\}', ']\\}]') %>% 
    # make it pretty
    jsonlite::prettify()
