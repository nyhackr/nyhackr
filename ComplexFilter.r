isIn <- function(right, left)
{
    left %in% right
}

uniqueInAll <- function(checker, all)
{
    all %>% purrr::map_lgl(isIn, left=checker)
}

matchKeys <- function(vect, keys)
{
    keys[vect]
}

makeGroupOptionsComplex <- function(sharedData, group, allLevels) 
{
    # get the data.frame
    df <- sharedData$data(withSelection=FALSE, withFilter=FALSE, withKey=TRUE)
    # get the column holding the data to check
    if (inherits(group, "formula")) 
        group <- lazyeval::f_eval(group, df)
    # drop out if there is nothing in group
    if (length(group) < 1) {
        stop("Can't form options with zero-length group vector")
    }
    
    # get unique values from group
    oneOffs <- unlist(unique(group))
    # get group as it is
    allOfThem <- group
    
    # build list of values that are there
    listOfKeys <- oneOffs %>% 
        purrr::map(uniqueInAll, all=allOfThem) %>% 
        stats::setNames(nm=oneOffs) %>% 
        purrr::map(matchKeys, df$key_)
    
    options <- list(items=data.frame(value=oneOffs, label=oneOffs, 
                                     stringsAsFactors=FALSE), 
                    map=listOfKeys, 
                    group=sharedData$groupName())
    options
}

getColumns <- function(.data, col)
{
    # get the column holding the data to check
    if (inherits(col, "formula")) 
        col <- lazyeval::f_eval(col, .data)
    # drop out if there is nothing in col
    if (length(col) < 1) {
        stop("Can't form options with zero-length group vector")
    }
    
    return(col)
}

makeGroupOptionsComplex_multiKey <- function(sharedData1, sharedData2, 
                                             col1, key1, col2, key2, 
                                             allLevels) 
{
    # get the data.frame
    # get the data.frame
    df1 <- sharedData1$data(withSelection=FALSE, withFilter=FALSE, withKey=FALSE)
    df2 <- sharedData2$data(withSelection=FALSE, withFilter=FALSE, withKey=FALSE)
    
    # col1 <- getColumns(df, col1)
    # col2 <- getColumns(df, col2)
    # key1 <- getColumns(df, key1)
    # key2 <- getColumns(df, key2)
    
    keyList <- makeMultiKeys(data1=df1, data2=df2, 
                             col1=col1, col2=col2, 
                             key1=key1, key2=key2)
    
    options <- list(items=data.frame(value=names(keyList), label=names(keyList), 
                                     stringsAsFactors=FALSE), 
                    map=keyList, 
                    group=sharedData1$groupName())
    options
}

filter_display <- function(options, id, label, multiple=TRUE)
{
    htmltools::browsable(
        htmltools::attachDependencies(
            htmltools::tags$div(id=id, 
                                class="form-group crosstalk-input-select crosstalk-input", 
                                htmltools::tags$label(class="control-label", `for`=id, label), 
                                htmltools::tags$div(htmltools::tags$select(multiple=if(multiple) 
                                    NA
                                    else NULL), 
                                    htmltools::tags$script(type="application/json", `data-for`=id, 
                                                           jsonlite::toJSON(options, dataframe="columns", 
                                                                            pretty = TRUE)))), 
            c(list(crosstalk:::jqueryLib(), crosstalk:::bootstrapLib(), 
                   crosstalk:::selectizeLib()), crosstalk:::crosstalkLibs())))
}

filterComplex_select <- function (id, label, sharedData, group, allLevels=FALSE, multiple=TRUE)
{
    options <- makeGroupOptionsComplex(sharedData, group, allLevels)
    
    filter_display(options, id=id, label=label, multiple=multiple)
}

filter_select_multikey <- function(id, label, sharedData1, sharedData2, 
                                   col1, key1, col2, key2, 
                                   allLevels=FALSE, multiple=TRUE)
{
    options <- makeGroupOptionsComplex_multiKey(sharedData1=sharedData1,
                                                sharedData2=sharedData2,
                                                col1=col1, key1=key1,
                                                col2=col2, key2=key2, 
                                                allLevels=allLevels)
    
    filter_display(options, id=id, label=label, multiple=multiple)
}