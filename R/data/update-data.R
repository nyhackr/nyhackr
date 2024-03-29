source('R/gs-auth.R')
source('R/past-talks.R')
source('R/utils.R')
library(dplyr)

# exclusion list
# these are IDs of talks that should not show in the archive
# usually due to a meetup.com mistake
talks_to_exclude <- c(
  '292385218'
)

# get latest talks
talks_past <- get_past_talks(n = 3)
talks_upcoming <- get_next_talk() 
talks_to_add <- rbind(talks_past, talks_upcoming) |> filter(ID %notin% talks_to_exclude)
talks_current <- get_current_talks(gsheet_id)

# only add new talks if their ID is not in the current data but also update
# relevant data for old talks in the data
cols_to_keep <- c('descriptionHTML', 'topics', 'videoURL', 'slidesTitle', 'slidesURL', 'speaker', 'cardURL', 'ticketsHTML')
talks_to_add <- left_join(select(talks_to_add, -all_of(cols_to_keep)),
                       select(talks_current, ID, all_of(cols_to_keep)),
                       by = 'ID')

# use descriptionHTML from meetup if its empty in the current data
talks_to_add <- talks_to_add %>% 
  rowwise() %>%
  mutate(descriptionHTML = ifelse(
    is.na(descriptionHTML), 
    talks_upcoming$descriptionHTML[talks_upcoming$ID == ID],
    descriptionHTML)) %>% 
  ungroup()

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

# exclude any talks
talks_new <- talks_new |> filter(ID %notin% talks_to_exclude)

# write to googledrive
write_current_talks(talks_new, gsheet_id)
