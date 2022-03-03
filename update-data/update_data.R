source('R/gs_auth.R')
source('R/talks.R')


# initialize data ----------------------------------------------------------

# get all historical talks 
# talks <- get_past_talks(n = 1000, flatten = TRUE)

# write to googledrive
# write_current_talks(talks, gsheet_id)


# update data -------------------------------------------------------------

# get latest talks
talks_new <- get_past_talks(n = 3)
talks_current <- get_current_talks(gsheet_id)

# combine new with current
talks <- dplyr::distinct(dplyr::bind_rows(talks_current, talks_new))

# write to googledrive
# write_current_talks(talks, gsheet_id)

