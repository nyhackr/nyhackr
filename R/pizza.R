
#' Render the pizza plot
#'
#' Renders the plotly interactive plot on the pizza page. Build via ggplot and ggplotly
#'
#' @param .data a dataframe of the pizza data. See example.
#'
#' @return a plotly object
#'
#' @examples
#' pizza <- jsonlite::fromJSON("https://www.jaredlander.com/data/PizzaPollData.php")
#' render_pizza_plot(pizza)
render_pizza_plot <- function(.data){
  
  .data <- .data %>% 
    filter(polla_qid != 29) %>% 
    arrange(polla_qid) %>% 
    mutate(Answer = factor(Answer, 
                           levels = c('Never Again', 'Poor', 'Average', 'Good', 'Excellent')),
           ID = factor(polla_qid, levels = unique(sort(polla_qid))))
  
  # pull the pizza shop labels in the right order
  x_labels <- .data %>% 
    group_by(polla_qid) %>% 
    tidyr::nest() %>% 
    mutate(label = purrr::map(data, ~unique(.x$Place))) %>% 
    tidyr::unnest(label) %>% 
    pull(label)
  
  # build ggplot
  p <- .data %>% 
    ggplot(aes(x = ID, fill = Answer, y = Percent, text = Place, text2 = Votes)) + 
    geom_bar(position = 'stack', stat = 'identity', 
             color = 'white', size = 0.4) + 
    scale_x_discrete(labels = x_labels) +
    scale_y_continuous(breaks = seq(0, 1, by = 0.1)) +
    scale_fill_brewer(palette = 'YlGnBu') +
    labs(x = NULL,
         y = 'Proportion of votes',
         fill = NULL) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = -60, hjust = 0, size = 7))
  
  # convert to plotly
  n_polls <- length(unique(pizza$polla_qid))
  p <- plotly::ggplotly(p,
                        height = 700,
                        tooltip = c("text", 'text2', "Answer", "Percent")) %>%
    plotly::rangeslider(start = n_polls - 20,
                        end = n_polls)
  
  # wrap in div
  plot_div <- htmltools::tags$div(
    id = 'pizza-plot-container',
    p
  )
  
  return(plot_div)
}

#' @describeIn render_pizza_plot eCharts version of the pizza plot
render_pizza_plot_ec <- function(pizza){
  
  # clean up data
  pizza_cleaned <- pizza |>  
    tibble::tibble() |> 
    dplyr::filter(polla_qid != 29) |>  
    dplyr::arrange(polla_qid) |>  
    dplyr::mutate(
      Answer = factor(
        Answer, 
        levels = c('Never Again', 'Poor', 'Average', 'Good', 'Excellent')
      ),
      ID = factor(polla_qid, levels = unique(sort(polla_qid)))
    )
  
  # TODO: theres an issue with the x labels
  # need to use a unique id (pizza_cleaned$ID) for the x axis but should label
  #   it using pizza_cleaned$Place column. The x_axis_formatter attempts to do this
  #   but the results do not match the current plot
  
  # create x axis labels so the names as the pizza places, not the IDs
  # this is necessary b/c a given pizza place can occur twice
  # pull the pizza shop labels in the right order
  x_labels <- pizza_cleaned %>%
    dplyr::group_by(polla_qid) |> 
    dplyr::summarize(label = dplyr::first(Place)) |> 
    pull(label)
  label_array <- paste0('"', x_labels, '"', collapse = ', ')
  x_axis_formatter <- htmlwidgets::JS(
    glue::glue(
      .open = "<",
      .close = ">",
      "function(index){ return([<label_array>][index-1])}"
    )
  )
  
  # TOOD: this should show the label as the title, not the ID
  tooltip_formatter <- htmlwidgets::JS(
    "
    function(params){tmp = params;
      return('<strong>' + params.value[0] + '</strong>' +
      '<br/>' + params.seriesName + ': ' + parseFloat(params.value[1] * 100).toFixed(0)+'% (n=' + params.name + ')')}  
    "
  )
  
  # build the echart
  #  <- pizza_cleaned |> 
  ec_plot <- pizza_cleaned |> 
    dplyr::group_by(Answer) |> 
    echarts4r::e_chart(ID) |> #Place
    echarts4r::e_bar(Percent, bind = Votes, stack = 'grp') |> 
    echarts4r::e_aria(
      enabled = TRUE,
      decal = list(show = TRUE)
    ) |>
    echarts4r::e_theme("essos") |>
    echarts4r::e_color(background = '#ffffff00') |> 
    echarts4r::e_tooltip(formatter = tooltip_formatter) |>
    echarts4r::e_x_axis(
      axisLabel = list(rotate = -40),
      formatter = x_axis_formatter
    ) |> 
    echarts4r::e_y_axis(
      max = 1,
      formatter = echarts4r::e_axis_formatter("percent", digits = 0)
    ) |>
    echarts4r::e_axis_labels(x = NULL, y = "Proportion of Votes") |>
    echarts4r::e_datazoom(
      x_index = 0,
      toolbox = FALSE,
      type = "slider",
      start = max(pizza_cleaned$polla_qid) - 20
    ) |> 
    echarts4r::e_legend(top = 5) |>
    echarts4r::e_grid(bottom = 140)
  
  return(ec_plot)
}