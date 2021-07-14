library(fallRunDSM)
library(tidyverse)

watershed_order <- DSMhabitat::watershed_metadata %>%
  select(watershed, order) %>%
  filter(order > 0)

# SacPas data
grandtab_raw <- read_csv("data-raw/Grandtab_Modified.csv")
unique(grandtab_raw$run)

# Explore Locations -----
unique(grandtab_raw$location)
# location "Butte Creek" for spring run uses carcus count when available then snorkel
butte <- c(
  "Butte Creek - Carcass" = "Butte Creek",
  "Butte Creek - Snorkel" = "Butte Creek",
  "Butte Creek" = "Butte Creek")

grandtab_raw %>%
  mutate(ll = butte[location]) %>%
  filter(!is.na(ll), startyear >= 1998) %>%
  select(startyear, location, count, run) %>%
  spread(startyear, count) %>%  View

# Battle Creek
# remove "Hatchery Transfers to Battle Creek - CNFH" = "Battle Creek" from battle creek sum
# remove " Battle Creek - CNFH "
battle <- c("Battle Creek" = "Battle Creek", "Battle Creek - CNFH" = "Battle Creek",
            "Battle Creek - Downstream of CNFH" = "Battle Creek",
            "Battle Creek - Upstream of CNFH" = "Battle Creek",
            "Hatchery Transfers to Battle Creek - CNFH" = "Battle Creek")

grandtab_raw %>%
  mutate(ll = battle[location]) %>%
  filter(!is.na(ll), startyear >= 1998) %>%
  select(startyear, location, count, run) %>%
  spread(startyear, count) %>%  View

grandtab_raw %>%
  filter(location == "Mokelumne River") %>% View

grandtab_raw %>%
  filter(location %in% names(battle), between(endyear, 2013, 2017)) %>%
  group_by(location, origin) %>%
  summarise(n())
  summarise(mean=mean(count, na.rm=T))

# sacramento
# remove "Passing RBDD", "Downstream of RBDD", "Passing RBDD", "Upstream of RBDD"
grandtab_raw %>%
  filter(location %in% c("Mainstem - Downstream of RBDD",
                         "Mainstem - Upstream of RBDD",
                         "Mainstem",
                         "Passing RBDD",
                         "Downstream of RBDD",
                         "Upstream of RBDD"),
         startyear >= 1998, run == "Late-Fall") %>%
  select(startyear, minorbasin, location, count, run) %>%
  spread(startyear, count)


grandtab_raw %>%
  filter(location %in% c("Mainstem - Downstream of RBDD",
                         "Mainstem - Upstream of RBDD",
                         "Mainstem",
                         "Passing RBDD",
                         "Downstream of RBDD",
                         "Upstream of RBDD"),
         between(endyear, 2013, 2017)) %>%
  group_by(location, origin) %>%
  summarise(n())

grandtab_raw %>%
  filter(origin == "Redd Distribution") %>% View

# cleaned up location names
watershed_lookups <- c(
  "Mainstem - Downstream of RBDD" = "Upper Sacramento River",
  "Mainstem - Upstream of RBDD" = "Upper Sacramento River",
  "Mainstem" = "Upper Sacramento River",
  "Antelope Creek" = "Antelope Creek",
  "Battle Creek" = "Battle Creek",
  "Battle Creek - Downstream of CNFH" = "Battle Creek",
  "Battle Creek - Upstream of CNFH" = "Battle Creek",
  "Bear Creek" = "Bear Creek",
  "Big Chico" = "Big Chico Creek",
  "Butte Creek" = "Butte Creek",
  "Clear Creek" = "Clear Creek",
  "Cottonwood Creek" = "Cottonwood Creek",
  "Cow Creek" = "Cow Creek",
  "Deer Creek" = "Deer Creek",
  "Mill Creek" = "Mill Creek",
  "Paynes Creek" = "Paynes Creek",
  "Thomes Creek" = "Thomes Creek",
  "Bear River" = "Bear River",
  "Feather River" = "Feather River",
  "Yuba River" = "Yuba River",
  "American River" = "American River",
  "Calaveras River" = "Calaveras River",
  "Cosumnes River" = "Cosumnes River",
  "Mokelumne River" = "Mokelumne River",
  "Merced River" = "Merced River",
  "Stanislaus River" = "Stanislaus River",
  "Tuolumne River" = "Tuolumne River"
)

