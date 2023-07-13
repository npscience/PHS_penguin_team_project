library(shiny)
library(tidyverse)
library(bslib)


ha_demo <- read_csv("../PHS_penguin_team_project/data/cleaned_data/ha_demo_clean.csv")

all_boards <- ha_demo %>% 
  distinct(hb) 




ui <- fluidPage(
  
  titlePanel(tags$h1("Covid impact on hospital admissions")),
  
  
 fluidRow(
    column(width = 6,
           selectInput("heal_board",
                       tags$i("Select an healt board"),
                       choices = all_boards)
  ),
  
  column(
    width = 6,
    plotOutput("ha_admissions")
  ),
  
  ),
  

fluidRow(
  
  
#  column(
 #   width = 6,
#  ),
  
  
  column(width = 6,
         plotOutput("age_ha_covid"))
)
  
  
  
  
  
)











server <- function(input, output, session) {
  
  
  output$ha_admissions <- renderPlot({
    ha_demo %>% 
      filter(hb %in% c("S08000015", "S92000003")) %>% 
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
  
  
  
  
  output$age_ha_covid <- renderPlot({
    ha_demo %>% 
      filter(hb %in% c("S08000015"), age != "All ages") %>%
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