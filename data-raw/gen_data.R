library(sugrrants)
library(lubridate)
library(tidyverse)

pedestrian <- read_rds("data-raw/ped_counts_jan17.rds")
ped_loc <- read_rds("data-raw/ped_loc_jan17.rds")
grand_final <- tibble(
  holiday = rep("Grand Final", 2),
  date = ymd("2015-10-02", "2016-09-30")
)
pub_holiday <- au_holiday(2016)
pub_holiday <- bind_rows(pub_holiday, grand_final) %>% 
  rename(
    Holiday = holiday,
    Date = date
  )

ped <- pedestrian %>% 
  filter(Year == 2016) %>% 
  left_join(ped_loc, by = c("Sensor_ID", "Sensor_Name")) %>% 
  left_join(pub_holiday, by = "Date")

ped_loc <- ped %>% 
  distinct(Sensor_ID, Sensor_Name, Latitude, Longitude)

devtools::use_data(ped, overwrite = TRUE)
devtools::use_data(ped_loc, overwrite = TRUE)

melb_weather <- read_rds("data-raw/au_weather1947.rds") %>% 
  filter(station == "MELBOURNE REGIONAL OFFICE")

melb_plot <- melb_weather %>% 
  rowwise() %>% 
  mutate(TAVG = mean(c(TMAX, TMIN))) %>% 
  mutate(PRCP = if_else(is.na(PRCP), 0, PRCP))

melb_more <- melb_plot %>% 
  ungroup() %>% 
  mutate(
    .month = month(date, label = TRUE),
    .day = day(date),
    .year = year(date)
  )

melb_2016 <- read_rds("data-raw/melb_weather2016.rds") %>% 
  select(date, PRCP:TMIN) %>% 
  rowwise() %>% 
  mutate(TAVG = mean(c(TMAX, TMIN))) %>% 
  mutate(PRCP = if_else(is.na(PRCP), 0, PRCP)) %>% 
  ungroup() %>% 
  mutate(
    .month = month(date, label = TRUE),
    .day = day(date),
    .year = year(date)
  )

melb_temp2016 <- melb_2016 %>% 
  rename(
    lower16 = TMIN,
    upper16 = TMAX
  ) %>% 
  mutate(.month_day = ymd(paste(2016, .month, .day, sep = "-")))

melb_out <- melb_more %>% 
  group_by(.month, .day) %>% 
  summarise(
    lower = min(TMIN, na.rm = TRUE),
    upper = max(TMAX, na.rm = TRUE)
  ) %>% 
  mutate(.month_day = ymd(paste(2016, .month, .day, sep = "-")))

melb_temp <- melb_temp2016 %>% 
  left_join(melb_out, by = c(".month_day")) %>% 
  select(date, upper16, lower16, lower, upper)

melb_prcp <- melb_2016 %>% 
  filter(.year == 2016) %>% 
  rename(prcp = PRCP) %>% 
  group_by(.month) %>% 
  mutate(prcp = cumsum(prcp)) %>% 
  mutate(.month_day = ymd(paste(2016, .month, .day, sep = "-"))) %>% 
  ungroup() %>% 
  select(date, prcp)

devtools::use_data(melb_temp, overwrite = TRUE)
devtools::use_data(melb_prcp, overwrite = TRUE)
