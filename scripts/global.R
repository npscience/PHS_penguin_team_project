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