# Filter grandtab data ----
grandtab <- grandtab_raw %>%
  mutate(location2 = watershed_lookups[location]) %>%
  filter(!is.na(location2), endyear >= 1998, origin == "In-River") %>%
  group_by(run, watershed = location2, year = endyear) %>%
  summarise(count = sum(count, na.rm = TRUE)) %>%
  ungroup()

# Imputed Grandtab ----
# Fall
fall_spawn <- DSMhabitat::fr_spawn[,10,1] != 0

grandtab_imputed_fall <- grandtab %>%
  filter(run == "Fall") %>%
  select(-run) %>%
  right_join(watershed_order) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  gather(year, count, -watershed, -order) %>%
  group_by(watershed, order) %>%
  mutate(
    mean = round(mean(count[count > 0], na.rm = TRUE)),
    count2 = case_when(
      !fall_spawn[watershed] ~ as.numeric(NA),
      fall_spawn[watershed] & is.nan(mean) ~ 40,
      fall_spawn[watershed] & count == 0 ~ mean,
      fall_spawn[watershed] & is.na(count) ~ mean,
      TRUE ~ count
    )
  ) %>%
  ungroup() %>%
  select(watershed, count = count2, year, order) %>%
  spread(year, count) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_imputed_fall) <- watershed_order$watershed

# Winter
winter_spawn <- DSMhabitat::wr_spawn[ ,10, 1] != 0
upsac_wr <- grandtab %>%
  filter(run == "Winter", watershed == "Upper Sacramento River") %>%
  select(-run)

bat_wr <- upsac_wr %>%
  mutate(watershed = "Battle Creek",
         count = round((600/mean(count))* count))

grandtab_imputed_winter <- bind_rows(upsac_wr, bat_wr) %>%
  right_join(watershed_order) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_imputed_winter) <- watershed_order$watershed

# Spring
# TODO what to do about tiny mean values?
spring_spawn <- DSMhabitat::sr_spawn[,10,1] != 0

grandtab_imputed_spring <- grandtab %>%
  filter(run == "Spring") %>%
  select(-run) %>%
  right_join(watershed_order) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  gather(year, count, -watershed, -order) %>%
  group_by(watershed, order) %>%
  mutate(
    mean = round(mean(count[count > 0], na.rm = TRUE)),
    count2 = case_when(
      !spring_spawn[watershed] ~ as.numeric(NA),
      spring_spawn[watershed] & is.nan(mean) ~ 40,
      spring_spawn[watershed] & count == 0 ~ mean,
      spring_spawn[watershed] & is.na(count) ~ mean,
      TRUE ~ count
    )
  ) %>%
  ungroup() %>%
  select(watershed, count = count2, year, order) %>%
  spread(year, count) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_imputed_spring) <- watershed_order$watershed

# Late-Fall
late_fall_spawn <- DSMhabitat::lfr_spawn[,10,1] != 0

grandtab_imputed_late_fall <- grandtab %>%
  filter(run == "Late-Fall") %>%
  select(-run) %>%
  right_join(watershed_order) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  gather(year, count, -watershed, -order) %>%
  group_by(watershed, order) %>%
  mutate(
    mean = round(mean(count[count > 0], na.rm = TRUE)),
    count2 = case_when(
      !late_fall_spawn[watershed] ~ as.numeric(NA),
      late_fall_spawn[watershed] & is.nan(mean) ~ 40,
      late_fall_spawn[watershed] & count == 0 ~ mean,
      late_fall_spawn[watershed] & is.na(count) ~ mean,
      TRUE ~ count
    )
  ) %>%
  ungroup() %>%
  select(watershed, count = count2, year, order) %>%
  spread(year, count) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_imputed_late_fall) <- watershed_order$watershed

