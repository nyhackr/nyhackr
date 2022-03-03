
get_current_events <- function(gsheet_id){
  googlesheets4::read_sheet(gsheet_id, sheet = 'Events', col_types = 'ccccc')
}

render_events <- function(.data){
  .data[is.na(.data)] <- ''
  .data %>% 
    arrange(date) %>% 
    rowwise() %>% 
    group_map(~create_event(.x$date, .x$headerText, .x$optionalText, .x$URL, .x$imageURL)) %>% 
    htmltools::tagList()
}

create_event <- function(date, headerText, optionalText, url, imageURL){
  htmltools::tagList(
    htmltools::h1(headerText),
    htmltools::p(optionalText),
    create_event_card(url, imageURL),
    htmltools::br(), htmltools::br()
  )
}

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
