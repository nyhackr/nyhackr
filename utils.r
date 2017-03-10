library(crosstalk)
library(magrittr)
library(tidyjson)
source('JsonToDataFrame.r')
source('DataTableBuilder.r')
# for functions to build a filter with complex key
source('ComplexFilter.r')

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
                  Description=jstring('description')
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
    dplyr::mutate(Meetup=sprintf('<a href="%s">%s</a>', URL, Meetup)) %>% 
    # create links to files
    dplyr::mutate(Presentation=sprintf('<a href="https://slides.nyhackr.org/presentations/%s">%s</a>', 
                                File, Title)) #%>% 
    # drop columns we don't need
    # dplyr::select(-URL, -File)

talks <- events %>% 
    dplyr::group_by(ID, Meetup, EventMeetup, Presentation, Title, Venue, Date, Description, File, Format) %>% 
    dplyr::summarize(
        PresentationTopics=makeCharVector(PresentationTopic), 
        Presenter=makeCharVector(Presenter),
        EventMeetupTopics=makeCharVector(Topic),
        Speakers=makeCharVector(Speaker)) %>% 
    tidyr::unite(ShareKey, ID, EventMeetup, File, sep='_', remove=FALSE) %>% 
    dplyr::ungroup()

eventDetails <- talks %>% 
    dplyr::select(ShareKey, ID, Meetup, Venue, Date, Description, Speakers, EventMeetupTopics) %>% 
    dplyr::group_by(ID) %>% 
    dplyr::slice(1) %>% 
    dplyr::ungroup()

## create shared data
# create a name for a bunch of dataframes that are grouped
groupMeetup <- 'SpeakerEvents'
# a tibble of all the data
all_shared <- SharedData$new(data=talks, key=~ShareKey, group=groupMeetup)
# the talks tibble
talks_shared <- SharedData$new(data=talks %>% 
                                   # drop rows where presenter is NA
                                   dplyr::filter(!is.na(Presenter)) %>% 
                                   # keep these columns
                                   dplyr::select(ShareKey, Presentation, Meetup, Presenter), 
                               key=~ShareKey, group=groupMeetup)
# events tibble
events_shared <- SharedData$new(data=eventDetails %>% 
                                    # keep these columns
                                    dplyr::select(ShareKey, Description, Meetup, Date, Speakers), 
                                key=~ShareKey, group=groupMeetup)

## filter objects
topicFilter <- filterComplex_select(id='TopicSelector', label='Choose a Topic', 
                                    sharedData=all_shared, 
                                    group=~PresentationTopics)
speakerFilter <- filterComplex_select(id='SpeakerSelector', label='Choose a Meetup Speaker',
                                      sharedData=all_shared,
                                      group=~Speakers)
presenterFilter <- filterComplex_select(id='PresenterSelector', label='Choose a Presenter',
                                      sharedData=all_shared,
                                      group=~Presenter)
venueFilter <- filterComplex_select(id='VenueSelector', label='Choose a Venue',
                                    sharedData=all_shared,
                                    group=~Venue)
nameFilter <- filterComplex_select(id='MeetupSelector', label='Choose a Meetup',
                                    sharedData=all_shared,
                                    group=~EventMeetup)
titleFilter <- filterComplex_select(id='TitleSelector', label='Choose a Presentation',
                                    sharedData=all_shared,
                                    group=~Title)
