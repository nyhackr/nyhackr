library(crosstalk)
theDf <- tibble::tibble(
    Simple=c('R', 'R', 'R', 'Nothing', 'R'),
    Topic=list(c('R'), c('R', 'Python'), c('R', 'Time Series'), c('Python'), c('R', 'Python', 'Julia')),
    Title=c('Just R', 'R and Python', 'Time Series in R', 'Intro to Python', 'Choosing Between Languages'),
    Number=c('1', '2', '3', '4', '5'))
)

shareDF <- SharedData$new(theDf, key=~Number)
makeGroupOptionsComxplex(sharedData=shareDF, group=~Topic)

bscols(widths=c(4, 8),
       filterComplex_select(id='Chooser', label='Pick something please', sharedData=shareDF, group=~Topic),
       DT::datatable(shareDF)
)


events <- jsonlite::fromJSON('data/eventsSmall.json')
events$slides[[3]]$presenter

library(tidyjson)
eventData <- read_json('data/eventsSmall.json')
eventData %>% 
    gather_array

eventData %>% 
    gather_array %>% 
    spread_values(ID=jstring('id'), Speaker=jstring('slides', 'presenter')) %>% 
    enter_object('speakers') %>% 
    gather_array %>% append_values_string(column.name='Speaker') %>% 
    stripListChars %>% 
    ditchCols