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
## IMPROVE: put data wrangling into scripts -> just read in prepared data file here

## load in data
# for maps
hospitals <- read_csv("../data/cleaned_data/hospital_locations_clean.csv") 

# for occupancy middle plot
occupancy_by_hb <- read_csv("../data/cleaned_data/occupancy_by_hb.csv") %>% 
  mutate(quarter = zoo::as.yearqtr(quarter))

### colour palette for hospitals on map
pal <- colorFactor(c("navy", "blue", "steelblue", "skyblue",
                     "red","indianred", "maroon", "brown",
                     "springgreen", "springgreen2", "springgreen3", "springgreen4",
                     "gold", "goldenrod", "yellow", "orange"),
                   domain = unique(hospitals$HB))

# lists for selectors ----

hbs_list <- sort(unique(occupancy_by_hb$hb)) # used on both pages for now
covid_kpi_list <- c("Hospital admissions", "Percantage bed occupancy", "Delayed discharges")