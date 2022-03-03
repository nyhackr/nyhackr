
render_recent_talks <- function(.data, n = 4){
  .data %>% 
    arrange(desc(date)) %>% 
    slice_head(n = n) %>% 
    rowwise() %>% 
    group_map(~create_card(.x$meetupURL, .x$cardURL)) %>% 
    htmltools::tagList() %>% 
    htmltools::div(
      id = 'meetup-card-container',
      .
    )
} 

render_archive <- function(.data){
  .data %>% 
    arrange(desc(date)) %>% 
    rowwise() %>%
    mutate(MeetUp = as.character(htmltools::a(meetupTitle, href = meetupURL)),
           Video = as.character(htmltools::a(parse_video_domain(videoURL), href = videoURL))) %>%
    ungroup() %>%
    select(Date = date, Venue = venue, MeetUp, Speaker = speaker, 
           Topics = topics, Video) %>% 
    DT::datatable(
      filter = 'top',
      rownames = FALSE,
      escape = c(2, 5),
      options = list(
        columnDefs = list(list(targets = 4, searchable = TRUE, visible = FALSE)), # allows searching by topics but not show the column
        pageLength = 10,
        scrollX = TRUE
      )
    )
}

parse_video_domain <- function(url){
  if (is.na(url)) return('')
  urltools::domain(url)
}
