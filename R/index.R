
format_next_talk <- function(talk, photo_url){
  if (!length(talk)) {
    htmltools::div(
      htmltools::div(
        class = 'blur',
        create_card("https://www.meetup.com/nyhackr/", 
                    "https://secure.meetupstatic.com/photos/event/3/3/5/9/highres_501613145.jpeg", 
                    homepage = TRUE)
      ),
      htmltools::h2("Next talk coming soon"),
      htmltools::p("There is not a meetup currently scheduled. Please check back soon. Be sure to check out our Past talks page and YouTube channel.")
    )
  } else {
    meetupDescription <- talk[[1]]$description
    meetupTime <- format(
      as.POSIXct(as.numeric(talk[[1]]$time) / 1000, 
                 origin = '1970-01-01 00:00:00', 
                 tz = 'America/New_York'),
      '%B %e, %Y %r'
    )
    meetupName <- talk[[1]]$name
    htmltools::div(
      htmltools::h2(meetupName),
      htmltools::h3(meetupTime),
      htmltools::HTML(meetupDescription)
    )
  }
}
