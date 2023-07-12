library(sf)
library(tidyverse)

hospitals <- read.csv("map/nhs_hospitals_xy.csv")

# removing entries with NA in coordinate data

hospitals_valid <- hospitals %>%
  filter(!is.na(XCoordinate))

# converting coordinates from British National Grid to WGS84 to make locations 
# compatible with leaflet

hospitals_valid_coord <- hospitals_valid %>% 
  st_as_sf(coords = c("XCoordinate", "YCoordinate"), crs = 27700) %>%
  st_transform(4326) %>%
  st_coordinates() %>%
  as_tibble()

# attatching new location data to data

hospitals_named <- cbind(hospitals_valid, hospitals_valid_coord) %>% 
  rename("longitude"  = "X" ,"latitude" = "Y")

# adding location to entry without coordinates

hospitals_invalid <- hospitals %>%
  filter(is.na(XCoordinate))

# dataframe with new location data for missing entry

df <- read.table(text = "longitude latitude
                 -3.1385988 55.9218962",
                 header = TRUE)

hospitals_revalid <- cbind(hospitals_invalid, df)


all_hospital_long_lat <- rbind(hospitals_named, hospitals_revalid) %>% 
  arrange(Location)

write_csv(all_hospital_long_lat, "../data/map/hospital_locations_clean.csv")
