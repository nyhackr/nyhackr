library(crosstalk)
library(magrittr)
library(tidyjson)
library(htmltools)
source('utils/JsonToDataFrame.r')
source('utils/DataTableBuilder.r')
# for functions to build a filter with complex key
source('utils/ComplexFilter.r')
# for building complex keys
source('utils/KeyBuilding.r')

# meetupInfo <- jsonlite::fromJSON('data/events.json') %>% 
#     makeInfoDF() %>% 
#     narrowDownInfo() %>% 
#     renameInfo()

# create shared data
# titleDateShared <- SharedData$new(meetupInfo[, c('Title', 'Date', 'ID')], ~ID, group='InfoGroup')
# infoShared <- SharedData$new(meetupInfo, ~ID, group='InfoGroup')
# descShared <- SharedData$new(meetupInfo[, c('Description', 'ID')], ~ID, group='InfoGroup')

# makeDatatable(meetupInfo[1:5, 1:3])

# read event data
eventData <- tidyjson::read_json('data/events.json')

# get speaker info
# venue info
# presentation, topic and presenter info

stripListChars <- function(data)
{
    data %>% 
        dplyr::mutate_if(is.character, stringr::str_replace_all, pattern='^list\\(\\"', replace='') %>% 
        dplyr::mutate_if(is.character, stringr::str_replace_all, pattern='\\"\\)$', replace='')
}

stripListCharsFromDate <- function(data)
{
    data %>% 
        dplyr::mutate_at(dplyr::vars(Date), stringr::str_replace_all, pattern='^list\\(', replace='') %>% 
        dplyr::mutate_at(dplyr::vars(Date), stringr::str_replace_all, pattern='\\)$', replace='')
}

ditchCols <- function(data, cols=c('-document.id', '-array.index'))
{
    data %>% dplyr::select_(.dots=cols)
}

makeCharVector <- function(x)
{
    list(unique(x))
}

# general info
generalInfo <- eventData %>% 
    gather_array %>% 
    # get these details
    spread_values(ID=jstring('id'), 
                  URL=jstring('link'), 
                  Date=jstring('time'),
                  Meetup=jstring('name'),
                  Venue=jstring('venue', 'name'),
                  Description=jstring('description'),
                  Video=jstring('video'),
                  VideoSource=jstring('VideoSource')
    ) %>% 
    stripListChars %>% 
    stripListCharsFromDate %>% 
    # convert to data
    dplyr::mutate(Date=as.Date(as.POSIXct(as.numeric(Date)/1000, origin='1970-01-01 00:00:00')))

# speakers
speakerInfo <- eventData %>% 
    gather_array %>% 
    spread_values(ID=jstring('id')) %>% 
    enter_object('speakers') %>% 
    gather_array %>% append_values_string(column.name='Speaker') %>% 
    stripListChars %>% 
    ditchCols
    
# topics
topicInfo <- eventData %>% 
    gather_array %>% 
    spread_values(ID=jstring('id')) %>% 
    enter_object('topics') %>% 
    gather_array %>% append_values_string(column.name='Topic') %>% 
    stripListChars %>% 
    ditchCols

presentationInfo <- eventData %>% 
    gather_array %>% 
    spread_values(ID=jstring('id')) %>% 
    enter_object('slides') %>% 
    gather_array %>% 
    spread_values(Presenter=jstring('presenter'), 
                  Title=jstring("title"), 
                  File=jstring("file"), 
                  Format=jstring("format")
    ) %>% 
    enter_object('topics') %>% 
    gather_array %>% append_values_string(column.name='PresentationTopic') %>% 
    stripListChars %>% 
    ditchCols

# join all the info together
events <- dplyr::left_join(generalInfo, speakerInfo, by='ID') %>% 
    dplyr::left_join(topicInfo, by='ID') %>% 
    dplyr::left_join(presentationInfo, by='ID') %>% tibble::as_tibble()

