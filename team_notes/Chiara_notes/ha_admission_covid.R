library(shiny)
library(tidyverse)
library(bslib)


ha_demo <- read_csv("../PHS_penguin_team_project/data/cleaned_data/ha_demo_clean.csv")



ui <- fluidPage(
  
  titlePanel(tags$h1("Covid impact on hospital admissions")),
  
  
  plotOutput("ha_admissions"),
  
  
  
  
)











server <- function(input, output, session) {
  
  
  output$ha_admissions <- renderPlot({
    ha_demo %>% 
      filter(hb %in% c("S08000015", "Scotland")) %>% 
      group_by(hb, month_ending_date) %>% 
      summarise(mean_admissions = mean(number_admissions)) %>% 
      ggplot() +
      aes(x = month_ending_date, y = mean_admissions, group = hb, colour = hb) +
      geom_line()
  })
  
  
  
  
  
  
  
  
}

shinyApp(ui, server)