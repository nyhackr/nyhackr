render_pizza_plot <- function(.data){
  
  .data <- .data %>% 
    filter(polla_qid != 29) %>% 
    arrange(polla_qid) %>% 
    mutate(Answer = factor(Answer, 
                           levels = c('Never Again', 'Poor', 'Average', 'Good', 'Excellent')),
           ID = factor(polla_qid, levels = unique(sort(polla_qid))))
  
  # TODO: x labels do not line up!
  x_labels <- .data %>% 
    group_by(polla_qid) %>% 
    tidyr::nest() %>% 
    mutate(label = purrr::map(data, ~unique(.x$Place))) %>% 
    tidyr::unnest(label) %>% 
    pull(label)
  
  p <- .data %>% 
    ggplot(aes(x = ID, fill = Answer, y = Percent, text = Place, text2 = Votes)) + 
    geom_bar(position = 'stack', stat = 'identity', 
             color = 'white', size = 0.4) + 
    scale_x_discrete(labels = x_labels) +
    scale_y_continuous(breaks = seq(0, 1, by = 0.1)) +
    scale_fill_brewer(palette = 'YlGnBu') +
    labs(fill = NULL, x = NULL) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = -60, hjust = 0, size = 7))
  p <- plotly::ggplotly(p, height = 700, tooltip = c("text", 'text2', "Answer", "Percent"))
  
  # TODO add labels to tooltip
  
  htmltools::tags$div(
    id = 'pizza-plot-container',
    p
  )
}

# render_pizza_plot(pizza) 
