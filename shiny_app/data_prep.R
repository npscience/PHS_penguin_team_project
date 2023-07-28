# Data preparation ---
## Combined cleaning scripts from scripts/
library(tidyverse)
library(janitor)
library(lubridate)
library(sf)

# prepare hospital locations data (Ali) ---

hospitals <- read.csv("data/map/nhs_hospitals_xy.csv")

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

# attaching new location data to data

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

write_csv(all_hospital_long_lat, "shiny_app/cleaned_data/hospital_locations_clean.csv")

# prepare hospital bed occupancy data (Naomi) ----

# load in raw data ----
beds <- read_csv("data/beds_by_nhs_board_of_treatment_and_specialty.csv") %>% 
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
hospitals <- read_csv("data/cleaned_data/hospital_locations_clean.csv")
hospitals_lookup <- hospitals %>% 
  clean_names() %>% 
  select(location, location_name, longitude, latitude)
# join long and lat with occupancy data
hospital_location_occupancy <- hospital_occupancy %>% 
  left_join(hospitals_lookup)

# write cleaned data to new file to load into shiny
write_csv(hospital_location_occupancy, "shiny_app/cleaned_data/hospital_location_occupancy.csv")

# prep data for plot of occupancy over time per health board ----
# select same columns from original df
occupancy_per_hb <- beds %>% 
  group_by(hb, quarter) %>% 
  summarise(total_occupied_beddays = sum(total_occupied_beddays),
            all_staffed_beddays = sum(all_staffed_beddays)) %>% 
  mutate(percentage_occupancy = 100 * (total_occupied_beddays / all_staffed_beddays))

# write cleaned data to new file to load into shiny
write_csv(occupancy_per_hb, "shiny_app/cleaned_data/occupancy_per_hb.csv")


# prepare delayed discharges data (Ali) ----
delayed <- clean_names(read_csv("data/delayed-discharge-beddays-health-board.csv"))

delayed <- delayed %>% 
  select(month_of_delay,
         hbt,
         age_group,
         number_of_delayed_bed_days,
         average_daily_number_of_delayed_beds,
         reason_for_delay)

delayed <- delayed %>% 
  mutate(month_of_delay = ym(month_of_delay))

means_before <- delayed %>% 
  filter(age_group == "18plus",
         month_of_delay < "2020-01-01",
         reason_for_delay == "All Delay Reasons"
  ) %>% 
  summarise(mean = mean(average_daily_number_of_delayed_beds), .by = hbt)

## making the mean difference and by health board with locations
means_after <- delayed %>% 
  filter(age_group == "18plus",
         month_of_delay >= "2022-01-01",
         reason_for_delay == "All Delay Reasons") %>% 
  summarise(mean = mean(average_daily_number_of_delayed_beds), .by = hbt)

mean_diff <- inner_join(means_before, means_after, by = "hbt") %>% 
  mutate(mean_diff = mean.y - mean.x, HB = hbt)

map <- read_csv("data/cleaned_data/hospital_locations_clean.csv")

map_means <- left_join(map, mean_diff, by = "HB")

write_csv(delayed, "shiny_app/cleaned_data/delayed.csv")
write_csv(map_means, "shiny_app/cleaned_data/delayed_map_means.csv")


# prepare hospital admissions data (Chiara) ----

ha_demo <- read_csv("data/covid/hospital_admissions/hospital_admissions_hb_agesex_20230706.csv") %>% 
  clean_names()
ha_simd <- read_csv("data/covid/hospital_admissions/hospital_admissions_hb_simd_20230706.csv") %>% 
  clean_names()
map <- read_csv("data/cleaned_data/hospital_locations_clean.csv") %>% 
  clean_names()

ha_demo <- ha_demo %>% 
  mutate(month_ending_date = ym(str_sub(as.character(week_ending), start = 1, end = 6)), .after = week_ending) %>% 
  mutate(week_ending = ymd(week_ending)) 

ha_simd <- ha_simd %>% 
  mutate(month_ending_date = ym(str_sub(as.character(week_ending), start = 1, end = 6)), .after = week_ending) %>% 
  mutate(week_ending = ymd(week_ending))

ha_demo <- ha_demo %>% 
  mutate(age = case_when(
    age_group == "Under 5"~ "Under 5",
    age_group %in% c("15 - 44", "45 - 64")~"5 - 64",
    age_group %in% c("65 - 74", "75 - 84", "85 and over")~"over 65",
    age_group == "5 - 14"~ "5 - 64",
    age_group == "All ages"~"All ages" 
  ),
  .after = age_group)

join <- left_join(ha_demo, map, by = "hb")

ha_for_join <- ha_demo %>% 
  group_by(hb) %>% 
  summarise(mean_adm = mean(number_admissions))

join_ha_map <- full_join(map, ha_for_join, by = "hb")

write_csv(join_ha_map, "shiny_app/cleaned_data/join_ha_map.csv")

write_csv(ha_demo, "shiny_app/cleaned_data/ha_demo_clean.csv")


# prepare ae attendances data for winter/summer tab (Thijmen) ----

#### Create dataset including season terminology for summer/winter difference

# Open datafile and clean names
waiting_times <- read.csv("data/a_and_e/monthly_ae_activity_202305.csv") %>% 
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


########
# Create dataset for plotting demographics for  season 
# A. Open datafile and clean names

demo_attendances <- read.csv("data/a_and_e/opendata_monthly_ae_demographics_202305.csv") %>% 
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

# (Naomi -- merge location and waiting times for leaflet plot)

##### 
# 3. Load in data for leaflet map
locations <- read.csv("shiny_app/cleaned_data/hospital_locations_clean.csv")

waiting_times <- read.csv("data/a_and_e/monthly_ae_activity_202305.csv") %>% 
  clean_names() %>% 
  rename("Location" = "treatment_location") %>% 
  left_join(locations, by = "Location")

#thijmen end

#### save files to cleaned data folder:
write.csv(demo_attendances_season, file = "shiny_app/cleaned_data/demographics_ae_season_cleaned.csv")
write.csv(attendances_ae, file = "shiny_app/cleaned_data/ae_attendences_cleaned.csv")
write_csv(waiting_times, "shiny_app/cleaned_data/waiting_times.csv")
