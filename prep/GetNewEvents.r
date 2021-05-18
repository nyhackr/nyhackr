library(meetupr)
library(dplyr)
library(jsonlite)
library(purrr)
library(tidyr)
library(stringr)


old_events <- fromJSON(here::here("data/events.json"), simplifyDataFrame= FALSE)
old_ids <- old_events %>%
    map_chr("id")

urlname <- "nyhackr"
past_events <- get_events(urlname, "past")

new_events <- past_events %>%
    filter(!id %in% old_ids) %>%
    hoist(
        resource,
        "rsvp_limit"
    ) %>%
    nest(venue = starts_with("venue")) %>%
    select(
        id,
        name,
        status,
        time,
        link,
        description,
        waitlist_count,
        yes_rsvp_count,
        rsvp_limit,
        venue
    ) %>%
    mutate(
        time = time * 1000,
        speakers = list(list()),
        topics = list(list()),
        slides = list(list()),
        venue = map(venue, function(x) {
            x %>%
                rename_all(str_remove, pattern = "^venue_") %>%
                mutate(across(everything(), ~ replace_na(.x, ""))) %>%
                as.list()
        })
    ) %>%
    transpose()

ignored_events <- c("273172949")

new_events <- discard(new_events, ~ .x$id %in% ignored_events)

updated <- c(old_events, new_events)
updated %>%
    toJSON() %>%
    prettify() %>%
    writeLines(here::here("data/events.json"), useBytes=TRUE)

