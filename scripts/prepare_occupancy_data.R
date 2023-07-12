# prepare hospital bed occupancy data for shiny ----
# naomi
library(tidyverse)
library(janitor)
library(lubridate)

# load in raw data ---
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