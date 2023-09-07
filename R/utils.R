
`%notin%` <- Negate(`%in%`)

is_truthy <- function(x){
  
  if (inherits(x, 'data.frame') && nrow(x) == 0)
    return(FALSE)
  
  # shiny::isTruthy
  if (inherits(x, "try-error")) 
    return(FALSE)
  if (!is.atomic(x)) 
    return(TRUE)
  if (is.null(x)) 
    return(FALSE)
  if (length(x) == 0) 
    return(FALSE)
  if (all(is.na(x))) 
    return(FALSE)
  if (is.character(x) && !any(nzchar(stats::na.omit(x)))) 
    return(FALSE)
  if (inherits(x, "shinyActionButtonValue") && x == 0) 
    return(FALSE)
  if (is.logical(x) && !any(stats::na.omit(x))) 
    return(FALSE)
  return(TRUE)
}

#' Create a formatted image card
#'
#' Wrap an image in a div with class 'meetup-card'. Styled with css/nyhackr.css.
#'
#' @param link 
#' @param imgURL 
#' @param homepage 
#'
#' @return html
#'
#' @examples
#' create_card('https://www.meetup.com/nyhackr/events/284488336/?utm_source=nyhackr',
#'             'https://nyhackr.blob.core.windows.net/headers/March_Meetup-Bill_Gold.png')
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
      href = link,
      htmltools::tags$img(
        src = imgURL,
      )
    )
  )
}


# data --------------------------------------------------------------

#' Get MeetUp information from the MeetUp API
#'
#' Make an API request to MeetUp and return the data
#'
#' @param format format the number with commas?
#'
#' @return list or dataframe
#'
#' @examples
#' get_n_members()
#' get_next_talk()
#' get_past_talks()
get_n_members <- function(format = TRUE){
  r <- httr::GET(
    'https://api.meetup.com/nyhackr'
  )
  n_members <- httr::content(r)$members
  
  if (format) {
    if (is.numeric(n_members)) {
      n_members <- glue::glue("{scales::comma_format()(n_members)} ")
    } else {
      n_members <- ''
    }
  }
  
  return(n_members)
}

convert_markdown_html <- function(talks) {
  stopifnot(is.list(talks))
  # gets rid of bad html and leaves good html
  talks$description <- talks$description |>
    stringr::str_trim() |>
    rvest::read_html() |>
    rvest::html_text2() |>
    markdown::mark() |>
    rvest::read_html() |> 
    rvest::html_elements("p")
  
  reg <- which(grepl("External registration</a></strong> required at <strong>", talks$description))
  talks$description[reg] <- '<p><strong>RSVP BELOW!</strong></p>'
  talks$description <- talks$description |> 
    paste0(collapse = "") |>
    stringr::str_remove_all("\\n")
  return(talks)
}

#' @describeIn get_n_members Get the next talk scheduled
get_next_talk <- function(flatten = TRUE){
  r <- httr::GET(
    'https://api.meetup.com/nyhackr/events',
    query = list(
      status = 'upcoming',
      desc = 'false',
      page = '1'
    )
  )
  talks <- httr::content(r)
  
  talks <- purrr::map(talks, convert_markdown_html) # expects a list
  
  if (flatten) talks <- purrr::map_dfr(talks, flatten_talk_jsons)
  
  return(talks)
}

#' @describeIn get_n_members Get the past talks
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
  
  talks <- purrr::map(talks, convert_markdown_html) # expects a list
  
  if (flatten) talks <- purrr::map_dfr(talks, flatten_talk_jsons)
  
  return(talks)
}

#' Flatten the API data into a dataframe
#' 
#' Extract and flatten the pulled API data into a dataframe
#' 
#' @param .data json data structured as a nested list
#'
#' @return
#'
#' @examples
#' resp <- httr::GET(
#'   'https://api.meetup.com/nyhackr/events',
#'   query = list(
#'     status = 'past',
#'     desc = 'true',
#'     page = 10
#'  )
#' talks <- httr::content(resp)
#' purrr::map_dfr(talks, flatten_talk_jsons)
flatten_talk_jsons <- function(.data){

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
  
  # make sure nulls are NAs so the column is included in the talk tibble
  if (identical(talk_venue_id, character(0)) | is.null(talk_venue_id)) talk_venue_id <- NA
  if (identical(talk_venue, character(0)) | is.null(talk_venue)) talk_venue <- NA
  if (identical(talk_venue_address, character(0)) | is.null(talk_venue_address)) talk_venue_address <- NA
  
  talk_description_html <- stringr::str_trim(.data$description)
  talk_rsvp_count <- .data$yes_rsvp_count
  talk_date <- {as.numeric(.data$time)/1000} |> 
    as.POSIXct(tz = 'America/New_York',
               origin = '1970-01-01 00:00:00') |> 
    lubridate::as_date()
  
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
    cardURL = NA,
    ticketsHTML = NA
  )
  talk[talk == ''] <- NA
  
  if (nrow(talk) == 0) cli::cli_alert_warning('Cleaned json contains no rows')
  
  return(talk)
}

#' @describeIn get_current_events Write out the current talks to the Google Sheet
write_current_talks <- function(.data, gsheet_id){
  googlesheets4::write_sheet(.data, ss = gsheet_id, sheet = 'Talks')
}

#' @describeIn get_current_events Get the current talks from the Google Sheet
get_current_talks <- function(gsheet_id){
  talks <- googlesheets4::read_sheet(gsheet_id, sheet = 'Talks', col_types = 'c')
  talks <- parse_current_talks(talks)
  return(talks)
}

#' @describeIn get_current_events Formats the talks data after being retrieved from the Google Sheet
parse_current_talks <- function(.data){
  .data[.data == 'NA'] <- NA
  .data[.data == ''] <- NA
  .data$date <- as.Date(.data$date)
  .data$rsvpCount <- as.integer(.data$rsvpCount)
  
  return(.data)
}
