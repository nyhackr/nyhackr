
render_next_talk <- function(talk, photo_url){
  if (nrow(talk) == 0) {
    htmltools::div(
      htmltools::div(
        class = 'blur',
        create_card("https://www.meetup.com/nyhackr/", 
                    "https://nyhackr.blob.core.windows.net/headers/November_Meetup-JD_Long.png", 
                    homepage = TRUE)
      ),
      htmltools::h3("Next talk coming soon"),
      htmltools::p("There is not a meetup currently scheduled. Please check back soon. Be sure to check out our Past talks page and YouTube channel.")
    )
  } else {
    date_formated <- format(talk$date, '%B %e')
    htmltools::div(
      create_card(talk$meetupURL, talk$cardURL, homepage = TRUE),
      htmltools::h3(htmltools::strong(glue::glue("{date_formated}: {talk$meetupTitle}"))),
      htmltools::HTML(talk$descriptionHTML)
    )
  }
}

