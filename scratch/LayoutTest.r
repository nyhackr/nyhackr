library(magrittr)
library(dplyr)
tester <- jsonlite::fromJSON('data/eventsSmall.json')
tester %>% head
dim(tester)
View(tester)
tester$slides[[3]]$topics


events %>% filter(Title == 'Machine Learning in R') %>% summarize(Topics=makeTopicVector(PresentationTopic))

dudeShared <- SharedData$new(dude)

bscols(widths=c(4, 8),
       filterComplex_select(id='this', label='choose', sharedData=dudeShared, group=~Topics),
       DT::datatable(dudeShared)
)

events %>% 
    group_by(Name) %>% 
    summarize(Topics=makeTopicVector(PresentationTopic)) -> dude2

dudeShared2 <- SharedData$new(dude2)

bscols(widths=c(4, 8),
       filterComplex_select(id='this', label='choose', sharedData=dudeShared2, group=~Topics),
       DT::datatable(dudeShared2)
)



bscols(widths=c(2, 4, 6),
       list(
           filterComplex_select(id='TopicSelector', label='Choose a Topic', 
                                sharedData=all_shared, 
                                group=~PresentationTopics),
           filterComplex_select(id='SpeakerSelector', label='Choose a Speaker',
                                sharedData=all_shared,
                                group=~Speakers),
           filterComplex_select(id='VenueSelector', label='Choose a Venue',
                                sharedData=all_shared,
                                group=~Venue)
       ),
       makeDatatable(talks_shared, colsToHide='ShareKey', scrollX=FALSE, height=400, width=400),
       makeDatatable(events_shared, colsToHide='ShareKey', scrollX=FALSE, height=400, width=600,
                     colsToFixWidth='Description', columnsWidth='10px')
)
