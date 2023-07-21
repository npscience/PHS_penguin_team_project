# prepare hospital bed occupancy data for shiny ----
# naomi
library(tidyverse)
library(janitor)
library(lubridate)

# PDA outcome: 2.3. Data transformations including data cleaning
# load in raw data ----
beds <- read_csv("../data/beds_by_nhs_board_of_treatment_and_specialty.csv") %>% 
  clean_names() %>% 
  mutate(quarter = zoo::as.yearqtr(quarter))

# prep data for heatmap of occupancy by location ----
most_recent_quarter <- beds %>% 
  arrange(desc(quarter)) %>% 
  head(1) %>% 
  pull(quarter)

hospital_occupancy <- beds %>% 
  # prep occupancy for most recent quarter for each location
  # by calculating across all noted specialties
  # (alternative: use average for all quarters in data)
  filter(quarter == most_recent_quarter) %>% 
  group_by(location, hb) %>% 
  summarise(total_occupied_beddays = sum(total_occupied_beddays),
            all_staffed_beddays = sum(all_staffed_beddays)) %>% 
  mutate(percentage_occupancy = 100 * (total_occupied_beddays / all_staffed_beddays)) 

# bring long and lat values into summary table for occupancy
# long and lat are in separate file (made by Ali)
hospitals <- read_csv("../data/cleaned_data/hospital_locations_clean.csv")
hospitals_lookup <- hospitals %>% 
  clean_names() %>% 
  select(location, location_name, longitude, latitude)
# join long and lat with occupancy data
hospital_location_occupancy <- hospital_occupancy %>% 
  left_join(hospitals_lookup)

# write cleaned data to new file to load into shiny
write_csv(hospital_location_occupancy, "../data/cleaned_data/hospital_location_occupancy.csv")

# prep data for plot of occupancy over time per health board ----
# select same columns from original df
occupancy_per_hb <- beds %>% 
  group_by(hb, quarter) %>% 
  summarise(total_occupied_beddays = sum(total_occupied_beddays),
            all_staffed_beddays = sum(all_staffed_beddays)) %>% 
  mutate(percentage_occupancy = 100 * (total_occupied_beddays / all_staffed_beddays))

# write cleaned data to new file to load into shiny
write_csv(occupancy_per_hb, "../data/cleaned_data/occupancy_per_hb.csv")


