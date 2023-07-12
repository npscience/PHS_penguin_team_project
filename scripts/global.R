# global -----

library(shiny)

library(tidyverse)
library(janitor)
library(lubridate)

library(bslib)
library(plotly)
library(leaflet) # for maps
library(sf) # if using geometry

# data wrangling ----

## load in data
# for maps
hospitals <- read_csv("../data/cleaned_data/hospital_locations_clean.csv") 

# for occupancy middle plot
occupancy_per_hb <- read_csv("../data/cleaned_data/occupancy_per_hb.csv") %>% 
  mutate(quarter = zoo::as.yearqtr(quarter))

### colour palette for hospitals on map
pal <- colorFactor(c("navy", "blue", "steelblue", "skyblue",
                     "red","indianred", "maroon", "brown",
                     "springgreen", "springgreen2", "springgreen3", "springgreen4",
                     "gold", "goldenrod", "yellow", "orange"),
                   domain = unique(hospitals$HB))

# lists for selectors ----


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
              "The Golden Jubilee National Hospital" = "SB0801") # used on both pages for now


covid_kpi_list <- c("Hospital admissions", "Percantage bed occupancy", "Delayed discharges")

