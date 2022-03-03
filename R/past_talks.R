# controls the past talks archive

render_archive <- function(.data){
  .data %>% 
    select(Date = date, Meetup = meetupTitle, Description = descriptionHTML) %>% 
    DT::datatable(
      rownames = FALSE,
      options = list(
        pageLength = 20,
        scrollX = TRUE
      ))
}
