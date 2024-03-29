#' Render the grid of recent talks on the past talks page
#'
#' @param .data a dataframe of recent talks. See example.
#' @param n the number of talks to show
#'
#' @return html
#'
#' @examples
#' talks <- get_current_talks(gsheet_id)
#' talks_past <- filter(talks, date < Sys.Date())
#' render_recent_talks(talks_past, n = 4)
render_recent_talks <- function(.data, n = 4){
  .data %>% 
    arrange(desc(date)) %>% 
    slice_head(n = n) %>% 
    rowwise() %>% 
    group_map(~create_card(.x$videoURL, .x$cardURL)) %>% 
    htmltools::tagList() %>% 
    htmltools::div(
      id = 'meetup-card-container',
      .
    )
} 

#' Render the datatable archive of past talks
#'
#' Renders the DT::datatable archive of all the past talks.
#'
#' @param .data 
#'
#' @return html
#'
#' @examples
#' talks <- get_current_talks(gsheet_id)
#' talks_past <- filter(talks, date < Sys.Date())
#' render_archive(talks_past)
render_archive <- function(.data){
  
  # munge data for datatable
  .data <- dt_format_data(.data)

  # render table
  DT::datatable(
    .data,
      filter = 'top',
      rownames = FALSE,
      escape = c(2, 4),
      options = list(
        columnDefs = list(
          list(targets = 0, orderable = FALSE, searchable = FALSE, 
               width = "15px", className = 'details-control'), # allows child rows
          list(targets = 1:4, className = 'dt-left'),
          list(targets = 4, orderable = FALSE, searchable = FALSE, width = "15px"),
          list(targets = 5:7, searchable = TRUE, visible = FALSE) # allows searching by topics and childrow content but not show the column
        ),
        autoWidth = TRUE,
        pageLength = 10,
        scrollX = TRUE
      ),
    callback = dt_callback_child_row() # enable child rows
  )
}

#' @describeIn render_archive Munge the talks data to get the format ready for DT::datatable
dt_format_data <- function(.data){

  # arrange data and clean up links
  data_cleaned <- .data %>% 
    arrange(desc(date)) %>% 
    rowwise() %>%
    mutate(Talk = meetupTitle,
           Video = parse_video_name(videoURL),
           PresentationDescription = format_presentation(
             speaker = speaker, 
             slidesURL = slidesURL,
             slidesTitle = slidesTitle,
             videoURL = videoURL,
             meetupURL = meetupURL
           )) %>%
    ungroup()
  
  # collapse MeetUps with multiple presentations into one row
  data_summarized <- data_cleaned %>% 
    group_by(ID) %>% 
    summarize(Date = dplyr::first(date), 
              Talk = dplyr::first(Talk),
              Speaker = paste0(unique(speaker), collapse = ", "),
              Video = dplyr::first(Video),
              Topic = paste0(topics, collapse = "; "),
              Venue = dplyr::first(venue), 
              childRow = format_child_row(first(descriptionHTML), PresentationDescription),
              .groups = 'drop') %>% 
    arrange(desc(Date)) %>% 
    select(-ID)
  
  # add blank column with icon to expand rows
  row_icon <- '<span class="fa fa-plus" style="color: #6898f7;"></span>'
  data_summarized <- dplyr::as_tibble(cbind('Detail' = row_icon, data_summarized))
  
  # replace NAs
  data_summarized[is.na(data_summarized)] <- '-'
  
  if (n_distinct(.data$ID) != nrow(data_summarized)) cli::cli_abort('Duplicate MeetUps detected')
  
  return(data_summarized)
}

#' @describeIn render_archive Format the video column in the archive
parse_video_name <- function(url, use_icon = TRUE){
  if (is.na(url)){
    return('-')
  }
  # url_domain <- urltools::domain(url)
  # video_html <- as.character(htmltools::a(url_domain, href = url, target = "_blank"))
  if (isTRUE(use_icon)){
    url_html <- glue::glue('<a href="{url}" target="_blank" style="font-size: 3rem;"><span class="fa fa-youtube"></span></a>')
  } else {
    url_html <- as.character(htmltools::a('Video', href = url, target = "_blank"))
  }
  
  return(url_html)
}

#' @describeIn render_archive Format the presentation paragraph in the archive
format_presentation <- function(speaker, slidesURL, slidesTitle, videoURL, meetupURL){
  glue::glue(
    "<b>Speaker</b>: {parse_speaker_name(speaker)} <br>",
    "<b>Slides</b>: {parse_slides_name(slidesURL, slidesTitle)} <br>",
    "<b>Video link</b>: {parse_video_name(videoURL, use_icon = FALSE)} <br>",
    "<b>MeetUp link</b>: {parse_meetup_name(meetupURL)} <br>"
  )
}

#' @describeIn render_archive Format the slides link in the archive
parse_slides_name <- function(url, title){
  if (is.na(url)) return("Not available")
  as.character(htmltools::a(title, href = url, target = "_blank"))
}

#' @describeIn render_archive Format the speaker name in the archive
parse_speaker_name <- function(name){
  if(is.na(name)) return('Not available')
  return(name)
}

#' @describeIn render_archive Format the MeetUp url link in the archive
parse_meetup_name <- function(url){
  if (is.na(url)) return("Not available")
  as.character(htmltools::a('MeetUp', href = url, target = "_blank"))
}

#' @describeIn render_archive Format the entire child row in the archive
format_child_row <- function(descriptionHTML, presentations){
  paste0(
    paste0(presentations, collapse = "<br>"),
    "<hr style='background: #a3a3a3; height: 1px;'>",
    descriptionHTML
  )
}

#' @describeIn render_archive Create the JavaScript callback function that creates the child row in the archive
dt_callback_child_row <- function(){
  DT::JS(
    "
        $('td').css({cursor: 'pointer'});
        var format = function(d) {
          return '<div style=\"border: gray 2px dashed; background: #fff; padding: .5em;\"> ' + d[7] + '</div>';
        };
        table.on('click', 'td', function() {
          var td = $(this), row = table.row(td.closest('tr'));
          if (row.child.isShown()) {
            row.child.hide();
            //td.html('<span class=\"fa fa-plus\" style=\"color: #6898f7;\"></span>');
          } else {
            row.child(format(row.data())).show();
            //td.html('<span class=\"fa fa-minus\" style=\"color: #6898f7\"></span>');
          }
        });
        "
  )
}
