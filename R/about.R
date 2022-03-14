#' @describeIn get_current_events Get the current sponsors from the Google Sheet
get_current_sponsors <- function(gsheet_id){
  googlesheets4::read_sheet(gsheet_id, sheet = 'Sponsors', col_types = 'cccc')
}

#' Render the grid of sponsors
#'
#' Grid forms a mosaic to best fit the image sizes. Images are arranged based on the Google Sheet order column. Formatted with css/sponsors.css.
#'
#' @param .data a dataframe of the books. See example.
#'
#' @return html
#'
#' @examples
#' sponsors <- get_current_sponsors(gsheet_id)
#' render_sponsors(sponsors)
render_sponsors <- function(.data){
  .data <- dplyr::arrange(.data, order)
  sponsors_output <- purrr::pmap(list(.data$URL, .data$imageURL), display_sponsor)
  htmltools::div(
    id = 'sponsor-container',
    sponsors_output
  )
}

#' @describeIn render_sponsors Display a single sponsor image with link
display_sponsor <- function(url, image){
  htmltools::a(
    href = url,
    htmltools::img(
      src = image
    )
  )
}
