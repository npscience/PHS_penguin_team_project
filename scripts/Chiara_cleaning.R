library(tidyverse)
library(ggplot2)
library(janitor)
library(lubridate)



ha_demo <- read_csv("../PHS_penguin_team_project/data/covid/hospital_admissions/hospital_admissions_hb_agesex_20230706.csv") %>% 
  clean_names()


ha_simd <- read_csv("../PHS_penguin_team_project/data/covid/hospital_admissions/hospital_admissions_hb_simd_20230706.csv") %>% 
  clean_names()


map <- read_csv("../PHS_penguin_team_project/data/cleaned_data/hospital_locations_clean.csv") %>% 
  clean_names()

#First of all, I create a column called 'month_ending_date', which I want have a data format and contains simply the month, in this way I will be able to group the data by month and make the dataset consistent with the other datasets.


ha_demo <- ha_demo %>% 
  mutate(month_ending_date = ym(str_sub(as.character(week_ending), start = 1, end = 6)), .after = week_ending) %>% 
  mutate(week_ending = ymd(week_ending)) 


ha_simd <- ha_simd %>% 
  mutate(month_ending_date = ym(str_sub(as.character(week_ending), start = 1, end = 6)), .after = week_ending) %>% 
  mutate(week_ending = ymd(week_ending))



#Since, the heal board code 'Scotland' correspond to the entire Scotland, I am going to mutate it in 'Scotland' for clarity.




#Finally, I am going to create a new column for dividing the age_groups into different age groups I am more interested in.

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


write_csv(join_ha_map, "../PHS_penguin_team_project/data/cleaned_data/join_ha_map.csv")

write_csv(ha_demo, "../PHS_penguin_team_project/data/cleaned_data/ha_demo_clean.csv")













