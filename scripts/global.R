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

## load in data
# for maps in general
# hospitals <- read_csv("../data/cleaned_data/hospital_locations_clean.csv") 

# for occupancy map and plot
hospital_location_occupancy <- read_csv("../data/cleaned_data/hospital_location_occupancy.csv")
occupancy_per_hb <- read_csv("../data/cleaned_data/occupancy_per_hb.csv") %>% 
  mutate(quarter = zoo::as.yearqtr(quarter))

### colour palette for hospitals on map
pal <- colorFactor(c("navy", "blue", "steelblue", "skyblue",
                     "red","indianred", "maroon", "brown",
                     "springgreen", "springgreen2", "springgreen3", "springgreen4",
                     "gold", "goldenrod", "yellow", "orange"),
                   domain = unique(hospital_location_occupancy$hb))

# lists for selectors ----

hbs_list <- sort(unique(occupancy_per_hb$hb)) # used on both pages for now
covid_kpi_list <- c("Hospital admissions", "Percantage bed occupancy", "Delayed discharges")