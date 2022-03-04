
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

# .data <- talks
render_archive <- function(.data){
  
  # munge data for datatable
  .data <- dt_format_data(.data)

  # render table
  DT::datatable(
    .data,
      filter = 'top',
      rownames = FALSE,
      escape = c(3),
      options = list(
        columnDefs = list(
          list(targets = 0, orderable = FALSE, searchable = FALSE, 
               width = "15px", className = 'details-control'), # allows child rows
          list(targets = 1:3, className = 'dt-left'),
          list(targets = 4:5, searchable = TRUE, visible = FALSE) # allows searching by topics but not show the column
        ),
        autoWidth = TRUE,
        pageLength = 10,
        scrollX = TRUE
      ),
      callback = dt_callback_child_row() # enable child rows
    )
}

dt_format_data <- function(.data){
  # filter, cleanup, and munge data to right shape for datatable

  # arrange data and clean up links
  .data <- .data %>% 
    arrange(desc(date)) %>% 
    rowwise() %>%
    mutate(MeetUp = as.character(htmltools::a(meetupTitle, href = meetupURL)),
           PresentationDescription = format_presentation(
             speaker = speaker, 
             videoURL = videoURL,
             slidesURL = slidesURL,
             slidesTitle = slidesTitle
             )) %>%
    ungroup()
  
  # collapse MeetUps with mulitple presentations into one row
  .data <- .data %>% 
    group_by(ID) %>% 
    summarize(Date = date, Venue = venue, MeetUp = MeetUp, 
              Topic = paste0(topics, collapse = "; "),
              childRow = format_child_row(first(descriptionHTML), PresentationDescription),
              .groups = 'drop') %>% 
    arrange(desc(Date)) %>% 
    select(-ID)
  
  # add blank column with icon to expand rows
  .data <- dplyr::as_tibble(cbind(' ' = '&plus;', .data))
  
  # replace NAs
  .data[is.na(.data)] <- '-'
  
  return(.data)
}

parse_video_name <- function(url){
  if (is.na(url)){
    return('Not available')
  }
  url_domain <- urltools::domain(url)
  return(as.character(htmltools::a(url_domain, href = url)))
}

parse_slides_name <- function(url, title){
  if (is.na(url)) return("Not available")
  as.character(htmltools::a(title, href = url))
}

parse_speaker_name <- function(name){
  if(is.na(name)) return('Not available')
  return(stringr::str_to_title(name))
}

format_presentation <- function(speaker, videoURL, slidesURL, slidesTitle){
  glue::glue(
    "<b>Presentation</b>: {parse_slides_name(slidesURL, slidesTitle)} <br>",
    "<b>Speaker</b>: {parse_speaker_name(speaker)} <br>",
    "<b>Video</b>: {parse_video_name(videoURL)}",
  )
}

format_child_row <- function(descriptionHTML, presentations){
  paste0(
    descriptionHTML, 
    "<br>",
    paste0(presentations, collapse = "<br><br>")
  )
}

dt_callback_child_row <- function(){
  DT::JS(
    "
        table.column(0).nodes().to$().css({cursor: 'pointer'});
        var format = function(d) {
          return '<div style=\"background-color:#eee; padding: .5em;\"> ' + d[5] + '</div>';
        };
        table.on('click', 'td.details-control', function() {
          var td = $(this), row = table.row(td.closest('tr'));
          if (row.child.isShown()) {
            row.child.hide();
            td.html('&plus;');
          } else {
            row.child(format(row.data())).show();
            td.html('&#8315;');
          }
        });
        "
  )
}
