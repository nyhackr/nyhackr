
`%notin%` <- Negate(`%in%`)

# wrap an image in a div with class 'meetup-card'
create_card <- function(link, imgURL, homepage = FALSE){
  
  class <- "meetup-card"
  if (homepage){
    class <- glue::glue("{class} home-card")
  } else {
    class <- glue::glue("{class} col-xs-12 col-sm-6 col-md-4")
  }
  
  htmltools::tags$div(
    class = class,
    htmltools::tags$a(
      href = link, #"https://www.meetup.com/nyhackr/",
      htmltools::tags$img(
        src = imgURL,
      )
    )
  )
}


# data --------------------------------------------------------------

get_next_talk <- function(){
  r <- httr::GET(
    'https://api.meetup.com/nyhackr/events',
    query = list(
      status = 'upcoming',
      desc = 'false',
      page = '1'
    )
  )
  x <- httr::content(r)
  return(x)
}

get_past_talks <- function(n = 1000, flatten = TRUE){
  resp <- httr::GET(
    'https://api.meetup.com/nyhackr/events',
    query = list(
      status = 'past',
      desc = 'true',
      page = n
    )
  )
  talks <- httr::content(resp)
  
  if (flatten) talks <- purrr::map_dfr(talks, flatten_talk_jsons)
  
  return(talks)
}

flatten_talk_jsons <- function(.data){
  # extract and flatten the pulled api data into a dataframe
  # TOOD: implement for multiple speakers per event or is that just handled within google drive manual edit?
  
  talk_id <- .data$id
  talk_meetupURL <- .data$link
  talk_meetupTitle <- .data$name
  
  talk_venue_id <- as.character(.data$venue$id)
  talk_venue <- .data$venue$name
  talk_venue_address <- paste(
    .data$venue$address_1,
    .data$venue$address_2,
    .data$venue$city,
    .data$venue$state,
    .data$venue$zip,
    .data$venue$localized_country_name,
    sep = ' '
  )
  talk_venue_address <- stringr::str_squish(talk_venue_address)
  
  talk_description_html <- stringr::str_trim(.data$description)
  talk_rsvp_count <- .data$yes_rsvp_count
  talk_date <- as.Date(as.POSIXct(as.numeric(.data$time)/1000, origin='1970-01-01 00:00:00'))
  
  
  # combine into one tidy dataframe
  talk <- dplyr::tibble(
    ID = talk_id,
    meetupURL = talk_meetupURL,
    date = talk_date,
    venueID = talk_venue_id,
    venue = talk_venue,
    venueAddress = talk_venue_address,
    rsvpCount = talk_rsvp_count,
    meetupTitle = talk_meetupTitle,
    descriptionHTML = talk_description_html,
    topics = NA,
    videoURL = NA,
    slidesTitle = NA,
    slidesURL = NA,
    speaker = NA,
    cardURL = NA
  )
  
  talk[talk == ''] <- NA
  
  return(talk)
}

write_current_talks <- function(.data, gsheet_id){
  googlesheets4::write_sheet(.data, ss = gsheet_id, sheet = 'Talks')
}

get_current_talks <- function(gsheet_id){
  talks <- googlesheets4::read_sheet(gsheet_id, sheet = 'Talks', col_types = 'c')
  talks <- parse_current_talks(talks)
  return(talks)
}

parse_current_talks <- function(.data){
  .data[.data == 'NA'] <- NA
  .data[.data == ''] <- NA
  .data$date <- as.Date(.data$date)
  .data$rsvpCount <- as.integer(.data$rsvpCount)
  
  return(.data)
}

