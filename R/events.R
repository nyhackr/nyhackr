#' Manage the current data in Google Sheets
#' 
#' Retrieve/write the latest data from/to Google Sheets.
#' 
#' @param gsheet_id the Google Sheet unique ID. Found in the URL. Should be set within .Renviron as "GSHEET_ID={ID}"
#'
#' @return
#'
#' @examples
#' gsheet_id <- Sys.getenv('GSHEET_ID')
#' get_current_events(gsheet_id)
get_current_events <- function(gsheet_id){
  googlesheets4::read_sheet(gsheet_id, sheet = 'Events', col_types = 'ccccc')
}

#' Render the events on the events page
#'
#' @param .data a dataframe of the events. See example.
#'
#' @return html
#'
#' @examples
#' events <- get_current_events(gsheet_id)
#' render_events(events)
render_events <- function(.data){
  .data[is.na(.data)] <- ''
  .data %>% 
    arrange(date) %>% 
    rowwise() %>% 
    group_map(~create_event(.x$date, .x$headerText, .x$optionalText, .x$URL, .x$imageURL)) %>% 
    htmltools::tagList()
}

#' @describeIn render_events Format and display a single event
create_event <- function(date, headerText, optionalText, url, imageURL){
  htmltools::tagList(
    create_event_card(url, imageURL),
    htmltools::h1(headerText),
    htmltools::HTML(optionalText),
    htmltools::br(), htmltools::br(), htmltools::br()
  )
}

#' @describeIn render_events Format and display a single event image card
create_event_card <- function(url, imageURL){
  htmltools::div(
    class = 'event-card',
    htmltools::a(
      href = url,
      htmltools::img(
        src = imageURL
      )
    )
  )
}
