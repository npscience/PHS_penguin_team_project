library(shiny)
library(tidyverse)
library(bslib)


ha_demo <- read_csv("../PHS_penguin_team_project/team_notes/Chiara_notes/da_demo_clean.csv")



ui <- fluidPage(
  
)

server <- function(input, output, session) {
  
}

shinyApp(ui, server)