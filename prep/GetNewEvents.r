library(httr)
library(jsonlite)
library(magrittr)
library(purrr)

trimInfo <- function(info)
{
    # drop fields
    info$created <- NULL
    info$duration <- NULL
    info$fee <- info$fee$amount
    info$updated <- NULL
    info$utc_offset <- NULL
    info$venue$repinned <- NULL
    info$venue$countrycode <- info$venue$country
    info$venue$country <- info$venue$localized_country_name
    info$venue$localized_country_name <- NULL
    info$group$lat <- NULL
    info$group$lon <- NULL
    info$visibility <- NULL
    info$group <- NULL
    info$manual_attendance_count <- NULL
    info$how_to_find_us <- NULL
    
    # add placeholders for manually edited fields
    info$speakers <- character()
    info$topics <- character()
    info$slides <- character()
    info$videos <- character()
    info$VideoSource <- character()
    
    return(info)
}

# make request from meetup API
r <- GET('https://api.meetup.com/nyhackr/events', 
         query=list(
             key=Sys.getenv('MEETUP_KEY'), 
             status='past', 
             desc='true', 
             page='10'
         )
)

# parse the JSON response into a list and then trim the data
meetupInfo <- content(r, as = 'parsed') %>% 
    map(trimInfo)

# read in previously stored events in data/events.json as a list
oldEvents <- readLines('data/events.json') %>% 
    fromJSON(simplifyDataFrame=FALSE)

# find all event ids from the Meetup API response not found in the stored events
newIds <- meetupInfo %>% 
    map('id') %>% 
    setdiff(oldEvents %>% map('id')) %>% 
    unlist

# if there exist any new event ids, filter out the new events and append them
# to the events data
if (length(newIds) > 0)
{
    # extract new events by id, create appended data set and save to
    # (temporary) data/events.json.new
    new_events <- meetupInfo %>% 
        keep(function(x) x[['id']] %in% newIds) %>% 
        c(oldEvents, .) %>% 
        toJSON() %>% 
        prettify() %>% 
        writeLines('data/events.json.new', useBytes=TRUE)
    # save old data/events.json to data/events.json.old and move new
    # data/events.json.new to data/events.json
    file.rename('data/events.json', 'data/events.json.old')
    file.rename('data/events.json.new', 'data/events.json')
}
