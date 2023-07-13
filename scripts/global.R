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
  leaflet(options = leafletOptions(zoomSnap = 0.05, zoomDelta = 0.05)) %>% 
  addProviderTiles(providers$Stamen.TonerLite) %>% 
  addCircleMarkers(lng = ~ longitude,
                   lat = ~ latitude,
                   weight = 1,
                   radius = 5,
                   fillOpacity = 1,
                   popup = ~ paste(location_name, br(), "Board:", hb),
                   color = ~ occupancy_pal(percentage_occupancy)
  ) %>% 
  setView(lng = -56.4907, lat = 4.2026, zoom = 0.05)

## [old] colour palette for hospitals on map
pal <- colorFactor(c("navy", "blue", "steelblue", "skyblue",
                     "red","indianred", "maroon", "brown",
                     "springgreen", "springgreen2", "springgreen3", "springgreen4",
                     "gold", "goldenrod", "yellow", "orange"),
                   domain = unique(hospital_location_occupancy$hb))
