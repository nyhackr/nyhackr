get_current_sponsors <- function(gsheet_id){
  googlesheets4::read_sheet(gsheet_id, sheet = 'Sponsors', col_types = 'cccc')
}

display_sponsor <- function(url, image){
  htmltools::a(
    href = url,
    htmltools::img(
      src = image
    )
  )
}

render_sponsors <- function(.data){
  .data <- dplyr::arrange(.data, order)
  sponsors_output <- purrr::pmap(list(.data$URL, .data$imageURL), display_sponsor)
  htmltools::div(
    id = 'sponsor-container',
    sponsors_output
  )
}
