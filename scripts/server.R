# server -----
server <- function(input, output, session) {
  
  # output$occupancy_heatmap_all ----
  # static, shows all of scotland
  output$occupancy_heatmap_all <- renderLeaflet({
    occupancy_heatmap_all
  })
  
  
  # output$occupancy_heatmap ----
  # reactive to hb selector
  output$occupancy_heatmap <- renderLeaflet({
    hospital_location_occupancy %>% 
      filter(hb == input$hb) %>% 
      leaflet() %>% 
      addProviderTiles(providers$Stamen.TonerLite) %>% 
      addCircleMarkers(lng = ~ longitude,
                       lat = ~ latitude,
                       weight = 1,
                       radius = 5,
                       fillOpacity = 1,
                       popup = ~ paste(location_name, br(), "Board:", hb),
                       color = ~ occupancy_pal(percentage_occupancy)
      )
  })
  
  # output$occupancy_ts ----
  
  # plot ave_length_of_stay over time with hb filter
  # assign to plot_ts_occupancy_filter_hb
  # note scale all health boards == individual HB so keep on same graph
  output$occupancy_ts <- renderPlot({
    occupancy_per_hb %>% 
      # filter for hb, always show "all of scotland" = S92000003
      filter(hb %in% c("S92000003", input$hb)) %>% 
      ggplot() +
      aes(x = quarter, y = percentage_occupancy, colour = hb) +
      geom_line() +
      geom_point() +
      scale_colour_brewer(type = "qual", palette = "Set1") +
      labs(x = "\nYear quarter", y = "Percentage occupancy\n",
           title = "Percentage occupancy (hospital beds)",
           colour = "Health board") +
      theme(legend.position = "bottom",
            panel.background = element_blank(),
            panel.grid.minor.x = element_blank(),
            panel.grid.minor.y = element_blank(),
            axis.text = element_text(size = 12),
            axis.title = element_text(size = 16),
            legend.title = element_text(size = 12),
            plot.title = element_text(size = 20)
      )
  })
  
}