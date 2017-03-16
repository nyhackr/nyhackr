#' 
makeInfoDF <- function(info)
{
    # make fee either be 0 or the amount
    info$fee <- purrr::map_dbl(info$fee, ~ max(.x, 0))
    # fix the type of a bunch of columns
    info$id <- as.character(info$id)
    info$name <- as.character(info$name)
    info$rsvp_limit <- as.character(info$rsvp_limit)
    info$status <- as.character(info$status)
    info$Date <- as.Date(as.POSIXct(as.numeric(info$time)/1000, origin='1970-01-01 00:00:00'))
    info$waitlist_count <- as.character(info$waitlist_count)
    info$yes_rsvp_count <- as.character(info$yes_rsvp_count)
    info$link <- as.character(info$link)
    info$description <- as.character(info$description)
    # convert venue info to columns of the data.frame
    info$VenueID <- as.character(info$venue$id)
    info$Venue <- as.character(info$venue$name)
    info$VenueLat <- as.numeric(info$venue$lat)
    info$VenueLon <- as.numeric(info$venue$lon)
    info$VenueAddress_1 <- as.character(info$venue$address_1)
    info$VenueAddress_2 <- as.character(info$venue$address_2)
    info$VenueCity <- as.character(info$venue$city)
    info$VenueCountry <- as.character(info$venue$country)
    info$VenueCountryCode <- as.character(info$venue$countrycode)
    info$VenueZip <- as.character(info$venue$zip)
    info$VenueState <- as.character(info$venue$state)
    
    # get ride of the venue DF
    info$venue <- NULL
    
    return(info)
}

narrowDownInfo <- function(info)
{
    # info$fee <- NULL
    # info$id <- NULL
    info$rsvp_limit <- NULL
    info$time <- NULL
    info$waitlist_count <- NULL
    
    return(info)
}

renameInfo <- function(info)
{
    info %>% 
        dplyr::select(Title=name,
                      Date,
                      Fee=fee,
                      Status=status,
                      Attendence=yes_rsvp_count,
                      URL=link,
                      Description=description,
                      ID=id,
                      Venue,
                      Latitude=VenueLat, Longitude=VenueLon,
                      Address1=VenueAddress_1, Address2=VenueAddress_2,
                      City=VenueCity,
                      Slides=slides)
}

# library(magrittr)
# events <- jsonlite::fromJSON('data/events.json')
# events <- events %>% makeInfoDF %>% narrowDownInfo #%>% renameInfo
# dataForDisplay <- function(x)
# {
#     
# }

# info <- makeInfoDF(meetupData)
# head(info)
