delayed <- clean_names(read_csv("../../data/delayed-discharge-beddays-health-board.csv"))

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


map <- read_csv("../../data/cleaned_data/hospital_locations_clean.csv")

map_means <- left_join(map, mean_diff, by = "HB")

write_csv(delayed, "../../data/cleaned_data/delayed.csv")
write_csv(map_means, "../../data/cleaned_data/delayed_map_means.csv")