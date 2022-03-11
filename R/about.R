get_current_sponsors <- function(gsheet_id){
  googlesheets4::read_sheet(gsheet_id, sheet = 'Sponsors', col_types = 'cccc')
}

display_sponsor <- function(url, image){
  htmltools::div(
    class = 'sponsor-container',
    class = "col-xs-12 col-sm-6 col-md-4 col-lg-3",
    htmltools::p(
      htmltools::a(
        href = url,
        target = "_blank",
        htmltools::img(
          src = image
        )
      )
    )
  )
}

render_sponsors <- function(.data){
  .data <- dplyr::arrange(.data, order)
  sponsors_output <- purrr::pmap(list(.data$URL, .data$imageURL), display_sponsor)
  htmltools::div(
    class = 'sponsor-flexArea',
    sponsors_output
  )
}
