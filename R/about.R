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

# render_sponsors <- function(){
#   crosstalk::bscols(widths=c(6, 6),
#                     list(
#                       htmltools::a(href="https://www.r-consortium.org/",
#                                    htmltools::img(src="img/sponsors/RConsortium-logo.png",
#                                                   style="width: 75%;")
#                       ),
#                       htmltools::tags$p(class='spacer'),
#                       htmltools::a(href="https://www.eventbrite.com/e/learn-bayes-mcmc-and-stan-2017-with-andrew-gelman-jonah-gabry-michael-betancourt-tickets-36284546054?discount=nyhackr",
#                                    htmltools::img(
#                                      src="img/sponsors/stanlogo-2.png",
#                                      style="width: 55%;")
#                       ),
#                       htmltools::tags$p(class='spacer'),
#                       htmltools::a(href="http://www.ebaynyc.com/",
#                                    htmltools::img(src="img/sponsors/ebaynyc-web.png",
#                                                   style="width: 75%;")
#                       ),
#                       htmltools::tags$p(class='spacer'),
#                       htmltools::a(href="https://www.oreilly.com/",
#                                    htmltools::img(src="img/sponsors/oreilly-logo.png")
#                       )
#                     ),
#                     list(
#                       htmltools::a(href="http://www.oreilly.com/pub/cpc/79528",
#                                    htmltools::img(src="img/sponsors/JupyterCon.png")
#                       ),
#                       htmltools::tags$p(class='spacer'),
#                       htmltools::a(href="https://mran.microsoft.com/open/",
#                                    htmltools::img(src="img/sponsors/microsoft-logo.png")
#                       ),
#                       htmltools::tags$p(class='spacer'),
#                       htmltools::a(href="https://www.datacamp.com/home",
#                                    htmltools::img(src="img/sponsors/DataCampHorizontalFull.png")
#                       ),
#                       htmltools::tags$p(class='spacer'),
#                       htmltools::a(href="http://slicelife.com/",
#                                    htmltools::img(
#                                      src="img/sponsors/slice-logo-primary-web-large.png",
#                                      style="width: 60%;")
#                       ),
#                       htmltools::tags$p(class='spacer'),
#                       htmltools::a(href="https://www.ecohealthalliance.org/",
#                                    htmltools::img(
#                                      src="img/sponsors/EcohealthAlliance-logo.png",
#                                      style="width: 60%;")
#                       )
#                     )
#   )
# }