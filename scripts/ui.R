# UI -----
ui <- fluidPage(
  theme = bs_theme(bootswatch = "simplex"),
  
  # ABOVE TABS ----
  titlePanel(tags$h3("Trends in acute care provision")),
  
  # global selector for health board
  fluidRow(
    #column(width = 6,
    selectInput(inputId = "hb",
                       label = tags$b("Which health board?"),
                       choices = hbs_list,
                       selected = "S08000015")
  ),
  # column(width = 6,
  #        img(src = "../images/phs_logo.png", align = "right")
  #         #imageOutput("PHSlogo")
  # ),
  
  # start tabs
  tabsetPanel(
    
    # Tab 1: Winter/Summer effect ----
    
    tabPanel(tags$b("Winter/Summer effect"),
             HTML("<br>"),
             
             fluidRow(
               column(width = 6,
                      leafletOutput("attendance_season_heatmap")
               ),
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
             )),
    
    
    # Tab 2: COVID impact on hospital admissions ----
    
    tabPanel(tags$b("COVID impact in hospital admissions"),
             HTML("<br>"),
             
             fluidRow(
               column(width = 4,
                      leafletOutput("admissions_heatmap")
               ),
               column(width = 4,
                      plotOutput("admissions_ts")
               ),
               column(width = 4,
                      plotOutput("admissions_plot")
               )
             ),
             fluidRow(
               "These plot shows the trend of hospital admissions over time, from the beginning of 2020 up to June 2023."
             )
    ),
    
    # Tab 3: COVID impact on bed occupancy ----
    
    tabPanel(tags$b("COVID impact on bed occupancy"),
             HTML("<br>"),
             fluidRow(
               "From Public Health Scotland data glossary: 'The percentage occupancy is the percentage of average available staffed beds that were occupied by inpatients during the period.'"
             ),
             fluidRow(
               column(width = 4,
                      leafletOutput("occupancy_heatmap_all")
               ),
               column(width = 4,
                      leafletOutput("occupancy_heatmap")
               ),
               column(width = 4,
                      plotOutput("occupancy_ts")
               )
             ),
             fluidRow(
               "These maps show % bed occupancy for the most recent quarter with data available (2022 Q4)"
             )
    ),
    
    # Tab 4: COVID impact on delayed discharges ----
    
    tabPanel(tags$b("COVID impact on delayed discharges"),
             HTML("<br>"),
             
             fluidRow(
               column(width = 6,
                      leafletOutput("delays_map")
               ),
               column(width = 6,
                      plotOutput("delays_age")
               )
             ),
             fluidRow(
               column(width = 5, offset = 1,
                        "asdfsadfasf"),
               column(width = 6,
                        "asdfsadfasf"),
             )
    )
  )
)
  