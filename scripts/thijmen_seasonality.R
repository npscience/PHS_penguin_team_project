library(shiny)
library(tidyverse)
library(ggplot2)
library(janitor)
library(lubridate)
library(bslib)

# create input selector for hbs
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
              "Lanarkshire" = "S08000032") # used on both pages for now

####
#### Create dataset including season terminology for summer/winter difference

# Open datafile and clean names
waiting_times <- read.csv("../data/a_and_e/monthly_ae_activity_202305.csv") %>% 
  clean_names()

#1. create variable for season
season_name <- setNames(rep(c("winter", "spring", "summer", "autumn"), each = 3),
                        month.name)

# 2. create table specifying season
attendances_ae <- waiting_times %>% 
  select(month, hbt, number_of_attendances_all) %>% 
  #let's add a column indicating season
  mutate(month_label = month(
    ym(month), label = TRUE, abbr = FALSE), 
    .before = hbt) %>% 
  mutate(season = season_name[month_label], .before = hbt) %>% 
  # create a  year column, 
  mutate(year = year(ym(month)), .before = hbt) %>% 
  # create a "fake" year for december, to make sure that december of previous year falls in next year for correct grouping
  mutate(year = if_else(month_label == "December", year+1, year)) %>% 
  mutate(season = if_else(month_label == "December", "winter", season)) %>%  
  mutate(season = if_else(month_label == "March", "spring", season)) %>% 
  mutate(season = if_else(month_label == "June", "summer", season)) %>% 
  mutate(season = if_else(month_label == "September", "autumn", season)) %>% 
  # create a column to later filter right season!
  mutate(right_season = if_else(
    str_detect(season, "winter|summer"), TRUE, FALSE),
    .before = hbt) 

# 3.
#lets create a table with a yearly average per hb per season, for each year:
avg_yearperseason_hb <- attendances_ae %>% 
  select(year, hbt, number_of_attendances_all) %>% 
  group_by(year, hbt) %>% 
  summarise(average_season_year = sum(number_of_attendances_all)/4) %>% 
  filter(year < 2020 & year > 2007) %>%
  filter(hbt == "S08000028")

# 4. lets create a table as input for the ggplot
input_table_ggplot_attendances <- attendances_ae %>% 
  filter(right_season == TRUE) %>% 
  group_by(year, season, hbt) %>% 
  summarise(total_attendances = sum(number_of_attendances_all)) %>%
  filter(year < 2020 & year > 2007) %>% 
  filter(hbt == "S08000028")

########
########
# Create dataset for plotting demographics for  season 
# A. Open datafile and clean names
demo_attendances <- read.csv("../data/a_and_e/opendata_monthly_ae_demographics_202305.csv") %>% 
  clean_names()

# B. create table specifying season
demo_attendances_season <- demo_attendances %>% 
  select(month, hbt, age, sex, deprivation, number_of_attendances) %>% 
  #let's add a column indicating season
  mutate(month_label = month(
    ym(month), label = TRUE, abbr = FALSE), 
    .before = hbt) %>% 
  mutate(season = season_name[month_label], .before = hbt) %>% 
  # create a  year column, 
  mutate(year = year(ym(month)), .before = hbt) %>% 
  # create a "fake" year for december, to make sure that december of previous year falls in next year for correct grouping
  mutate(year = if_else(month_label == "December", year+1, year)) %>% 
  mutate(season = if_else(month_label == "December", "winter", season)) %>%  
  mutate(season = if_else(month_label == "March", "spring", season)) %>% 
  mutate(season = if_else(month_label == "June", "summer", season)) %>% 
  mutate(season = if_else(month_label == "September", "autumn", season)) %>% 
  # create a column to later filter right season!
  mutate(right_season = if_else(
    str_detect(season, "winter|summer"), TRUE, FALSE),
    .before = hbt) 




ui <- fluidPage(
  theme = bs_theme(bootswatch = "simplex"),
  
  fluidRow(
    
    # select hb(s)
    selectInput(inputId = "season_hb",
                label = tags$b("Which health board?"),
                choices = hbs_list,
                selected = "S08000015")
  ),
  
  fluidRow(
    column(width = 6,
           plotOutput("plot_season")
    )),
  
  fluidRow(
    column(width = 6,
           plotOutput("plot_season_demo_simd")
    ),
    column(width = 6,
           plotOutput("plot_season_demo_age")
  )
)
)
  


server <- function(input, output, session) {
  
  
  # create the plot for season difference
  output$plot_season <- renderPlot({
    ggplot() +
      geom_col(data = input_table_ggplot_attendances, 
               aes(
                 x = year, 
                 y = total_attendances, 
                 fill = season),
               position = "dodge", col = "white") +
      geom_line(data = avg_yearperseason_hb, 
                aes(
                  x = year, 
                  y = average_season_year))
  
})
  
  # create the plot with demographics - focus on deprivation
  output$plot_season_demo_simd <- renderPlot({
    
    demo_attendances_season %>% 
      filter(right_season == TRUE) %>% 
      filter(year < 2020 & year > 2007) %>% 
      filter(hbt == input$season_hb) %>% 
      select(year, season, hbt, deprivation, number_of_attendances) %>% 
      group_by(year, season, hbt, deprivation) %>% 
      summarise(total_per_deprivation = sum(number_of_attendances)) %>% 
      ggplot() +
      aes(x = year, y = total_per_deprivation, fill = as.character(deprivation), group = season) +
      geom_col(position = "dodge", col = "white")
  
})
  
  # create the plot with demographics - focus on age
  output$plot_season_demo_age <- renderPlot({
    
    demo_attendances_season %>% 
      filter(right_season == TRUE) %>% 
      filter(year < 2020 & year > 2007) %>% 
      filter(hbt == input$season_hb) %>% 
      select(year, season, hbt, age, number_of_attendances) %>% 
      group_by(year, season, hbt, age) %>% 
      summarise(total_per_age = sum(number_of_attendances)) %>% 
      ggplot() +
      aes(x = year, y = total_per_age, fill = as.character(age), group = season) +
      geom_col(position = "dodge", col = "white") 
    
  })
  
}
  
shinyApp(ui, server)