library(httr)
# get al linfo from the meetup api
r <- GET('https://api.meetup.com/nyhackr/events', 
         query=list(
             key=Sys.getenv('MEETUP_KEY'), 
             status='past,upcoming', 
             desc='false', 
             page='90'))

x <- jsonlite::toJSON(content(r))
writeLines(jsonlite::prettify(x), 'data/events_raw.json', useBytes=TRUE)

# keep just some stuff for the site
meetupInfo <- jsonlite::fromJSON('data/events_raw.json', simplifyDataFrame=FALSE)
# meetupInfo[[1]]

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
    # info$group$created <- NULL
    # info$group$join_mode <- NULL
    info$group$lat <- NULL
    info$group$lon <- NULL
    info$visibility <- NULL
    info$group <- NULL
    info$manual_attendance_count <- NULL
    info$how_to_find_us <- NULL
    
    return(info)
}

meetupInfo <- purrr::map(meetupInfo, trimInfo)
# meetupInfo[[34]] <- NULL
writeLines(jsonlite::prettify(jsonlite::toJSON(meetupInfo)), 'data/events.json', useBytes=TRUE)
