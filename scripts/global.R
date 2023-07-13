# global -----

library(shiny)

library(tidyverse)
library(janitor)
library(lubridate)

library(bslib)
library(plotly)
library(leaflet) # for maps
library(sf) # if using geometry

# load in data ----

# for occupancy map and plot
hospital_location_occupancy <- read_csv("../data/cleaned_data/hospital_location_occupancy.csv")
occupancy_per_hb <- read_csv("../data/cleaned_data/occupancy_per_hb.csv") %>% 
  mutate(quarter = zoo::as.yearqtr(quarter))

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

# theme for plots ----

## tbc

## occupancy heatmap
occupancy_pal <- colorNumeric(
  palette = "viridis",
  domain = hospital_location_occupancy$percentage_occupancy)

## static plot to show all of scotland
occupancy_heatmap_all <- hospital_location_occupancy %>% 
  leaflet() %>% 
  addProviderTiles(providers$Stamen.TonerLite) %>% 
  addCircleMarkers(lng = ~ longitude,
                   lat = ~ latitude,
                   weight = 1,
                   radius = 5,
                   fillOpacity = 1,
                   popup = ~ paste(location_name, br(), "Board:", hb),
                   color = ~ occupancy_pal(percentage_occupancy)
  )

## [old] colour palette for hospitals on map
pal <- colorFactor(c("navy", "blue", "steelblue", "skyblue",
                     "red","indianred", "maroon", "brown",
                     "springgreen", "springgreen2", "springgreen3", "springgreen4",
                     "gold", "goldenrod", "yellow", "orange"),
                   domain = unique(hospital_location_occupancy$hb))

########### thijmen
#### Create dataset including season terminology for summer/winter difference

# Open datafile and clean names
waiting_times <- read.csv("../data/a_and_e/monthly_ae_activity_202305.csv") %>% 
  clean_names()

# 1. create variable for season
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

#still thjijmen
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

# still thijmen
##### Load in data for leaflet map
locations <- read.csv("../data/cleaned_data/hospital_locations_clean.csv")

#thijmen end


#Chiara data

ha_demo <- read_csv("../data/cleaned_data/ha_demo_clean.csv")
join_ha_map <- read_csv("../data/cleaned_data/join_ha_map.csv")






