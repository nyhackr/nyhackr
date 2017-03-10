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

