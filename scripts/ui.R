# UI -----
ui <- fluidPage(
  theme = bs_theme(bootswatch = "simplex"),
  
  # ABOVE TABS ----
  titlePanel(tags$h3("Main title")),
  
  # global selector for health board
  fluidRow(selectInput(inputId = "hb",
                       label = tags$b("Which health board?"),
                       choices = hbs_list,
                       selected = "S08000015")
  ),
  
  # start tabs
  tabsetPanel(
    
    # Tab 1: Winter/Summer effect ----
    
    tabPanel(tags$b("Winter/Summer effect"),
             HTML("<br>"),
             
             fluidRow(
               column(width = 6,
                      plotOutput("plot1")
               ),
               column(width = 6,
                      plotOutput("plot2")
               )
             )
    ),
    
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
             )
    ),
    
    # Tab 3: COVID impact on bed occupancy ----
    
    tabPanel(tags$b("COVID impact on bed occupancy"),
             HTML("<br>"),
             
             fluidRow(
               column(width = 4,
                      leafletOutput("occupancy_heatmap"),
                      "This map shows occupancy in 2022 Q4"
               ),
               column(width = 6, offset = 2,
                      plotOutput("occupancy_ts")
               )
             )
    ),
    
    # Tab 4: COVID impact on delayed discharges ----
    
    tabPanel(tags$b("COVID impact on delayed discharges"),
             HTML("<br>"),
             
             fluidRow(
               column(width = 4,
                      leafletOutput("delayed_heatmap")
               ),
               column(width = 4,
                      plotOutput("delayed_ts")
               ),
               column(width = 4,
                      plotOutput("delayed_plot")
               )
             )
    )
  )
)
