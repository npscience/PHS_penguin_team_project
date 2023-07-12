delayed <- clean_names(read_csv("delayed-discharge-beddays-health-board.csv"))

delayed <- delayed %>% 
  select(month_of_delay,
         hbt,
         age_group,
         number_of_delayed_bed_days,
         average_daily_number_of_delayed_beds,
         reason_for_delay)

delayed_no_reason <- delayed %>% 
  filter(reason_for_delay == "All Delay Reasons") %>% 
  select(-reason_for_delay)

delayed <- delayed %>% 
  mutate(month_of_delay = ym(month_of_delay))


delayed_no_reason <- delayed_no_reason %>% 
  mutate(month_of_delay = ym(month_of_delay))

write_csv(delayed, "cleaned_data/delayed.csv")
write_csv(delayed_no_reason, "cleaned_data/delayed_no_reason.csv")

