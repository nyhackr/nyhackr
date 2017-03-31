pizzaPoll <- tibble::as_tibble(jsonlite::fromJSON('http://www.jaredlander.com/data/PizzaPollData.php'))

# placeTime <- pizzaPoll %>%
#     select(Place, pollq_id) %>% distinct(Place, pollq_id)
# 
# duped <- pizzaPoll %>% 
#     mutate(Name=factor(Time, levels=placeTime$Time, labels=placeTime$Place))
# 
# 
# tidyr::unite(Place_Time, Place, Time, Answer, sep='_', remove=FALSE) %>% 
#     dplyr::mutate(Place=factor(Place, levels=Place_Time, labels=Place))
# 
# factor(c(1, 1, 2), labels=c(1, 2), levels=c('a', 'a'))


# idToPlace_generate <- function(places)
# {
#     function(id)
#     {
#         places[id]
#     }
# }
# 
# idToPlace <- idToPlace_generate(placeTime$Place %>% setNames(placeTime$pollq_id))
# idToPlace('43')
