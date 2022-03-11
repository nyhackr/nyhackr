
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
          src = image
        )
      )
    )
  )
}

render_books <- function(.data){
  .data <- dplyr::slice_sample(.data, n = nrow(.data), replace = FALSE)
  bookOutput <- purrr::pmap(list(.data$title, .data$authors, .data$URL, .data$imageURL), displayBook)
  htmltools::div(
    class = 'book-flexArea',
    bookOutput
  )
}