grandtab_imputed <- list(fall = grandtab_imputed_fall,
                         late_fall = grandtab_imputed_late_fall,
                         winter = grandtab_imputed_winter,
                         spring = grandtab_imputed_spring)

usethis::use_data(grandtab_imputed, overwrite = TRUE)

# Grandtab Observed -----

# Fall
grandtab_observed_fall <- grandtab %>%
  filter(run == "Fall") %>%
  select(-run) %>%
  filter(count > 100) %>%
  right_join(watershed_order) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_observed_fall) <- watershed_order$watershed

# Winter
grandtab_observed_winter <- grandtab_imputed_winter
  # grandtab %>%
  # filter(run == "Winter") %>%
  # select(-run) %>%
  # filter(count > 100) %>%
  # right_join(watershed_order) %>%
  # spread(year, count) %>%
  # select(-`<NA>`) %>%
  # arrange(order) %>%
  # select(-watershed, -order) %>%
  # as.matrix()
# rownames(grandtab_observed_winter) <- watershed_order$watershed

# Spring
grandtab_observed_spring <- grandtab %>%
  filter(run == "Spring") %>%
  select(-run) %>%
  filter(count > 100) %>%
  right_join(watershed_order) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_observed_spring) <- watershed_order$watershed

# Late-Fall
grandtab_observed_late_fall <- grandtab %>%
  filter(run == "Late-Fall") %>%
  select(-run) %>%
  filter(count > 100) %>%
  right_join(watershed_order) %>%
  spread(year, count) %>%
  select(-`<NA>`) %>%
  arrange(order) %>%
  select(-watershed, -order) %>%
  as.matrix()

rownames(grandtab_observed_late_fall) <- watershed_order$watershed

grandtab_observed <- list(fall = grandtab_observed_fall,
                          late_fall = grandtab_observed_late_fall,
                          winter = grandtab_observed_winter,
                          spring = grandtab_observed_spring)
usethis::use_data(grandtab_observed, overwrite = TRUE)

# check species presence ---
should_be_missing <- DSMscenario::watershed_labels[
  !as.logical(DSMhabitat::watershed_species_present[1:31, ]$fr *
                DSMhabitat::watershed_species_present[1:31,]$spawn)]
missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_observed_fall, na.rm = T))]
all(should_be_missing %in% missing)
missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_imputed_fall, na.rm = T))]
all(should_be_missing %in% missing)

should_be_missing <- DSMscenario::watershed_labels[
  !as.logical(DSMhabitat::watershed_species_present[1:31, ]$lfr *
                DSMhabitat::watershed_species_present[1:31,]$spawn)]
missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_observed_late_fall, na.rm = T))]
all(should_be_missing %in% missing)
missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_imputed_late_fall, na.rm = T))]
all(should_be_missing %in% missing)

should_be_missing <- DSMscenario::watershed_labels[
  !as.logical(DSMhabitat::watershed_species_present[1:31, ]$sr *
                DSMhabitat::watershed_species_present[1:31,]$spawn)]
missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_observed_spring, na.rm = T))]
all(should_be_missing %in% missing)
missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_imputed_spring, na.rm = T))]
all(should_be_missing %in% missing)

should_be_missing <- DSMscenario::watershed_labels[
  !as.logical(DSMhabitat::watershed_species_present[1:31, ]$wr *
                DSMhabitat::watershed_species_present[1:31,]$spawn)]
missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_observed_winter, na.rm = T))]
all(should_be_missing %in% missing)
missing <- DSMscenario::watershed_labels[is.nan(rowMeans(grandtab_imputed_winter, na.rm = T))]
all(should_be_missing %in% missing)

# Adult Seeds -----
# Jim used "Battle Creek - Downstream of CNFH" for "Battle Creek"
mean_escapement_2013_2017 <- grandtab %>%
  filter(between(year, 2013, 2017)) %>%
  group_by(watershed, run) %>%
  summarise(mean = round(mean(count, na.rm = TRUE))) %>%
  spread(run, mean) %>%
  right_join(watershed_order) %>%
  arrange(order) %>%
  select(-order) %>%
  ungroup()

usethis::use_data(mean_escapement_2013_2017, overwrite = TRUE)
