library(shiny)

library(tidyverse)
library(janitor)
library(lubridate)

library(bslib)
library(plotly)
library(leaflet) # for maps
library(sf) 


ha_demo <- read_csv("../data/cleaned_data/ha_demo_clean.csv")
join_ha_map <- read_csv("../data/cleaned_data/join_ha_map.csv")

hbs_list <- c("Ayrshire and Arran" = "S08000015",
              "Borders" = "S08000016",
              "Dumfries and Galloway" = "S08000017",
              "Forth Valley" = "S08000019",
              "Grampian" = "S08000020",
              "Highland" = "S08000022",
              "Lothian" = "S08000024",
              "Orkney" = "S08000025",
              "Shetland" = "S08000026",
              "Western Isles" = "S08000028",
              "Fife" = "S08000029",
              "Tayside" = "S08000030",
              "Greater Glasgow and Clyde" = "S08000031",
              "Lanarkshire" = "S08000032",
              "All Scotland" = "S92000003",
              "The Golden Jubilee National Hospital" = "SB0801")




ui <- fluidPage(
  
  titlePanel(tags$h1("Covid impact on hospital admissions")),
  
  
  
  fluidRow(
    column(width = 6,
           selectInput("hb",
                       tags$i("Select an healt board"),
                       choices = hbs_list)
    )
  ),
  
  
 fluidRow(
    column(width = 4,
           leafletOutput("admissions_heatmap")
  ),
  
  column(
    width = 4,
    plotOutput("admissions_ts")
  ),
  
  column(width = 4,
         plotOutput("admissions_plot"))
 
  
  ),
  

)










server <- function(input, output, session) {
  
  
  output$admissions_heatmap <- renderLeaflet({
    join_ha_map %>% 
      leaflet() %>% 
      addProviderTiles(providers$Stamen.TonerLite) %>%
      addCircleMarkers(lng = ~ longitude,
                       lat = ~ latitude,
                       weight = 0,
                       fillColor = ~colorNumeric('RdYlGn', mean_adm)
                       (mean_adm),
                       fillOpacity = 0.9
                       #popup = ~ paste( br(), "Board:", HB, br(), round(mean_diff, 0))
      )
  })
  
  
  output$admissions_ts <- renderPlot({
    ha_demo %>% 
      filter(hb %in% c(input$hb)) %>% 
      group_by(hb, month_ending_date) %>% 
      summarise(mean_admissions = mean(number_admissions)) %>% 
      ggplot() +
      aes(x = month_ending_date, y = mean_admissions, group = hb, colour = hb) +
      geom_line(show.legend = FALSE) +
      labs(
        x = "\ntime",
        y = "average monthly hospital admissions\n"
      )
  })
  
  
  
  
  output$admissions_plot <- renderPlot({
    ha_demo %>% 
      filter(hb %in% c(input$hb), age != "All ages") %>%
      group_by(age, month_ending_date) %>% 
      summarise(mean_admissions = mean(number_admissions)) %>% 
      ggplot() +
      aes(x = month_ending_date, y = mean_admissions, group = age, colour = age) +
      geom_line() +
      labs(
        x = "\ntime",
        y = "average monthly hospital admissions\n"
      )
  })
  
  
  
  
  
  
  
  
}

shinyApp(ui, server)