# make links
events <- events %>% 
    # create links to meetup pages
    dplyr::mutate(EventMeetup=Meetup) %>% 
    dplyr::mutate(Meetup=sprintf('<a href="%s" target="_blank">%s</a>', URL, Meetup)) %>% 
    # create links to files
    dplyr::mutate(Presentation=sprintf('<a href="https://slides.nyhackr.org/presentations/%s" target="_blank">%s</a>', 
                                File, Title)) %>% 
    # get rid of list() in VideoSource
    dplyr::mutate(VideoSource=stringr::str_replace(VideoSource, 'list\\(\\)', '')) %>% 
    dplyr::mutate(Video=dplyr::if_else(!is.na(Video) & Video != "", 
                                       sprintf('<a href="%s" target="_blank">%s</a>', Video, VideoSource), 
                                       NA_character_))

talks <- events %>% 
    dplyr::group_by(ID, Meetup, EventMeetup, Presentation, Title, Venue, Date, Description, File, Format, Video, VideoSource) %>% 
    dplyr::summarize(
        PresentationTopics=makeCharVector(PresentationTopic), 
        Presenter=makeCharVector(Presenter),
        EventMeetupTopics=makeCharVector(c(Topic, PresentationTopic)),
        Speakers=makeCharVector(Speaker)) %>% 
    tidyr::unite(ShareKey, ID, EventMeetup, File, sep='_', remove=FALSE) %>% 
    dplyr::ungroup() %>% 
    dplyr::mutate(ID=as.character(ID))

eventDetails <- talks %>% 
    dplyr::select(ShareKey, ID, Meetup, EventMeetup, Venue, Date, Description, Speakers, EventMeetupTopics, Video, VideoSource) %>% 
    dplyr::mutate(ShareKey=ID) %>% 
    dplyr::group_by(ID) %>% 
    dplyr::slice(1) %>% 
    dplyr::ungroup()

## create shared data
# create a name for a bunch of dataframes that are grouped
groupMeetup <- 'SpeakerEvents'
# a tibble of all the data
all_shared <- SharedData$new(data=talks, key=~ShareKey, group=groupMeetup)
# a tibble of all columns for eventDetails
details_shared <- SharedData$new(data=eventDetails, key=~ShareKey, group=groupMeetup)
# the talks tibble
talks_shared <- SharedData$new(data=talks %>% 
                                   # drop rows where presenter is NA
                                   dplyr::filter(!is.na(Presenter)) %>% 
                                   # add dummy column
                                   dplyr::mutate(` ` = '') %>% 
                                   # keep these columns
                                   dplyr::select(` `, ShareKey, Presentation, Meetup, Presenter), 
                               key=~ShareKey, group=groupMeetup)
# events tibble
events_shared <- SharedData$new(data=eventDetails %>% 
                                    # add dummy column
                                    dplyr::mutate(` ` = '') %>% 
                                    # keep these columns
                                    dplyr::select(` `, ShareKey, Description, Meetup, Date, Speakers, Video), 
                                key=~ShareKey, group=groupMeetup)

## filter objects
topicFilter <- filter_select_multikey(id='TopicSelector', label='Choose a Topic',
                                          sharedData1=all_shared,
                                          sharedData2=details_shared,
                                          col1='PresentationTopics', key1='ShareKey',
                                          col2='EventMeetupTopics', key2='ShareKey')
presenterFilter <- filter_select_multikey(id='SpeakerSelector', label='Choose a Presenter',
                                      sharedData1=talks_shared,
                                      sharedData2=events_shared,
                                      col1='Presenter', key1='ShareKey',
                                      col2='Speakers', key2='ShareKey')
venueFilter <- filter_select_multikey(id='VenueSelector', label='Choose a Venue',
                                          sharedData1=all_shared,
                                          sharedData2=details_shared,
                                          col1='Venue', key1='ShareKey',
                                          col2='Venue', key2='ShareKey')
nameFilter <- filter_select_multikey(id='MeetupSelector', label='Choose a Meetup',
                                      sharedData1=all_shared,
                                      sharedData2=details_shared,
                                      col1='EventMeetup', key1='ShareKey',
                                      col2='EventMeetup', key2='ShareKey')
titleFilter <- filterComplex_select(id='TitleSelector', label='Choose a Presentation',
                                    sharedData=all_shared,
                                    group=~Title)
videoFilter <- filter_select_multikey(id='VideoSelector', label='Choose a Video Host',
                                     sharedData1=all_shared,
                                     sharedData2=details_shared,
                                     col1='VideoSource', key1='ShareKey',
                                     col2='VideoSource', key2='ShareKey')