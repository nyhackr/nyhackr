theDf <- data.frame(ID=c('a', 'b', 'c', 'a'), Name=c('Jared', 'Bob', 'Sarah', 'Danny'), stringsAsFactors=FALSE)

library(crosstalk)
sharedDF <- SharedData$new(theDf)
bscols(widths=c(4, 8),
       list(
           filter_select(id='IDchoice', label='Choose an ID', sharedData=sharedDF, group=~ID, allLevels=FALSE),
           filter_select(id='Namechoice', label='Choose a name', sharedData=sharedDF, group=~Name, allLevels=FALSE),
           filter_checkbox(id='Namechoice2', label='Choose a name', sharedData=sharedDF, group=~Name, allLevels=FALSE)
       ),
       DT::datatable(sharedDF, width=500, height=600)
)

library(DT)
datatable(theDf, callback=JS('table.column( 0 ).data().unique();'), rownames=FALSE)
