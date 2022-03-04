source('R/gs_auth.R')
source('R/talks.R')


# initialize data ----------------------------------------------------------

# # get all historical talks froom meetup.com
# talks <- get_past_talks(n = 1000, flatten = TRUE)
# 
# # get old file that includes topics and speakers
# talks_old <- jsonlite::read_json('https://raw.githubusercontent.com/nyhackr/nyhackr/master/data/events.json')
# 
# # scratch work to figure out issues
# # which(purrr::map_lgl(talks_old, function(event){
# #   event$id == 11138871 #40727692 #12848628
# # }))
# # 
# # meetup <- talks_old[[6]]
# # 
# # # drop talk 83, 84, 85 b/c structure problems
# # talks_old <- talks_old[-c(83, 84, 85)]
# # 
# # meetup <- talks_old[[105]]
# 
# # flatten the json into a rectangular df with each row representing a
# # presentation. E..g if a single meetup has two presentations then there will be two rows
# # for that meetup
# talks_old_rectangle <- purrr::map_dfr(talks_old, function(meetup){
#   
#   # create a row containing the meetup-wide details
#   meetup_details <- tibble(
#     ID = meetup$id[[1]],
#     meetupURL = meetup$link[[1]],
#     date = as.Date(as.POSIXct(as.numeric(meetup$time)/1000, origin='1970-01-01 00:00:00')),
#     venueID = as.character(meetup$venue$id[[1]]),
#     venue = meetup$venue$name[[1]],
#     venueAddress = paste(
#       meetup$venue$address_1,
#       meetup$venue$address_2,
#       meetup$venue$city,
#       meetup$venue$state,
#       meetup$venue$zip,
#       meetup$venue$localized_country_name,
#       sep = ' '
#     ) %>% stringr::str_squish(),
#     rsvpCount = meetup$yes_rsvp_count[[1]],
#     meetupTitle = meetup$name[[1]],
#     descriptionHTML = stringr::str_trim(meetup$description),
#     videoURL = tryCatch(meetup$video[[1]], error = function(e) NA),
#     cardURL = NA
#   )
#   # presentation <- meetup$slides[[1]]
#   
#   # add a row with each presentation/speaker details
#   if (!identical(meetup$slides, list())){
#     meetup_details <- purrr::map_dfr(meetup$slides, function(presentation) {
#         bind_cols(
#           meetup_details,
#           topics = trimws(paste0(presentation$topics, collapse = "; ")),
#           slidesTitle = presentation$title[[1]],
#           slidesURL = presentation$file[[1]],
#           speaker = trimws(paste0(presentation$presenter, collapse = "; "))
#         )
#       })
#   }
#     
#     return(meetup_details)
# })
# 
# talks_current <- get_current_talks(gsheet_id)
# talks_old_rectangle <- talks_old_rectangle[, colnames(talks_current)]

# write to googledrive
# write_current_talks(talks, gsheet_id)
# readr::write_delim(talks_old_rectangle, "~/Desktop/talks_old.txt", delim = ";|")


# update data -------------------------------------------------------------

# get latest talks
talks_new <- get_past_talks(n = 3)
talks_current <- get_current_talks(gsheet_id)

# combine new with current
talks <- dplyr::distinct(dplyr::bind_rows(talks_current, talks_new))

# write to googledrive
# write_current_talks(talks, gsheet_id)

