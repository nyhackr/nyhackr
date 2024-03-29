#' Render the next talk on home page
#'
#' Format and render the next talk on the homepage. If there is no upcoming talk, then display placeholder image and boilerplate text.
#'
#' @param talk a dataframe of the next talk. See example.
#'
#' @return html
#'
#' @examples
#' talk_next <- get_current_talks(gsheet_id) %>% 
#'   filter(date >= Sys.Date()) %>% 
#'   arrange(date) %>% 
#'   slice_head(n = 1)
#' render_next_talk(talk_next)
render_next_talk <- function(talk){
  if (nrow(talk) == 0) {
    htmltools::div(
      htmltools::div(
        class = 'blur',
        create_card("https://www.meetup.com/nyhackr/", 
                    "https://nyhackr.blob.core.windows.net/headers/November_Meetup-JD_Long.png", 
                    homepage = TRUE)
      ),
      htmltools::h3("Next talk coming soon"),
      htmltools::p("There is not a meetup currently scheduled. Please check back soon. Be sure to check out our ",
                   htmltools::a(href = '/past-talks.html', 'Past talks page.'))
    )
  } else {
    date_formated <- format(talk$date, '%B %e')
    htmltools::div(
      if (is_truthy(talk$ticketsHTML)){
        add_ticket_div('#tickets')
      } else {
        add_ticket_div(talk$meetupURL)
      },
      create_card(talk$meetupURL, talk$cardURL, homepage = TRUE),
      htmltools::h3(htmltools::strong(glue::glue("{date_formated}: {talk$meetupTitle}"))),
      htmltools::HTML(talk$descriptionHTML),
      if (!is.na(talk$ticketsHTML)){
        htmltools::div(
          id = 'tickets',
          htmltools::HTML(talk$ticketsHTML)
        )
      } else {''}
    )
  }
}

add_ticket_div <- function(url = '#tickets'){
  htmltools::tagList(
    htmltools::a(
      href = url,
      htmltools::div(
        id = 'tickets-tag',
        'RSVP'
      )
    ),
    htmltools::a(
      href = url,
      htmltools::div(
        id = 'tickets-tag-mobile',
        'Click here to RSVP'
      )
    )
  )
}
