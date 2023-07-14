# Cleaning script to clean and prepare data from A&E monthly activity
# for seasonality effect dashboard tab

# load in libraries
library(tidyverse)
library(janitor)
library(lubridate)


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

#### save files to cleaned data folder:
write.csv(demo_attendances_season, file = "data/cleaned_data/demographics_ae_season_cleaned.csv")

write.csv(attendances_ae, file = "data/cleaned_data/ae_attendences_cleaned.csv")
