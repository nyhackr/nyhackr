
get_current_books <- function(gsheet_id){
  googlesheets4::read_sheet(gsheet_id, sheet = 'Books', col_types = 'cccc')
}

displayBook <- function(title, authors, url, image){
  htmltools::div(
    class = 'book-container',
    class = "col-xs-12 col-sm-6 col-md-4 col-lg-3",
    htmltools::div(
      class = 'book-text-container',
      htmltools::div(
        class = 'book-text',
        htmltools::a(class = 'book-title',
                     href = url,
                     title),
        htmltools::p(class = 'book-author',
                     authors)
      )
    ),
    htmltools::p(
      htmltools::a(
        href = url,
        htmltools::img(
          src = sprintf('img/books/%s', image)
        )
      )
    )
  )
}

render_books <- function(.data){
  bookOutput <- sample(purrr::pmap(list(.data$Title, .data$Authors, .data$URL, .data$ImageURL), displayBook))
  htmltools::div(
    class = 'book-flexArea',
    bookOutput
  )
}
