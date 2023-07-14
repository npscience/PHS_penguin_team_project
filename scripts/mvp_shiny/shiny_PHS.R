# global -----

library(shiny)
library(tidyverse)
library(bslib)
library(plotly)
library(janitor)
library(lubridate)
library(leaflet) # for maps
library(sf) # if using geometry

# data wrangling ----
## IMPROVE: put data wrangling into scripts -> just read in prepared data file here

## hospitals for map
hospitals <- read_csv("../data/map/hospital_locations_clean.csv")

### colour palette for hospitals on map
pal <- colorFactor(c("navy", "blue", "steelblue", "skyblue",
                     "red","indianred", "maroon", "brown",
                     "springgreen", "springgreen2", "springgreen3", "springgreen4",
                     "gold", "goldenrod", "yellow", "orange"),
                   domain = unique(hospitals$HB))

## bed occupancy
# load in data
beds <- read_csv("../data/beds_by_nhs_board_of_treatment_and_specialty.csv") %>% 
  clean_names() %>% 
  mutate(quarter = zoo::as.yearqtr(quarter))

# generate occupancy data for all health boards to compare individual hbs to
all_hbs_occupancy <- beds %>% 
  group_by(quarter) %>% 
  summarise(total_occupied_beddays = sum(total_occupied_beddays),
            all_staffed_beddays = sum(all_staffed_beddays)) %>% 
  mutate(percentage_occupancy = 100 * (total_occupied_beddays / all_staffed_beddays),
         hb = "All health boards", .after = quarter)

# select same columns from original df
occupancy_per_hb <- beds %>% 
  group_by(hb, quarter) %>% 
  summarise(total_occupied_beddays = sum(total_occupied_beddays),
            all_staffed_beddays = sum(all_staffed_beddays)) %>% 
  mutate(percentage_occupancy = 100 * (total_occupied_beddays / all_staffed_beddays))

# combine all_hbs data with individual hbs data
occupancy <- bind_rows(all_hbs_occupancy, occupancy_per_hb)

# lists for selectors ----

hbs_list <- sort(unique(occupancy$hb)) # used on both pages for now
covid_kpi_list <- c("Occupancy", "Something else")

# UI -----
ui <- fluidPage(
  theme = bs_theme(bootswatch = "simplex"),
  
  # ABOVE TABS ----
  titlePanel(tags$h3("Main title")),
  
  # add fluidRow here if want a global selector
  
  # start tabs
  tabsetPanel(
    
    # Tab 1: Winter/Summer effect ----
    
    tabPanel(tags$b("Winter/Summer effect"),
             HTML("<br>"),
             fluidRow(
               
               # select hb(s)
               selectInput(inputId = "season_hb",
                           label = tags$b("Which health board?"),
                           choices = hbs_list,
                           selected = "S08000015")
             ),
             
             fluidRow(
               column(width = 6,
                      plotOutput("plot1")
               ),
               column(width = 6,
                      plotOutput("plot2")
               )
             )
    ),
    
    # Tab 2: COVID impact ----
    
    tabPanel(tags$b("COVID impact"),
             HTML("<br>"),
             
             fluidRow(
               # select hb(s)
               column(width = 6,
                      selectInput(inputId = "covid_hb",
                                  label = tags$b("Which health board(s)?"),
                                  choices = hbs_list,
                                  selected = "S08000015")
               ),
               column(width = 6,
                      selectInput(inputId = "covid_kpi",
                                  label = tags$b("Which metric?"),
                                  choices = covid_kpi_list,
                                  selected = "Bed occupancy")
               ),
             ),
             
             fluidRow(
               column(width = 4,
                      leafletOutput("occupancy_heatmap")
               ),
               column(width = 8,
                      plotOutput("occupancy_ts")
               )
             )
    ),
  )
)

# server -----
server <- function(input, output, session) {
  
  # output$occupancy_heatmap ----
  
  output$occupancy_heatmap <- renderLeaflet({
    hospitals %>% 
      filter(HB == input$covid_hb) %>% 
      leaflet() %>% 
      addTiles() %>% 
      addCircleMarkers(lng = ~ longitude,
                       lat = ~ latitude,
                       weight = 1,
                       popup = ~ paste(Location, br(), "Board:", HB),
                       color = ~pal(HB)
      )
  })
  
  # output$occupancy_ts ----
  
  # plot ave_length_of_stay over time with hb filter
  # assign to plot_ts_occupancy_filter_hb
  # note scale all health boards == individual HB so keep on same graph
  output$occupancy_ts <- renderPlot({
    occupancy %>% 
      # filter for multi-select - replace S08000015 with input selector for hb
      filter(hb %in% c("All health boards", input$covid_hb)) %>% 
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

shinyApp(ui, server)