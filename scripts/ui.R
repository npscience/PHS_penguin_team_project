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
