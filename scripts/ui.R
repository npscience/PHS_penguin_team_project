# UI -----
ui <- fluidPage(
  theme = bs_theme(bootswatch = "pulse"),
  
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
               column(width = 5, offset = 1,
                      leafletOutput("attendance_season_heatmap")
               ),
               column(width = 5,
                      plotOutput("plot_season")
               )),
             HTML("<br><br>"),
             
             fluidRow(
               column(width = 5, offset = 1,
                      plotOutput("plot_season_demo_simd")
               ),
               column(width = 5, 
                      plotOutput("plot_season_demo_age")
               )
             ),
             
             fluidRow(
               
               HTML("<br><br>"),
               column(width = 11.5,
                      offset = 0.5,
               tags$body("This dashboard uses ", a("Monthly A&E activity and waiting times data", href = "https://www.opendata.nhs.scot/dataset/monthly-accident-and-emergency-activity-and-waiting-times")," from Public Health Scotland and NHS Scotland, which contains public sector information licensed under the ",a("Open Government Licence v3.0.", href = "https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/"))
               ))
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
             ),
             HTML("<br>"),
             fluidRow(
               "These plot shows the trend of hospital admissions over time, from the beginning of 2020 up to June 2023."
             ),
             
             fluidRow(
               
               HTML("<br><br>"),
               column(width = 11.5,
                      offset = 0.5,
                      tags$body("This dashboard uses data about", a("COVID-19 Wider Impacts - Hospital Admissions", href = "https://www.opendata.nhs.scot/dataset/covid-19-wider-impacts-hospital-admissions")," from Public Health Scotland and NHS Scotland, which contains public sector information licensed under the ",a("Open Government Licence v3.0.", href = "https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/"))
               ))
    ),
    
    # Tab 3: COVID impact on bed occupancy ----
    
    tabPanel(tags$b("COVID impact on bed occupancy"),
             HTML("<br>"),
             
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
             HTML("<br>"),
             fluidRow(
               "These maps show % bed occupancy for the most recent quarter with data available (2022 Q4)"
             ),
             
             fluidRow(
               
               HTML("<br><br>"),
               column(width = 11.5,
                      offset = 0.5,
                      tags$body("This dashboard uses data on", a("Beds Information in Scotland", href = "https://www.opendata.nhs.scot/dataset/hospital-beds-information")," from Public Health Scotland and NHS Scotland, which contains public sector information licensed under the ",a("Open Government Licence v3.0.", href = "https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/"))
               ))
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
                      "Map of difference in means of average delayed discharge bed-days by health board before and after COVID-19. The points are more red in health boards where there are more delayed bed-days after covid than before"),
               column(width = 6,
                      "Splitting the data by age group, see the proportion of the effect on 75+ year olds as opposed to those of 74 or younger"),
             ),
             
             fluidRow(
               
               HTML("<br><br>"),
               column(width = 11.5,
                      offset = 0.5,
                      tags$body("This dashboard uses ", a("Delayed Discharges in NHS Scotland data", href = "https://www.opendata.nhs.scot/dataset/delayed-discharges-in-nhsscotland")," from Public Health Scotland and NHS Scotland, which contains public sector information licensed under the ",a("Open Government Licence v3.0.", href = "https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/"))
               ))
    )
  )
)
