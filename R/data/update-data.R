source('R/gs-auth.R')
source('R/past-talks.R')
source('R/utils.R')
library(dplyr)

# get latest talks
talks_past <- get_past_talks(n = 3)
talks_upcoming <- get_next_talk()
talks_to_add <- rbind(talks_past, talks_upcoming)
talks_current <- get_current_talks(gsheet_id)

# only add new talks if their ID is not in the current data but also update
# relevant data for old talks in the data
# TODO: does this work when there is multiple presentations per event?
cols_to_keep <- c('descriptionHTML', 'topics', 'videoURL', 'slidesTitle', 'slidesURL', 'speaker', 'cardURL', 'ticketsHTML')
talks_to_add <- left_join(select(talks_to_add, -all_of(cols_to_keep)),
                       select(talks_current, ID, all_of(cols_to_keep)),
                       by = 'ID')

# make sure MeetUp link has utm_source tag
if (nrow(talks_to_add) > 0){
  has_utm <- stringr::str_detect(talks_to_add$meetupURL, "utm_source=nyhackr$")
  talks_to_add$meetupURL[!has_utm] <- glue::glue("{talks_to_add$meetupURL[!has_utm]}?utm_source=nyhackr")
}

# add new talks and overwrite talks with old data
talks_new <- talks_current %>% 
  filter(ID %notin% talks_to_add$ID) %>% 
  rbind(talks_to_add) %>% 
  distinct() %>% 
  arrange(date)

# write to googledrive
write_current_talks(talks_new, gsheet_id)
