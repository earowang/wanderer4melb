library(stringr)
library(lubridate)
library(tidyverse)

ghcn_stations <- read_table("data/ghcnd-stations.txt",
  col_names = c("ID", "lat", "lon", "elev", "blank", "station"))

au <- ghcn_stations[str_detect(ghcn_stations$ID, "^ASN"), ]
melb <- au[which(str_detect(au$station, "MELBOURNE")), ]$station

melb_stations <- ghcn_stations %>% 
  filter(station %in% melb)

yrs <- 1947:2016
melb_weather <- vector(mode = "list", length = length(yrs))
for (i in yrs) {
  URL <- paste0("https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/by_year/",
    i, ".csv.gz")
  temp <- read_csv(URL, col_names = c("ID", "date", "element", "value"))

  melb_weather[[i - yrs[1] + 1]] <- temp %>% 
    filter(ID %in% melb_stations$ID) %>% 
    mutate(
      value = value / 10,
      date = ymd(date)
    ) %>% 
    spread(element, value)
}

URL <- paste0("https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/by_year/",
  "2016", ".csv.gz")
temp <- read_csv(URL, col_names = c("ID", "date", "element", "value"))

melb_weather <- temp %>% 
  filter(ID %in% melb_stations$ID) %>% 
  mutate(
    value = value / 10,
    date = ymd(date)
  ) %>% 
  spread(element, value)
melb_weather <- bind_rows(melb_weather)
melb_weather <- melb_weather %>% 
  left_join(melb_stations, by = "ID")

melb_weather <- melb_weather %>% 
  select(ID:TMIN, TAVG, lat:station) %>% 
  filter(ID == "ASN00086282") # melbourne airport

write_rds(melb_weather, path = "data/melb_weather2016.rds")

