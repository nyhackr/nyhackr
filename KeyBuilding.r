# function for building tag key combos
# called by listToDF
makeTagColumn <- function(data, name)
{
    data %>% 
        dplyr::mutate(Tag=name) %>% 
        dplyr::select_(.dots=c('Tag', Key=names(data))) %>% 
    dplyr::mutate(Key=as.character(Key))
}

# function for going from a list of keys to a data.frame of tag-key combos
# calls makeTagColumn
listToDF <- . %>% purrr::map(tibble::as_tibble) %>% purrr::map2_df(names(.), makeTagColumn)

# function for combining sets of keys
# called by makeMultiKeys
combineKeys <- function(keys1, keys2)
{
    combined <- dplyr::bind_rows(
        keys1 %>% listToDF,
        keys2 %>% listToDF
    ) %>% 
        dplyr::group_by(Tag) %>% 
        dplyr::summarize(Key=makeCharVector(Key))
    
    combined$Key %>% setNames(combined$Tag)
}

# make a set of tags and keys based on two columns and two keys
# calls makeKeys
# calls combineKeys
makeMultiKeys <- function(data1, data2, 
                          col1, col2, 
                          key1, key2)
{
    # generate keys
    col1_Key <- makeKeys(data1, col=col1, key=key1)
    col2_Key <- makeKeys(data2, col=col2, key=key2)
    
    combineKeys(col1_Key, col2_Key)
}

# maps data to keys
# called by makeMultiKey
makeKeys <- function(data, col, key)
{
    # set a variable for the column
    column <- data %>% magrittr::extract2(col)
    key <- data %>% magrittr::extract2(key)
    # unlist it and take the uniques
    oneOffs <- column %>% unlist %>% unique
    
    # build list of values that are there
    oneOffs %>% 
        purrr::map(uniqueInAll, all=column) %>% 
        stats::setNames(nm=oneOffs) %>% 
        purrr::map(matchKeys, key)
}