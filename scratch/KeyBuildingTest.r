eventDetails$Speakers %>% head(3)
talks$Speakers %>% head(3)
talks %>% dplyr::select(EventMeetup, Title, Presenter, Speakers)
talks[3:6, ]$Presenter
talks[3:6, ]$Speakers

talkTopic <- makeGroupOptionsComplex(sharedData=all_shared, group=~PresentationTopics)
talkTopic$map
eventTopic <- makeGroupOptionsComplex(sharedData=all_shared, group=~EventMeetupTopics)
eventTopic$map

individual <- tribble(
    ~ID, ~Meetup, ~TalkTopic, ~MeetupTopic, ~ Presenter, ~Speakers,
    1, 'R vs Python', 'R', c('R', 'Python'), 'Jared', c('Jared', 'Wes'),
    1, 'R vs Python', 'Python', c('R', 'Python'), 'Wes', c('Jared', 'Wes'),
    2, 'Julia vs R', c('Julia', 'R'), c('R', 'Julia'), 'Stefan', c('Stefan'),
    3, 'Just R', c('R'), c('R'), 'Jared', c('Jared'),
    4, 'R and Friends', c('R', 'SQL'), c('R', 'SQL', 'Cpp'), 'Jared', c('Jared', 'Dirk')
    ) %>% 
    tidyr::unite(Key, ID, Presenter, sep='_', remove=FALSE)
individual

grouped <- individual %>% 
    dplyr::group_by(ID) %>% 
    dplyr::slice(1) %>% 
    dplyr::ungroup() %>% 
    dplyr::select(-TalkTopic, -Presenter) %>% 
    dplyr::mutate(Key=ID)
grouped

individual$MeetupTopic %>% purrr::map(~ .x %in% individual$TalkTopic)

# within it's own column
oneOffs <- unique(unlist(individual$TalkTopic))
# get group as it is
allOfThem <- individual$TalkTopic

# build list of values that are there
withinKeys <- oneOffs %>% 
    purrr::map(uniqueInAll, all=allOfThem) %>% 
    stats::setNames(nm=oneOffs) %>% 
    purrr::map(matchKeys, individual$Key)

# within it's other column
oneOffs <- unique(unlist(individual$MeetupTopic))
# get group as it is
allOfThem <- individual$MeetupTopic

# build list of values that are there
withoutKeys <- oneOffs %>% 
    purrr::map(uniqueInAll, all=allOfThem) %>% 
    stats::setNames(nm=oneOffs) %>% 
    purrr::map(matchKeys, individual$ID) %>% 
    purrr::map(unique)

withinKeys
individual
withoutKeys


withinKeys %>% tibble::as_tibble() %>% tidyr::gather(key=Topic, value=Key) %>% 
    dplyr::bind_rows(withoutKeys %>% tibble::as_tibble() %>% tidyr::gather(key=Topic, value=Key) %>% dplyr::mutate(Key=as.character(Key))
    ) %>% 
    dplyr::group_by(Topic) %>% 
    dplyr::summarize(Key=makeCharVector(Key)) %>% 
    as.list



talk <- makeKeys(individual, 'TalkTopic', 'Key')
session <- makeKeys(individual, 'MeetupTopic', 'ID')
 %>% 
    as.list

withinKeys %>% tibble::as_tibble() %>% tidyr::gather(key=Topic, value=Key) %>% 
    dplyr::bind_rows(withoutKeys %>% tibble::as_tibble() %>% tidyr::gather(key=Topic, value=Key) %>% dplyr::mutate(Key=as.character(Key))
    ) %>% 
    dplyr::group_by(Topic) %>% 
    dplyr::summarize(Key=makeCharVector(Key)) %>% 
    as.list



talk %>% purrr::map(tibble::as_tibble) %>% purrr::map2_df(names(talk), makeTagColumn)
session %>% purrr::map(tibble::as_tibble) %>% purrr::map2_df(names(session), makeTagColumn)

combineKeys(talk, session)

makeMultiKeys(individual, col1='TalkTopic', key1='Key', col2='MeetupTopic', key2='ID')
